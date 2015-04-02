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
        
        
        getContactsList()
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
    
    func xmppStream(sender: XMPPStream!, didFailToSendIQ iq: XMPPIQ!, error: NSError!)
    {
        println("Error sending iq: \(iq), error: \(error)")
    }
    
    func xmppStream(sender: XMPPStream!, didReceiveIQ iq: XMPPIQ!) -> Bool
    {
        println("xmppStream:didReceiveIQ:")
        
        if let queryElement = iq.elementForName("query", xmlns: "jabber:iq:roster")
        {
            let itemElenments = queryElement.elementsForName("item") as [DDXMLElement]
            for itemElement in itemElenments
            {
                println(itemElement.attributeForName("jid").stringValue())
                
                MagicalRecord.saveWithBlockAndWait
                { (context: NSManagedObjectContext!) -> Void in
                    let localAccount = self.account.MR_inContext(context) as Account
                    
                    let jid  = itemElement.attributeForName("jid").stringValue()
                    let name = itemElement.attributeForName("name").stringValue()
                    var groupName: String? = nil
                    let groups = itemElement.elementsForName("group") as? [DDXMLElement]
                    if let groups = groups
                    {
                        if let group = first(groups)
                        {
                            groupName = group.stringValue()
                        }
                    }

                    println("group: \(groupName)")

                    if var buddy = Interlocutor.MR_findFirstByAttribute("bareName",
                        withValue: jid, inContext: context)
                        as? Interlocutor
                    {
                        println("old buddy: \(buddy.name):'\(buddy.group)'")
                        if buddy.name != name
                        {
//                            println("NAME SET!!!")
                            buddy.name = name
                        }
                        
                        if groupName != nil && buddy.group != groupName
                        {
//                            println("GROUP SET!!!")
                            buddy.group = groupName!
                        }
                        
                        println("new buddy: \(buddy.name):'\(buddy.group)'")
                    }
                    else
                    {
                        let newBuddy = Interlocutor(name: name,
                            bareName: jid,
                            group: nil,
                            account: self.account,
                            inManagedObjectContext: context)
                    }
                }
            }
        }
        
        return false
    }
    
    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!)
    {
        // a buddy went offline/online
        let presenceType     = presence.type()
        let presenceFromUser = presence.from().user

        // create interlocutor if there is no such
        var other =
        Interlocutor.MR_findFirstByAttribute("bareName", withValue: presence.from().bare())
            as? Interlocutor
        
        if other == nil
        {
            println("new Interlocutor from presence data")
            MagicalRecord.saveWithBlockAndWait
            { (context: NSManagedObjectContext!) -> Void in
                other = Interlocutor(xmppJID: presence.from(),
                    group: nil,
                    account: self.account,
                    inManagedObjectContext: context)
            }
        }
        
       // inform delegate
        if other?.bareName != account.me.bareName
        {
            if presenceType == "available"
            {
                if let cd = chatDelegate
                {
                    cd.newBuddyOnline(other!)
                }
            }
            else if presenceType == "unavailable"
            {
                if let cd = chatDelegate
                {
                    cd.buddyWentOffline(other!)
                }
            }
        }
    }
    
    func xmppStream(sender: XMPPStream!, didSendMessage message: XMPPMessage!)
    {
        if message.isChatMessageWithBody()
        {
            handleNewChatMessageWithBody(message)
        }
    }
    
    func xmppStream(sender: XMPPStream!, didReceiveMessage message: XMPPMessage!)
    {
        if message.isChatMessageWithBody()
        {
            handleNewChatMessageWithBody(message)
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
    
    func getContactsList()
    {
        var error: NSError? = nil
        
        let query = DDXMLElement(XMLString: "<query xmlns='jabber:iq:roster'/>", error: &error)
        
        let iq = DDXMLElement(name: "iq")
        iq.addAttributeWithName("type", stringValue: "get")
        iq.addAttributeWithName("id", stringValue: "ANY_ID_NAME")
        iq.addAttributeWithName("from", stringValue: "ANY_ID_NAME@"+account.hostName)
        iq.addChild(query)
        
        stream.sendElement(iq)
    }
    
    func handleNewChatMessageWithBody(message: XMPPMessage!)
    {
        let text = message.body()
        var date: NSDate! = nil
        if let dateString = message.attributeStringValueForName("date") {
            date = Message.stringAsDate(dateString)
        } else {
            date = NSDate()
        }
        
        var from = Interlocutor.MR_findFirstByAttribute("bareName",
            withValue: message.from().bare()) as? Interlocutor
        if from == nil
        {
            MagicalRecord.saveWithBlockAndWait
            { (context: NSManagedObjectContext!) -> Void in
                from = Interlocutor(xmppJID: message.from(),
                    group: nil,
                    account: self.account,
                    inManagedObjectContext: context)
                println("New interlocutor (from) saving: \(from)");
            }
        }
        var to = Interlocutor.MR_findFirstByAttribute("bareName",
            withValue: message.to().bare()) as? Interlocutor
        if to == nil
        {
            MagicalRecord.saveWithBlockAndWait
            { (context: NSManagedObjectContext!) -> Void in
                to = Interlocutor(xmppJID: message.to(),
                    group: nil,
                    account: self.account,
                    inManagedObjectContext: context)
                println("New interlocutor (to) saving: \(to)");
            }
        }
        
        if from!.isBare()
            && to!.isBare()
            && countElements(text) > 0
        {
            var m: Message! = nil
            MagicalRecord.saveWithBlockAndWait
            { (context: NSManagedObjectContext!) -> Void in
                m = Message(text: text,
                    sender: from!,
                    receiver: to!,
                    date: date,
                    inManagedObjectContext: context)
                println("New message saving: \(m)");
            }
            
            if let md = messageDelegate
            {
                println("Informing delegate about new message");
                md.newMessageReceived(m)
            }
        }
    }
}