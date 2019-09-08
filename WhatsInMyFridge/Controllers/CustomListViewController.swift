//
//  CustomListViewController.swift
//  WhatsInMyFridge
//
//  Created by Chinmay Ghotkar on 4/16/19.
//  Copyright © 2019 Chinmay Ghotkar. All rights reserved.
//

import UIKit
import CoreData

class CustomListViewController: UIViewController {

    @IBOutlet weak var customListTableView: UITableView!
    @IBOutlet weak var customListTitle: UINavigationItem!
    
    var itemManager : ItemCoreDataManager!
    
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var selectedList : List? {
        didSet {
            // because we perform this operation on the main thread, it is safe
            OperationQueue.main.addOperation { // this will not crash
                self.itemManager.load()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customListTableView.register(UINib(nibName: "GroceryListsCellTableViewCell", bundle: nil), forCellReuseIdentifier: "customListCell")
        
        itemManager = ItemCoreDataManager(tableView: customListTableView)
        if let list = selectedList {
            self.customListTitle.title = list.name!
            itemManager.selectedList = list
        } else {
            print("Selected List is null\n")
        }
        
        customListTableView.keyboardDismissMode = .onDrag // .interactive
        customListTableView.reloadData()
    }
    
    @IBAction func addItem(_ sender: Any) {
        itemManager.addItemAction(controller: self)
    }
    
    @IBAction func editItem(_ sender: UIBarButtonItem) {
        customListTableView.isEditing = !customListTableView.isEditing
        customListTableView.reloadData()
        sender.title = self.customListTableView.isEditing ? "Done" : "Edit"
    }
}

//MARK: - TableView Delegate Methods

extension CustomListViewController:  UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemManager.itemList.count + 1
    }
}

//MARK: TableView Data Source Methods

extension CustomListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = customListTableView.dequeueReusableCell(withIdentifier: "customListCell") as! GroceryListsCellTableViewCell

        print(itemManager.itemList.count, indexPath.row)
        if indexPath.row < itemManager.itemList.count {
            let item = itemManager.itemList[indexPath.row]
            cell.listName.text = itemManager.getRowOutputString(item: item)
        } else {
            if customListTableView.isEditing {
                cell.listName.isUserInteractionEnabled = true
            } else {
                cell.listName.isUserInteractionEnabled = false
            }
            cell.listName.text = ""
            cell.selectionStyle = .none
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < itemManager.itemList.count {
            itemManager.showEditDialog(controller: self, for: indexPath.row)
        }
        tableView.deselectRow(at: indexPath, animated: true)
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .insert {
            print("inserting")
            let cell = customListTableView.cellForRow(at: indexPath) as! GroceryListsCellTableViewCell
            itemManager.addNewItem(with: cell.listName.text ?? "", quantity: "-1", displayOrder: itemManager.itemList.count)
            customListTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row < itemManager.itemList.count {
            return .delete
        } else {
            return .insert
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let tempItem = itemManager.itemList[sourceIndexPath.row]
        itemManager.itemList.remove(at: sourceIndexPath.row)
        itemManager.itemList.insert(tempItem, at: destinationIndexPath.row)
        
        itemManager.updateDisplayOrder()
        itemManager.save()
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

extension CustomListViewController: UISearchBarDelegate {
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
