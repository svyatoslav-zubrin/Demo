//
//  XMPPCommunicator.swift
//  XMPPFrameworkDemmo
//
//  Created by Slava Zubrin on 2/16/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import Foundation

class XMPPCommunicator: NSObject {

    private var stream: XMPPStream
    private var pass: String = ""
    var isOpen: Bool = false
    
    var chatDelegate: ChatDelegate?
    var messageDelegate: MessageDelegate?
    
    var currentUserName: String {
        return stream.myJID.user
    }
    
    // Singleton
    
    class var sharedInstance : XMPPCommunicator {
        struct Static {
            static let instance : XMPPCommunicator = XMPPCommunicator()
        }
        return Static.instance
    }

    // MARK: - Lifecycle
    
    override init() {
        println("XMPPCommunicator.init() called")
        
        stream = XMPPStream()
        stream.hostName = "szmini.local"
        stream.hostPort = 5222

        super.init()
        
        stream.addDelegate(self, delegateQueue: dispatch_get_main_queue())
    }
    
    // MARK: - Public
    
    func connect() -> Bool {
        var result = false
        
        if !stream.isDisconnected() {
            println("Already connected")
            result = true
        }
        
        if result == false {
            if let jabberId = UserSettings.sharedInstance.userId {
                if let password = UserSettings.sharedInstance.userPassword {
                    stream.myJID = XMPPJID.jidWithString(jabberId)
                    pass = password
                    var error: NSError? = nil
                    // TODO: get rid of old school connection and replace it with modern one
                    if stream.connectWithTimeout(XMPPStreamTimeoutNone, error: &error) {
                        // inform about connection problems
                        println("Connect with timeout called")
                        result = true
                    }
                }
            }
        }
        
        println("Connection establishment status: %@", result == true ? "SUCCESS" : "ERROR")

        return result
    }
    
    func disconnect() {
        goOffline()
        stream.disconnect()
    }
    
    func sendMessage(message: Message) {
        
        let bodyElement = DDXMLElement(name: "body", stringValue: message.message)
        let msgElement  = DDXMLElement(name: "message")
        msgElement.addAttributeWithName("type", stringValue: "chat")
        msgElement.addAttributeWithName("to", stringValue: message.receiverName)
        msgElement.addChild(bodyElement)
        
        stream.sendElement(msgElement)
    }
}

// MARK: - XMPPStreamDelegate

extension XMPPCommunicator: XMPPStreamDelegate {
    
    func xmppStreamDidAuthenticate(sender: XMPPStream!) {
        println("xmppStreamDidAuthenticate:")
        
        // authentication successful
        goOnline()
        
        if let cd = chatDelegate {
            cd.myStatusChanged(.Available)
        }
    }
    
    func xmppStreamDidConnect(sender: XMPPStream!) {
        println("xmppStreamDidConnect:")
        
        // connection to the server successful
        isOpen = true
        var error: NSError? = nil
        stream.authenticateWithPassword(pass, error: &error)
        
        if error != nil {
            // TODO: handle error appropriately
        }
    }
    
    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!) {
        println("xmppStream:didReceivePresence:")
        
        // a buddy went offline/online
        let presenceType = presence.type()
        let myUsername = sender.myJID.user
        let presenceFromUser = presence.from().user
        
        if presenceFromUser != myUsername {
            if presenceType == "available" {
                if let cd = chatDelegate {
                    cd.newBuddyOnline(presenceFromUser)
                }
            } else if presenceType == "unavailable" {
                if let cd = chatDelegate {
                    cd.buddyWentOffline(presenceFromUser)
                }
            }
        }
    }
    
    func xmppStream(sender: XMPPStream!, didReceiveMessage message: XMPPMessage!) {
        println("xmppStream:didReceiveMessage:")
        
        // message received
        if message.isMessageWithBody() {
            let text = message.body()
            let from = message.from().user != nil ? message.from().user : ""
            let to   = message.to().user
            
            let m = Message(text: text, sender: from, receiver: to)
            
            if let md = messageDelegate {
                md.newMessageReceived(m)
            }
        } else {
            println("typing...")
        }
    }
}

// MARK: - Private

private extension XMPPCommunicator {
    func goOnline() {
        stream.sendElement(XMPPPresence())
    }
    
    func goOffline() {
        stream.sendElement(XMPPPresence(type: "unavailable"))
    }
}