//
// Created by Slava Zubrin on 3/23/15.
// Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import Foundation
import Parse.PFUser
import Parse.PFFile

extension PFUser
{
    private enum AssociatedKeys: String
    {
        case Avatar = "avatar"
        case AvatarURL = "avatar_URL"
        case Messages = "messages"
    }

    // MARK: - Avatar

    var avatar: PFFile?
    {
        set
        {
            let currentUser: PFUser! = PFUser.currentUser()

            println("Current user for avatar: \(currentUser), \(self)")

            assert(currentUser != nil,  "There is no logged in user to set avatar")
            assert(currentUser == self, "You can't set avatar for any user except logged in")

            currentUser[AssociatedKeys.Avatar.rawValue] = newValue

            if let value = newValue
            {
                if let url = value.url
                {
                    currentUser[AssociatedKeys.AvatarURL.rawValue] = url
                }
                else
                {
                    currentUser[AssociatedKeys.AvatarURL.rawValue] = nil
                }
            }
            else
            {
                currentUser[AssociatedKeys.AvatarURL.rawValue] = nil
            }
        }

        get
        {
            return self[AssociatedKeys.Avatar.rawValue] as? PFFile
        }
    }

    var avatarURL: String?
    {
        set
        {
            let currentUser: PFUser! = PFUser.currentUser()

            println("Current user for avatar: \(currentUser), \(self)")

            assert(currentUser != nil,  "There is no logged in user to set avatar's url")
            assert(currentUser == self, "You can't set avatar's url for any user except logged in")

            currentUser[AssociatedKeys.AvatarURL.rawValue] = newValue
        }
        get
        {
            return self[AssociatedKeys.AvatarURL.rawValue] as? String
        }
    }

//    // MARK: - Messages
//
//    private(set) var messages: [Message]?
//    {
//        set
//        {
//            self[AssociatedKeys.Messages.rawValue] = messages
//        }
//
//        get
//        {
//            return self[AssociatedKeys.Messages.rawValue] as? [Message]
//        }
//    }
//
//    func addMessage(message: Message)
//    {
//        if let messages = self.messages
//        {
//            messages.append(message)
//        }
//        else
//        {
//            self.messages = [message]
//        }
//    }
}