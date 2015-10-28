//
//  NewOutfitCell.swift
//  DressTime
//
//  Created by Fab on 23/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class NewOufitCell: UICollectionViewCell {
    
    @IBOutlet weak var styleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        
    }
    
    func createClotheView(clothe: Clothe, style: String,  rect: CGRect){
        let view = UIView(frame: rect)
        view.backgroundColor = UIColor.clearColor()
        view.roundCorners(UIRectCorner.AllCorners, radius: 3.0)
        view.clipsToBounds = true
        
        view.layer.masksToBounds = false
        view.layer.shadowOffset = CGSizeMake(-15, 20)
        view.layer.shadowRadius = 5
        view.layer.shadowOpacity = 0.5
        view.layer.shadowPath = UIBezierPath(rect: self.bounds).CGPath
        
        let imageView = UIImageView(frame: CGRectMake(0, 0, rect.size.width, rect.size.height))
        var img = UIImage(data: clothe.clothe_image)!
        
        var mode = UIViewContentMode.Top
        if (rect.size.height != containerView.frame.size.height){
            img = img.imageResize(CGSizeMake(rect.size.width, 160.0))
        } else {
            mode = UIViewContentMode.ScaleToFill
        }
        
        imageView.image = img
        imageView.contentMode = mode
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        containerView.addSubview(view)
        
        self.styleLabel.text = style
    }
    
    func setBrandClothe(image: String, partnerName: String, rate: Int, rect: CGRect){
        if let data: NSData = NSData(base64EncodedString: image, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters) {
            
            let view = UIView(frame: rect)
            view.backgroundColor = UIColor.clearColor()
            view.roundCorners(UIRectCorner.AllCorners, radius: 3.0)
            view.clipsToBounds = true
            
            view.layer.masksToBounds = false
            view.layer.shadowOffset = CGSizeMake(-15, 20)
            view.layer.shadowRadius = 5
            view.layer.shadowOpacity = 0.5
            view.layer.shadowPath = UIBezierPath(rect: self.bounds).CGPath
            
            let imageView = UIImageView(frame: CGRectMake(0, 0, rect.size.width, rect.size.height))
            var img = UIImage(data: data)!
            
            var mode = UIViewContentMode.Top
            if (rect.size.height != containerView.frame.size.height){
                img = img.imageResize(CGSizeMake(rect.size.width, 160.0))
            } else {
                mode = UIViewContentMode.ScaleToFill
            }
            
            imageView.image = img
            imageView.contentMode = mode
            imageView.clipsToBounds = true
            view.addSubview(imageView)
            containerView.addSubview(view)
            
            self.styleLabel.text = partnerName
        }
        
    }
    
    func removeOldImages(){
        for var item in containerView.subviews {
            item.removeFromSuperview()
        }
    }
}