//
//  BuddiesViewController.swift
//  XMPPFrameworkDemmo
//
//  Created by Slava Zubrin on 2/16/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit

class BuddiesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var statusView: UIView!
    
    private var onlineBuddies: [String] = []
    private var iPathOfSelectedBuddy: NSIndexPath?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusView.layer.cornerRadius = 10
        statusView.clipsToBounds = true
        
        XMPPCommunicator.sharedInstance.chatDelegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let userId = UserSettings.sharedInstance.userId
        if userId == nil || countElements(userId!) == 0 {
            showLogin()
        } else {
            if XMPPCommunicator.sharedInstance.connect() {
                println("Show buddy list!")
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "BuddiesListToChat" {
            let dvc = segue.destinationViewController as ChatViewController
            if let iPath = iPathOfSelectedBuddy {
                dvc.interlocutorName = onlineBuddies[iPath.row]
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension BuddiesViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return onlineBuddies.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "OnlineBuddyCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as UITableViewCell
        cell.textLabel!.text = onlineBuddies[indexPath.row]
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
}

// MARK: - UITableViewDelegate

extension BuddiesViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        iPathOfSelectedBuddy = indexPath
        self.performSegueWithIdentifier("BuddiesListToChat", sender: self)
    }
}

// MARK: - ChatDelegate

extension BuddiesViewController: ChatDelegate {
    
    func myStatusChanged(newStatus: ChatStatus) {
        if newStatus == .Available {
            statusView.backgroundColor = UIColor.greenColor()
        } else {
            statusView.backgroundColor = UIColor.redColor()
        }
    }
    
    func newBuddyOnline(name: String) {
        onlineBuddies.append(name)
        tableView.reloadData()
    }
    
    func buddyWentOffline(name: String) {
        onlineBuddies.removeObject(name)
        tableView.reloadData()
    }
    
    func didDisconnect() {
        statusView.backgroundColor = UIColor.redColor()
    }
}

// MARK: - Private

private extension BuddiesViewController {
    
    func showLogin() {
        self.performSegueWithIdentifier("BuddiesListToLogin", sender: self)
    }
}
