//
//  UIView+Dresstime.swift
//  DressTime
//
//  Created by Fab on 22/11/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.CGPath
        self.layer.mask = mask
    }
}