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
        // TODO: debug code...

        let me = PFUser.currentUser()

        let m1 = Message("Message from other user", sender: interlocutor, receiver: me)
        let m2 = Message("There should be another very long message from other user. Probably he wants to explain something and make it obvious to me.", sender: interlocutor, receiver: me)
        let m3 = Message("And here is my answer: got it, OK.", sender: me, receiver: interlocutor)

        messages.append(m1)
        messages.append(m2)
        messages.append(m3)
    }
    
    func sendMessage(_ text: String, _ handler: (success: Bool) -> Void)
    {
        println("send message: \(text)")
        
        // TODO: send message
        
        handler(success: true)
    }
}
