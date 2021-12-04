//
//  MVVMViewModel.swift
//  GitHubReference-MVVM
//
//  Created by Hiroaki-Hirabayashi on 2021/12/04.
//

import Foundation
import NSObject_Rx
import RxCocoa
import RxSwift

/// ViewModelの入力に関するprotocol
protocol MVVMViewModelInput {
    var searchWordObserver: AnyObserver<String> { get }
    var sortTypeObserver: AnyObserver<Bool> { get }
}

/// ViewModelの出力に関するprotocol
protocol MVVMViewModelOutput {
    var changeModelsObservable: Observable<Void> { get }
    var models: [GitHubModel] { get }
}

/// ViewModelはInputとOutputのprotocolに準拠する
final class MVVMViewModel: MVVMViewModelInput, MVVMViewModelOutput, HasDisposeBag {

    // inputについての記述
    // 入力側の定型文的な書き方
    private let _searchWord = PublishRelay<String>()
    lazy var searchWordObserver: AnyObserver<String> = .init(eventHandler: { event in
        guard let e = event.element else { return }
        self._searchWord.accept(e)
    })

    // 入力側の定型文的な書き方
    private let _sortType = PublishRelay<Bool>()
    lazy var sortTypeObserver: AnyObserver<Bool> = .init(eventHandler: { event in
        guard let e = event.element else { return }
        self._sortType.accept(e)
    })

    // outputについての記述
    // 出力側の定型文的な書き方
    private let _changeModelsObservable = PublishRelay<Void>()
    lazy var changeModelsObservable = _changeModelsObservable.asObservable()
    // 最後に取得したデータ
    private(set) var models: [GitHubModel] = []

    // 初期化時にストリームを決める
    init() {
        // 入力を合成してストリームに値がきたらAPIを叩いて
        // 出力に値を保存して、出力にストリームを流す
        Observable.combineLatest(
            _searchWord,
            _sortType
        ).flatMapLatest({ searchWord, sortType -> Observable<[GitHubModel]> in
            GitHubAPI.shared.rx.get(searchWord: searchWord, isDesc: sortType)
        }).map { [weak self] models -> Void in
            // 最後に得たデータを保存
            self?.models = models
            // 値が更新したことを告げるためだけのストリームを流すのでVoidにする
            return
        }.bind(to: _changeModelsObservable).disposed(by: disposeBag)
    }
}
