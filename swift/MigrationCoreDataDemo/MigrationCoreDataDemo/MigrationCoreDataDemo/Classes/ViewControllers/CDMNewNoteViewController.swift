//
//  CDMNewNoteViewController.swift
//  MigrationCoreDataDemo
//
//  Created by Slava Zubrin on 11/1/14.
//  Copyright (c) 2014 zubrin. All rights reserved.
//

import UIKit
import CoreData


class CDMNewNoteViewController
    : UIViewController
    , UINavigationControllerDelegate
    , UIImagePickerControllerDelegate
{
    // MARK: - Properties

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var imageButton: UIButton!
    
    var selectedImage: UIImage? = nil
    
    // MARK: - View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - User actions
    
    @IBAction func saveAction(sender: AnyObject)
    {
        if self.validateForm()
        {
            self.createNewNote()
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func selectImage(sender: AnyObject)
    {
        self.presentImagePicker()
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController!,
                               didFinishPickingImage image: UIImage!,
                               editingInfo: [NSObject : AnyObject]!)
    {
        self.selectedImage = image
        self.imageButton.setBackgroundImage(self.selectedImage, forState: UIControlState.Normal)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

// MARK: - Private -

private extension CDMNewNoteViewController
{
    
    func validateForm() -> Bool
    {
        return !self.titleTextField.text.isEmpty && !self.bodyTextView.text.isEmpty
    }
    
    func createNewNote()
    {
        let moc = CDMCoreDataManager.sharedManager.moc!
        
        let noteDesc = NSEntityDescription.entityForName("Note", inManagedObjectContext: moc)
        let note = Note(entity: noteDesc!, insertIntoManagedObjectContext: moc)
        note.title = self.titleTextField.text
        note.body  = self.bodyTextView.text
        note.dateCreated = NSDate()
        if let image = self.selectedImage
        {
            note.image = image
        }
        
        CDMCoreDataManager.sharedManager.saveContext()
    }
    
    func presentImagePicker()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)
        {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.delegate = self
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert = UIAlertController(title: "Sorry...", message: "The photo library unavailable", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}