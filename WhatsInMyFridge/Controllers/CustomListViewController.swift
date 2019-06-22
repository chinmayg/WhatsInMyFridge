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
        
        customListTableView.delegate = self
        customListTableView.dataSource = self

        customListTableView.register(UINib(nibName: "GroceryListsCellTableViewCell", bundle: nil), forCellReuseIdentifier: "customListCell")
        
        itemManager = ItemCoreDataManager(tableView: customListTableView)
        if let list = selectedList {
            self.customListTitle.title = list.name!
            itemManager.selectedList = list
        } else {
            print("Selected List is null\n")
        }
        
        customListTableView.reloadData()
    }
    
    @IBAction func addItem(_ sender: Any) {
        itemManager.addItemAction(controller: self)
    }
    
    func getOriginalListAlphabetical() {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        request.sortDescriptors  = [NSSortDescriptor(key: "name", ascending: true )]
        
        itemManager.load(with: request)
    }
}
//MARK: - TableView Delegate Methods

extension CustomListViewController:  UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemManager.itemList.count
    }
}

//MARK: TableView Data Source Methods

extension CustomListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = customListTableView.dequeueReusableCell(withIdentifier: "customListCell") as! GroceryListsCellTableViewCell
        let item = itemManager.itemList[indexPath.row]
        
        cell.listName.text = itemManager.getRowOutputString(item: item)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemManager.showEditDialog(controller: self, for: indexPath.row)
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
}

//MARK: - Search Bar Methods

extension CustomListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        itemManager.load(predicate: NSPredicate(format: "name CONTAINS[cd] %@ ", searchBar.text!))
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            getOriginalListAlphabetical()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
