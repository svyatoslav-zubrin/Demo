//
//  main.swift
//  SimpleCollections
//
//  Created by Slava Zubrin on 2/22/15.
//  Copyright (c) 2015 com.home. All rights reserved.
//

import Foundation

println("Hello, World!")

var queue: QueueBasedOnLinkedList<Int>? = QueueBasedOnLinkedList<Int>()

if let q = queue {
    q.enqueue(6)
    q.enqueue(7)
    
    println(q.dequeue() != nil ? "not nil" : "nil")
}