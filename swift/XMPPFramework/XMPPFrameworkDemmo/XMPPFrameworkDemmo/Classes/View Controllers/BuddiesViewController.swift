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
    
    private var onlineBuddies: [AnyObject] = []
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let userId = UserSettings.sharedInstance.userId
        if userId == nil || countElements(userId!) == 0 {
            showLogin()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "BuddiesListToChat" {
            let dvc = segue.destinationViewController as ChatViewController
            dvc.interlocutorName = "Test interlocutor name"
        }
    }
}

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
        cell.textLabel!.text = "Test buddy name"
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
}

extension BuddiesViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("BuddiesListToChat", sender: self)
    }
}

private extension BuddiesViewController {
    
    func showLogin() {
        self.performSegueWithIdentifier("BuddiesListToLogin", sender: self)
    }
}
