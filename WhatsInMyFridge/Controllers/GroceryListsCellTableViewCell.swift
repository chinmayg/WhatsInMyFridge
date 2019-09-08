//
//  GroceryListsCellTableViewCell.swift
//  WhatsInMyFridge
//
//  Created by Chinmay Ghotkar on 4/15/19.
//  Copyright © 2019 Chinmay Ghotkar. All rights reserved.
//

import UIKit

class GroceryListsCellTableViewCell: UITableViewCell {

    @IBOutlet weak var listName: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        listName.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
