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
    private var selectedIndexPath: NSIndexPath? = nil
    
    
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

            if let image = note.image
            {
                cell.imageView.image = image
            }
            else
            {
                println("Image == nil")
            }
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.selectedIndexPath = indexPath
        self.notesTableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.performSegueWithIdentifier("NotesListToNewNote", sender: self)
    }

    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(controller: NSFetchedResultsController)
    {
        self.notesTableView.reloadData()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if self.selectedIndexPath != nil
        {
            if let note = self.frc!.objectAtIndexPath(self.selectedIndexPath!) as? Note
            {
                let vc = segue.destinationViewController as CDMNewNoteViewController
                vc.note = note
            }
        }
    }
}

// MARK: - Private -

private extension CDMNotesViewController
{

    func prepareFRC() -> Void
    {
        var fr = NSFetchRequest(entityName: "Note")
        fr.sortDescriptors = [self.notesSortByTitleDescriptor()]
        self.frc = NSFetchedResultsController(fetchRequest: fr,
                                              managedObjectContext: CDMCoreDataManager.sharedManager.moc!,
                                              sectionNameKeyPath: nil,
                                              cacheName: nil)
        self.frc!.delegate = self
    }
    
    func notesSortByTitleDescriptor() -> NSSortDescriptor
    {
        return NSSortDescriptor(key: "title", ascending: true)
    }
    
    func notesSortByDateDescriptor() -> NSSortDescriptor
    {
        return NSSortDescriptor(key: "dateCreated", ascending: true)
    }
}
