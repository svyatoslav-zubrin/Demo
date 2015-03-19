//
//  ContactsViewController.swift
//  ParseChat
//
//  Created by Slava Zubrin on 3/19/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit
import Parse

class ContactsViewController: UIViewController
{
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)

        if PFUser.currentUser() == nil
        {
            LoginProcessor.sharedInstance.startLoginProcessFrom(self)
        }
    }
}

// MARK: - Private

private
extension ContactsViewController
{

}

