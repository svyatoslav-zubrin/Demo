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
    @IBOutlet weak var hostNameTextField: UITextField!
    @IBOutlet weak var hostPortTextField: UITextField!
    @IBOutlet weak var serviceTypePicker: UIPickerView!
    
    private var account: Account?
    private var isPreview: Bool = false
    
    private var isFormValid: Bool {
        // TODO: implementation needed
        return false
    }
    
    // MARK: - User actions
    
    @IBAction func loginAction(sender: UIButton) {
        
        if isFormValid {
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

            // TODO: the work was stopped here...
            
//            self.navigationController?.popViewControllerAnimated(true)
        } else {
            // TODO: inform user about error with an alert
            println("Form is not filled correctly")
        }
    }
    
    // MARK: - Public
    
    func previewModeForAccount(_account: Account) {
        isPreview = true
        account = _account
    }
}

extension LoginViewController: UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ServiceType.count()
    }
    
    func pickerView(pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int) -> String!
    {
        return "xxx"
    }
}
