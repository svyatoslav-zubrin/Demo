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
    
    var interlocutor: Interlocutor! = nil
    var messages: [Message] = []
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Conversation with " + interlocutor.name
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
            
            let messageObject = Message(text: message,
                sender: XMPPCommunicator.sharedInstance.me,
                receiver: interlocutor)
            XMPPCommunicator.sharedInstance.sendMessage(messageObject)
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
        cell.detailTextLabel?.text = m.sender.name
        if m.sender.bareName == XMPPCommunicator.sharedInstance.me.bareName {
            cell.backgroundColor = UIColor.blueColor()
            cell.textLabel?.textColor = UIColor.yellowColor()
            cell.detailTextLabel?.textColor = UIColor.yellowColor()
        } else {
            cell.backgroundColor = UIColor.yellowColor()
            cell.textLabel?.textColor = UIColor.blueColor()
            cell.detailTextLabel?.textColor = UIColor.blueColor()
        }
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
