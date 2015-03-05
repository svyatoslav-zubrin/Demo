//
//  AccountsListViewController.swift
//  XMPPFrameworkDemmo
//
//  Created by Slava Zubrin on 2/19/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit
import CoreData

class AccountsListViewController: UITableViewController
{
    private var indexPathOfSelectedAccount: NSIndexPath?
    
    private var frc: NSFetchedResultsController!
    
    private var accounts: [Account]
    {
        return UserSettings.sharedInstance.accounts
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        frc = Account.MR_fetchAllGroupedBy("serviceType",
                withPredicate: nil,
                sortedBy: "serviceType",
                ascending: true,
                delegate: self)

        if frc.fetchedObjects?.count == 0
        {
            performSegueWithIdentifier("AccountsListToLogin", sender: self)
        }
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        let iPath = indexPathOfSelectedAccount
        if segue.identifier == "AccountsListToLogin" && iPath != nil
        {
            if let dvc = segue.destinationViewController as? LoginViewController
            {
                let section = frc.sections![iPath!.section] as NSFetchedResultsSectionInfo
                let account = section.objects[iPath!.row] as Account
                dvc.previewModeForAccount(account)
            }
        }
    }

    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        if let sections = frc.sections as? [NSFetchedResultsSectionInfo]
        {
            return sections.count
        }
        else
        {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int
    {
        if let sections = frc.sections as? [NSFetchedResultsSectionInfo] {
            return sections[section].numberOfObjects
        }
        else
        {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView,
                            cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("AccountCell", forIndexPath: indexPath)
                as UITableViewCell

        let section = frc.sections![indexPath.section] as NSFetchedResultsSectionInfo
        let account = section.objects[indexPath.row] as Account

        cell.textLabel?.text = account.humanReadableName
        cell.detailTextLabel?.text = "\(account.hostName):\(account.hostPort)"
        let image = account.isOnline() ? UIImage(named: "Connected") : UIImage(named: "Disconnected")
        if let image = image
        {
            let renderedImage = image.imageWithRenderingMode(.AlwaysTemplate)
            cell.imageView?.image = renderedImage
            cell.imageView?.tintColor = account.isOnline() ? UIColor.myGreenColor() : UIColor.redColor()
        }

        return cell
    }
    
    // editing actions
    override func tableView(tableView: UITableView,
                            canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
    override func tableView(tableView: UITableView,
                            commitEditingStyle editingStyle: UITableViewCellEditingStyle,
                            forRowAtIndexPath indexPath: NSIndexPath)
    {
        // stub implementation
    }
    
    override func tableView(tableView: UITableView,
                            editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?
    {
        let section = frc.sections![indexPath.section] as NSFetchedResultsSectionInfo
        let account = section.objects[indexPath.row] as Account

        // login/logout button
        
        let isOnline = account.isOnline()
        let action =
        UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: isOnline ? "Logout" : "Login", handler:
        { action, indexpath in
            if let communicator = CommunicatorsProvider.sharedInstance.getCommunicatorByAccountId(account.accountId)
                    as? XMPPCommunicator
            {
                // use existing communicator
                if isOnline
                {
                    communicator.disconnect()

                    tableView.reloadRowsAtIndexPaths([indexPath],
                        withRowAnimation: UITableViewRowAnimation.Automatic)
                }
                else
                {
                    if communicator.connect()
                    {
                        tableView.reloadRowsAtIndexPaths([indexPath],
                            withRowAnimation: UITableViewRowAnimation.Automatic)
                    }
                    else
                    {
                        // handle connection error appropriately
                    }
                }
            }
            else
            {
                // create new communicator
                let c = CommunicatorFactory.communicatorForAccount(account) as XMPPCommunicator
                c.chatDelegate = self
                CommunicatorsProvider.sharedInstance.addCommunicator(c)
                if c.connect()
                {
                    tableView.reloadRowsAtIndexPaths([indexPath],
                        withRowAnimation: UITableViewRowAnimation.Automatic)
                }
            }

            tableView.editing = false
        });
        
        if !isOnline
        {
            action.backgroundColor = UIColor.myGreenColor()
        }
        
        // delete button
        
        let deleteAction =
        UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler:
        { action, indexpath in
            if isOnline
            {
                if let communicator = CommunicatorsProvider.sharedInstance.getCommunicatorByAccountId(account.accountId)
                        as? XMPPCommunicator
                {
                    communicator.disconnect()
                }
            }
            
            MagicalRecord.saveWithBlock(
            { (context: NSManagedObjectContext!) -> Void in
                let localAccount = account.MR_inContext(context) as Account
                localAccount.MR_deleteInContext(context)
                return
            },
            completion:
            { (success: Bool, error: NSError!) -> Void in
                if !success
                {
                    println("Error deleting account: \(error)")
                }
            })
        });

        return [action, deleteAction];
    }
    
    // MARK: - UITableViewDelegate
}

extension AccountsListViewController: ChatDelegate
{
    func accountDidDisconnect(_account: Account)
    {
        // TODO: implementation needed
    }
    
    func account(_account: Account,
                 changedStatus newStatus: ChatStatus)
    {
        // TODO: implementation needed
        if let index = find(accounts, _account)
        {
            let iPath = NSIndexPath(forRow: index, inSection: 0)
            tableView.reloadRowsAtIndexPaths([iPath],
                withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func newBuddyOnline(buddy: Interlocutor)
    {
        // stub implementation (no optional methods for swift protocols)

        
    }
    
    func buddyWentOffline(buddy: Interlocutor)
    {
        // stub implementation (no optional methods for swift protocols)
    }
}

extension AccountsListViewController: NSFetchedResultsControllerDelegate
{
    func controllerDidChangeContent(controller: NSFetchedResultsController)
    {
        tableView.reloadData()

        if let sections = frc.sections as? [NSFetchedResultsSectionInfo]
        {
           if sections.count == 0
           {
               performSegueWithIdentifier("AccountsListToLogin", sender: self)
           }
        }
    }
}
