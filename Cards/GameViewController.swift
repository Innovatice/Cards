//
//  GameViewController.swift
//  Cards
//
//  Created by Eric Williams on 9/23/14.
//  Copyright (c) 2014 Eric Williams. All rights reserved.
//

import UIKit
import iAd
import MultipeerConnectivity

class GameViewController: UIViewController, MCBrowserViewControllerDelegate, ADBannerViewDelegate{
        
    let playerConnect = PlayerConnect()
    let deck = Deck()
    let card = Card()

    var startGameButton = UIButton()
    var howToPlayButton = UIButton()
    var dealButton = UIButton()
    var shuffleButton = UIButton()
    var player1position: UIView!
    var player2position: UIView!
    var player1PlayedCard: Card?
    var player2PlayedCard: Card?
    var playedCards: [Card] = []
    var dealCardViewArray: [UIView] = []
    var howToPlayWindow: UIView!
    var backButton = UIButton()
    var howToTextField: UITextView!
    var adBannerView: ADBannerView!
    var cardsOnTable: Int = 0 // count for how many cards should be on table
    
    //    var gameBoardBackButton: UIButton!
    //    var player1Icon: UIView!
    //    var player2Icon: UIView!
    //    var connectionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        loadAds()
        deck.chooseDeck()
        
        startGameButton = UIButton(frame: CGRectMake((SCREEN_WIDTH - 200) / 2.0 + 300, (SCREEN_HEIGHT - 200) / 2.0 - 225, 200, 100))
        startGameButton.layer.cornerRadius = 30
        startGameButton.setTitle("Start Game", forState: .Normal)
        startGameButton.titleLabel?.font = UIFont(name: "HelveticaNeue-light", size: 30)
        startGameButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        startGameButton.backgroundColor = UIColor(red: 0.180, green: 0.063, blue: 0.00, alpha: 1.0)
        startGameButton.addTarget(self, action: Selector("startGameClicked"), forControlEvents: .TouchUpInside)
        self.view.addSubview(startGameButton)
        
