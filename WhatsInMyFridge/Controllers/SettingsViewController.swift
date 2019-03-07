//
//  SettingsViewController.swift
//  WhatsInMyFridge
//
//  Created by Chinmay Ghotkar on 2/5/19.
//  Copyright © 2019 Chinmay Ghotkar. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    var settingsItems = [["Move to other list", "Delete from current list"],["Move to other list", "Delete from current list"]]
    var settingsTitles = ["Default Fridge List Actions","Default Grocery List Actions"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsTableView.dataSource = self
        settingsTableView.delegate = self
        
        UserDefaults.standard.register(defaults: ["Fridge" : ListAction.none.rawValue,
                                                  "Grocery" : ListAction.none.rawValue])
        
//        UserDefaults.standard.set(ListAction.none.rawValue,forKey: "Fridge")
//        UserDefaults.standard.set(ListAction.none.rawValue,forKey: "Grocery")
        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingsTitles[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsItems[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = settingsTableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) as UITableViewCell
        
        cell.textLabel?.text = settingsItems[indexPath.section][indexPath.row]
        var selectedAction = ListAction.none.rawValue
        
        if indexPath.section == 0 {
            selectedAction = UserDefaults.standard.integer(forKey: "Fridge")
        } else {
            selectedAction = UserDefaults.standard.integer(forKey: "Grocery")
        }
        
        switch(indexPath.row) {
        case ListAction.move.rawValue:
            if selectedAction == ListAction.move.rawValue {
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            } else {
                cell.accessoryType = UITableViewCell.AccessoryType.none
            }
            break
        case ListAction.delete.rawValue:
            if selectedAction == ListAction.delete.rawValue {
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            } else {
                cell.accessoryType = UITableViewCell.AccessoryType.none
            }
            break
        default:
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedSection = indexPath.section
        let selectedRow = indexPath.row
        var action = ListAction.none
        var currentSelectedAction = ListAction.none.rawValue
        
        if selectedSection == 0 {
            currentSelectedAction = UserDefaults.standard.integer(forKey: "Fridge")
        } else {
            currentSelectedAction = UserDefaults.standard.integer(forKey: "Grocery")
        }
        
        UserDefaults.standard.integer(forKey: "Fridge")
        if selectedRow == 0 {
            print("Selected Move action")
            if currentSelectedAction == ListAction.move.rawValue {
                action = ListAction.none
            } else {
                action = ListAction.move
            }
        } else{
            print("Selected Delete action")
            if currentSelectedAction == ListAction.delete.rawValue {
                action = ListAction.none
            } else {
                action = ListAction.delete
            }

        }
        
        if selectedSection == 0 {
            UserDefaults.standard.set(action.rawValue, forKey: "Fridge")
        } else {
            UserDefaults.standard.set(action.rawValue, forKey: "Grocery")
        }
        
        settingsTableView.reloadData()
    }
}
