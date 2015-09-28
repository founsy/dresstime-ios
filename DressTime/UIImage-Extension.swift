//
//  UIImage-Extension.swift
//  DressTime
//
//  Created by Fab on 28/09/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func imageWithImage(i_width: CGFloat) -> UIImage
    {
        let oldWidth = self.size.width;
        let scaleFactor = i_width / oldWidth;
    
        let newHeight = self.size.height * scaleFactor;
        let newWidth = oldWidth * scaleFactor;
    
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
        self.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
}