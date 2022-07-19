//
//  ChatCollectionViewFlowLayout.swift
//  MMTextureChat
//
//  Created by Mukesh on 11/07/17.
//  Copyright © 2017 MadAboutApps. All rights reserved.
//

import UIKit

public class ChatCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    private var topMostVisibleItem    =  Int.max
    private var bottomMostVisibleItem = -Int.max
    
    private var offset: CGFloat = 0.0
    private var visibleAttributes: [UICollectionViewLayoutAttributes]?
    
    private var isInsertingItemsToTop    = false
    private var isInsertingItemsToBottom = false
    
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        // Reset each time all values to recalculate them
        // ════════════════════════════════════════════════════════════
        
        // Get layout attributes of all items
        visibleAttributes = super.layoutAttributesForElements(in: rect)
        
        // Erase offset
        offset = 0.0
        
        // Reset inserting flags
        isInsertingItemsToTop    = false
        isInsertingItemsToBottom = false
        
        return visibleAttributes
    }
    
    override public func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        
        // Check where new items get inserted
        // ════════════════════════════════════════════════════════════
        
        // Get collection view and layout attributes as non-optional object
        guard let collectionView = self.collectionView       else { return }
        guard let visibleAttributes = self.visibleAttributes else { return }
        
        
        // Find top and bottom most visible item
        // ────────────────────────────────────────────────────────────
        
        bottomMostVisibleItem = -Int.max
        topMostVisibleItem    =  Int.max
        
        let container = CGRect(x: collectionView.contentOffset.x,
                               y: collectionView.contentOffset.y,
                               width:  collectionView.frame.size.width,
                               height: (collectionView.frame.size.height - (collectionView.contentInset.top + collectionView.contentInset.bottom)))
        
        for attributes in visibleAttributes {
            
            // Check if cell frame is inside container frame
            if attributes.frame.intersects(container) {
                let item = attributes.indexPath.item
                if item < topMostVisibleItem    { topMostVisibleItem    = item }
                if item > bottomMostVisibleItem { bottomMostVisibleItem = item }
            }
        }
        
        
        // Call super after first calculations
        super.prepare(forCollectionViewUpdates: updateItems)
        
        
        // Calculate offset of inserting items
        // ────────────────────────────────────────────────────────────
        
        var willInsertItemsToTop    = false
        
        willInsertItemsToTop = updateItems[0].indexPathAfterUpdate?.item == 0
        
        // Pass on information if items need more than one screen
        // ────────────────────────────────────────────────────────────
        
        // Just continue if one flag is set
        if willInsertItemsToTop {
            
            // Get heights without top and bottom
            let collectionViewContentHeight = collectionView.contentSize.height
            let collectionViewFrameHeight   = collectionView.frame.size.height - (collectionView.contentInset.top + collectionView.contentInset.bottom)
            
            // Continue only if the new content is higher then the frame
            // If it is not the case the collection view can display all cells on one screen
            if collectionViewContentHeight + offset > collectionViewFrameHeight {
                
                if willInsertItemsToTop {
                    CATransaction.begin()
                    CATransaction.setDisableActions(true)
                    isInsertingItemsToTop = true
                    
                }
            }
        }
    }
    
    override public func finalizeCollectionViewUpdates() {
        
        // Set final content offset with animation or not
        // ════════════════════════════════════════════════════════════
        
        // Get collection view as non-optional object
        guard let collectionView = self.collectionView else { return }
        
        if isInsertingItemsToTop {
            
            // Calculate new content offset
            let newContentOffset = CGPoint(x: collectionView.contentOffset.x,
                                           y: collectionView.contentOffset.y + offset)
            
            // Set new content offset without animation
            collectionView.contentOffset = newContentOffset
            
            // Commit/end transaction
            CATransaction.commit()
            
        } else if isInsertingItemsToBottom {
            
            // Calculate new content offset
            // Always scroll to bottom
            let newContentOffset = CGPoint(x: collectionView.contentOffset.x,
                                           y: collectionView.contentSize.height + offset - collectionView.frame.size.height + collectionView.contentInset.bottom)
            
            // Set new content offset with animation
            //            collectionView.setContentOffset(newContentOffset, animated: true)
        }
    }
}


