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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // DEBUG
        usernameTextField.text = "user1@szmini.local"
        passwordTextField.text = "password"
        hostNameTextField.text = "szmini.local"
        hostPortTextField.text = "5222"
        serviceTypePicker.selectRow(ServiceType.Local.rawValue, inComponent: 0, animated: true)
    }
    
    // MARK: - User actions
    
    @IBAction func saveAction(sender: UIBarButtonItem)
    {
        if isFormValid
        {
            var service: Service? = nil
            let selectedServiceTypeIndex = serviceTypePicker.selectedRowInComponent(0)
            if  selectedServiceTypeIndex == ServiceType.Custom.rawValue {
                service = Service(type: ServiceType(rawValue: selectedServiceTypeIndex)!)
            } else {
                let hostName = hostNameTextField.text
                let hostPort = hostPortTextField.text.toInt()!
                service = Service(hostName: hostName)//, hostPort: hostPort)
            }
            
            let userId = usernameTextField.text
            let userPassword = passwordTextField.text
            var acc = Account(userIdentifier: userId, password: userPassword, service: service!)
            
            UserSettings.sharedInstance.addAccount(acc)
            
            self.navigationController?.popViewControllerAnimated(true)
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
