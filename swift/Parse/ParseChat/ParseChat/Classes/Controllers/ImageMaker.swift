//
//  ImageMaker.swift
//  ParseChat
//
//  Created by Slava Zubrin on 3/20/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import Foundation

typealias ImageMakerHandler = (success: Bool, image: UIImage?) -> Void

class ImageMaker: NSObject
{
    var imageMakerHandler: ImageMakerHandler? = nil
    
    func getPhotoFrom(controller: UIViewController, handler: ImageMakerHandler)
    {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        imageMakerHandler = handler
        
        controller.presentViewController(imagePicker, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ImageMaker: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        if let handler = imageMakerHandler
        {
            handler(success: false, image: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController!,
        didFinishPickingImage image: UIImage!,
        editingInfo: [NSObject : AnyObject]!)
    {
        if let handler = imageMakerHandler
        {
            handler(success: true, image: image)
        }
    }
}