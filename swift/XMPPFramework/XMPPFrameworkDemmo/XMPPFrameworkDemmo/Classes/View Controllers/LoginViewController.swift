//
//  LoginViewController.swift
//  XMPPFrameworkDemmo
//
//  Created by Slava Zubrin on 2/16/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController
{
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var hostNameTextField: UITextField!
    @IBOutlet weak var hostPortTextField: UITextField!
    @IBOutlet weak var serviceTypePicker: UIPickerView!
    
    private var account: Account?
    private var isPreview: Bool = false
    
    private var isFormValid: Bool
    {
        var isUserCredentialsValid = true
        if usernameTextField.text.isEmpty
        && passwordTextField.text.isEmpty
        {
            isUserCredentialsValid = false
        }
        
        var isServiceValid = true
        if isUserCredentialsValid == true
        {
            let selection = serviceTypePicker.selectedRowInComponent(0)
            if selection != -1
            {
                if ServiceType(rawValue: selection) == ServiceType.Custom
                {
                    if hostNameTextField.text.isEmpty
                    && hostPortTextField.text.isEmpty
                    {
                        isServiceValid = false
                    }
                }
            }
        }
        
        return isUserCredentialsValid && isServiceValid
    }
    
    // MARK: - Lifecycle
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)

        // DEBUG
        usernameTextField.text = "zubrin@jabber.qarea.org"
        passwordTextField.text = "qarea3ub"
        hostNameTextField.text = "jabber.qarea.org"
        hostPortTextField.text = "5222"
        serviceTypePicker.selectRow(ServiceType.QArea.rawValue, inComponent: 0, animated: true)
    }
    
    // MARK: - User actions
    
    @IBAction func saveAction(sender: UIBarButtonItem)
    {
        if isFormValid
        {
            MagicalRecord.saveWithBlock(
                { (context: NSManagedObjectContext!) -> Void in
                    
                    // account
                    let account = Account.MR_createInContext(context) as Account
                    
                    let selectedServiceTypeIndex = self.serviceTypePicker.selectedRowInComponent(0)
                    account.serviceType = selectedServiceTypeIndex
                    if  selectedServiceTypeIndex == ServiceType.Custom.rawValue
                    {
                        account.hostName = self.hostNameTextField.text
                        account.hostPort = self.hostPortTextField.text.toInt()!
                    }
                    else
                    {
                        if let service = ServiceType(rawValue: selectedServiceTypeIndex)
                        {
                            account.hostName = service.defaultHostParameters.name
                            account.hostPort = service.defaultHostParameters.port
                        }
                    }
                    
                    let userId = self.usernameTextField.text
                    let userPassword = self.passwordTextField.text
                    account.userId = userId
                    account.password = userPassword
                    
                    // me
                    let me = Interlocutor(name: "Me",
                        bareName: userId,
                        group: nil,
                        account: account,
                        inManagedObjectContext: context)
                    account.me = me
                },
                completion:
                { (success: Bool, error: NSError!) -> Void in
                    if success
                    {
//                        UserSettings.sharedInstance.addAccount(account)
                    }
                    else
                    {
                        println("Error saving account to the local DB: \(error)")
                        // TODO: inform user about error
                    }
                    
                    self.navigationController?.popViewControllerAnimated(true)
                }
            )
        }
        else
        {
            let alert = UIAlertController(title: "Form is not valid",
                message: "Please, check if all needed fields are filled correctly and try to save the account again",
                preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK",
                style: UIAlertActionStyle.Cancel,
                handler: nil)
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Public
    
    func previewModeForAccount(_account: Account)
    {
        isPreview = true
        account = _account
    }
}

extension LoginViewController: UIPickerViewDataSource
{
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return ServiceType.count()
    }
    
    func pickerView(pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int) -> String!
    {
        return ServiceType(rawValue: row)?.toString()
    }
}

extension LoginViewController: UIPickerViewDelegate
{
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        let selectedServiceType = ServiceType(rawValue: row)
        
        let usePredefinedHost = row != ServiceType.Custom.rawValue
        hostNameTextField.enabled = !usePredefinedHost
        hostPortTextField.enabled = !usePredefinedHost
        
        if usePredefinedHost
        {
            hostPortTextField.text = "\(selectedServiceType!.defaultHostParameters.port)"
            hostNameTextField.text = selectedServiceType!.defaultHostParameters.name
        }
    }
}
