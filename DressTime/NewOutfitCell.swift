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
    
    func createClotheView(clothe: Clothe, rect: CGRect){
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
        imageView.image = UIImage(data: clothe.clothe_image)!.imageResize(CGSizeMake(rect.size.width, 160.0))
        imageView.contentMode = .Top
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        containerView.addSubview(view)
    }
    
    func removeOldImages(){
        for var item in containerView.subviews {
            item.removeFromSuperview()
        }
    }
}