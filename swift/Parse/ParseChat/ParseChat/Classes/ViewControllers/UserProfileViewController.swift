//
//  UserProfileViewController.swift
//  ParseChat
//
//  Created by Slava Zubrin on 3/20/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override
    func viewDidLoad()
    {
        super.viewDidLoad()
        
    }
    
    override
    func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
    
        setup()
    }

    private
    func setup()
    {
        if let user = PFUser.currentUser()
        {
            usernameLabel.text = user.username
        }
        else
        {
            usernameLabel.text = ""
        }
    }
}
