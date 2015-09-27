//
//  OverlayView.swift
//  CustomCamera
//
//  Created by Fab on 11/07/2015.
//
//

import Foundation
import UIKit

class OverlayView: UIView {
    var rectForClearing: CGRect!
    var overallColor: UIColor!
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        // Initialization code
        self.backgroundColor = UIColor.clearColor()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)!
        self.backgroundColor =  UIColor.clearColor()
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let ct = UIGraphicsGetCurrentContext();
        CGContextSetBlendMode(ct, CGBlendMode.Multiply);
        CGContextSetAlpha(ct, 0.4)
        CGContextSetFillColorWithColor(ct, UIColor.blackColor().CGColor);
        //
        CGContextFillRect(ct, self.bounds);
        CGContextClearRect(ct, self.rectForClearing);
        UIGraphicsEndImageContext()
    }

}