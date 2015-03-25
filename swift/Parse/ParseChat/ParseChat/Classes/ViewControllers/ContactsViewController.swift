//
//  ContactsViewController.swift
//  ParseChat
//
//  Created by Slava Zubrin on 3/19/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit
import ParseUI

class ContactsViewController: PFQueryTableViewController
{
 
    private enum SegueIdentifiers: String
    {
        case SEGUE_CONTACTS_TO_CHAT = "ContactsToChatSegue"
    }
    
    //
    
    @IBOutlet weak var revealButton: UIButton!
    @IBOutlet weak var logoutBBI: UIBarButtonItem!
    
    private var userSelectedForChat: PFUser? = nil

    // MARK: - Initialization

    required
    init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }

    private
    func setup()
    {
        parseClassName = "User"
        textKey = "username"
        imageKey = "avatar"
        placeholderImage = UIImage(named: "Profile.png")
        pullToRefreshEnabled = true
        paginationEnabled = true
        objectsPerPage = 25
    }

    // MARK: - View lifecycle

    override
    func viewDidLoad()
    {
        super.viewDidLoad()

        tuneRevealControllerInteraction()
    }

    override
    func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)

        if PFUser.currentUser() == nil
        {
            LoginProcessor.sharedInstance.delegate = self
            LoginProcessor.sharedInstance.startLoginProcessFrom(self)

            logoutBBI.enabled = false
        }
        else
        {
            logoutBBI.enabled = true
        }
    }

    // MARK: - User actions

    @IBAction
    func LogoutAction(sender: UIButton)
    {
        LoginProcessor.sharedInstance.delegate = self
        LoginProcessor.sharedInstance.startLogoutProcess()
    }
    
    // MARK: - Navigation
    
    override
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == SegueIdentifiers.SEGUE_CONTACTS_TO_CHAT.rawValue
        {
            if let dvc = segue.destinationViewController as? ChatViewController
            {
                dvc.interlocutor = userSelectedForChat
            }
        }
    }
}

// MARK: - PFQueryTableViewController

extension ContactsViewController
{
    override
    func queryForTable() -> PFQuery!
    {
        super.queryForTable()

        println("queryForTable called")

        let currentUser = PFUser.currentUser()
        if currentUser == nil
        {
            return nil
        }

        let query = PFUser.query()
        query.whereKey("username", notEqualTo: PFUser.currentUser().username)

        return query
    }
    
    override
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        userSelectedForChat = objects[indexPath.row] as? PFUser
        
        self.performSegueWithIdentifier(
            SegueIdentifiers.SEGUE_CONTACTS_TO_CHAT.rawValue,
            sender: self)
    }
}

// MARK: - LoginProcessorDelegate

extension ContactsViewController: LoginProcessorDelegate
{
    func loginFinished(success: Bool, user: PFUser?, error: LoginProcessorError?)
    {
        handleAuthorizationFinish(success, user: user, error: error)
    }

    func signupFinished(success: Bool, user: PFUser?, error: LoginProcessorError?)
    {
        handleAuthorizationFinish(success, user: user, error: error)
    }

    func logoutFinished(success: Bool, error: LoginProcessorError?)
    {
        logoutBBI.enabled = !success

        clear()

        LoginProcessor.sharedInstance.delegate = self
        LoginProcessor.sharedInstance.startLoginProcessFrom(self)
    }
}

// MARK: - Private

private
extension ContactsViewController
{
    func tuneRevealControllerInteraction()
    {
        if self.revealViewController() != nil
        {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            revealButton.addTarget(self.revealViewController(),
                                   action: "revealToggle:",
                                   forControlEvents: UIControlEvents.TouchUpInside)
        }
    }

    func handleAuthorizationFinish(success: Bool, user: PFUser?, error: LoginProcessorError?)
    {
        if success == true
        {
            logoutBBI.enabled = true
            dismissViewControllerAnimated(true, completion:
            { () -> Void in
                self.loadObjects()
            })
        }
        else
        {
            switch error!
            {
                case LoginProcessorError.InvalidData:
                    println("invalid data provided...")
                case LoginProcessorError.Cancelled:
                    println("login process canceled")
                default:
                    println("unknown error during signup")
            }
        }
    }
}

