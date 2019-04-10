//
//  TableViewTextField.swift
//  WhatsInMyFridge
//
//  Created by Chinmay Ghotkar on 4/9/19.
//  Copyright © 2019 Chinmay Ghotkar. All rights reserved.
//

import UIKit

class TableViewTextField: UITextField {
    required init(coder aDecoder: NSCoder) {
        self.indexSection = 0
        self.indexRow = 0
        
        super.init(coder: aDecoder)!
    }
    
    var indexRow : Int
    var indexSection : Int

}
