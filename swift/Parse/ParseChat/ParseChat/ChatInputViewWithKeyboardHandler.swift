//
// Created by Slava Zubrin on 3/25/15.
// Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit

class ChatInputViewWithKeyboardHandler: NSObject
{
    @IBOutlet weak var chatInputView: ChatInputView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    func registerForKeyboardHandling()
    {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "handleKeyboardWillShow:",
            name: UIKeyboardWillShowNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "handleKeyboardWillHide:",
            name: UIKeyboardWillHideNotification,
            object: nil)
    }

    func unregisterFromKeyboardHandling()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
        
    func handleKeyboardWillShow(notification: NSNotification)
    {
        println("handleKeyboardWillShow called")
        
        if chatInputView == nil || bottomConstraint == nil
        {
            return
        }

        if let info = notification.userInfo
        {
            if let kbSizeValue = info[UIKeyboardFrameBeginUserInfoKey] as? NSValue
            {
                var animationDuration = 0.3
                if let duration = info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber
                {
                    animationDuration = duration.doubleValue
                }
                
                let kbSize = kbSizeValue.CGRectValue()
                bottomConstraint.constant += kbSize.height
                UIView.animateWithDuration(animationDuration, animations:
                { () -> Void in
                    self.chatInputView.layoutIfNeeded()
                })
            }
        }
    }
    
    func handleKeyboardWillHide(notification: NSNotification)
    {
        println("handleKeyboardWillHide called")

        if chatInputView == nil || bottomConstraint == nil
        {
            return
        }
        
        if let info = notification.userInfo
        {
            if let kbSizeValue = info[UIKeyboardFrameBeginUserInfoKey] as? NSValue
            {
                var animationDuration = 0.3
                if let duration = info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber
                {
                    animationDuration = duration.doubleValue
                }
                
                let kbSize = kbSizeValue.CGRectValue()
                bottomConstraint.constant -= kbSize.height
                UIView.animateWithDuration(animationDuration, animations:
                    { () -> Void in
                        self.chatInputView.layoutIfNeeded()
                })
            }
        }
    }
}
