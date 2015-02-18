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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 78.0
    }
    
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
                receiver: interlocutor,
                time: String.getCurrentTime())
            XMPPCommunicator.sharedInstance.sendMessage(messageObject)
        }
    }
}

// MARK: - UITableViewDataSource

extension ChatViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let m = messages[indexPath.row]
        
        let cellId = m.sender == XMPPCommunicator.sharedInstance.me ? "MyMessageCell" : "InterlocutorMessageCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as ChatCell
        
        cell.senderAndTimeLabel.text = "\(m.sender.bareName) \(m.time)"
        cell.messageLabel.text = m.message.stringBySubstitutingEmoticons()
        
        return cell
    }
}

// MARK: - MessageDelegate

extension ChatViewController: MessageDelegate {
    func newMessageReceived(message: Message) {
        messages.append(message)
        tableView.reloadData()
    }
}
