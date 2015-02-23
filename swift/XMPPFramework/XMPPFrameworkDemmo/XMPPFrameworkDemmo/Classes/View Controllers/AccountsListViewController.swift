//
//  AccountsListViewController.swift
//  XMPPFrameworkDemmo
//
//  Created by Slava Zubrin on 2/19/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit

class AccountsListViewController: UITableViewController {

    private var indexPathOfSelectedAccount: NSIndexPath?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if UserSettings.sharedInstance.accounts.count == 0 {
            performSegueWithIdentifier("AccountsListToLogin", sender: self)
        }
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let iPath = indexPathOfSelectedAccount
        if segue.identifier == "AccountsListToLogin" && iPath != 0 {
            if let dvc = segue.destinationViewController as? LoginViewController {
                let account = UserSettings.sharedInstance.accounts[iPath!.row]
                dvc.previewModeForAccount(account)
            }
        }
    }

    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserSettings.sharedInstance.accounts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AccountCell", forIndexPath: indexPath) as UITableViewCell
        let account = UserSettings.sharedInstance.accounts[indexPath.row]
        cell.textLabel?.text = account.humanReadableName
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
}
