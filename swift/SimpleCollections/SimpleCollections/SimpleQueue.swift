//
//  SimpleQueue.swift
//  SimpleCollections
//
//  Created by Slava Zubrin on 2/22/15.
//  Copyright (c) 2015 com.home. All rights reserved.
//

import Foundation

protocol SimpleQueue<Item> {
    func enqueue(item: Item)
    func dequeue() -> Item?
}


class QueueBasedOnArray<Item> {
    
    private let contaner: Array<Item>?
    
    func enqueue(item: Item) {
        
    }
    
    func dequeue(item: Item) {
        
    }
}

class QueueBasedOnLinkedList {
    
}