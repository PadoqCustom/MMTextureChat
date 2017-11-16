//
//  Message.swift
//  gameofchats
//
//  Created by Brian Voong on 7/7/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit


public class MMMessage: NSObject {
    
    public var isOutgoing: Bool = false
    public var text: NSAttributedString?
    public var bottomStatusText: String?
    public var name : String?
    public var sectionStamp : String?
    public var userImgURL : String?
    public var userImage: UIImage?
    
    //if image cell
    public var imageUrl: String?
    public var image: UIImage?
    public var imageWidth: NSNumber?
    public var imageHeight: NSNumber?
    
    //if video cell
    public var videoUrl: String?
    
    public init(text: NSAttributedString?, name: String?, bottomText: String?, sectionText: String?, isOutgoing: Bool, userImage: UIImage?, userImageURL: String?, imageUrl: String?, image: UIImage?, imageWidth: NSNumber?, imageHeight: NSNumber?, videoUrl: String?) {
        super.init()
        self.isOutgoing = isOutgoing
        self.text = text
        self.bottomStatusText = bottomText
        self.name = name
        self.sectionStamp = sectionText
        self.userImgURL = userImageURL
        self.userImage = userImage
        self.imageUrl = imageUrl
        self.image = image
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.videoUrl = videoUrl
        
    }
    
    public convenience init(text: NSAttributedString, name: String?, isOutgoing: Bool, userImage: UIImage?) {
        self.init(text: text, name: name, bottomText: nil, sectionText: nil, isOutgoing: isOutgoing, userImage: userImage, userImageURL: nil, imageUrl: nil, image: nil, imageWidth: nil, imageHeight: nil, videoUrl: nil)
    }
    
    public init(image : String){
        super.init()
        self.imageUrl = image
        setdemodata(time: "", stamp: "", name: "Mukesh")
    }
    
    
    public init(image : String , caption : String){
        super.init()
        
        self.imageUrl = image
        self.text = NSAttributedString(string : caption)
        setdemodata(time: "", stamp: "Monday, Jun 4th", name: "Mandy")
        
    }
    
    
    public init(msg : String){
        super.init()
        
        self.text = NSAttributedString(string : msg , attributes : kAMMessageCellNodeBubbleAttributes)
        setdemodata(time: "", stamp: "", name: "Muks")
        
        
    }
    
    
    public init(videourl : String){
        super.init()
        
        self.videoUrl = videourl
        setdemodata(time: "", stamp: "Today", name: "Honey")
        
    }
    
    
    func setdemodata(time : String , stamp : String , name : String){
        self.bottomStatusText = nil
        if(stamp != ""){
            self.sectionStamp = stamp
            
        }
        self.name = name
        self.userImgURL = "https://static.tvtropes.org/pmwiki/pub/images/hero_ironman01.png"
    }
    
    
    
}


