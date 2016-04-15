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

    func imageResize (sizeChange:CGSize)-> UIImage{
        var ratio:CGFloat = 1.0
        if (self.size.width > sizeChange.width){
            ratio = self.size.width/sizeChange.width
        }
        let newWidth = self.size.width/CGFloat(ratio);
        let newHeight = self.size.height/CGFloat(ratio);
        
        let newSize = CGSizeMake(newWidth, newHeight)
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        self.drawInRect(CGRect(origin: CGPointZero, size: newSize))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
}