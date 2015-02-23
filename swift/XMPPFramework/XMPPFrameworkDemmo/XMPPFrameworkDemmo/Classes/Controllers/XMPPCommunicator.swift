//
//  XMPPCommunicator.swift
//  XMPPFrameworkDemmo
//
//  Created by Slava Zubrin on 2/16/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import Foundation

class XMPPCommunicator: BaseCommunicator {

    var account: Account
    var isOpen: Bool = false
    private var stream: XMPPStream
    
    var me: Interlocutor {
        return Interlocutor(xmppJID: stream.myJID, service: account.service)
    }
    
    // MARK: - Lifecycle
    
    init(account _account: Account) {
        
        stream = XMPPStream()
        account = _account

//        service = Service(type: .Local)!
//        service = Service(type: .QArea)!
        
        super.init()

        configureStreamForService(account.service)
        stream.addDelegate(self, delegateQueue: dispatch_get_main_queue())
    }
    
    // MARK: - Public
    
    func connect() -> Bool {
        
        var result = false
        
        if !stream.isDisconnected() {
            result = true
        }
        
        if result == false {
            stream.myJID = XMPPJID.jidWithString(account.userId)
            var error: NSError? = nil
            if stream.connectWithTimeout(XMPPStreamTimeoutNone, error: &error) {
                result = true
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
        msgElement.addAttributeWithName("to",   stringValue: message.receiver.bareName)
        msgElement.addAttributeWithName("from", stringValue: message.sender.bareName)
        msgElement.addAttributeWithName("time", stringValue: message.time)
        msgElement.addChild(bodyElement)
        
        stream.sendElement(msgElement)
    }
}

// MARK: - XMPPStreamDelegate

extension XMPPCommunicator: XMPPStreamDelegate {
    
    func xmppStreamDidAuthenticate(sender: XMPPStream!) {
        // authentication successful
        goOnline()
        
        if let cd = chatDelegate {
            cd.myStatusChanged(.Available)
        }
    }
    
    func xmppStreamDidConnect(sender: XMPPStream!) {
        // connection to the server successful
        isOpen = true
        var error: NSError? = nil
        stream.authenticateWithPassword(account.password, error: &error)
        
        if error != nil {
            // TODO: handle error appropriately
        }
    }
    
    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!) {
        // a buddy went offline/online
        let presenceType = presence.type()
        let myUsername = sender.myJID.user
        let presenceFromUser = presence.from().user
        
        let me      = Interlocutor(xmppJID: sender.myJID, service: account.service)
        let other   = Interlocutor(xmppJID: presence.from(), service: account.service)
        
        println("Type: \(presence.type()), status: \(presence.status()), show: \(presence.show())")
        
        if other != me {
            if presenceType == "available" {
                if let cd = chatDelegate {
                    cd.newBuddyOnline(other)
                }
            } else if presenceType == "unavailable" {
                if let cd = chatDelegate {
                    cd.buddyWentOffline(other)
                }
            }
        }
    }
    
    func xmppStream(sender: XMPPStream!, didSendMessage message: XMPPMessage!) {

        if message.isChatMessageWithBody() {
            let text = message.body()
            let time = message.attributeStringValueForName("time")
            let from = Interlocutor(xmppJID: message.from(), service: account.service)
            let to   = Interlocutor(xmppJID: message.to(), service: account.service)
            if from.isBare()
                && to.isBare()
                && countElements(text) > 0 {
                    
                    let m = Message(text: text, sender: from, receiver: to, time: time)
                    
                    if let md = messageDelegate {
                        md.newMessageReceived(m)
                    }
            }
        } else {
            println("typing...")
        }
    }
    
    func xmppStream(sender: XMPPStream!, didReceiveMessage message: XMPPMessage!) {

        if message.isChatMessageWithBody() {
            let text = message.body()
            let time = message.attributeStringValueForName("time")
            let from = Interlocutor(xmppJID: message.from(), service: account.service)
            let to   = Interlocutor(xmppJID: message.to(), service: account.service)
            
            if from.isBare()
            && to.isBare()
            && countElements(text) > 0 {
                
                let m = Message(text: text, sender: from, receiver: to, time: time != nil ? time : "")
                
                if let md = messageDelegate {
                    md.newMessageReceived(m)
                }
            }
        } else {
            println("typing...")
        }
    }
    
    func xmppStream(sender: XMPPStream!,
        didFailToSendMessage message: XMPPMessage!,
        error: NSError!) {
            
        println("Failed to send message: \(message) with error: \(error.localizedDescription)")
    }
}

// MARK: - Private

private extension XMPPCommunicator {
    
    func configureStreamForService(_service: Service) {
        stream.hostName = account.service.hostName
        stream.hostPort = account.service.hostPort
    }
    
    func goOnline() {
        stream.sendElement(XMPPPresence())
    }
    
    func goOffline() {
        stream.sendElement(XMPPPresence(type: "unavailable"))
    }
}