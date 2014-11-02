//
//  CDMNotesViewController.swift
//  MigrationCoreDataDemo
//
//  Created by Slava Zubrin on 11/1/14.
//  Copyright (c) 2014 zubrin. All rights reserved.
//

import UIKit
import CoreData

class CDMNotesViewController
    : UIViewController
    , UITableViewDataSource
    , UITableViewDelegate
    , NSFetchedResultsControllerDelegate
{
    // MARK: - Properties
    
    @IBOutlet weak var notesTableView: UITableView!
    
    private var frc: NSFetchedResultsController?
    
    
    // MARK: - View lifecycle

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.prepareFRC()
        
        if self.frc!.performFetch(nil)
        {
            self.notesTableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        if let frc = self.frc
        {
            return frc.sections!.count
        }
        else
        {
            return 0
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let frc = self.frc
        {
            if let sections = frc.sections
            {
                return sections[section].numberOfObjects!
            }
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        if let note = self.frc!.objectAtIndexPath(indexPath) as? Note
        {
            cell.textLabel.text = note.title
        }
        
        return cell
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(controller: NSFetchedResultsController)
    {
        self.notesTableView.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

// MARK: - Private -

private extension CDMNotesViewController
{

    func prepareFRC() -> Void
    {
        var fr = NSFetchRequest(entityName: "Note")
        fr.sortDescriptors = [self.notesSortDescriptor()]
        self.frc = NSFetchedResultsController(fetchRequest: fr,
                                              managedObjectContext: CDMCoreDataManager.sharedManager.moc!,
                                              sectionNameKeyPath: nil,
                                              cacheName: nil)
        self.frc!.delegate = self
    }
    
    func notesSortDescriptor() -> NSSortDescriptor
    {
        return NSSortDescriptor(key: "title", ascending: true)
    }
}
