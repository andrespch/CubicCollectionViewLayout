//
//  CubicCollectionViewLayout.swift
//  CubicCollectionViewLayout
//
//  Created by andres portillo on 1/7/17.
//  Copyright © 2017 andres portillo. All rights reserved.
//

import UIKit
class CubicCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    var radians: CGFloat = 0.0
    var anchorPoint: CGPoint = CGPoint(x: 0.5, y: 0.5)
    override func copy(with zone: NSZone? = nil) -> Any {
        let attr =  super.copy(with: zone) as! CubicCollectionViewLayoutAttributes
        attr.anchorPoint = self.anchorPoint
        attr.radians = self.radians
        return attr
    }
}

open class CubicCollectionViewLayout: UICollectionViewLayout {
    
   var attributes = [CubicCollectionViewLayoutAttributes]()
    
    override init() {
        super.init()
        commonInit()
    }
    
    required public
    init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
    }
    
    fileprivate var itemWidth: CGFloat {
        return collectionView!.bounds.size.width
    }
    
    fileprivate var itemHeight: CGFloat {
        return collectionView!.bounds.size.height
    }
    
    fileprivate let maxAngle: CGFloat = 90.0
    
    private var numberOfItems: Int {
        return collectionView!.numberOfItems(inSection: 0)
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributes
    }
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributes[indexPath.row]
    }
    
    override open class var layoutAttributesClass: AnyClass {
        return CubicCollectionViewLayoutAttributes.self
    }
    
    open override var collectionViewContentSize: CGSize {
        return CGSize(width: CGFloat(numberOfItems) * itemWidth, height: itemHeight)
    }
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override open func prepare() {
        super.prepare()

        if attributes.isEmpty {
            for index in 0..<numberOfItems {
                let indexPath = IndexPath(item: index, section: 0)
                let itemAttributes = attributesForItem(at: indexPath)
                attributes.append(itemAttributes)
            }
        } else {
            for indexPath in collectionView!.indexPathsForVisibleItems {
                let itemAttributes = attributesForItem(at: indexPath)
                attributes[indexPath.row] = itemAttributes
            }
        }
    }
    
    fileprivate func attributesForItem(at indexPath: IndexPath) -> CubicCollectionViewLayoutAttributes {
        let itemAttributes = CubicCollectionViewLayoutAttributes(forCellWith: indexPath)
        let angle = angleForCell(at: indexPath)

        let anchorX:CGFloat
        if page >= CGFloat(indexPath.row) { // Current page
            anchorX = 1.0
        } else if (page < CGFloat(indexPath.row)) && (page + 1 > CGFloat(indexPath.row)) { // Page moving into the scren
            anchorX = 0.0
        } else { // Pages not yet shown
            anchorX = 0.5
        }

        itemAttributes.radians = angle.toRadians()
        
        itemAttributes.anchorPoint = CGPoint(x: anchorX, y: 0.5)
        var transform = CATransform3DIdentity
        transform.m34 = 1/500
        itemAttributes.zIndex = indexPath.row
        transform = CATransform3DRotate(transform, angle.toRadians(), 0, 1, 0)
        itemAttributes.transform3D = transform
        itemAttributes.size = CGSize(width: itemWidth, height: itemHeight)
        
        let centerDiff = anchorX == 1 ? itemWidth/2 : (anchorX == 0.5 ? 0.0 : -itemWidth/2)
        var centerX = (itemWidth * CGFloat(indexPath.row) + itemWidth/2)
        centerX += centerDiff
       
        itemAttributes.center = CGPoint(x: centerX, y: itemHeight/2)
        return itemAttributes
    }
}

extension CGFloat {
    fileprivate func toRadians() -> CGFloat {
        return (self * CGFloat(M_PI)) / 180.0
    }
}

// MARK: - Helpers
extension CubicCollectionViewLayout {
    fileprivate func angleForCell(at indexPath: IndexPath) -> CGFloat {
        let p = transitionProgressForCell(at: indexPath)
        return maxAngle * p
    }
    
    fileprivate var page: CGFloat {
        return CGFloat(collectionView!.contentOffset.x / collectionView!.frame.width)
    }
    
    fileprivate func transitionProgressForCell(at indexPath: IndexPath) -> CGFloat {
        let offsetX = collectionView!.contentOffset.x
        let cellX1 = CGFloat(indexPath.row) * collectionView!.frame.width
        let x1 = offsetX
        let x2 = (offsetX + itemWidth)
        
        if x1 > cellX1 { //cell is shown or on its way to being hidden
            let p = (x1 - cellX1) / itemWidth
            return p
        } else if x2 > cellX1 {// cell is ahead of contentOffset.x
            let p = (x2 - cellX1) / itemWidth
            return -1 * (1 - p)
        }
        return 0
    }
}
