//
//  TableViewCell.swift
//  GitHubReference-MVVM
//
//  Created by Hiroaki-Hirabayashi on 2021/12/05.
//

import UIKit

final class TableViewCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var urlLabel: UILabel!
    
    static let reuseIdentifier = "TableViewCell"
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        urlLabel.text = nil
    }
    
    static func loadNib() -> UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }

    func configure(gitHubModel: GitHubModel) {
        titleLabel.text = gitHubModel.name
        urlLabel.text = gitHubModel.urlString
    }
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//    }
    
}
