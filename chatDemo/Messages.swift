//
//  Message.swift
//  chatDemo
//
//  Created by Sundevs on 3/6/17.
//  Copyright © 2017 Sundevs. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {

    var fromId:String?
    var text:String?
    var timestamp:NSNumber?
    var toId:String?
    
    var imageUrl:String?
    
    var imageHeight:NSNumber?
    var imageWidth:NSNumber?
    
    var videoUrl:String?
    
    func chatpatnerId() -> String? {
        
        return fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId
    }
    
    init(dictionary: [String:AnyObject]) {
        super.init()
        
        fromId = dictionary["fromId"] as? String
        text = dictionary["text"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        toId = dictionary["toId"] as? String
        
        imageUrl = dictionary["imageUrl"] as? String
        imageHeight = dictionary["imageHeight"] as? NSNumber
        imageWidth = dictionary["imageWidth"] as? NSNumber
        
        self.videoUrl = dictionary["videoUrl"] as? String

    }

}
