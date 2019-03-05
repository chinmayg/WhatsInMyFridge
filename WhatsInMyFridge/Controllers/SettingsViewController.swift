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
        
        return cell
        
    }
}
