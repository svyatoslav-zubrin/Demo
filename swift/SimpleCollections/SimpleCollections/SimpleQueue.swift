//
//  SimpleQueue.swift
//  SimpleCollections
//
//  Created by Slava Zubrin on 2/22/15.
//  Copyright (c) 2015 com.home. All rights reserved.
//

import Foundation

// MARK: - Simple queue unterface

protocol SimpleQueue {
    typealias Item
    
    func enqueue(item: Item)
    func dequeue() -> Item?
    func isEmpty() -> Bool
    func size() -> Int
}

// MARK: - Queue based on immutable array -

class QueueBasedOnArray<Item> : SimpleQueue {
    
    private var container: Array<Item?>
    private var first: Int = 0
    private var last : Int = -1
    
    init() {
        container = Array<Item?>(count:2, repeatedValue: nil)
    }
    
    // MARK: SimpleQueue conformance
    
    func enqueue(item: Item) {
        if elementsNumber == container.count { resize(2 * container.count) }
        
        // simply shift all data to the beginning of the array if needed
        if last == container.count - 1 { resize(container.count) }

        last++
        container[last] = item
    }
    
    func dequeue() -> Item? {
        let item = container[first]
        first++
        return item
    }
    
    func isEmpty() -> Bool {
        return first > last
    }
    
    func size() -> Int {
        return elementsNumber
    }
    
    // MARK: Private
        
    private var elementsNumber : Int {
        return last - first + 1
    }

    private func resize(newSize: Int) {
        var newContainer = Array<Item?>(count: newSize, repeatedValue: nil)
        var j: Int = 0
        for i in first...last {
            newContainer[j] = container[i]
            j++
        }
        first = 0
        last  = j-1
        
        container = newContainer
    }
}

// MARK: - Queue based on linked list -

class QueueBasedOnLinkedList<Item> : SimpleQueue {
    
    private var first: Node<Item>? = nil // pointer to first object in queue
    private var last : Node<Item>? = nil // pointer to the last object in queue
    private var N: Int = 0 // number of objects in queue
    
    // MARK: SimpleQueue conformance
    
    func enqueue(item: Item) {
        let oldLast = last
        let node = Node(value: item)
        last = node
        if isEmpty() {
            first = last
        } else {
            oldLast!.next = last
        }
        N++
    }
    
    func dequeue() -> Item? {
        if isEmpty() { return nil }
        
        let item = first!.value
        first = first!.next
        if isEmpty() { last = nil }
        
        return item
    }
    
    func isEmpty() -> Bool {
        return first == nil
    }
    
    func size() -> Int {
        return N
    }
}

// MARK: Linked List Helpers

class Node<Item> {
    let value: Item
    var next: Node? = nil

    init(value _value: Item, next _next: Node?) {
        value = _value
        next = _next
    }

    convenience init(value _value: Item) {
        self.init(value: _value, next: nil)
    }
    
    func hasNext() -> Bool {
        return next != nil
    }
}

