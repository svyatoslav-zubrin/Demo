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
        
        self.notesTableView.allowsMultipleSelection = false
        
        self.prepareFRC()
        
        if self.frc!.performFetch(nil)
        {
            self.notesTableView.reloadData()
        }
    }

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.selectedIndexPath = nil
    }
    
    // MARK: - User actions

    @IBAction func editAction(sender: AnyObject?)
    {
        self.notesTableView.setEditing(!self.notesTableView.editing, animated: true)
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
                let sectionInfo = frc.sections![section] as NSFetchedResultsSectionInfo
                return sectionInfo.numberOfObjects
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

    func tableView(tableView: UITableView,
                   editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?
    {
        let action =
        UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete")
        { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            self.deleteNoteAtIndexPath(indexPath)
            { (error: NSError?) -> Void in
                if let err = error
                {
                    println("   Unable to delete note: \(err.localizedDescription)")
                }
                else
                {
                    self.notesTableView.reloadData()
                }
            }
        }
        
        return [action]
    }

    func tableView(tableView: UITableView,
                   commitEditingStyle editingStyle: UITableViewCellEditingStyle,
                   forRowAtIndexPath indexPath: NSIndexPath)
    {
        // empty on purpose
    }
    
    func tableView(tableView: UITableView,
                   editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
    {
        return UITableViewCellEditingStyle.Delete
    }
    
    // MARK: - NSFetchedResultsControllerDelegate

    func controllerWillChangeContent(controller: NSFetchedResultsController)
    {
        println("controllerWillChangeContent.beginUpdates")
        self.notesTableView!.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController!)
    {
        println("controllerDidChangeContent.endUpdates")
        self.notesTableView!.endUpdates()
    }

    func controller(controller: NSFetchedResultsController,
                    didChangeObject anObject: AnyObject,
                    atIndexPath indexPath: NSIndexPath?,
                    forChangeType type: NSFetchedResultsChangeType,
                    newIndexPath: NSIndexPath?)
    {
        println("didChangeObjectAtIndexPath")
        switch type
        {
            case .Insert:
                self.notesTableView.insertRowsAtIndexPaths([newIndexPath!],
                                                            withRowAnimation: UITableViewRowAnimation.Automatic)
            case .Delete:
                self.notesTableView.deleteRowsAtIndexPaths([indexPath!],
                                                            withRowAnimation: UITableViewRowAnimation.Automatic)
            case .Update:
                let cell = self.notesTableView.cellForRowAtIndexPath(indexPath!)
                self.configureCell(cell, atIndexPath: indexPath!)
            case .Move:
                self.notesTableView.deleteRowsAtIndexPaths([indexPath!],
                                                            withRowAnimation: UITableViewRowAnimation.Automatic)
                self.notesTableView.insertRowsAtIndexPaths([newIndexPath!],
                                                            withRowAnimation: UITableViewRowAnimation.Automatic)
            default:
                break
        }
    }
    
    // MARK: - Navigation

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
    func configureCell(cell: UITableViewCell!, atIndexPath indexPath: NSIndexPath!)
    {
        if let note = self.frc!.objectAtIndexPath(indexPath) as? Note
        {
            cell.textLabel.text = note.title
            
            if let image = note.image
            {
                cell.imageView.image = image
            }
        }
    }
    
    func prepareFRC() -> Void
    {
        var fr = NSFetchRequest(entityName: "Note")
        fr.sortDescriptors = [Note.sortByDateDescriptor()]
        self.frc = NSFetchedResultsController(fetchRequest: fr,
                                              managedObjectContext: CDMCoreDataManager.sharedManager.moc!,
                                              sectionNameKeyPath: nil,
                                              cacheName: nil)
        self.frc!.delegate = self
    }
    
    func deleteNoteAtIndexPath(indexPath: NSIndexPath, resultHandler: (error: NSError?) -> Void )
    {
        var error: NSError? = nil
        
        if let note = self.frc!.objectAtIndexPath(indexPath) as? Note
        {
            let moc = CDMCoreDataManager.sharedManager.moc!
            moc.deleteObject(note)
            CDMCoreDataManager.sharedManager.saveContext()
        }
        else
        {
            error = NSError(domain: "CoreDataDemoDomain", code: 1001, userInfo: nil)
        }
        
        resultHandler(error: error)
    }
}
