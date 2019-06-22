//
//  KitchenViewController.swift
//  WhatsInMyFridge
//
//  Created by Chinmay Ghotkar on 2/5/19.
//  Copyright © 2019 Chinmay Ghotkar. All rights reserved.
//

import UIKit

class KitchenViewController: UIViewController {

    @IBOutlet weak var kitchenTableView: UITableView!
    @IBOutlet weak var emptyMsgLabel: UILabel!
    
    var itemManager : ItemCoreDataManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        kitchenTableView.dataSource = self
        kitchenTableView.delegate = self
        
        // Used to register the custom .xib file
        kitchenTableView.register(UINib(nibName: "GroceryListsCellTableViewCell", bundle: nil), forCellReuseIdentifier: "fridgeCell")
        
        itemManager = ItemCoreDataManager(tableView: kitchenTableView)
        itemManager.loadFridge()
        itemManager.load()
        
        kitchenTableView.reloadData()

        kitchenTableView.keyboardDismissMode = .onDrag // .interactive
    }
    
    @IBAction func addItemButton(_ sender: Any) {
        itemManager.addItemAction(controller: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        itemManager.load()
        
        kitchenTableView.reloadData()
    }
    

    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        itemManager.save()
        
        return true
    }
}

//MARK: - TableView Delegate Methods

extension KitchenViewController:  UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemManager.itemList.count
    }
}

//MARK: TableView Data Source Methods

extension KitchenViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = kitchenTableView.dequeueReusableCell(withIdentifier: "fridgeCell") as! GroceryListsCellTableViewCell
        let item = itemManager.itemList[indexPath.row]
        
        cell.listName.text = itemManager.getRowOutputString(item: item)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
            print("Delete Action Tapped")
            self.itemManager.deleteItemFromList(for: indexPath.row)
        }
        
        let editAction = UIContextualAction(style: .destructive, title: "Edit") { (action, view, handler) in
            print("Edit Action Tapped")
            self.itemManager.showEditDialog(controller: self, for: indexPath.row)
        }
        
        let moveAction = UIContextualAction(style: .destructive, title: "Move") { (action, view, handler) in
            print("Move Action Tapped")
            self.itemManager.showMoveListDialog(controller : self, for: indexPath.row)
        }
        
        deleteAction.backgroundColor = .red
        editAction.backgroundColor = .blue
        moveAction.backgroundColor = .gray
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction, moveAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemManager.showEditDialog(controller: self, for: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - Search Bar Methods

extension KitchenViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        itemManager.load(predicate: NSPredicate(format: "name CONTAINS[cd] %@ ", searchBar.text!))
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            itemManager.getOrginalListAlphabetical()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

