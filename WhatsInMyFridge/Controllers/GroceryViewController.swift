//
//  GroceryViewController.swift
//  WhatsInMyFridge
//
//  This view controller is used to display all of the created grocery lists
//
//  Created by Chinmay Ghotkar on 2/5/19.
//  Copyright © 2019 Chinmay Ghotkar. All rights reserved.
//

import UIKit
import CoreData


class GroceryViewController: UIViewController {

    @IBOutlet weak var groceryTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var listOfList: [List] = []
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        groceryTableView.dataSource = self
        groceryTableView.delegate = self
        
        groceryTableView.register(UINib(nibName: "GroceryListsCellTableViewCell", bundle: nil), forCellReuseIdentifier: "groceryListCell")
        groceryTableView.keyboardDismissMode = .onDrag // .interactive

        load()

    }
    
    @IBAction func addItemButton(_ sender: Any) {
        let alert = UIAlertController(title: "Add New List", message: "", preferredStyle: .alert)
        
        // Add a text field to the alert for the new item's name
        alert.addTextField(configurationHandler: nil)
        alert.textFields?[0].placeholder = "New List Name"
        
        // Add a "OK" button to the alert. The handler calls addNewToDoItem()
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            if let listName = alert.textFields?[0].text {
                if listName.count == 0 {
                    self.addNewList(with: "New List")
                } else {
                    self.addNewList(with: listName)
                }
            } else {
                self.addNewList(with: "New List")
            }
        }))

        // Add a "cancel" button to the alert. This one doesn't need a handler
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        // Present the alert to the user
        self.present(alert, animated: true, completion: nil)
    }
    
    private func addNewList(with name: String)
    {
        let newList = List(context: managedContext)
        
        newList.name = name
        
        listOfList.append(newList)
        
        save()
    }
    
    func save() {
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }

        groceryTableView.reloadData()
    }
    
    func load(with request : NSFetchRequest<List> = List.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let parentListPredicate = NSPredicate(format: "NOT name MATCHES %@", "Fridge");
        
        request.sortDescriptors  = [NSSortDescriptor(key: "name", ascending: true )]
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [parentListPredicate, additionalPredicate])
        } else {
            request.predicate = parentListPredicate
        }
        do {
            listOfList = try managedContext.fetch(request)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        groceryTableView.reloadData()

    }
    
    func getOrginalListAlphabetical() {
        let request : NSFetchRequest<List> = List.fetchRequest()
        request.sortDescriptors  = [NSSortDescriptor(key: "name", ascending: true )]
        
        load(with: request)
    }

    func deleteItemFromList(indexPath: IndexPath) {
        managedContext.delete(listOfList[indexPath.row])
        listOfList.remove(at: indexPath.row)
        save()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()

        return true
    }
    
    func showEditDialog(for tableRow : Int) {
        let alert = UIAlertController(title: "Edit List Name", message: "", preferredStyle: .alert)
        
        // Add a text field to the alert for the new item's name
        alert.addTextField(configurationHandler: nil)
        alert.textFields?[0].placeholder = listOfList[tableRow].name
        
        // Add a "OK" button to the alert. The handler calls addNewToDoItem()
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            if let name = alert.textFields?[0].text {
                self.listOfList[tableRow].name = name
            }
            
            self.save()
        }))
        
        // Add a "cancel" button to the alert. This one doesn't need a handler
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK: - TableView Delegate Methods

extension GroceryViewController:  UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfList.count
    }
}

//MARK: TableView Data Source Methods

extension GroceryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = groceryTableView.dequeueReusableCell(withIdentifier: "groceryListCell") as! GroceryListsCellTableViewCell
        let list = listOfList[indexPath.row]
        
        cell.listName.text = list.name

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(listOfList[indexPath.row].name!)
        performSegue(withIdentifier: "customListSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! CustomListViewController
        print(listOfList.count)
        if let indexPath = groceryTableView.indexPathForSelectedRow {
            print("Prepare print", listOfList[indexPath.row].name!)
            destinationVC.selectedList = listOfList[indexPath.row]
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
            print("Delete Action Tapped")
            self.deleteItemFromList(indexPath: indexPath)
        }
        
        let editAction = UIContextualAction(style: .destructive, title: "Edit") { (action, view, handler) in
            print("Edit Action Tapped")
            self.showEditDialog(for: indexPath.row)
        }
        
        deleteAction.backgroundColor = .red
        editAction.backgroundColor = .blue
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return configuration
    }
}

//MARK: - Search Bar Methods

extension GroceryViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        load(predicate: NSPredicate(format: "name CONTAINS[cd] %@ ", searchBar.text!))
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            getOrginalListAlphabetical()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
