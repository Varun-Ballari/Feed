//
//  TableViewCell.swift
//  Feed-iOS
//
//  Created by Varun Ballari on 1/28/18.
//  Copyright © 2018 Akhila Ballari. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet var organization: UILabel!
    @IBOutlet var fed: UILabel!
    @IBOutlet var wheat: UIImageView!
    @IBOutlet var date: UILabel!
    @IBOutlet var food: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
