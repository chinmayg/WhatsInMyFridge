//
//  ItemTVCell.swift
//  WhatsInMyFridge
//
//  Created by Chinmay Ghotkar on 2/27/19.
//  Copyright © 2019 Chinmay Ghotkar. All rights reserved.
//

import UIKit

class ItemTVCell: UITableViewCell {

    @IBOutlet weak var itemName: TableViewTextField!
    @IBOutlet weak var itemQuantity: TableViewTextField!
    @IBOutlet weak var cellLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
