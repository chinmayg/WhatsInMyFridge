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

    private var foodList : [Item] = []
    @IBOutlet weak var customListTableView: UITableView!
    @IBOutlet weak var customListTitle: UINavigationItem!
    
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var selectedList : List? {
        didSet {
            // because we perform this operation on the main thread, it is safe
            OperationQueue.main.addOperation { // this will not crash
                self.load()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customListTitle.title = selectedList!.name!
        customListTableView.delegate = self
        customListTableView.dataSource = self

        customListTableView.register(UINib(nibName: "ItemTVCell", bundle: nil), forCellReuseIdentifier: "customListCell")
    }
    
    @IBAction func addItem(_ sender: Any) {
        let alert = UIAlertController(title: "Add Food", message: "", preferredStyle: .alert)
        
        // Add a text field to the alert for the new item's name
        alert.addTextField(configurationHandler: nil)
        alert.textFields?[0].placeholder = "Food item Name"
        // Add a text field to the alert for the new item's quantity
        alert.addTextField(configurationHandler: nil)
        alert.textFields?[1].placeholder = "How many?"
        // Add a "cancel" button to the alert. This one doesn't need a handler
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Add a "OK" button to the alert. The handler calls addNewToDoItem()
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            if let name = alert.textFields?[0].text,let quantity = alert.textFields?[1].text
            {
                if let number = Int(quantity) {
                    self.addNewFoodItem(name: name, quantity: number)
                } else {
                    self.addNewFoodItem(name: name, quantity: 0)
                }
            }
        }))
        
        // Present the alert to the user
        self.present(alert, animated: true, completion: nil)
    }
    
    private func addNewFoodItem(name: String, quantity: Int)
    {
        // Create new item and add it to the todo items list
        //data.append(Item(name: name, quanity: quantity, dateAdded: "02/28/2019"))
        let food = Item(context: managedContext)
        
        // 3
        food.setValue(name, forKeyPath: "name")
        food.setValue(quantity, forKeyPath: "quantity")
        food.setValue("Fridge", forKeyPath: "currentList")
        food.parentList = selectedList
        foodList.append(food)
        
        // 4
        save()
    }
    
    func getOriginalListAlphabetical() {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        request.sortDescriptors  = [NSSortDescriptor(key: "name", ascending: true )]
        
        load(with: request)
    }
    
    func deleteItemFromList(indexPath: IndexPath) {
        managedContext.delete(foodList[indexPath.row])
        foodList.remove(at: indexPath.row)
        save()
    }

    func save() {
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }

        customListTableView.reloadData()
    }

    func load(with request : NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let parentListPredicate = NSPredicate(format: "parentList.name MATCHES %@", selectedList!.name!)

        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [parentListPredicate, additionalPredicate])
        } else {
            request.predicate = parentListPredicate
        }
        do {
            foodList = try managedContext.fetch(request)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        customListTableView.reloadData()

    }
}
//MARK: - TableView Delegate Methods

extension CustomListViewController:  UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodList.count
    }
}

//MARK: TableView Data Source Methods

extension CustomListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = customListTableView.dequeueReusableCell(withIdentifier: "customListCell") as! ItemTVCell
        let food = foodList[indexPath.row]

        cell.itemName.adjustsFontSizeToFitWidth = true
        cell.itemName.text = food.value(forKeyPath: "name") as? String
        cell.itemName.indexRow = indexPath.row
        //cell.itemName.addTarget(self, action: #selector(textFieldDidChange), for: .editingDidEnd)


        cell.itemQuantity.adjustsFontSizeToFitWidth = true
        // cell.itemQuantity.addTarget(self, action: #selector(textFieldDidChange), for: .editingDidEnd)
        cell.itemQuantity.text = "\(food.value(forKeyPath: "quantity") as? Int ?? 0)"
        cell.itemQuantity.indexRow = indexPath.row

        cell.cellLabel.text = "# Needed"
        return cell
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
            print("Delete Action Tapped")
            self.deleteItemFromList(indexPath: indexPath)
        }

        let editAction = UIContextualAction(style: .destructive, title: "Edit") { (action, view, handler) in
            print("Edit Action Tapped")
//            self.performSegue(withIdentifier: "customListSegue", sender: self)
        }

        deleteAction.backgroundColor = .red
        editAction.backgroundColor = .blue
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return configuration
    }
}

//MARK: - Search Bar Methods

extension CustomListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        load(predicate: NSPredicate(format: "name CONTAINS[cd] %@ ", searchBar.text!))
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
