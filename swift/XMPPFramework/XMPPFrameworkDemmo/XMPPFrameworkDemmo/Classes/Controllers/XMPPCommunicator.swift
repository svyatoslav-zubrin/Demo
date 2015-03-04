//
//  XMPPCommunicator.swift
//  XMPPFrameworkDemmo
//
//  Created by Slava Zubrin on 2/16/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import Foundation

class XMPPCommunicator: BaseCommunicator
{
    var account: Account
    var isOpen: Bool = false
    private var stream: XMPPStream
    
    var me: Interlocutor
    {
        return account.me
    }
    
    // MARK: - Lifecycle
    
    init(account _account: Account)
    {
        stream = XMPPStream()
        account = _account
        
        super.init()

        configureStreamForAccount(account)
        stream.addDelegate(self, delegateQueue: dispatch_get_main_queue())
    }
    
    // MARK: - Public
    
    func connect() -> Bool
    {
        var result = false
        
        if !stream.isDisconnected()
        {
            result = true
        }
        
        if result == false
        {
            stream.myJID = XMPPJID.jidWithString(account.userId)
            var error: NSError? = nil
            if stream.connectWithTimeout(XMPPStreamTimeoutNone, error: &error)
            {
                result = true
            }
        }
        
        println("Connection establishment status: %@", result == true ? "SUCCESS" : "ERROR")

        return result
    }
    
    func disconnect()
    {
        goOffline()
        stream.disconnect()
        isOpen = false
        
        println("Disconnected")
    }

    func sendMessage(body _body: String, receiver _receiver: Interlocutor, date _date: NSDate?)
    {
        let bodyElement = DDXMLElement(name: "body", stringValue: _body)
        let msgElement  = DDXMLElement(name: "message")
        msgElement.addAttributeWithName("type", stringValue: "chat")
        msgElement.addAttributeWithName("to",   stringValue: _receiver.bareName)
        msgElement.addAttributeWithName("from", stringValue: account.me.bareName)
        let date = _date != nil ? _date : NSDate()
        msgElement.addAttributeWithName("date", stringValue: String(Message.dateAsString(date!)))
        msgElement.addChild(bodyElement)

        stream.sendElement(msgElement)
    }
}

// MARK: - XMPPStreamDelegate

extension XMPPCommunicator: XMPPStreamDelegate
{
    func xmppStreamDidAuthenticate(sender: XMPPStream!)
    {
        println("xmppStreamDidAuthenticate")
        
        // authentication successful
        goOnline()
        
        if let cd = chatDelegate
        {
            cd.account(account, changedStatus: .Available)
        }
    }
    
    func xmppStream(sender: XMPPStream!, didNotAuthenticate error: DDXMLElement!)
    {
        println("xmppStream:didNotAuthenticate: with error: \(error)")
    }
    
    func xmppStreamDidConnect(sender: XMPPStream!)
    {
        println("xmppStreamDidConnect")
        
        // connection to the server successful
        var error: NSError? = nil
        stream.authenticateWithPassword(account.password, error: &error)
        
        if error != nil
        {
            // TODO: handle error appropriately
            println("error authenticate: \(error?.localizedDescription)")
            isOpen = false
        }
        else
        {
            println("authenticate succeeded")
            isOpen = true
        }
    }
    
    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!)
    {
        // a buddy went offline/online
        let presenceType = presence.type()
        let myUsername = sender.myJID.user
        let presenceFromUser = presence.from().user
        
        let me      = account.me
        let other   = Interlocutor(xmppJID: presence.from(), account: account)
        
        println("Type: \(presence.type()), status: \(presence.status()), show: \(presence.show())")
        
        if other != me
        {
            if presenceType == "available"
            {
                if let cd = chatDelegate
                {
                    cd.newBuddyOnline(other)
                }
            }
            else if presenceType == "unavailable"
            {
                if let cd = chatDelegate
                {
                    cd.buddyWentOffline(other)
                }
            }
        }
    }
    
    func xmppStream(sender: XMPPStream!, didSendMessage message: XMPPMessage!)
    {
        if message.isChatMessageWithBody()
        {
            let text = message.body()
            let dateString = message.attributeStringValueForName("date")
            let date = Message.stringAsDate(dateString)
            let from = Interlocutor(xmppJID: message.from(), account: account)
            let to   = Interlocutor(xmppJID: message.to(), account: account)
            if from.isBare()
            && to.isBare()
            && countElements(text) > 0
            {
                let m = Message(text: text, sender: from, receiver: to, date: date)
                
                if let md = messageDelegate
                {
                    md.newMessageReceived(m)
                }
            }
        }
        else
        {
            println("typing...")
        }
    }
    
    func xmppStream(sender: XMPPStream!, didReceiveMessage message: XMPPMessage!)
    {
        if message.isChatMessageWithBody()
        {
            let text = message.body()
            let date = Message.stringAsDate(message.attributeStringValueForName("time"))
            let from = Interlocutor(xmppJID: message.from(), account: account)
            let to   = Interlocutor(xmppJID: message.to(), account: account)
            
            if from.isBare()
            && to.isBare()
            && countElements(text) > 0
            {
                // TODO: correct date passing as a parameter
                let m = Message(text: text, sender: from, receiver: to, date: date)
                
                if let md = messageDelegate
                {
                    md.newMessageReceived(m)
                }
            }
        }
        else
        {
            println("typing...")
        }
    }
    
    func xmppStream(sender: XMPPStream!,
        didFailToSendMessage message: XMPPMessage!,
        error: NSError!)
    {
        println("Failed to send message: \(message) with error: \(error.localizedDescription)")
    }
}

// MARK: - Private

private extension XMPPCommunicator
{
    func configureStreamForAccount(_account: Account)
    {
        stream.hostName = account.hostName
        stream.hostPort = UInt16(account.hostPort.integerValue)
    }
    
    func goOnline()
    {
        stream.sendElement(XMPPPresence())
    }
    
    func goOffline()
    {
        stream.sendElement(XMPPPresence(type: "unavailable"))
    }
}