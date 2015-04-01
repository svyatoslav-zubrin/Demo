//
// Created by Slava Zubrin on 3/24/15.
// Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit
import Parse

class ChatViewController: UIViewController
{
    // Assosiation keys
    private enum CellReuseIdentifier: String
    {
        case MyCell = "MyMessageCell"
        case InterlocutorCell = "InterlocutorMessageCell"
    }

    // Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet var keyboardHandler: ChatInputViewWithKeyboardHandler!

    // ivars
    var interlocutor: PFUser! = nil
    private var messages: [Message] = []
    
    // MARK: - View lifecycle
    
    override
    func viewDidLoad()
    {
        super.viewDidLoad()
        
        assert(interlocutor != nil, "To start a chat interlocutor must be set first")
        
        setupTableView()
        
        fetchHistory()
    }
    
    override
    func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = interlocutor.username.capitalizedString

        if let keyboardHandler = keyboardHandler
        {
            keyboardHandler.registerForKeyboardHandling()
        }
    }
    
    override
    func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        if let keyboardHandler = keyboardHandler
        {
            keyboardHandler.unregisterFromKeyboardHandling()
        }
    }

    // MARK: - User actions
    
    @IBAction
    func sendAction(sender: AnyObject)
    {
        if let text = inputTextView.text
        {
            let trimmedText = text.stringByTrimmingCharactersInSet(
                NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if countElements(trimmedText) > 0
            {
                sendMessage(trimmedText)
                { (success: Bool) -> Void in
                    if success
                    {
                        self.inputTextView.text = ""
                        self.inputTextView.resignFirstResponder()
                        
                        self.tableView.reloadData()
                    }
                    else
                    {
                        println("Error while sending message")
                        // TODO: handle error appropriately
                    }
                }
            }
            else
            {
                inputTextView.resignFirstResponder()
            }
        }
        else
        {
            inputTextView.resignFirstResponder()
        }
    }
}

// MARK: - UITableViewDataSourse

extension ChatViewController: UITableViewDataSource
{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return countElements(messages)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cellId: String! = nil

        let currentUser = PFUser.currentUser()!
        let message = messages[indexPath.row]
        if message.sender == currentUser
        {
            cellId = CellReuseIdentifier.MyCell.rawValue
        }
        else
        {
            cellId = CellReuseIdentifier.InterlocutorCell.rawValue
        }

        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as ChatCell
        cell.senderAndTimeLabel.text = message.sender.username
        cell.messageLabel.text = message.body

        return cell
    }
}

// MARK: - Private

private
extension ChatViewController
{
    func setupTableView()
    {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 78.0
    }
    
    func fetchHistory()
    {
        let me = PFUser.currentUser()
        
        let query = Message.query()
        query.whereKey(Message.AssociatedKeys.Receiver.rawValue, containedIn: [me!, interlocutor!])
        query.whereKey(Message.AssociatedKeys.Sender.rawValue, containedIn: [me!, interlocutor!])
        query.findObjectsInBackgroundWithBlock(
        { (objects: [AnyObject]!, error: NSError!) -> Void in
            if error != nil
            {
                println("Error fetching messages: \(error)")
            }
            else
            {
                if var objects = objects as? [Message]
                {
                    println("Objects: \(objects)")
                    
                    objects.sort(
                        {$0.createdAt.compare($1.createdAt) == NSComparisonResult.OrderedAscending})
                    self.messages = objects
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    func sendMessage(text: String, _ handler: (success: Bool) -> Void)
    {
        let me = PFUser.currentUser()
        let message = Message(text, sender: me, receiver: interlocutor)

        message.saveInBackgroundWithBlock()
        { (success: Bool, error: NSError!) in
            self.messages.append(message)
            handler(success: true)
        }
    }
}
