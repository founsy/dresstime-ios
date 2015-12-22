//
//  CurveArrowView.swift
//  DressTime
//
//  Created by Fab on 17/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import UIKit

class CurveArrowView: UIView {
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 1.0)
        CGContextSetStrokeColorWithColor(context,
            UIColor.whiteColor().CGColor)
        
        
        let midPointX = 0.5 * rect.width
        let midPointY = 0.7 * rect.height

        CGContextMoveToPoint(context, 10, rect.height);
        CGContextAddQuadCurveToPoint(context, midPointX, midPointY, rect.width - 10, 0);
        CGContextStrokePath(context)
        
        CGContextMoveToPoint(context, rect.width - 10, 0);
        CGContextAddLineToPoint(context, rect.width - 20, 10);
        CGContextStrokePath(context)
        
        CGContextMoveToPoint(context, rect.width - 10, 0);
        CGContextAddLineToPoint(context, rect.width - 10, 10);
        CGContextStrokePath(context)

        
        
    }
}