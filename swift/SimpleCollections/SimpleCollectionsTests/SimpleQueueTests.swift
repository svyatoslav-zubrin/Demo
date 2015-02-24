//
//  SimpleQueueTests.swift
//  SimpleCollections
//
//  Created by Slava Zubrin on 2/24/15.
//  Copyright (c) 2015 com.home. All rights reserved.
//

import Cocoa
import XCTest

class SimpleQueueTests: XCTestCase {
   
    // MARK: - Prepare test environment
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - Queue based on linked list
    
    func testEnqueueOperationForQueueBasedOnLinkedList() {
        
        let q = QueueBasedOnLinkedList<Int>()
        
        q.enqueue(6)
        q.enqueue(7)
        q.enqueue(8)
        
        q.dequeue()
        q.dequeue()
        let res = q.dequeue()
        
        XCTAssertEqual(res!, 8, "Incorrect enqueue/dequeue operations for queue based on linked list")
    }
    
    /**
    1000        - 0.007 sec
    10000       - 0.058 sec
    100000      - 0.554 sec
    1000000     - 5.640 sec
    */
    func testPerformanceOfQueueBasedOnLinkedList() {

        let q = QueueBasedOnLinkedList<Int>()
        
        self.measureBlock() {
        
            for i in 0...1000000 {
                q.enqueue(i)
            }
            
            for i in 0...1000000 {
                q.dequeue()
            }
        }
    }
    
    // MARK: - Queue based on array

    func testEnqueueOperationForQueueBasedOnArray() {
        
        let q = QueueBasedOnArray<Int>()

        q.enqueue(6)
        q.enqueue(7)
        q.enqueue(8)
        
        q.dequeue()
        q.dequeue()
        let res = q.dequeue()

        XCTAssertEqual(res!, 8, "Incorrect enqueue/dequeue operations for queue based on array")
    }
    
    /**
    1000        -  0.011 sec
    10000       -  0.154 sec
    100000      -  1.312 sec
    1000000     - 11.226 sec
    */
    func testPerformanceOfQueueBasedOnArray() {

        let q = QueueBasedOnArray<Int>()
        
        self.measureBlock() {
            
            for i in 0...1000000 {
                q.enqueue(i)
            }
            
            for i in 0...1000000 {
                q.dequeue()
            }
        }
    }
}
