//
//  CustomFlowLayout.swift
//  RotatoinViewSample
//
//  Created by jelee on 2023/04/24.
//

import Foundation

import UIKit

class CustomFlowLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        collectionView.clipsToBounds = false
        
        // セルのサイズ設定（はみ出し効果はここの幅を調整する）
        itemSize = CGSize(width: collectionView.bounds.width * 0.5, height: collectionView.bounds.height)
        
        // スクロール方向設定
        scrollDirection = .horizontal
        
        // セル間のスペーシング設定
        minimumLineSpacing = collectionView.bounds.width * 0.1
        
        // セクションインセット設定
        let inset = collectionView.bounds.width * 0.1
        sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        
        let proposedRect = CGRect(origin: CGPoint(x: proposedContentOffset.x, y: 0), size: collectionView.bounds.size)
        
        guard let layoutAttributes = layoutAttributesForElements(in: proposedRect) else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        
        var candidateAttributes: UICollectionViewLayoutAttributes?
        let proposedContentOffsetCenterX = proposedContentOffset.x + collectionView.bounds.width * 0.5
        
        for attributes in layoutAttributes {
            if attributes.representedElementCategory != .cell {
                continue
            }
            
            if candidateAttributes == nil {
                candidateAttributes = attributes
                continue
            }
            
            if abs(attributes.center.x - proposedContentOffsetCenterX) < abs(candidateAttributes!.center.x - proposedContentOffsetCenterX) {
                candidateAttributes = attributes
            }
        }
        
        return CGPoint(x: candidateAttributes!.center.x - collectionView.bounds.width * 0.5, y: proposedContentOffset.y)
    }
}
