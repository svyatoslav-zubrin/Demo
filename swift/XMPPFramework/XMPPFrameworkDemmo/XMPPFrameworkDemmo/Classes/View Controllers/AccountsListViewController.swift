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
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)

//        for account in accounts
//        {
//            if let comm = CommunicatorsProvider.sharedInstance.getCommunicatorByAccountId(account.accountId)
//            {
//                comm.chatDelegate = self
//            }
//        }

        tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

//        for account in accounts
//        {
//            if let comm = CommunicatorsProvider.sharedInstance.getCommunicatorByAccountId(account.accountId)
//            {
//                comm.chatDelegate = nil
//            }
//        }
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        let iPath = indexPathOfSelectedAccount
        if segue.identifier == "AccountsListToLogin" && iPath != nil
        {
            if let dvc = segue.destinationViewController as? LoginViewController
            {
//                let account = UserSettings.sharedInstance.accounts[iPath!.row]
                let section: NSFetchedResultsSectionInfo = frc.sections![iPath!.section] as NSFetchedResultsSectionInfo
                let account = section.objects[iPath!.row] as Account
                dvc.previewModeForAccount(account)
            }
        }
    }

    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return frc.sections!.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return (frc.sections![section] as NSFetchedResultsSectionInfo).objects.count //UserSettings.sharedInstance.accounts.count
    }
    
    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("AccountCell", forIndexPath: indexPath) as UITableViewCell
        let account = (frc.sections![indexPath.section] as NSFetchedResultsSectionInfo).objects[indexPath.row] as Account
        cell.textLabel?.text = account.humanReadableName
        cell.detailTextLabel?.text = "\(account.hostName):\(account.hostPort)"
        cell.imageView?.image = account.isOnline()
            ? UIImage(named: "Connected")
            : UIImage(named: "Disconnected")
        cell.imageView?.image = cell.imageView?.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        cell.imageView?.tintColor = account.isOnline() ? UIColor.myGreenColor() : UIColor.redColor()
        return cell
    }
    
    // editing actioins
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
        let account = (frc.sections![indexPath.section] as NSFetchedResultsSectionInfo).objects[indexPath.row] as Account
        
        // login/logout button
        
        let isOnline = account.isOnline()
        let action = UITableViewRowAction(style: UITableViewRowActionStyle.Default,
            title: isOnline ? "Logout" : "Login",
            handler: { action, indexpath in
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
                    println("new communicator creation")
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
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default,
            title: "Delete",
            handler: { action, indexpath in
                if isOnline
                {
                    if let communicator = CommunicatorsProvider.sharedInstance.getCommunicatorByAccountId(account.accountId)
                            as? XMPPCommunicator
                    {
                        communicator.disconnect()
                    }
                }
                
//                UserSettings.sharedInstance.removeAccount(account)
                
                tableView.beginUpdates() // optional
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                tableView.endUpdates()
        });
        

        return [action, deleteAction];
    }
    
    // MARK: - UITableViewDelegate
}

extension AccountsListViewController: ChatDelegate
{
    func accountDidDisconnect(_account: Account) {
        // TODO: implementation needed
    }
    
    func account(_account: Account, changedStatus newStatus: ChatStatus)
    {
        // TODO: implementation needed
        if let index = find(accounts, _account)
        {
            let iPath = NSIndexPath(forRow: index, inSection: 0)
            tableView.reloadRowsAtIndexPaths([iPath],
                withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func newBuddyOnline(buddy: Interlocutor) {
        // stub implementation (no optional methods for swift protocols)
    }
    
    func buddyWentOffline(buddy: Interlocutor) {
        // stub implementation (no optional methods for swift protocols)
    }
}

extension AccountsListViewController: NSFetchedResultsControllerDelegate
{
    func controllerDidChangeContent(controller: NSFetchedResultsController)
    {
        tableView.reloadData()
    }
}
