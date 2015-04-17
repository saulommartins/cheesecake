//
//  MasterViewController.swift
//  chesecake
//
//  Created by Saulo Mendes Martins on 4/11/15.
//  Copyright (c) 2015 Saulo Mendes Martins. All rights reserved.
//

import UIKit
import CoreData
//import AeroGearHttp
import Alamofire

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    var fieldSortList: String? = "authors"
    var ascSortList: Bool? = true
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var segmentAscControl: UISegmentedControl!

    @IBAction func reorderChange(sender: UISegmentedControl) {
        switch self.segmentControl!.selectedSegmentIndex
        {
        case 0:
            reorderList("authors")
        case 1:
            reorderList("date")
        default:
            reorderList("title")
            break;
        }
    }
    @IBAction func ascChange(sender: UISegmentedControl) {
        switch self.segmentAscControl!.selectedSegmentIndex
        {
        case 0:
            self.ascSortList = true
        default:
            self.ascSortList = false
            break;
        }
        reorderList(self.fieldSortList!)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        self.getJson()
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func reorderList(field: String) {
        self.fieldSortList = field
        _fetchedResultsController = nil
        self.tableView.reloadData()
    }

    
    func insertNewObject(item: NSDictionary) {
        
        let context = self.fetchedResultsController.managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context) as! NSManagedObject
        
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        let title = item["title"] as! String
        let dateString = item["date"] as! String
        let webSite = item["website"] as! String
        let authors = item["authors"] as! String
        let content = item["content"] as! String
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let date: NSDate = dateFormatter.dateFromString(dateString)!
        let dateTimestamp: Double = date.timeIntervalSince1970
        newManagedObject.setValue(title, forKey: "title")
//        newManagedObject.setValue(dateFormatter.dateFromString(dateString), forKey: "date")
        newManagedObject.setValue(dateTimestamp, forKey: "date")
        //        newManagedObject.setValue(dateString, forKey: "date")
        newManagedObject.setValue(webSite, forKey: "website")
        newManagedObject.setValue(authors, forKey: "authors")
        newManagedObject.setValue(content, forKey: "content")
        newManagedObject.setValue(false, forKey: "read")
        
        // Save the context.
        var error: NSError? = nil
        if !context.save(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
    }
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("passou")
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
	        self.markRead(true, atIndexPath: indexPath)
            let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.rightBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellArticle", forIndexPath: indexPath) as! UITableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        println(editingStyle)
        
        if editingStyle == .Delete {
            println("passou")
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
                
            var error: NSError? = nil
            if !context.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //println("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) ->[AnyObject]? {

        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
        println("read = ")
        println(object.valueForKey("read"))
        if (object.valueForKey("read")!.boolValue == true) {
            var unreadAction = UITableViewRowAction(style: .Default, title: "Mark as Unread") { (action, indexPath) -> Void in
                self.markRead(false, atIndexPath: indexPath)
            }
            unreadAction.backgroundColor = UIColor.blueColor()
            
            return [unreadAction]
        }else{
            var readAction = UITableViewRowAction(style: .Default, title: "Mark as Read") { (action, indexPath) -> Void in
                self.markRead(true, atIndexPath: indexPath)
            }
            readAction.backgroundColor = UIColor.blueColor()
            
            return [readAction]
           
        }
   }
    
    
    func markRead(read: Bool, atIndexPath indexPath: NSIndexPath) {
        tableView.editing = false
        let context = self.fetchedResultsController.managedObjectContext
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
        object.setValue(read, forKey: "read")
        println("readAction")
        var error: NSError? = nil
        if !context.save(&error) {
            abort()
        }
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
            let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
        //        cell.textLabel!.text = object.valueForKey("title")!.description
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateTimestamp = object.valueForKey("date") as! Double
        let date = NSDate(timeIntervalSince1970:dateTimestamp)
        
        (cell.contentView.viewWithTag(10) as! UILabel).text = object.valueForKey("title") as? String
        (cell.contentView.viewWithTag(20) as! UILabel).text = dateFormatter.stringFromDate(date)
        (cell.contentView.viewWithTag(30) as! UILabel).text = object.valueForKey("authors") as? String
        (cell.contentView.viewWithTag(40) as! UIImageView).image = UIImage(named: "book")
        if (object.valueForKey("read") as? Bool == false) {
            (cell.contentView.viewWithTag(50) as! UIImageView).image = UIImage(named: "rhboRGk")
        }else{
            (cell.contentView.viewWithTag(50) as! UIImageView).image = nil
        }
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Article", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: self.fieldSortList!, ascending: self.ascSortList!)
        let sortDescriptors = [sortDescriptor]
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
    	var error: NSError? = nil
    	if !_fetchedResultsController!.performFetch(&error) {
    	     // Replace this implementation with code to handle the error appropriately.
    	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             //println("Unresolved error \(error), \(error.userInfo)")
    	     abort()
    	}
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController? = nil

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }
     */

    
    
    func getJson () {
        let countItem = self.fetchedResultsController.sections?.count ?? 0
        let sectionInfo = self.fetchedResultsController.sections![0] as! NSFetchedResultsSectionInfo
//        if (countItem <= 0) {
//            let http = Http(baseURL: "http://www.ckl.io")
//            http.GET("/challenge", completionHandler: {(response, error) in
//                print("getting a json");
//                let dataArray = response as NSArray
//                for item in dataArray { // loop through data items
//                    let obj = item as NSDictionary
//                    self.insertNewObject(obj)
//                }
//            })
        if (sectionInfo.numberOfObjects <= 0) {
            Alamofire.request(.GET, "http://www.ckl.io/challenge")
                .responseJSON { (_, _, JSON, _) in
//                    println(JSON)
                    let dataArray = JSON as! NSArray
                    for item in dataArray { // loop through data items
                        let obj = item as! NSDictionary
                        self.insertNewObject(obj)
                    }
            }
        }
    }
    
}

