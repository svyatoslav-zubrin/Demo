//
//  SimpleQueue.swift
//  SimpleCollections
//
//  Created by Slava Zubrin on 2/22/15.
//  Copyright (c) 2015 com.home. All rights reserved.
//

import Foundation

protocol SimpleQueue {
    typealias Item
    
    func enqueue(item: Item)
    func dequeue() -> Item?
}

// MARK: - Queue based on immutable array

class QueueBasedOnArray<Item> {
    
    private var contaner: Array<Item>?
    
    init() {
        contaner = [Item]()
    }
    
    func enqueue(item: Item) {
        
    }
    
    func dequeue() -> Item? {
        return nil
    }
}

// MARK: - Queue based on linked list

class QueueBasedOnLinkedList<Item> {
    
    private var contaner: [Item]?
    
    init() {
        // TODO: incorrect implementation
        contaner = [Item]()
    }
    
    func enqueue(item: Item) {
        
    }
    
    func dequeue() -> Item? {
        return nil
    }
}

// MARK: Linked List Helpers

class Node<Item> {
    let value: Item
    var next: Node?
    
    init(value _value: Item, next _next: Node?) {
        value = _value
        next = _next
    }
    
    func hasNext() -> Bool {
        return next != nil
    }
}

