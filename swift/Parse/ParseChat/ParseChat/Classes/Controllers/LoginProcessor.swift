//
//  LoginProcessor.swift
//  ParseChat
//
//  Created by Slava Zubrin on 3/19/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import Foundation

class LoginProcessor: NSObject
{
    // MARK: - Singleton
    
    class var sharedInstance : LoginProcessor {
        struct Static {
            static let instance : LoginProcessor = LoginProcessor()
        }
        return Static.instance
    }
 
    // MARK - Properties
    
    private var loginEntryController: UIViewController! = nil
    
    // MARK: - Public

    func startLoginProcessFrom(controller: UIViewController)
    {
        let loginVC = PFLogInViewController()
        loginVC.logInView.logo = nil
        loginVC.delegate = self
        
        let signupVC = PFSignUpViewController()
        signupVC.signUpView.logo = nil
        signupVC.delegate = self
        
        loginVC.signUpController = signupVC
        
        loginEntryController = controller
        loginEntryController.presentViewController(loginVC, animated: true, completion: nil)
    }
}

// MARK: - PFLogInViewControllerDelegate

extension LoginProcessor : PFLogInViewControllerDelegate
{
    func logInViewController(logInController: PFLogInViewController!,
        shouldBeginLogInWithUsername username: String!,
        password: String!) -> Bool
    {
        if username != nil
        && password != nil
        && countElements(username) > 0
        && countElements(password!) > 0
        {
            return true; // Begin login process
        }
        
        // TODO: inform user that some information is missing
        println("Some user info is missing")

        return false; // Interrupt login process
    }
    
    func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController!)
    {
        loginEntryController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logInViewController(logInController: PFLogInViewController!,
        didFailToLogInWithError error: NSError!)
    {
        // TODO: inform user that something goes wrong with login process
        println("Something goes wrong with login: \(error.localizedDescription)")
    }
    
    func logInViewController(logInController: PFLogInViewController!,
        didLogInUser user: PFUser!)
    {
        loginEntryController.dismissViewControllerAnimated(true, completion:
        { () -> Void in
            self.loginEntryController = nil
        })
    }
}

// MARK: - PFSignUpViewControllerDelegate

extension LoginProcessor : PFSignUpViewControllerDelegate
{
    
}


