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
        fridgeTableView.register(UINib(nibName: "ItemTVCell", bundle: nil), forCellReuseIdentifier: "fridgeCell")
        UserDefaults.standard.register(defaults: ["Fridge" : ListAction.none.rawValue,
                                                  "Grocery" : ListAction.none.rawValue])
        selectedList = List(context: managedContext)
        selectedList?.name = "Fridge"
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
        food.setValue("Fridge", forKeyPath: "currentList")
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
    
    func getOrginalListAlphabetical() {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        request.sortDescriptors  = [NSSortDescriptor(key: "name", ascending: true )]
        
        load(with: request)
    }
    
    func moveItemToOtherList(indexPath: IndexPath) {
        let entity = NSEntityDescription.entity(forEntityName: "Item", in: self.managedContext)!
        let food_fridge = self.foodList[indexPath.row]
        let food_grocery = NSManagedObject(entity: entity, insertInto: self.managedContext)
        food_grocery.setValue(food_fridge.value(forKeyPath: "name"), forKeyPath: "name")
        food_grocery.setValue(food_fridge.value(forKeyPath: "quantity"), forKeyPath: "quantity")
        
        managedContext.delete(self.foodList[indexPath.row])
        foodList.remove(at: indexPath.row)
        save()
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
        
        let cell = fridgeTableView.dequeueReusableCell(withIdentifier: "fridgeCell") as! ItemTVCell
        let food = foodList[indexPath.row]
        
        cell.itemName.adjustsFontSizeToFitWidth = true
        cell.itemName.text = food.value(forKeyPath: "name") as? String
        cell.itemName.indexRow = indexPath.row
        //cell.itemName.addTarget(self, action: #selector(textFieldDidChange), for: .editingDidEnd)
        
        
        cell.itemQuantity.adjustsFontSizeToFitWidth = true
        // cell.itemQuantity.addTarget(self, action: #selector(textFieldDidChange), for: .editingDidEnd)
        cell.itemQuantity.text = "\(food.value(forKeyPath: "quantity") as? Int ?? 0)"
        cell.itemQuantity.indexRow = indexPath.row
        
        cell.cellLabel.text = "# in Fridge"
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
        }
        
        deleteAction.backgroundColor = .red
        editAction.backgroundColor = .blue
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return configuration
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

