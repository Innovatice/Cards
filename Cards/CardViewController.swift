//
//  CardViewController.swift
//  Cards
//
//  Created by Eric Williams on 9/24/14.
//  Copyright (c) 2014 Eric Williams. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class CardViewController: UIViewController, MCBrowserViewControllerDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    let playerConnect = PlayerConnect()
    
    var cardHolderScroll = UIScrollView()
    var cardsInHand: [Card] = []
    var cardViewArray: [UIView] = []
    var activePlayer: Bool = false
    var connectionLabel: UILabel!
    var connectionDot: UIView!
    var numCardsToSend: Int = 0
    var cardCount: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 0.090, green: 0.459, blue: 0.580, alpha: 1.0)
        
        connectionLabel = UILabel(frame: CGRectMake(60, 260, 150, 50))
        connectionLabel.backgroundColor = UIColor.clearColor()
        connectionLabel.text = "Connecting..."
        connectionLabel.textColor = UIColor.whiteColor()
        connectionLabel.font = UIFont(name: "HelveticaNeue", size: 24)
        self.view.addSubview(connectionLabel)
        
        connectionDot = UIView(frame: CGRectMake(20, 270, 30, 30))
        connectionDot.backgroundColor = UIColor.redColor()
        connectionDot.layer.cornerRadius = 15
        self.view.addSubview(connectionDot)
        
        cardHolderScroll.frame = self.view.frame
        cardHolderScroll.pagingEnabled = true
        
        cardCount = UILabel(frame: CGRectMake((SCREEN_WIDTH - 50) / 2.0 + 250, 10, 50, 50))
        cardCount.backgroundColor = UIColor(red: 0.600, green: 0.145, blue: 0.114, alpha: 1.0)
        cardCount.layer.cornerRadius = 25
        cardCount.layer.masksToBounds = true
        cardCount.textAlignment = .Center
        cardCount.font = UIFont(name: "HelveticaNeue-light", size: 24)
        cardCount.textColor = UIColor.whiteColor()
        
        
        NSNotificationCenter.defaultCenter().addObserverForName("CardHolderSetGameboard", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            
            let gbID = notification.userInfo!["GameboardPeerID"] as! MCPeerID
            
            GameDeviceInfo.gameDI().gameBoardID = gbID
            self.connectionLabel.text = "Connected"
            self.connectionDot.backgroundColor = UIColor.greenColor()
            self.view.backgroundColor = UIColor(patternImage: (UIImage(named: "cardholderbackground"))!)

        }
        
        NSNotificationCenter.defaultCenter().addObserverForName("CardHolderCardsToPlay", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            
            let num = notification.userInfo!["num"] as! NSString
            self.numCardsToSend = Int(num.intValue)
            
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName("CardHolderDealCard", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            
            let card = notification.userInfo!["card"] as! Card
            
            self.cardsInHand.append(card)
            
            self.cardCount.text = String(self.cardsInHand.count)
            
            self.connectionDot.removeFromSuperview()
            self.connectionLabel.removeFromSuperview()
            
            if self.cardsInHand.count == 52 {
                
                print("You Win")
                
                let winnerAlert = UIView(frame: CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT))
                winnerAlert.backgroundColor = UIColor.whiteColor()
                winnerAlert.alpha = 0.88
                self.view.addSubview(winnerAlert)
            }
            
            print(card.name)
            print(notification.userInfo!["peerID"] as! MCPeerID)
            
            let cardView = card.backView()
            
            self.addSwipeToFirstCard()
            
            let padding: CGFloat = (SCREEN_HEIGHT - 300) / 2.0
            
            cardView.frame.origin.x = CGFloat(60 * (self.cardsInHand.count - 1)) + padding
            cardView.frame.origin.y = -400

            self.cardViewArray.append(cardView)
            self.cardHolderScroll.addSubview(cardView)
            self.cardHolderScroll.insertSubview(cardView, atIndex: 0)
            
            
            UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                
                for cardView in self.cardViewArray {
                    
                    cardView.frame.origin.y = padding
                }
                
            }, completion: nil)
            
            self.cardHolderScroll.contentSize = CGSizeMake(CGFloat(self.cardsInHand.count) * 60, 200)
            self.cardHolderScroll.frame.size.width = 320
            self.cardHolderScroll.clipsToBounds = false
            
            print(self.cardsInHand.count)
            
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName("CardHolderSetActive", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            
            self.activePlayer = true
            
        }
        
        self.view.addSubview(cardHolderScroll)
        self.view.addSubview(cardCount)
        
    }
    
    func addSwipeToFirstCard() {
        
        if cardViewArray.count == 0 { return }
        
        let swipeCardUp = UISwipeGestureRecognizer(target: self, action: Selector("swipeCardToTable:"))
        swipeCardUp.direction = UISwipeGestureRecognizerDirection.Up
        
        cardViewArray[0].addGestureRecognizer(swipeCardUp)
        
        
    }
    
    func swipeCardToTable(gestureRecognizer: UISwipeGestureRecognizer) {
        
        if self.cardsInHand.count > 0 && numCardsToSend > 0 {
            
            activePlayer = false
            numCardsToSend--
            
            print(GameDeviceInfo.gameDI().gameBoardID)
            
            let card = self.cardsInHand[0]
            self.cardsInHand.removeAtIndex(0)
            
            self.cardCount.text = String(self.cardsInHand.count)
            
            self.cardHolderScroll.contentSize = CGSizeMake(CGFloat(self.cardsInHand.count) * 60, 200)

            
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                
                self.cardViewArray[0].frame.origin.y = -400
                
                }, completion: { (success) -> Void in
                    
                    self.cardViewArray[0].removeFromSuperview()
                    self.cardViewArray.removeAtIndex(0)
                    
                    self.playerConnect.sendInfo(["action":"PlayCard","card":card], toPeer: GameDeviceInfo.gameDI().gameBoardID)

                    
                    UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                        
                        for cardView in self.cardViewArray {
                            
                            cardView.frame.origin.x -= 60
                        }
                        
                        }, completion: { (success) -> Void in
                            
                            self.addSwipeToFirstCard()
                    })

            })
        }
    }
    
    func browserViewControllerDidFinish(
        browserViewController: MCBrowserViewController)  {
            // Called when the browser view controller is dismissed (ie the Done
            // button was tapped)
            
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func browserViewControllerWasCancelled(
        browserViewController: MCBrowserViewController)  {
            // Called when the browser view controller is cancelled
            
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    override func shouldAutorotate() -> Bool {
        return true
    }
    
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return UIInterfaceOrientationMask.AllButUpsideDown
        } else {
            return UIInterfaceOrientationMask.All
        }
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
}