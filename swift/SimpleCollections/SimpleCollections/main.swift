//
//  main.swift
//  SimpleCollections
//
//  Created by Slava Zubrin on 2/22/15.
//  Copyright (c) 2015 com.home. All rights reserved.
//

import Foundation

println("Hello, World!")

func testQueueBasedOnLinkedList() {
    var queue: QueueBasedOnLinkedList<Int>? = QueueBasedOnLinkedList<Int>()

    if let q = queue {
        q.enqueue(6)
        q.enqueue(7)
        q.enqueue(8)
        
        if let value = q.dequeue() {
            println(value)
        } else {
            println("empty queue")
        }
    }
}

func testQueueBasedOnArray() {
    var queue: QueueBasedOnArray<Int>? = QueueBasedOnArray<Int>()
    
    if let q = queue {
        q.enqueue(6)
        q.enqueue(7)
        q.enqueue(8)
        
        q.dequeue()
        q.dequeue()
        if let value = q.dequeue() {
            println(value)
        } else {
            println("empty queue")
        }
    }
}

testQueueBasedOnArray()