//
//  ContactsViewController.swift
//  ParseChat
//
//  Created by Slava Zubrin on 3/19/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit

class ContactsViewController: PFQueryTableViewController
{
    @IBOutlet weak var logoutBBI: UIBarButtonItem!
    
    // MARK: - Initialization
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup()
    {
        textKey = "username"
        pullToRefreshEnabled = true
        paginationEnabled = true
        objectsPerPage = 25
    }
    
    // MARK: - View lifecycle
    
    override func viewDidAppear(animated: Bool)
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
    
    @IBAction func debugAction(sender: UIButton)
    {
        let query = PFUser.query()
        query.findObjectsInBackgroundWithBlock(
        { (users: [AnyObject]!, error: NSError!) -> Void in
            println("\(users.count) users found")
        })
    }
    
    @IBAction func LogoutAction(sender: UIButton)
    {
        LoginProcessor.sharedInstance.delegate = self
        LoginProcessor.sharedInstance.startLogoutProcess()
    }
}

// MARK: - PFQueryTableViewController

extension ContactsViewController
{
    override func queryForTable() -> PFQuery!
    {
        super.queryForTable()
        
        let query = PFUser.query()
        query.whereKey("username", notEqualTo: PFUser.currentUser().username)
        
        return query
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
        
        LoginProcessor.sharedInstance.delegate = self
        LoginProcessor.sharedInstance.startLoginProcessFrom(self)
    }
}

// MARK: - Private

private
extension ContactsViewController
{
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

