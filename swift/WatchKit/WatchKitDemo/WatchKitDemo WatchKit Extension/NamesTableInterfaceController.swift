//
//  NamesTableInterfaceController.swift
//  WatchKitDemo
//
//  Created by Slava Zubrin on 1/8/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import WatchKit
import Foundation

class NamesTableInterfaceController: WKInterfaceController
{
    @IBOutlet weak var table: WKInterfaceTable!
    
    var names: Array<String> = []
    var selectedIndex: Int?
    
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
        
        getSharedData()
        loadTableData()
    }
    
    override func willActivate()
    {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate()
    {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    // MARK: User actions

    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int)
    {
        let name = names[rowIndex]
        println("selected person with name: \(name)")
        
        // How to pass an action from the WatchKit Extension to binded iOS App?
        WKInterfaceController.openParentApplication(["selectedName": name], reply: { (data, error) -> Void in
            if let name = data["name"] as? String {
                if let indx = find(self.names, name) {
                    
                    if self.selectedIndex != indx {
                        if self.selectedIndex != nil {
                            self.setColor(UIColor.blackColor(), forNameAtIndex: self.selectedIndex!)
                        }
                        self.selectedIndex = indx
                        self.setColor(UIColor.redColor(), forNameAtIndex: self.selectedIndex!)
                    }
                }
            }
        })
    }
    
    // MARK: Private

    private func getSharedData()
    {
        if let sharedUserDefaults = NSUserDefaults(suiteName: "group.testWatchKitToIOSShareGroup")
        {
            let list = sharedUserDefaults.objectForKey("list") as? Array<String>
            if list != nil
            {
                println(list)
                self.names = list!
            }
        }
    }
    
    private func loadTableData()
    {
        table?.setNumberOfRows(names.count, withRowType: "TableRowController")
        
        for (index, name) in enumerate(names) {
            let row = table.rowControllerAtIndex(index) as NameTableRowController
            row.iLabel.setText(name)
            row.iImage.setImageNamed("user_male3-50.png")
        }
    }
    
    private func setColor(_color: UIColor, forNameAtIndex index: Int)
    {
        let row = table.rowControllerAtIndex(index) as NameTableRowController
        row.iLabel.setTextColor(_color)
    }
}
