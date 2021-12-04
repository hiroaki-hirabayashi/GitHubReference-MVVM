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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
