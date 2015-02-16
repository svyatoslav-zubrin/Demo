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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Conversation with " + interlocutorName
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    
        self.textField.becomeFirstResponder()
        
        XMPPCommunicator.sharedInstance.messageDelegate = self
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        XMPPCommunicator.sharedInstance.messageDelegate = nil
    }
    
    // MARK: - User actions
    
    @IBAction func sendAction(sender: UIButton) {
        if let message = textField.text {
            
            textField.text = ""
            
            let messageText = String(format: "%@:%@", arguments: [message, "you"])
            let messageObject = Message(text: message/*Text*/,
                sender: "you",
                receiver: XMPPCommunicator.sharedInstance.currentUserName)
            messages.append(messageObject)

            XMPPCommunicator.sharedInstance.sendMessage(messageObject)
            
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

extension ChatViewController: MessageDelegate {
    func newMessageReceived(message: Message) {
        messages.append(message)
        tableView.reloadData()
    }
}
