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
    var itemManager : ItemCoreDataManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Used to register the custom .xib file
        kitchenTableView.register(UINib(nibName: "GroceryListsCellTableViewCell", bundle: nil), forCellReuseIdentifier: "fridgeCell")
        
        itemManager = ItemCoreDataManager(tableView: kitchenTableView)
        itemManager.loadFridge()
        itemManager.load()
        
        kitchenTableView.reloadData()

        kitchenTableView.keyboardDismissMode = .onDrag // .interactive
    }
    
    @IBAction func addItemButton(_ sender: UIBarButtonItem) {
        itemManager.addItemAction(controller: self)
    }
    
    @IBAction func editItemButton(_ sender: UIBarButtonItem) {
        kitchenTableView.isEditing = !kitchenTableView.isEditing
        kitchenTableView.reloadData()
        sender.title = self.kitchenTableView.isEditing ? "Done" : "Edit"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        itemManager.load()
        
        kitchenTableView.reloadData()
    }
}

//MARK: - TableView Delegate Methods

extension KitchenViewController:  UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemManager.itemList.count + 1
    }
}

//MARK: TableView Data Source Methods

extension KitchenViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = kitchenTableView.dequeueReusableCell(withIdentifier: "fridgeCell") as! GroceryListsCellTableViewCell

        if indexPath.row != itemManager.itemList.count {
            let item = itemManager.itemList[indexPath.row]
            cell.listName.text = itemManager.getRowOutputString(item: item)
        } else {
            if kitchenTableView.isEditing {
                cell.listName.isUserInteractionEnabled = true
            } else {
                cell.listName.isUserInteractionEnabled = false
            }
            cell.listName.text = ""
            cell.selectionStyle = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        if indexPath.row >= itemManager.itemList.count {
            return UISwipeActionsConfiguration(actions: [])
        }
        
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
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row < itemManager.itemList.count {
            return .delete
        } else {
            return .insert
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .insert {
            print("inserting")
            let cell = kitchenTableView.cellForRow(at: indexPath) as! GroceryListsCellTableViewCell
            itemManager.addNewItem(with: cell.listName.text ?? "", quantity: "-1", displayOrder: itemManager.itemList.count)
            kitchenTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let tempItem = itemManager.itemList[sourceIndexPath.row]
        itemManager.itemList.remove(at: sourceIndexPath.row)
        itemManager.itemList.insert(tempItem, at: destinationIndexPath.row)
        
        itemManager.updateDisplayOrder()
        itemManager.save()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < itemManager.itemList.count {
            itemManager.showEditDialog(controller: self, for: indexPath.row)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row < itemManager.itemList.count {
            return true
        } else {
            return false
        }
    }
}

//MARK: - Search Bar Methods

extension KitchenViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text?.count == 0 {
            self.itemManager.load()
        } else {
            itemManager.load(predicate: NSPredicate(format: "name CONTAINS[cd] %@ ", searchBar.text!))
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            DispatchQueue.main.async {
                self.itemManager.load()
                searchBar.resignFirstResponder()
            }
        }
    }
}

