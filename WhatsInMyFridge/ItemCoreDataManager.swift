//
//  ItemCoreDataManager.swift
//  WhatsInMyFridge
//
//  Created by Chinmay Ghotkar on 6/21/19.
//  Copyright © 2019 Chinmay Ghotkar. All rights reserved.
//

import UIKit
import CoreData

class ItemCoreDataManager {
    
    var itemList : [Item] = []
    var listOfList: [List] = []
    var selectedList : List?
    var currentTableView : UITableView!
    
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    init(tableView : UITableView) {
        self.currentTableView = tableView
    }
    
    // Test if the string quantity value is valid
    func checkIfCorrectQuantity(testQuantity: String) -> Int {
        var setQuantity : Int

        if let number = Int(testQuantity) {
            print("number value", number)
            if number <= 0 {
                print("Setting value to -1")
                setQuantity = -1
            } else {
                setQuantity = number
            }
        } else {
            setQuantity = -1
        }
        
        return setQuantity
    }
    
    func addNewItem(with name: String, quantity: String)
    {
        let setQuantity = checkIfCorrectQuantity(testQuantity: quantity)
        
        print("set Quantity", setQuantity)

        // Create new item and add it to the todo items list
        let item = Item(context: managedContext)
        
        item.setValue(name, forKeyPath: "name")
        item.setValue(setQuantity, forKeyPath: "quantity")
        item.parentList = selectedList
        itemList.append(item)
        
        save()
    }
    
    func editItem(with name: String, quantity: String, atRow : Int)
    {
        let setQuantity = checkIfCorrectQuantity(testQuantity: quantity)
        
        print("set Quantity", setQuantity)
        
        // Create new item and add it to the todo items list
        let item = itemList[atRow]
        
        item.setValue(name, forKeyPath: "name")
        item.setValue(setQuantity, forKeyPath: "quantity")
        
        save()
    }
    
    func save() {
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
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
        }
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
            itemList = try managedContext.fetch(request)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
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
    
    func deleteItemFromList(for tableRow : Int) {
        managedContext.delete(itemList[tableRow])
        itemList.remove(at: tableRow)
        save()
        self.currentTableView.reloadData()
    }
    
    func showEditDialog(controller : UIViewController ,for tableRow : Int) {
        let alert = UIAlertController(title: "Edit Item", message: "", preferredStyle: .alert)

        // Add a text field to the alert for the new item's name
        alert.addTextField(configurationHandler: nil)
        alert.textFields?[0].text = itemList[tableRow].name
        // Add a text field to the alert for the new item's quantity
        alert.addTextField(configurationHandler: nil)
        
        // if a previous value was set, put the value in the text field
        if self.itemList[tableRow].quantity != -1 {
            alert.textFields?[1].text = String(self.itemList[tableRow].quantity)
        }

        // Add a "OK" button to the alert. The handler calls editItem()
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            if let name = alert.textFields?[0].text, let quantity = alert.textFields?[1].text
            {
                self.editItem(with: name, quantity : quantity, atRow: tableRow)
                self.currentTableView.reloadData()
            }

            self.save()
        }))

        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (_) in
            self.deleteItemFromList(for: tableRow)
        }))

        // Add a "cancel" button to the alert. This one doesn't need a handler
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        controller.present(alert, animated: true, completion: nil)
    }

    func showMoveListDialog(controller : UIViewController, for tableRow : Int) {
        let alert = UIAlertController(title: "Lists", message: "", preferredStyle: .actionSheet)

        loadLists()

        for list in listOfList {

            let listAction = UIAlertAction(title: list.name, style: .default) { (_) in
                self.itemList[tableRow].parentList = list
                self.save()
                self.load()
                self.currentTableView.reloadData()
            }

            alert.addAction(listAction)

        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))

        print(listOfList.count)
        controller.present(alert, animated: true)
    }
}
