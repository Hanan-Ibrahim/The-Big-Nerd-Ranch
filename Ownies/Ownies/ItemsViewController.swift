//
//  ItemsViewController.swift
//  Ownies
//
//  Created by Han on 17.04.2020.
//  Copyright © 2020 Han. All rights reserved.
//
import UIKit

class ItemsViewController: UITableViewController {

    // MARK: variables
    var itemStore: ItemStore!
    var imageStore: ImageStore!
    
    
    // MARK:  View life cycle of Items Controller
    required init?(coder aDecoder: NSCoder) {
        //Can't be accessed through IB, needs to be done programmatically
        super.init(coder: aDecoder)
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //called when view is triggered
        //reload table so that when user presses back button, changes are seen immediately
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Called after the controller's view is load
        // Customizing the table background
        let backView = UIImageView(image: #imageLiteral(resourceName: "pink"))
        backView.contentMode = .scaleAspectFit
        
        let color = UIColor(red: 1, green: 0.95, blue: 0.85, alpha: 1)
        tableView.backgroundColor = color
        
        tableView.backgroundView = backView
        tableView.backgroundView?.isOpaque = false
        
        
        // tableView.rowHeight = 65 better do this: for dynamic cell heights
        // and give it init guessing
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 65
        
        print("Bundle: \(Bundle.main.bundlePath)")

    }
    
    
    // MARK:  UITableViewController methods
    // tells table how many rows it should display for each section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return itemStore.allItems.count
    }
    
    // what to content display in these cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get a new recycled cell. Prototype of ItemCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        let item = itemStore.allItems[indexPath.row]

        // Config cell with item
         cell.nameLabel.text = item.name
         cell.serialNumberLabel.text = item.serialNumber
         cell.valueLabel.text = "$\(item.valueInDollars)"
         cell.backgroundView?.isOpaque = false
    
        // Color for pricy items
         if item.valueInDollars < 50 {
            cell.valueLabel.textColor = UIColor.green
            cell.backgroundColor = #colorLiteral(red: 0.7939542498, green: 0.8392156959, blue: 0.9764705896, alpha: 0.8698630137)
          } else {
            cell.valueLabel.textColor = UIColor.red
            cell.backgroundColor = #colorLiteral(red: 0.991022201, green: 0.5253678026, blue: 0.706628161, alpha: 0.8356164384)
          }
         return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "No more items!"
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // If the table view is asking to commit a delete command
        if editingStyle == .delete {
                let item = itemStore.allItems[indexPath.row]
            
                let title = "Delete \(item.name)?"
                let message = "Are you sure you want to delete this item?"
                
                let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                ac.addAction(cancelAction)
                
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive,
                                                 handler: { (action) -> Void in
                                //Remove the item from the store
                                  self.itemStore.removeItem(item: item)
                                //Remove the item's image from the image store
                                self.imageStore.deleteImageForKey(key: item.itemKey)
                                //Also remove that row from the table view with an animation
                                tableView.deleteRows(at: [indexPath], with: .automatic)
                                   })
                ac.addAction(deleteAction)
            
                // Present the alert controller
                present(ac, animated: true, completion: nil)
            }
        }
    
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //Update the model
        itemStore.moveItem(from: sourceIndexPath.row, to: destinationIndexPath.row)
        
    }
    
    // Change name of delete command to remove
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Remove"
    }
    /*
    // Preventing Reordering of last row
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == (itemStore.allItems.count - 1) {
            return false
           }
         return true
    }
    // Make constant row in no editing mode
     override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
       if indexPath.row == (itemStore.allItems.count - 1) {
         return .none
         }
         return .delete
     }
    
    // Indents last row if its in editing mode
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == (itemStore.allItems.count - 1) {
            return false
        }
        return true
    }
*/
    
    // MARK: - Button Action for AddItem
    @IBAction func addNewItem(_ sender: UIBarButtonItem) {
        // Create a new item and add it to the store
        let newItem = itemStore.createItem()
        
        //Figure out where that item is an the array
        if let index = itemStore.allItems.index(of: newItem) {
            let indexPath = IndexPath(row: index, section: 0)
            
            //Insert this new row into the table
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
    
    // MARK: - Segue for showItem
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //If the triggered segue is the "showItem" segue
        if segue.identifier == "showItem" {
            //Figure out which row was just tapped
            if let row = tableView.indexPathForSelectedRow?.row {
                
                //Get the item asscoiated with this row pass it along
                let item = itemStore.allItems[row]
                let detailViewController = segue.destination as! DetailViewController
                detailViewController.item = item
                detailViewController.imageStore = imageStore
            }
        }
    }
}
