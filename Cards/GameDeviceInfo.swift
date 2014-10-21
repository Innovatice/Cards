//
//  GameDeviceInfo.swift
//  Cards
//
//  Created by Eric Williams on 9/29/14.
//  Copyright (c) 2014 Eric Williams. All rights reserved.
//

import UIKit
import MultipeerConnectivity

let _gameDI: GameDeviceInfo = { GameDeviceInfo() }()

enum GDType: String {
    
    case Gameboard = "Gameboard"
    case CardHolder = "CardHolder"
}

class GameDeviceInfo: NSObject {
    
    var deviceType : GDType = .Gameboard
    
    var gameBoardID: MCPeerID!
    
    var playerIDs: [MCPeerID] = []
    
    class func gameDI() -> GameDeviceInfo {
        return _gameDI
    }
   
}
