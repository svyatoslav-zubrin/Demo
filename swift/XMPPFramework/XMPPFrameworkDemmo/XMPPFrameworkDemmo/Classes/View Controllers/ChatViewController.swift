//
//  ChatViewController.swift
//  XMPPFrameworkDemmo
//
//  Created by Slava Zubrin on 2/16/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    var interlocutorName: String = ""
    var messages: [Message] = []
    
    // MARK: - Lifecycle
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.textField.becomeFirstResponder()
    }
    
    // MARK: - User actions
    
    @IBAction func sendAction(sender: UIButton) {
        if let message = textField.text {
            
            // TODO: send message through XMPP
            
            textField.text = ""
            
            let messageText = String(format: "%@:%@", arguments: [message, "you"])
            messages.append(Message(text: messageText, sender: "you"))
            
            tableView.reloadData()
        }
    }
}

extension ChatViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "MessageCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as UITableViewCell
        
        let m = messages[indexPath.row]
        cell.textLabel?.text = m.message
        cell.detailTextLabel?.text = m.senderName
        cell.accessoryType = UITableViewCellAccessoryType.None
        
        return cell
    }
}

/*
extension ChatViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // start a chat
    }
}
*/
