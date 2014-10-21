//
//  Deck.swift
//  Cards
//
//  Created by Eric Williams on 9/24/14.
//  Copyright (c) 2014 Eric Williams. All rights reserved.
//

import UIKit


class Deck: NSObject {
    
    var deckOfCards: [Card] = []
    
    func setupPlayingCards(cardTypes: [[String:String]]) {
        
        deckOfCards = []
        
        for cardType in cardTypes  {
            
            var card = Card()
            
            card.name = cardType["name"]!
            card.type = cardType["type"]!
            card.value = cardType["value"]!
            
            deckOfCards.append(card)
        }
        
        shuffleDeck()
    }
    
    
    func chooseDeck() {
        
        setupPlayingCards([
            
            ["name":"Ace","type":"Heart","value":"14"],
            ["name":"King","type":"Heart","value":"13"],
            ["name":"Queen","type":"Heart","value":"12"],
            ["name":"Jack","type":"Heart","value":"11"],
            ["name":"10","type":"Heart","value":"10"],
            ["name":"9","type":"Heart","value":"9"],
            ["name":"8","type":"Heart","value":"8"],
            ["name":"7","type":"Heart","value":"7"],
            ["name":"6","type":"Heart","value":"6"],
            ["name":"5","type":"Heart","value":"5"],
            ["name":"4","type":"Heart","value":"4"],
            ["name":"3","type":"Heart","value":"3"],
            ["name":"2","type":"Heart","value":"2"],
            ["name":"Ace","type":"Spade","value":"14"],
            ["name":"King","type":"Spade","value":"13"],
            ["name":"Queen","type":"Spade","value":"12"],
            ["name":"Jack","type":"Spade","value":"11"],
            ["name":"10","type":"Spade","value":"10"],
            ["name":"9","type":"Spade","value":"9"],
            ["name":"8","type":"Spade","value":"8"],
            ["name":"7","type":"Spade","value":"7"],
            ["name":"6","type":"Spade","value":"6"],
            ["name":"5","type":"Spade","value":"5"],
            ["name":"4","type":"Spade","value":"4"],
            ["name":"3","type":"Spade","value":"3"],
            ["name":"2","type":"Spade","value":"2"],
            ["name":"Ace","type":"Diamond","value":"14"],
            ["name":"King","type":"Diamond","value":"13"],
            ["name":"Queen","type":"Diamond","value":"12"],
            ["name":"Jack","type":"Diamond","value":"11"],
            ["name":"10","type":"Diamond","value":"10"],
            ["name":"9","type":"Diamond","value":"9"],
            ["name":"8","type":"Diamond","value":"8"],
            ["name":"7","type":"Diamond","value":"7"],
            ["name":"6","type":"Diamond","value":"6"],
            ["name":"5","type":"Diamond","value":"5"],
            ["name":"4","type":"Diamond","value":"4"],
            ["name":"3","type":"Diamond","value":"3"],
            ["name":"2","type":"Diamond","value":"2"],
            ["name":"Ace","type":"Club","value":"14"],
            ["name":"King","type":"Club","value":"13"],
            ["name":"Queen","type":"Club","value":"12"],
            ["name":"Jack","type":"Club","value":"11"],
            ["name":"10","type":"Club","value":"10"],
            ["name":"9","type":"Club","value":"9"],
            ["name":"8","type":"Club","value":"8"],
            ["name":"7","type":"Club","value":"7"],
            ["name":"6","type":"Club","value":"6"],
            ["name":"5","type":"Club","value":"5"],
            ["name":"4","type":"Club","value":"4"],
            ["name":"3","type":"Club","value":"3"],
            ["name":"2","type":"Club","value":"2"]
            
            ])
    }
    
    func shuffleDeck() {
        
        sort(&deckOfCards) {(_, _) in arc4random() % 2 == 0}
        
//        println(deckOfCards)

    }

}


