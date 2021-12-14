//
//  NoMVVM.swift
//  GitHubReference-MVVM
//
//  Created by Hiroaki-Hirabayashi on 2021/12/12.
//

import NSObject_Rx
import RxOptional
import RxSwift
import UIKit

final class RxNoMVVMViewController: UIViewController, HasDisposeBag {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    
    private var responseData: [GitHubModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 文字列のストリーム (1)
        let searchWordObservable = textField.rx.text
            .debounce(RxTimeInterval.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged().filterNil()
        
        // ソートのストリーム (2)
        // 初回読み込み時または変化があれば、segmentedControlのindexをストリームに流す
        let sortTypeObservable = Observable.merge(
            Observable.just(segmentedControl.selectedSegmentIndex),
            segmentedControl.rx.controlEvent(.valueChanged).map { self.segmentedControl.selectedSegmentIndex }
        ).map { $0 == 0 }
        
        // (1), (2)を合成してストリームに値がきたらAPIを叩いてテーブルをリロード
        let getAPIObservable = Observable.combineLatest(searchWordObservable, sortTypeObservable)
            .flatMapLatest { searchWord, sortType -> Observable<[GitHubModel]> in
                GitHubAPI.shared.rx.get(searchWord: searchWord, isDesc: sortType)
            }
        
        //購買する
        getAPIObservable.subscribeOn(MainScheduler.instance).subscribe(onNext: { [weak self] models in
            self?.responseData = models
            self?.tableView.reloadData()
        }, onError: { error in
            print(error.localizedDescription)
        }).disposed(by: disposeBag)
        
        // この書き方だとUITableViewDataSourceがいらなくなるが警告が出る
        //        getAPIObservable.subscribeOn(MainScheduler.instance)
        //            .bind(to: self.tableView.rx.items(cellIdentifier: TableViewCell.reuseIdentifier, cellType: TableViewCell.self)) { _, element, cell in
        //                guard let cell = cell as? TableViewCell else { return }
        //                cell.configure(gitHubModel: element)
        //            }.disposed(by: disposeBag)
    }
}

// UITableViewDataSourceをoutletで繋げる
extension RxNoMVVMViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return responseData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let gitHubModel = responseData[safe: indexPath.item],
              let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.reuseIdentifier, for: indexPath) as? TableViewCell
        else { return UITableViewCell() }
        cell.configure(gitHubModel: gitHubModel)
        return cell
    }
    
}
