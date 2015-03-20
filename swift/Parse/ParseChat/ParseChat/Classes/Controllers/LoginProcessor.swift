//
//  LoginProcessor.swift
//  ParseChat
//
//  Created by Slava Zubrin on 3/19/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import Foundation

enum LoginProcessorError
{
    case InvalidData
    case Cancelled
    case Undefined
}

protocol LoginProcessorDelegate
{
    func loginFinished(success:  Bool, user: PFUser?, error: LoginProcessorError?) -> Void
    func signupFinished(success: Bool, user: PFUser?, error: LoginProcessorError?) -> Void
    func logoutFinished(success: Bool, error: LoginProcessorError?) -> Void
}

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
    
    var delegate: LoginProcessorDelegate? = nil
    
    // MARK: - Public

    func startLoginProcessFrom(controller: UIViewController)
    {
        let loginVC = LoginViewController()
        loginVC.delegate = self
        
        let signupVC = SignupViewController()
        signupVC.delegate = self
        
        loginVC.signUpController = signupVC
        
        controller.presentViewController(loginVC, animated: true, completion: nil)
    }
    
    func startLogoutProcess()
    {
        PFUser.logOut()
        
        if let d = delegate {
            d.logoutFinished(true, error: nil)
        }
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
        if let d = delegate {
            d.loginFinished(false, user: nil, error: LoginProcessorError.InvalidData)
        }

        return false; // Interrupt login process
    }
    
    func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController!)
    {
        if let d = delegate {
            d.loginFinished(false, user: nil, error: LoginProcessorError.Cancelled)
        }
    }
    
    func logInViewController(logInController: PFLogInViewController!,
        didFailToLogInWithError error: NSError!)
    {
        if let d = delegate {
            d.loginFinished(false, user: nil, error: LoginProcessorError.Undefined)
        }
        println("Something goes wrong with login: \(error.localizedDescription)")
    }
    
    func logInViewController(logInController: PFLogInViewController!,
        didLogInUser user: PFUser!)
    {
        if let d = delegate {
            d.loginFinished(true, user: user, error: nil)
        }
    }
}

// MARK: - PFSignUpViewControllerDelegate

extension LoginProcessor : PFSignUpViewControllerDelegate
{
    func signUpViewController(signUpController: PFSignUpViewController!,
        shouldBeginSignUp info: [NSObject : AnyObject]!) -> Bool
    {
        var isInformationComplete = true
        
        // loop through all of the submitted data
        for (key, value) in info
        {
            let v = value as? String
            if v == nil || countElements(v!) <= 0
            {
                isInformationComplete = false
                break
            }
        }
        
        // Display an alert if a field wasn't completed
        if isInformationComplete == false
        {
            if let d = delegate {
                d.signupFinished(false, user: nil, error: LoginProcessorError.InvalidData)
            }
            println("Missing Information: make sure you fill out all of the information!")
        }
        
        return isInformationComplete;
    }
    
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController!)
    {
        if let d = delegate {
            d.signupFinished(false, user: nil, error: LoginProcessorError.Cancelled)
        }
    }
    
    func signUpViewController(signUpController: PFSignUpViewController!,
        didFailToSignUpWithError error: NSError!)
    {
        if let d = delegate {
            d.signupFinished(false, user: nil, error: LoginProcessorError.Undefined)
        }
        println("Something goes wrong with signup: \(error.localizedDescription)")
    }
    
    func signUpViewController(signUpController: PFSignUpViewController!,
        didSignUpUser user: PFUser!)
    {
        if let d = delegate {
            d.signupFinished(true, user: user, error: nil)
        }
    }
}


