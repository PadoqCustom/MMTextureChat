//
//  Message.swift
//  gameofchats
//
//  Created by Brian Voong on 7/7/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit


class Message: NSObject {

    var isOutgoing: Bool = false
    var text: NSAttributedString?
    var bottomStatusText: String?
    var name : String?
    var sectionStamp : String?
    var userImgURL : String?
    var userImage: UIImage?
    
    //if image cell
    var imageUrl: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    
    //if video cell
    var videoUrl: String?
    
    

    
    init(image : String){
        super.init()
        self.imageUrl = image
        setdemodata(time: "", stamp: "", name: "Mukesh")
    }
    
    
    init(image : String , caption : String){
        super.init()

        self.imageUrl = image
        self.text = NSAttributedString(string : caption)
        setdemodata(time: "", stamp: "Monday, Jun 4th", name: "Mandy")

    }
    
    
    init(msg : String){
        super.init()

        self.text = NSAttributedString(string : msg , attributes : kAMMessageCellNodeBubbleAttributes)
        setdemodata(time: "", stamp: "", name: "Muks")


    }
    
    
    init(videourl : String){
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
