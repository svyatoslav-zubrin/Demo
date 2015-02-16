//
//  LoginViewController.swift
//  XMPPFrameworkDemmo
//
//  Created by Slava Zubrin on 2/16/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - User actions
    
    @IBAction func loginAction(sender: UIButton) {
        UserSettings.sharedInstance.userId = usernameTextField.text
        UserSettings.sharedInstance.userPassword = passwordTextField.text
        
        self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            // do nothing
        })
    }
}
