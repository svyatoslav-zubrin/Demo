//
//  NamesTableInterfaceController.swift
//  WatchKitDemo
//
//  Created by Slava Zubrin on 1/8/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import WatchKit
import Foundation

class NamesTableInterfaceController: WKInterfaceController {

    @IBOutlet weak var table: WKInterfaceTable!
    
    let names = ["Slava", "Igor", "Serega", "Leonid"]
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        loadTableData()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    // MARK: Private
    
    private func loadTableData()
    {
        table?.setNumberOfRows(names.count, withRowType: "TableRowController")
        
        for (index, name) in enumerate(names) {
            let row = table.rowControllerAtIndex(index) as NameTableRowController
            row.iLabel.setText(name)
            row.iImage.setImageNamed("user_male3-50.png")
        }
    }
}
