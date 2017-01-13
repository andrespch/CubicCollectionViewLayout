//
//  CubicCell.swift
//  CubicCell
//
//  Created by andres portillo on 1/7/17.
//  Copyright © 2017 andres portillo. All rights reserved.
//

import UIKit

open class CubicCell: UICollectionViewCell {
    override open func prepareForReuse() {
        super.prepareForReuse()
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    override open func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let cubicAttributes = layoutAttributes as? CubicCollectionViewLayoutAttributes else { fatalError("LayoutAttributes of class CubicCollectionViewLayoutAttributes expected") }
        layer.anchorPoint = cubicAttributes.anchorPoint
    }
}
