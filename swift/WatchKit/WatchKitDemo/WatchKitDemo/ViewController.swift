//
//  ViewController.swift
//  WatchKitDemo
//
//  Created by Slava Zubrin on 1/8/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit
import Foundation

class ViewController
    : UIViewController
    , UITableViewDelegate
    , UITableViewDataSource
{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var watchSelectionLabel: UILabel!
    
    let tableItems = ["Names", "Surnames"]
    let names = ["Slava", "Lesha", "Igor", "Sergey"]
    let surnames = ["Zubrin", "Naboychenko", "Kupreev", "Galagan"]
    
    var selectedArray: Array<String>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // default selection
        selectArray(names)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if let selectedName = NSUserDefaults.standardUserDefaults().objectForKey("selectedName") as? String {
            watchSelectionLabel.text = selectedName
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: Selector("handleWatchKitNotification:"),
                                                         name: "WATCH_KIT_SELECTED_USER_NAME",
                                                         object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table view methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = tableItems[indexPath.row]
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectArray(indexPath.row == 0 ? names : surnames)
    }
    
    // MARK: Private

    private func selectArray(array: Array<String>) {
        self.selectedArray = array

        // share data between iOS app and WatchKit extension with NSUserDefaults
        if let sharedUserDefaults = NSUserDefaults(suiteName: "group.testWatchKitToIOSShareGroup") {
            sharedUserDefaults.setObject(selectedArray, forKey: "list")
            sharedUserDefaults.synchronize()
        }
    }
    
    func handleWatchKitNotification(notification: NSNotification) {
        println("WATCH_KIT_SELECTED_USER_NAME notification handled in the controller")
        
        if let nameInfo = notification.object as? NameInfo {
            watchSelectionLabel.text = nameInfo.userName
            
            nameInfo.replyBlock(["name" : nameInfo.userName])
        }
    }
}


