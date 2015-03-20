//
//  LoginViewController.swift
//  ParseChat
//
//  Created by Slava Zubrin on 3/20/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import Foundation

class LoginViewController: PFLogInViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let logoImage = UIImage(named: "Logo.jpg")
        self.logInView.logo = UIImageView(image: logoImage!)
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        let logoImage = UIImage(named: "Logo.jpg")
        let windowSize = UIApplication.sharedApplication().windows.first!.size!
        self.logInView.logo.frame = CGRectMake(
            (windowSize.width - logoImage!.size.width) / 2,
            20,
            logoImage!.size.width,
            logoImage!.size.height)
    }
}