//
//  UIImage-Extension.swift
//  DressTime
//
//  Created by Fab on 28/09/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit
import ImageIO

extension UIImage {
    func imageWithImage(_ i_width: CGFloat) -> UIImage
    {
        let oldWidth = self.size.width;
        let scaleFactor = i_width / oldWidth;
    
        let newHeight = self.size.height * scaleFactor;
        let newWidth = oldWidth * scaleFactor;
    
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight));
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage!;
    }

    func imageResize (_ sizeChange:CGSize)-> UIImage{
        var ratio:CGFloat = 1.0
        if (self.size.width > sizeChange.width){
            ratio = self.size.width/sizeChange.width
        }
        let newWidth = self.size.width/CGFloat(ratio);
        let newHeight = self.size.height/CGFloat(ratio);
        
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
    
    func optimizedResize() -> UIImage {
        let size = self.size.applying(CGAffineTransform(scaleX: 0.5, y: 0.5))
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
    
    func resize(_ sizeChange:CGSize) -> UIImage? {        
        if let imageSource = CGImageSourceCreateWithData(UIImageJPEGRepresentation(self, 1.0)! as CFData, nil) {
            let options: [NSString: NSObject] = [
                kCGImageSourceCreateThumbnailWithTransform:true as NSObject,
                kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height)/2.0 as NSObject,
                kCGImageSourceCreateThumbnailFromImageAlways: true as NSObject
            ]
            
            let scaledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary?).flatMap { UIImage(cgImage: $0) }
            return scaledImage
        }
        return nil
    }
    
}
