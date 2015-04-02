//
//  ChatViewController.swift
//  XMPPFrameworkDemmo
//
//  Created by Slava Zubrin on 2/16/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    var account: Account! = nil
    var interlocutor: Interlocutor! = nil
    var messages: [Message] = []
    
    var frc:NSFetchedResultsController! = nil
    
    var communicator: BaseCommunicator
    {
        return CommunicatorsProvider.sharedInstance.getCommunicatorByAccountId(account.accountId)!
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 78.0
        
        fetchMessages()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.title = "Conversation with " + interlocutor.name
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
    
        self.textField.becomeFirstResponder()
        
        communicator.messageDelegate = self
    }

    override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        communicator.messageDelegate = nil
    }
    
    // MARK: - User actions
    
    @IBAction func sendAction(sender: UIButton)
    {
        if let message = textField.text
        {
            textField.text = ""
            
            let xmppCommunicator = communicator as XMPPCommunicator
            xmppCommunicator.sendMessage(body: message, receiver: interlocutor, date: NSDate())
        }
    }
}

// MARK: - UITableViewDataSource

extension ChatViewController: UITableViewDataSource
{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let objects = frc.fetchedObjects
        {
            return objects.count;
        }
        else
        {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {

        let m = frc.objectAtIndexPath(indexPath) as Message

        let xmppCommunicator = communicator as XMPPCommunicator // TODO: correct classes hierarchi for baseComm...->XMPPComm... to make all properties public in base class
        
        let cellId = m.sender == xmppCommunicator.me ? "MyMessageCell" : "InterlocutorMessageCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as ChatCell

        let dateString = m.date != nil ? Message.dateAsString(m.date!) : ""
        cell.senderAndTimeLabel.text = "\(m.sender.bareName) \(dateString)"
        cell.messageLabel.text = m.body.stringBySubstitutingEmoticons()
        
        return cell
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension ChatViewController: NSFetchedResultsControllerDelegate
{
    func controllerDidChangeContent(controller: NSFetchedResultsController)
    {
        self.tableView.reloadData()
    }
}

// MARK: - MessageDelegate

extension ChatViewController: MessageDelegate
{
    func newMessageReceived(message: Message)
    {
        messages.append(message)
        tableView.reloadData()
    }
}

// MARK: - Private

private
extension ChatViewController
{
    func fetchMessages()
    {
        let predicateToMe = NSPredicate(format: "SELF.receiver.name = %@ && SELF.sender.name = %@",
            argumentArray: [account.me.name, interlocutor.name])
        let predicateFromMe = NSPredicate(format: "SELF.sender.name = %@ && SELF.receiver.name = %@",
            argumentArray: [account.me.name, interlocutor.name])
        let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType,
            subpredicates: [predicateToMe, predicateFromMe])
        
        frc = Message.MR_fetchAllSortedBy("date",
            ascending: true,
            withPredicate: predicate,
            groupBy: nil,
            delegate: self);
    }
}
