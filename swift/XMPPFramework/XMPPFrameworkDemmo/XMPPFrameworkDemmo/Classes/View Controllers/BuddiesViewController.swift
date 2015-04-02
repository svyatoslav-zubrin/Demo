//
//  BuddiesViewController.swift
//  XMPPFrameworkDemmo
//
//  Created by Slava Zubrin on 2/16/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit
import CoreData

class BuddiesViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView!

    var frc: NSFetchedResultsController! = nil
    
    private var onlineBuddies: [Interlocutor] = []
    private var offlineBuddies: [Interlocutor] = []
    private var buddiesGrouped: [[Interlocutor]] = []
    private var iPathOfSelectedBuddy: NSIndexPath?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        frc = Interlocutor.MR_fetchAllGroupedBy("group",
            withPredicate: nil,
            sortedBy: "group,name",
            ascending: true,
            delegate: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "BuddiesListToChat"
        {
            let dvc = segue.destinationViewController as ChatViewController
            if let iPath = iPathOfSelectedBuddy
            {
                let i = frc.objectAtIndexPath(iPath) as Interlocutor;
                dvc.account = i.account
                dvc.interlocutor = i
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension BuddiesViewController: UITableViewDataSource
{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        if let sections = frc.sections
        {
            return sections.count
        }
        else
        {
            if let fos = frc.fetchedObjects
            {
                return fos.count > 0 ? 1 : 0
            }
            else
            {
                return 0
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let sections = frc.sections
        {
            return sections[section].numberOfObjects
        }
        else
        {
            if let fos = frc.fetchedObjects
            {
                return fos.count
            }
            else
            {
                return 0
            }
        }
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cellId = "OnlineBuddyCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as UITableViewCell
    
        if let buddy = frc.objectAtIndexPath(indexPath) as? Interlocutor
        {
            cell.textLabel!.text = buddy.name
            cell.detailTextLabel!.text = buddy.bareName + " (" + buddy.group + ")"
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell.selectionStyle = .None
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView,
        titleForHeaderInSection section: Int) -> String?
    {
        if let sections = frc.sections
        {
            return sections[section].name
        }
        else
        {
            return ""
        }
    }
}

// MARK: - UITableViewDelegate

extension BuddiesViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        iPathOfSelectedBuddy = indexPath
        self.performSegueWithIdentifier("BuddiesListToChat", sender: self)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension BuddiesViewController: NSFetchedResultsControllerDelegate
{
    func controllerDidChangeContent(controller: NSFetchedResultsController)
    {
        tableView.reloadData()
    }
}

// MARK: - ChatDelegate

extension BuddiesViewController: ChatDelegate {
    
    func account(_account: Account, changedStatus newStatus: ChatStatus)
    {
    }
    
    func newBuddyOnline(buddy: Interlocutor)
    {
        if contains(offlineBuddies, buddy)
        {
            offlineBuddies.removeObject(buddy)
        }
        
        if !contains(onlineBuddies, buddy)
        {
            onlineBuddies.append(buddy)
            groupBuddies()
        }
        
        tableView.reloadData()
    }
    
    func buddyWentOffline(buddy: Interlocutor)
    {
        onlineBuddies.removeObject(buddy)
        offlineBuddies.append(buddy)
        groupBuddies()
        tableView.reloadData()
    }
    
    func accountDidDisconnect(_account: Account)
    {

    }
}

// MARK: - Private

private extension BuddiesViewController
{
    func showLogin()
    {
        self.performSegueWithIdentifier("BuddiesListToLogin", sender: self)
    }
    
    func groupBuddies()
    {
        
        func distinct<T: Equatable>(source: [T]) -> [T]
        {
            var unique = [T]()
            for item in source
            {
                if !contains(unique, item)
                {
                    unique.append(item)
                }
            }
            return unique
        }
        
        typealias GroupType = (Character, [Interlocutor])
        
        let buddiesSorted = onlineBuddies.sorted{$0.name < $1.name}
        let letters = buddiesSorted.map
        { (buddy) -> Character in
            return first(buddy.bareName.uppercaseString)!
        }
        
        let distinctLetters = distinct(letters)
        
        var onlineGroups = distinctLetters.map
        { (letter) -> GroupType in
            return (letter, self.onlineBuddies.filter
            { (buddy) -> Bool in
                return first(buddy.bareName.uppercaseString) == letter
            })
        }
        
        buddiesGrouped = onlineGroups.map {$1}

        if offlineBuddies.count != 0
        {
            offlineBuddies = offlineBuddies.sorted{$0.name < $1.name}
            buddiesGrouped.append(offlineBuddies)
        }
    }
}
