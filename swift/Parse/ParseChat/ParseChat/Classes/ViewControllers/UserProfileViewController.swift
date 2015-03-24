//
//  UserProfileViewController.swift
//  ParseChat
//
//  Created by Slava Zubrin on 3/20/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit
import ParseUI

class UserProfileViewController: UIViewController
{
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
    
    @IBAction
    func avatarAction(sender: UIButton)
    {
        imageMaker.getPhotoFrom(self, handler:
        { (success: Bool, image: UIImage?) -> Void in
            if let i = image
            {
                let imageFile = PFFile(name: "avatar.png", data: UIImagePNGRepresentation(i))
                imageFile.saveInBackgroundWithBlock(
                { (succeeded: Bool, error: NSError!) -> Void in
                    if succeeded && error == nil
                    {
                        let user = PFUser.currentUser()
                        user.avatar = imageFile
                        user.saveInBackgroundWithBlock(
                        { (succeeded: Bool, error: NSError!) -> Void in
                            self.avatarImageView.image = i
                        })
                    }
                    else
                    {
                        println("Wrong file uploading: \(error.localizedDescription)")
                    }
                })
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
}

// MARK: - Private

private
extension UserProfileViewController
{
    func setup()
    {
        if let user = PFUser.currentUser()
        {
            usernameLabel.text = user.username
            let user = PFUser.currentUser()
            if let avatarUrlString = user.avatarURL
            {
                if let url = NSURL(string: avatarUrlString)
                {
                    if let data = NSData(contentsOfURL: url)
                    {
                        avatarImageView.image = UIImage(data: data)
                    }
                }
            }
            else
            {
                println("User doesn't have avatar_url parameter")
                avatarImageView.image = UIImage(named: "Profile.png")
            }
        }
        else
        {
            usernameLabel.text = ""
            avatarImageView.image = UIImage(named: "Profile.png")
        }
    }
}
