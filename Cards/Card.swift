//
//  Card.swift
//  Cards
//
//  Created by Eric Williams on 9/23/14.
//  Copyright (c) 2014 Eric Williams. All rights reserved.
//

import UIKit


class Card: NSObject {
    
    var name = ""
    var type = ""
    var value = ""

    override init() {
    
    }
        
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("name") as! String
        type = aDecoder.decodeObjectForKey("type") as! String
        value = aDecoder.decodeObjectForKey("value") as! String

        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(type, forKey: "type")
        aCoder.encodeObject(value, forKey: "value")

    }

    
    func image() -> UIImage {
        
        return UIImage(named: name + type)!
    }
    
    func cardView() -> UIImageView {
        
        let view = UIImageView(image: self.image())
        view.frame = CGRectMake(10, 10, 195, 284)
        view.userInteractionEnabled = true
        
        return view
        
    }
    
    func backView() -> UIImageView {
        
        let view = UIImageView(image: UIImage(named: "cardDown"))
        view.frame = CGRectMake(10, 10, 200, 300)
        view.userInteractionEnabled = true

        
        return view
        
    }
    
    
}
