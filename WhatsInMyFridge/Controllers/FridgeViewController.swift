//
//  ViewController.swift
//  WhatsInMyFridge
//
//  Created by Chinmay Ghotkar on 2/5/19.
//  Copyright © 2019 Chinmay Ghotkar. All rights reserved.
//

import UIKit
import CoreData

class FridgeViewController: UIViewController {

    @IBOutlet weak var fridgeTableView: UITableView!
    @IBOutlet weak var emptyMsgLabel: UILabel!
    
    var selectedList : List?
    
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var foodList : [Item] = []
    private var listOfList: [List] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        fridgeTableView.dataSource = self
        fridgeTableView.delegate = self
        
        // Used to register the custom .xib file
        fridgeTableView.register(UINib(nibName: "GroceryListsCellTableViewCell", bundle: nil), forCellReuseIdentifier: "fridgeCell")
        UserDefaults.standard.register(defaults: ["Fridge" : ListAction.none.rawValue,
                                                  "Grocery" : ListAction.none.rawValue])
        loadFridge()
        load()
        
        fridgeTableView.keyboardDismissMode = .onDrag // .interactive
//        fridgeTableView.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
    }
    
    @IBAction func addItemButton(_ sender: Any) {
        let alert = UIAlertController(title: "Add Food", message: "Add food to Fridge List", preferredStyle: .alert)
        
        
        // Add a text field to the alert for the new item's name
        
        alert.addTextField(configurationHandler: nil)
        alert.textFields?[0].placeholder = "Food item Name"
        // Add a text field to the alert for the new item's quantity

        alert.addTextField(configurationHandler: nil)
        alert.textFields?[1].placeholder = "How much of the item"
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

        food.setValue(name, forKeyPath: "name")
        food.setValue(quantity, forKeyPath: "quantity")
        food.parentList = selectedList
        foodList.append(food)

        save()
    }
    
    @objc func textFieldDidChange(_ textField: TableViewTextField) {
        print("textFieldChanged", textField.text!)
        print("index row", textField.indexRow)
        let food = foodList[textField.indexRow]
        
        if Int(textField.text!) == nil {
            food.setValue(textField.text!, forKeyPath: "name")
        } else {
            food.setValue(Int(textField.text!), forKeyPath: "quantity")
        }
        
        // 4
        save()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        load()
        
        fridgeTableView.reloadData()
    }
    
    func save() {
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        fridgeTableView.reloadData()
    }
    
    func load(with request : NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let parentListPredicate = NSPredicate(format: "parentList.name MATCHES %@", selectedList!.name!)
        request.sortDescriptors  = [NSSortDescriptor(key: "name", ascending: true )]
        
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
        
        fridgeTableView.reloadData()
        
    }
    
    func loadFridge(with request : NSFetchRequest<List> = List.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let parentListPredicate = NSPredicate(format: "name MATCHES %@", "Fridge");
        
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
        
        // Fridge list is not there, add new list to coredata
        print(listOfList.count)
        if listOfList.count == 0 {
            let fridge = List(context: managedContext)
            fridge.name = "Fridge"
            listOfList.append(fridge)
            selectedList = listOfList[0]
            save()
        } else {
            selectedList = listOfList[0]
            fridgeTableView.reloadData()
        }
        
    }
    
    func loadLists(with request : NSFetchRequest<List> = List.fetchRequest(), predicate: NSPredicate? = nil) {
        let parentListPredicate = NSPredicate(format: "NOT name MATCHES %@", selectedList!.name!)
        
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
    }
    
    
    func getOrginalListAlphabetical() {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        request.sortDescriptors  = [NSSortDescriptor(key: "name", ascending: true )]
        
        load(with: request)
    }
    
    func deleteItemFromList(indexPath: IndexPath) {
        managedContext.delete(foodList[indexPath.row])
        foodList.remove(at: indexPath.row)
        save()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        save()
        
        return true
    }
    
    func showEditDialog(for tableRow : Int) {
        let alert = UIAlertController(title: "Edit Item", message: "", preferredStyle: .alert)
        
        // Add a text field to the alert for the new item's name
        alert.addTextField(configurationHandler: nil)
        alert.textFields?[0].placeholder = foodList[tableRow].name
        // Add a text field to the alert for the new item's quantity
        alert.addTextField(configurationHandler: nil)
        alert.textFields?[1].placeholder = String(self.foodList[tableRow].quantity)
        
        // Add a "OK" button to the alert. The handler calls addNewToDoItem()
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            if let quantity = alert.textFields?[1].text
            {
                if let number = Int16(quantity) {
                    self.foodList[tableRow].quantity = number
                } else {
                    self.foodList[tableRow].quantity = 0
                }
            }
            
            if let name = alert.textFields?[0].text {
                self.foodList[tableRow].name = name
            }
            
            self.save()
        }))
        
        // Add a "cancel" button to the alert. This one doesn't need a handler
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showMoveListDialog(for tableRow : Int) {
        let alert = UIAlertController(title: "Lists", message: "", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        loadLists()
        
        for list in listOfList {
            
            let listAction = UIAlertAction(title: list.name, style: .default) { (_) in
                self.foodList[tableRow].parentList = list
                self.save()
                self.load()
            }
            
            alert.addAction(listAction)
            
        }
        
        print(listOfList.count)
        self.present(alert, animated: true)
    }
}


//MARK: - TableView Delegate Methods

extension FridgeViewController:  UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodList.count
    }
}

//MARK: TableView Data Source Methods

extension FridgeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = fridgeTableView.dequeueReusableCell(withIdentifier: "fridgeCell") as! GroceryListsCellTableViewCell
        let food = foodList[indexPath.row]
        
        cell.listName.text = "\(food.quantity) \(food.name ?? "")"
        
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
            self.showEditDialog(for: indexPath.row)
        }
        
        let moveAction = UIContextualAction(style: .destructive, title: "Move") { (action, view, handler) in
            print("Move Action Tapped")
            self.showMoveListDialog(for: indexPath.row)
        }
        
        deleteAction.backgroundColor = .red
        editAction.backgroundColor = .blue
        moveAction.backgroundColor = .gray
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction, moveAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showEditDialog(for: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)

    }
}

//MARK: - Search Bar Methods

extension FridgeViewController: UISearchBarDelegate {
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