        howToPlayButton = UIButton(frame: CGRectMake((SCREEN_WIDTH - 200) / 2.0 + 300, (SCREEN_HEIGHT - 200) / 2.0 - 100, 200, 100))
        howToPlayButton.layer.cornerRadius = 30
        howToPlayButton.setTitle("How To Play", forState: .Normal)
        howToPlayButton.titleLabel?.font = UIFont(name: "HelveticaNeue-light", size: 30)
        howToPlayButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        howToPlayButton.backgroundColor = UIColor(red: 0.180, green: 0.063, blue: 0.00, alpha: 1.0)
        howToPlayButton.addTarget(self, action: Selector("howToClicked"), forControlEvents: .TouchUpInside)
        self.view.addSubview(howToPlayButton)
        
        
        NSNotificationCenter.defaultCenter().addObserverForName("GameboardPlayCard", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in

            var card = notification.userInfo!["card"] as Card

            self.playedCards.append(card)
            
            var peerID = notification.userInfo!["peerID"] as MCPeerID
            var cardView = card.cardView()
            
            for p in 0..<GameDeviceInfo.gameDI().playerIDs.count {
                
                let playerID = GameDeviceInfo.gameDI().playerIDs[p]
                
                if playerID == peerID {

                    switch (p) {
                        
                    case 0 :
                        
                        self.player1position.addSubview(cardView)
                        self.player1PlayedCard = card

                        
                    case 1 :
                        
                        self.player2position.addSubview(cardView)
                        self.player2PlayedCard = card
                        
                    default :
                        
                        println("ummmmm")
                        
                    }
                    
                    let yMultiplier: CGFloat = (Bool(p)) ? 1.0 : -0.5
        
                    cardView.center = CGPointMake(100, self.view.frame.size.height * yMultiplier)

                    UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                        
                        cardView.frame.origin.y = 0
                        
                        var random = CGFloat(Int(arc4random_uniform(20)) - 10) / 100
                        
                        cardView.transform = CGAffineTransformMakeRotation(random)

                    }, completion: nil)
                }
                
            }
            
            if self.cardsOnTable == self.playedCards.count { self.checkPlayedCards() }
            
        }
    }
    
    func checkPlayedCards() {
        
        if (self.player1PlayedCard != nil && self.player2PlayedCard != nil) {
            
            // test value for winner
            
            let p1Card = self.player1PlayedCard?.value.toInt()
            let p2Card = self.player2PlayedCard?.value.toInt()
            
            if (p1Card == p2Card) {
                
                for playerID in GameDeviceInfo.gameDI().playerIDs {
                    
                    playerConnect.sendInfo(["action":"CardsToPlay","num":"4"], toPeer: playerID)
                    
                }
                
                cardsOnTable += 8
                
            } else {

                let p = (p1Card > p2Card) ? 0 : 1;
                
                let winner = GameDeviceInfo.gameDI().playerIDs[p];
                
                let yMultiplier: CGFloat = (Bool(p)) ? 1.5 : -0.5

                UIView.animateWithDuration(0.2, delay: 0.8, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                    
                    for view in self.player1position.subviews as [UIView] {
                        
                        view.center = CGPointMake(self.view.center.x, self.view.frame.size.height * yMultiplier)

                    }
                    
                    for view in self.player2position.subviews as [UIView] {
                        
                        view.center = CGPointMake(self.view.center.x, self.view.frame.size.height * yMultiplier)
                        
                    }
                    
                }, completion: { (success) -> Void in
                    
                    for view in self.player1position.subviews as [UIView] {
                        
                        view.removeFromSuperview()
                        
                    }
                    
                    for view in self.player2position.subviews as [UIView] {
                        
                        view.removeFromSuperview()
                        
                    }
                    
                    for card in self.playedCards {
                        
                        self.playerConnect.sendInfo(["action":"DealCard","card":card], toPeer: winner)
                        
                        
                    }
                    
                    self.playedCards = []
                    
                    for playerID in GameDeviceInfo.gameDI().playerIDs {
                        
                        self.playerConnect.sendInfo(["action":"CardsToPlay","num":"1"], toPeer: playerID)
                        
                    }
                    
                    
                })
                
                // send cards to winner
                println("The winner is \(winner)")
                
                cardsOnTable = 2
                
            }

            self.player1PlayedCard = nil
            self.player2PlayedCard = nil
            
            for playerID in GameDeviceInfo.gameDI().playerIDs {
                
                setActivePlayer(playerID)
            }
        }
    }
    
    func startGameClicked() {
        
        startGameButton.removeFromSuperview()
        howToPlayButton.removeFromSuperview()
        
        // create cards loop
        
        dealButton = UIButton(frame: CGRectMake(105, (SCREEN_HEIGHT - 275.0) / 2.0, 200, 275))
        dealButton.setImage(UIImage(named: "cardDown"), forState: UIControlState.Normal)
        dealButton.layer.cornerRadius = 15
        dealButton.addTarget(self, action: Selector("dealButtonClicked"), forControlEvents: .TouchUpInside)
        
        for c in 0..<52 {
            
            var dealCardView = UIImageView(frame: dealButton.frame)
            
            dealCardView.image = UIImage(named: "cardDown")
                        
            var random = CGFloat(Int(arc4random_uniform(20)) - 10) / 100
            
            dealCardView.transform = CGAffineTransformMakeRotation(random)
            
            self.view.addSubview(dealCardView)
            
            self.dealCardViewArray.append(dealCardView)
            
            println(self.dealCardViewArray.count)
            
            
        }
        
        self.view.addSubview(dealButton)
        
//        gameBoardBackButton = UIButton(frame: CGRectMake(20, 20, 80, 80))
//        gameBoardBackButton.backgroundColor = UIColor(red: 0.600, green: 0.145, blue: 0.114, alpha: 1.0)
//        gameBoardBackButton.layer.cornerRadius = 40
//        gameBoardBackButton.setTitle("back", forState: .Normal)
//        gameBoardBackButton.addTarget(self, action: Selector("backToHomeScreen"), forControlEvents: .TouchUpInside)
//        self.view.addSubview(gameBoardBackButton)
        
        
        shuffleButton = UIButton(frame: CGRectMake(920, 20, 80, 80))
        shuffleButton.backgroundColor = UIColor.blueColor()
        shuffleButton.setTitle("shuffle", forState: .Normal)
        shuffleButton.layer.cornerRadius = 40
        shuffleButton.addTarget(deck, action: Selector("shuffleDeck"), forControlEvents: .TouchUpInside)
        self.view.addSubview(shuffleButton)
        
        
        player1position = UIView(frame: CGRectMake((SCREEN_WIDTH - 200) / 2.0 - 5, 15, 200, 275))
        self.view.addSubview(player1position)
        
        
//        player1Icon = UIView(frame: CGRectMake((SCREEN_WIDTH - 80) / 3.0, 20, 80, 80))
//        player1Icon.backgroundColor = UIColor.clearColor()
//        player1Icon.layer.borderColor = UIColor.blackColor().CGColor
//        player1Icon.layer.borderWidth = 2
//        player1Icon.layer.cornerRadius = 40
//        self.view.addSubview(player1Icon)
        
        player2position = UIView(frame: CGRectMake((SCREEN_WIDTH - 200) / 2.0 - 5, 450, 200, 275))
        self.view.addSubview(player2position)
        
        
//        player2Icon = UIView(frame: CGRectMake((SCREEN_WIDTH - 80) / 1.5, 645, 80, 80))
//        player2Icon.backgroundColor = UIColor.clearColor()
//        player2Icon.layer.borderColor = UIColor.blackColor().CGColor
//        player2Icon.layer.borderWidth = 2
//        player2Icon.layer.cornerRadius = 40
//        self.view.addSubview(player2Icon)
        
//        connectionLabel = UILabel(frame: CGRectMake(20, 700, 300, 50))
//        connectionLabel.backgroundColor = UIColor.clearColor()
//        connectionLabel.textColor = UIColor.whiteColor()
//        connectionLabel.font = UIFont(name: "HelveticaNeue", size: 28)
//        connectionLabel.text = "Connected Devices: "
//        self.view.addSubview(connectionLabel)
    
    }
    
    
    func dealButtonClicked() {
        
        var deviceConnectionAlert = UIAlertController(title: "Two Devices Not Connected", message: "Please Check Connection Status on iPhone", preferredStyle: UIAlertControllerStyle.Alert)
        
        if GameDeviceInfo.gameDI().playerIDs.count < 2 {
            
            println("2 Devices not Connected")
            
            deviceConnectionAlert.addAction(UIAlertAction(title: "Go Back", style: UIAlertActionStyle.Default, handler: nil))
        
            self.presentViewController(deviceConnectionAlert, animated: true, completion: nil)

        } else {
            
            for i in 0..<26 {
                
                for p in 0..<GameDeviceInfo.gameDI().playerIDs.count {
                    
                    if deck.deckOfCards.count > 0 as Int {
                        
                        let card = self.deck.deckOfCards[0]
                        self.deck.deckOfCards.removeAtIndex(0)
                        
                        let playerID = GameDeviceInfo.gameDI().playerIDs[p]
                        
                        // based on last card in deck array
                        
                        var topCard = self.dealCardViewArray.last!
                        
                        self.dealCardViewArray.removeLast()
                                                
                        UIView.animateWithDuration(0.2, delay: 0.22 * Double(i) + (Double(p) / 10), options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                            
                            let yMultiplier: CGFloat = (Bool(p)) ? 1.5 : -0.5
                            
                            topCard.center = CGPointMake(self.view.center.x, self.view.frame.size.height * yMultiplier)
                            
                            }, completion: { (success) -> Void in
                                
                                self.playerConnect.sendInfo(["action":"DealCard","card":card], toPeer: playerID)
                                
                                topCard.removeFromSuperview()
                                self.dealButton.removeFromSuperview()
                                
                        })
                    }
                }
            }
            
            for playerID in GameDeviceInfo.gameDI().playerIDs {
                
                playerConnect.sendInfo(["action":"CardsToPlay","num":"1"], toPeer: playerID)
                
            }
            
            cardsOnTable = 2
            
        }

        for playerID in GameDeviceInfo.gameDI().playerIDs {
            
            setActivePlayer(playerID)
        }
        
        shuffleButton.removeFromSuperview()
    }
    
    func setActivePlayer(playerID: MCPeerID) {
        
        playerConnect.sendInfo(["action":"SetActive"], toPeer: playerID)
        
    }
    
    func howToClicked() {
    
        
        howToPlayWindow = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        howToPlayWindow.backgroundColor = UIColor.whiteColor()
        howToPlayWindow.alpha = 0.92
        
        self.view.addSubview(howToPlayWindow)
        
        howToTextField = UITextView(frame: CGRectMake((SCREEN_WIDTH - 800) / 2.0, (SCREEN_HEIGHT - 500) / 2.0, 800, 500))
        howToTextField.backgroundColor = UIColor.grayColor()
        howToTextField.layer.cornerRadius = 30
        howToTextField.layer.borderColor = UIColor(red: 0.600, green: 0.114, blue: 0.078, alpha: 1.0).CGColor
        howToTextField.layer.borderWidth = 4
        howToTextField.text = "The Name of the Game is Simple: Each player is dealt 26 cards and the object of the game is to win all the cards in the deck.  Each player swipes a card from their device and the higher card wins that round.  If players throw the same card then 3 more cards are thrown and a fourth one determines who wins the round. Each player simply swipes the first card from their corresponding devices and play continues as such until a winner collects all the cards in the deck. For the sake of consistency only the first card in each player's hand can be swiped per round."
        howToTextField.textAlignment = .Center
        howToTextField.editable = false
        howToTextField.textColor = UIColor.whiteColor()
        howToTextField.font = UIFont(name: "HelveticaNeue-light", size: 34)
        howToPlayWindow.addSubview(howToTextField)
        
        var backButton = UIButton(frame: CGRectMake(30, 30, 60, 60))
        backButton.backgroundColor = UIColor(red: 0.600, green: 0.114, blue: 0.078, alpha: 1.0)
        backButton.layer.cornerRadius = 30
        backButton.addTarget(self, action: Selector("backButtonClicked"), forControlEvents: .TouchUpInside)
        backButton.layer.masksToBounds = true
        
        howToPlayWindow.addSubview(backButton)

        
    }
    
    func backButtonClicked() {

        println("back button pressed")
        
        howToPlayWindow.removeFromSuperview()
        
    }
    
    func backToHomeScreen() {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    
    
    func browserViewControllerDidFinish(
        browserViewController: MCBrowserViewController!)  {
            // Called when the browser view controller is dismissed (ie the Done
            // button was tapped)
            
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func browserViewControllerWasCancelled(
        browserViewController: MCBrowserViewController!)  {
            // Called when the browser view controller is cancelled
            
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.Landscape.toRaw())
        } else {
            return Int(UIInterfaceOrientationMask.All.toRaw())
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
        
    func loadAds() {
        
        adBannerView = ADBannerView(adType: ADAdType.MediumRectangle)
        adBannerView.center = CGPoint(x: view.bounds.size.width - 175, y: view.bounds.size.height - (adBannerView.frame.size.height / 2) - 25)
        adBannerView.delegate = self
        adBannerView.hidden = false
        
        view.addSubview(adBannerView)
    }
    
}
