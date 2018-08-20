//
//  MessageTextBubbleNode.swift
//  MMTextureChat
//
//  Created by Mukesh on 11/07/17.
//  Copyright © 2017 MadAboutApps. All rights reserved.
//

import UIKit
import AsyncDisplayKit

public class MessageTextBubbleNode: ASDisplayNode , ASTextNodeDelegate{
    
    private let isOutgoing: Bool
    private let bubbleImageNode: ASImageNode
    private let textNode: ASTextNode
    
    public init(text: NSAttributedString, isOutgoing: Bool, bubbleImage: UIImage, linkColor: UIColor = .blue) {
        self.isOutgoing = isOutgoing
        
        bubbleImageNode = ASImageNode()
        bubbleImageNode.image = bubbleImage
        
        
        textNode = MessageTextNode()
        
        let attr = NSMutableAttributedString(attributedString: text)
        
        if isOutgoing {
            attr.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: text.length))
        }
        
        textNode.attributedText = attr
        
        super.init()
        
        addSubnode(bubbleImageNode)
        addSubnode(textNode)
        
        //target delegate
        textNode.isUserInteractionEnabled = true
        textNode.delegate = self
        let linkcolor = isOutgoing ? UIColor.white : linkColor
        textNode.addLinkDetection(attr.string, highLightColor: linkcolor)
        textNode.addUserMention(highLightColor: linkcolor)
        
    }
    
    
    override public func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let textNodeVerticalOffset = CGFloat(6)
        
        return ASBackgroundLayoutSpec(
            child: ASInsetLayoutSpec(
                insets: UIEdgeInsetsMake(
                    8,
                    12 + (isOutgoing ? 0 : textNodeVerticalOffset),
                    8,
                    12 + (isOutgoing ? textNodeVerticalOffset : 0)),
                child: textNode),
            background: bubbleImageNode)
    }
    
    
    //MARK: - Text Delegate
    
    public func textNode(_ textNode: ASTextNode, shouldHighlightLinkAttribute attribute: String, value: Any, at point: CGPoint) -> Bool {
        return true
    }
    
    public func textNode(_ textNode: ASTextNode, tappedLinkAttribute attribute: String, value: Any, at point: CGPoint, textRange: NSRange) {
        guard let url = value as? URL else {return}
        UIApplication.shared.openURL(url)

    }
}
