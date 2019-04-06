//
//  GroceryViewController.swift
//  WhatsInMyFridge
//
//  Created by Chinmay Ghotkar on 2/5/19.
//  Copyright © 2019 Chinmay Ghotkar. All rights reserved.
//

import UIKit
import CoreData


class GroceryViewController: UIViewController {

    @IBOutlet weak var groceryTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var foodList: [NSManagedObject] = []
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        groceryTableView.dataSource = self
        groceryTableView.delegate = self
        
        groceryTableView.register(UINib(nibName: "ItemTVCell", bundle: nil), forCellReuseIdentifier: "groceryCell")
        
        getOrginalListAlphabetical()
    }
    
    @IBAction func addItemButton(_ sender: Any) {
        let alert = UIAlertController(title: "Add Food", message: "Add food to Grocery List", preferredStyle: .alert)
        
        // Add a text field to the alert for the new item's name
        alert.addTextField(configurationHandler: nil)
        
        // Add a text field to the alert for the new item's quantity
        alert.addTextField(configurationHandler: nil)
        
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
        let entity = NSEntityDescription.entity(forEntityName: "Item", in: managedContext)!
        
        let food = NSManagedObject(entity: entity, insertInto: managedContext)

        food.setValue(name, forKeyPath: "name")
        food.setValue(quantity, forKeyPath: "quantity")
        food.setValue("Grocery", forKey: "currentList")
        foodList.append(food)
        
        hideTableView()
        
        save()
    }

    override func viewWillAppear(_ animated: Bool) {
        getOrginalListAlphabetical()
    }
    
    func hideTableView() {
        if foodList.isEmpty {
            self.groceryTableView.isHidden = true
        }
        else {
            self.groceryTableView.isHidden = false
        }
    }
    
    func save() {
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        hideTableView()
        
        groceryTableView.reloadData()
    }
    
    func load(with request : NSFetchRequest<Item> = Item.fetchRequest()) {
        hideTableView()
        
        do {
            foodList = try managedContext.fetch(request)
            
            // Remove fridge items from list
            
            for (index,food) in foodList.enumerated() {
                if (food.value(forKey: "currentList") as? String ?? "") == "Fridge" {
                    foodList.remove(at: index)
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        hideTableView()
        
        groceryTableView.reloadData()

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
}

//MARK: - TableView Delegate Methods

extension GroceryViewController:  UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodList.count
    }
}

//MARK: TableView Data Source Methods

extension GroceryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = groceryTableView.dequeueReusableCell(withIdentifier: "groceryCell") as! ItemTVCell
        let food = foodList[indexPath.row]
        
        cell.itemName.text = food.value(forKeyPath: "name") as? String
        cell.itemQuantity.text = "\(food.value(forKeyPath: "quantity") as? Int ?? 0)"
        cell.cellLabel.text = "# needed"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedAction = UserDefaults.standard.integer(forKey: "Grocery")
        
        if selectedAction == ListAction.move.rawValue {
            moveItemToOtherList(indexPath: indexPath)
        } else if selectedAction == ListAction.delete.rawValue {
            deleteItemFromList(indexPath: indexPath)
        } else {
            let alertController = UIAlertController(title: "", message: "Do you want to move this item to Fridge List or remove it?", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Move to Fridge List", style: .destructive, handler: { (_) in
                self.moveItemToOtherList(indexPath: indexPath)
            }))
            
            alertController.addAction(UIAlertAction(title: "Remove from List", style: .destructive, handler: { (_) in
                self.deleteItemFromList(indexPath: indexPath)
            }))
            
            alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
}

//MARK: - Search Bar Methods

extension GroceryViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()

        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@ ", searchBar.text!)
        request.sortDescriptors  = [NSSortDescriptor(key: "name", ascending: true )]
        
        load(with: request)
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
