//
//  WeatherLayout.swift
//  weather report
//
//  Created by alex surmava on 15.02.25.
//

import UIKit

class WeatherLayout: UICollectionViewFlowLayout {

    private var itemWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        return collectionView.frame.width * 0.75
    }
    
    private var itemHeight: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        return collectionView.frame.height * 0.70
    }
    
    override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    private func setupLayout() {
        scrollDirection = .horizontal
        minimumLineSpacing = 20
    }
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        
        itemSize = CGSize(width: itemWidth, height: itemHeight)
        
        let horizontalInset = (collectionView.frame.width - itemWidth) / 2
        sectionInset = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect),
              let collectionView = collectionView else { return nil }
        
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        
        attributes.forEach { attribute in
            let distanceFromCenter = abs(attribute.center.x - centerX)
            let scale = max(1 - (distanceFromCenter / collectionView.bounds.width) * 0.3, 0.85)
            attribute.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        
        return attributes
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                    withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return proposedContentOffset }
        let targetRect = CGRect(x: proposedContentOffset.x,
                              y: 0,
                              width: collectionView.bounds.width,
                              height: collectionView.bounds.height)
        
        guard let layoutAttributes = layoutAttributesForElements(in: targetRect) else {
            return proposedContentOffset
        }

        let centerX = proposedContentOffset.x + collectionView.bounds.width / 2
        let closestAttribute = layoutAttributes
            .min(by: { abs($0.center.x - centerX) < abs($1.center.x - centerX) })
        
        guard let closestAttribute = closestAttribute else { return proposedContentOffset }
        
        let targetOffsetX = closestAttribute.center.x - collectionView.bounds.width / 2
        return CGPoint(x: targetOffsetX, y: proposedContentOffset.y)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
