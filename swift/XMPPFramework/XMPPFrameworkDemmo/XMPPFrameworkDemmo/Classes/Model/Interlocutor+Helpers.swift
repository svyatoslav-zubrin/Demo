//
// Created by Slava Zubrin on 3/4/15.
// Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import Foundation

extension Interlocutor
{
    func isBare() -> Bool
    {
        return countElements(bareName) > 0
    }
}