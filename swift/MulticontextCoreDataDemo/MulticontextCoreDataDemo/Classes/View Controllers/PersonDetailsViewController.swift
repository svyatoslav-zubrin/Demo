//
//  PersonDetailsViewController.swift
//  MulticontextCoreDataDemo
//
//  Created by zubrin on 10/17/14.
//  Copyright (c) 2014 ___ZUBRIN___. All rights reserved.
//

import UIKit

class PersonDetailsViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    
    // MARK: - User actions

    @IBAction func createAction(sender: AnyObject) {
        if isFormValid() {
            let name = nameTextField.text
            let surname = surnameTextField.text
            createPerson(name: name, surname: surname)
            self.navigationController?.popViewControllerAnimated(true)
            
        } else {
            let alert = UIAlertController(title: "Error", message: "Check entered data, please.", preferredStyle: .Alert)
            let okTitle = "OK"
            let okAction = UIAlertAction(title: okTitle, style: UIAlertActionStyle.Default, handler: { action -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
                
            })
            alert.addAction(okAction)

            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
}

// MARK: - Private

private extension PersonDetailsViewController {
    
    func isFormValid() -> Bool {
        if let name = nameTextField.text {
            if let surname = surnameTextField.text {
                if !name.isEmpty && !surname.isEmpty {
                    return true
                }
            }
        }
        return false
    }
    
    func createPerson(#name: String, surname: String) {
        Person.save(name: name, surname: surname)
    }
}
