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
    
    var imageMaker = ImageMaker()
    
    // MARK: - View lifecycle
    
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

    // MARK: - User actions
    
    @IBAction func avatarAction(sender: UIButton)
    {
        imageMaker.getPhotoFrom(self, handler:
        { (success: Bool, image: UIImage?) -> Void in
            if let i = image
            {
                self.avatarImageView.image = i
            }
            
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
}

// MARK: - Private

private extension UserProfileViewController
{
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
