//
//  Player.swift
//  Cards
//
//  Created by Eric Williams on 9/27/14.
//  Copyright (c) 2014 Eric Williams. All rights reserved.
//

import UIKit

enum playerPositions {
    
    case playerBottom
    case playerLeft
    case playerRight
    case playerTop

}

class Player: NSObject {
    
    var playerPosition: UILabel!
    var playerPeerID: NSString!
    
}


