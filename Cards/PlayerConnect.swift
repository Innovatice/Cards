//
//  PlayerConnect.swift
//  Cards
//
//  Created by Eric Williams on 9/23/14.
//  Copyright (c) 2014 Eric Williams. All rights reserved.
//

import UIKit
import MultipeerConnectivity

let kMCSessionMaximumNumberOfPeers: Int = 6
let kMCSessionMinimumNumberOfPeers: Int = 1

class PlayerConnect: NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    
    let serviceType = "CardsNew"
    
    var session: MCSession!
    var myPeerID: MCPeerID!
    var browser: MCNearbyServiceBrowser!
    var assistant: MCNearbyServiceAdvertiser!

    override init() {
        super.init()
        
        self.myPeerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        self.session = MCSession(peer: myPeerID)
        self.session.delegate = self
        
        println(myPeerID)
        println(GameDeviceInfo.gameDI().deviceType.toRaw())
        
        switch(GameDeviceInfo.gameDI().deviceType) {
            
        case .Gameboard :
            
            self.browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
            self.browser.delegate = self
            self.browser.startBrowsingForPeers()
            
        case .CardHolder :
            
            self.assistant = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
            self.assistant.delegate = self
            self.assistant.startAdvertisingPeer()
            
        }
        
        
        // will close all sessions when entering MPC
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("closeSession"), name:UIApplicationWillResignActiveNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("closeSession"), name:UIApplicationWillTerminateNotification, object: nil)
        

        
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!,
        fromPeer peerID: MCPeerID!)  {
            // Called when a peer sends an NSData to us
            
            // This needs to run on the main queue
            dispatch_async(dispatch_get_main_queue()) {
                
                var info = NSKeyedUnarchiver.unarchiveObjectWithData(data) as NSDictionary
                
                var action = info["action"] as String
                
                // combining the switch case scenario using .toRaw data to identify device type
                NSNotificationCenter.defaultCenter().postNotificationName("\(GameDeviceInfo.gameDI().deviceType.toRaw())\(action)", object: nil , userInfo: info)
                
            }
    }
    
    func closeSession() {
        
        self.session.disconnect()
    }
    
    func sendInfo(info: NSMutableDictionary, toPeer peer: MCPeerID) {
        
        info["peerID"] = myPeerID
        
        println([peer])
        
        var infoData = NSKeyedArchiver.archivedDataWithRootObject(info)
        
        self.session.sendData(infoData, toPeers: [peer], withMode: MCSessionSendDataMode.Reliable, error: nil)
        
        
    }
    
    // The following methods do nothing, but the MCSessionDelegate protocol
    // requires that we implement them.
    func session(session: MCSession!,
        didStartReceivingResourceWithName resourceName: String!,
        fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!)  {
            
            // Called when a peer starts sending a file to us
    }
    
    func session(session: MCSession!,
        didFinishReceivingResourceWithName resourceName: String!,
        fromPeer peerID: MCPeerID!,
        atURL localURL: NSURL!, withError error: NSError!)  {
            // Called when a file has finished transferring from another peer
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!,
        withName streamName: String!, fromPeer peerID: MCPeerID!)  {
            // Called when a peer establishes a stream with us
    }
    
    func browser(browser: MCNearbyServiceBrowser!, didNotStartBrowsingForPeers error: NSError!) {
        
        println("did not start browsing")
    }
    
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
    
        println("found \(peerID)")
    
        self.browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 30)
        
    }
    
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
        
        //loop to remove items from playerIDs array
        
        println("lost \(peerID)")
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didNotStartAdvertisingPeer error: NSError!) {
        
        println("did not start advertising")
    }
    
    //handshake of devices
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
        
        println("invite \(peerID)")
        
        invitationHandler(true, self.session)
    }

    
    func session(session: MCSession!, peer peerID: MCPeerID!,
        didChangeState state: MCSessionState)  {
            
            
            switch(state) {
                
            case .Connected :
                
                switch(GameDeviceInfo.gameDI().deviceType) {
                    
                case .Gameboard :
                    GameDeviceInfo.gameDI().playerIDs.append(peerID)
                    
                    println(GameDeviceInfo.gameDI().playerIDs)
                    
                    sendInfo(["action":"SetGameboard","GameboardPeerID":myPeerID], toPeer: peerID)
                    
                    // send info with hostPeerID to peerID
                    
                case .CardHolder :
                    
                    println("blah")
//                    GameDeviceInfo.gameDI().gameBoardID = peerID
                }
                
            case .Connecting :
                
                println(peerID.displayName)
                println(state.toRaw())
                
            case .NotConnected :
                
                // remove gameboard or remove player
                
                println(peerID.displayName)
                println(state.toRaw())
                
//                self.browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 120)
                
            }
            
    }
    
}
