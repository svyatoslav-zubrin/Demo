//
//  PersonsTableViewController.swift
//  MulticontextCoreDataDemo
//
//  Created by zubrin on 10/17/14.
//  Copyright (c) 2014 ___ZUBRIN___. All rights reserved.
//

import UIKit
import CoreData

class PersonsTableViewController
    : UITableViewController
    , NSFetchedResultsControllerDelegate
{
    var frc: NSFetchedResultsController = NSFetchedResultsController()
    
    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        frc = getFetchedResultController()
        frc.delegate = self
        
        var error: NSError? = nil
        frc.performFetch(&error)
        if error != nil {
            println("Error fetching persons: \(error!.localizedDescription)")
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return frc.sections!.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return frc.sections![section].numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("personCellIdentifier", forIndexPath: indexPath) as UITableViewCell
        
        let person = frc.objectAtIndexPath(indexPath) as Person
        cell.textLabel?.text = "\(person.surname) \(person.name)"
        
        return cell
    }

    // MARK: - CoreData fetching

    func getFetchedResultController() -> NSFetchedResultsController {
        let moc = CoreDataManager.sharedManager.managedObjectContext
        frc = NSFetchedResultsController(fetchRequest: personsFetchRequest(),
                                         managedObjectContext: moc!,
                                         sectionNameKeyPath: nil,
                                         cacheName: nil)
        return frc
    }
    
    func personsFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Person")
//        let sortDescriptor = NSSortDescriptor(key: "surname", ascending: true)
//        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
}
