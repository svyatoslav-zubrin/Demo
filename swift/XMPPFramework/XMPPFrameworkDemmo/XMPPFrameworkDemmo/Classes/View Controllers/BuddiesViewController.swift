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
    
    private var onlineBuddies: [Interlocutor] = []
    private var offlineBuddies: [Interlocutor] = []
    private var buddiesGrouped: [[Interlocutor]] = []
    private var iPathOfSelectedBuddy: NSIndexPath?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusView.layer.cornerRadius = 10
        statusView.clipsToBounds = true
        
//        XMPPCommunicator.sharedInstance.chatDelegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        let userId = UserSettings.sharedInstance.userId
//        if userId == nil || countElements(userId!) == 0 {
//            showLogin()
//        } else {
////            if XMPPCommunicator.sharedInstance.connect() {
////                println("Show buddy list!")
////            }
//        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "BuddiesListToChat" {
            let dvc = segue.destinationViewController as ChatViewController
            if let iPath = iPathOfSelectedBuddy {
                dvc.interlocutor = buddiesGrouped[iPath.section][iPath.row]
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension BuddiesViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return buddiesGrouped.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buddiesGrouped[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "OnlineBuddyCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as UITableViewCell
        let buddy = buddiesGrouped[indexPath.section][indexPath.row]
        cell.textLabel!.text = buddy.bareName
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        cell.backgroundColor = isOfflineBuddiesGroup(indexPath.section)
                                    ? UIColor.redColor()
                                    : UIColor.whiteColor()
        cell.selectionStyle = .None
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isOfflineBuddiesGroup(section) {
            return "Offline users"
        } else {
            return String(first(buddiesGrouped[section].first!.bareName)!)
        }
    }
}

// MARK: - UITableViewDelegate

extension BuddiesViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !isOfflineBuddiesGroup(indexPath.section) {
            iPathOfSelectedBuddy = indexPath
            self.performSegueWithIdentifier("BuddiesListToChat", sender: self)
        }
    }
}

// MARK: - ChatDelegate

extension BuddiesViewController: ChatDelegate {
    
    func account(_account: Account, changedStatus newStatus: ChatStatus)
    {
        if newStatus == .Available {
            statusView.backgroundColor = UIColor.greenColor()
        } else {
            statusView.backgroundColor = UIColor.redColor()
        }
    }
    
    func newBuddyOnline(buddy: Interlocutor) {
        if contains(offlineBuddies, buddy) {
            offlineBuddies.removeObject(buddy)
        }
        
        if !contains(onlineBuddies, buddy) {
            onlineBuddies.append(buddy)
            groupBuddies()
        }
        
        tableView.reloadData()
    }
    
    func buddyWentOffline(buddy: Interlocutor) {
        onlineBuddies.removeObject(buddy)
        offlineBuddies.append(buddy)
        groupBuddies()
        tableView.reloadData()
    }
    
    func accountDidDisconnect(_account: Account)
    {
        statusView.backgroundColor = UIColor.redColor()
    }
}

// MARK: - Private

private extension BuddiesViewController {
    
    func showLogin() {
        self.performSegueWithIdentifier("BuddiesListToLogin", sender: self)
    }
    
    func groupBuddies() {
        
        func distinct<T: Equatable>(source: [T]) -> [T] {
            var unique = [T]()
            for item in source {
                if !contains(unique, item) {
                    unique.append(item)
                }
            }
            return unique
        }
        
        typealias GroupType = (Character, [Interlocutor])
        
        let buddiesSorted = onlineBuddies.sorted{$0.name < $1.name}
        let letters = buddiesSorted.map {
            (buddy) -> Character in
            return first(buddy.bareName.uppercaseString)!
        }
        
        let distinctLetters = distinct(letters)
        
        var onlineGroups = distinctLetters.map {
            (letter) -> GroupType in
            return (letter, self.onlineBuddies.filter {
                (buddy) -> Bool in
                    return first(buddy.bareName.uppercaseString) == letter
                }
            )
        }
        
        buddiesGrouped = onlineGroups.map {$1}

        if offlineBuddies.count != 0 {
            offlineBuddies = offlineBuddies.sorted{$0.name < $1.name}
            buddiesGrouped.append(offlineBuddies)
        }
    }
    
    func isOfflineBuddiesGroup(sectionIndex: Int) -> Bool {
        return offlineBuddies.count > 0 && sectionIndex == buddiesGrouped.count - 1
    }
}
