//
//  OufitCell.swift
//  DressTime
//
//  Created by Fab on 23/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

protocol OutfitCellDelegate {
    func outfitCell(outfitCell : UICollectionViewCell, typeSelected type: String)
}

class OufitCell: UICollectionViewCell {
    
    @IBOutlet weak var styleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    var delegate: OutfitCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func applyPlainShadow(view: UIView) {
        let layer = view.layer
        let shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: layer.cornerRadius)
        layer.masksToBounds = false
        layer.shadowColor = UIColor.blackColor().CGColor
        //layer.shadowOffset = CGSizeMake(0, 10)
        layer.shadowOpacity = 1
        layer.shadowRadius = 4
        layer.shouldRasterize = false
        layer.shadowPath = shadowPath.CGPath
    }

    
    func createClotheView(clothe: Clothe, style: String,  rect: CGRect){
        self.styleLabel.text = style.uppercaseString
        
        let view = UIView(frame: rect)
        view.backgroundColor = UIColor.clearColor()
        view.roundCorners(UIRectCorner.AllCorners, radius: 5.0)
        view.layer.masksToBounds = true
        
        var img = clothe.getImage()
        
        var mode = UIViewContentMode.Top
        if (rect.size.height != containerView.frame.size.height){
            img = img.imageResize(CGSizeMake(rect.size.width, rect.size.height))
        } else {
            mode = UIViewContentMode.ScaleToFill
        }
        
        let imageView = UIImageView(frame: CGRectMake(0, 0, rect.size.width, rect.size.height))
        imageView.image = img
        imageView.contentMode = mode

        applyPlainShadow(view)
        view.addSubview(imageView)
        containerView.addSubview(view)
    }
    
    func setLoadNecessaryImage(imageNamed: String, type: String, rect: CGRect){
        let view = UIView(frame: rect)
        view.backgroundColor = UIColor.clearColor()
        view.roundCorners(UIRectCorner.AllCorners, radius: 5.0)
        view.layer.masksToBounds = true
        view.accessibilityIdentifier = type
        let gesture = UITapGestureRecognizer(target: self, action: "someAction:")
        view.addGestureRecognizer(gesture)
        
        let img = UIImage(named: imageNamed)!
        let imageView = UIImageView(frame: CGRectMake(0, 0, rect.size.width, rect.size.height))
        imageView.backgroundColor = UIColor.clearColor()
        imageView.opaque = false
        imageView.image = img
        imageView.contentMode = UIViewContentMode.ScaleToFill
        view.addSubview(imageView)
        containerView.addSubview(view)
    }
    
    func setBrandClothe(image: String, partnerName: String, rate: Int, rect: CGRect){
        let view = UIView(frame: rect)
        view.backgroundColor = UIColor.clearColor()
        view.roundCorners(UIRectCorner.AllCorners, radius: 5.0)
        view.clipsToBounds = true
        
        view.layer.masksToBounds = false
        view.layer.shadowOffset = CGSizeMake(0, 20)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 1
        view.layer.shadowColor = UIColor.blackColor().CGColor
        view.layer.shadowPath = UIBezierPath(rect: self.bounds).CGPath
        
        let imageView = UIImageView(frame: CGRectMake(0, 0, rect.size.width, rect.size.height))
        imageView.layer.masksToBounds = false
        view.layer.shadowOffset = CGSizeMake(0, 20)
        imageView.layer.shadowRadius = 8
        imageView.layer.shadowOpacity = 1
        imageView.layer.shadowColor = UIColor.blackColor().CGColor
        imageView.layer.shadowPath = UIBezierPath(rect: self.bounds).CGPath
        var img = UIImage(named:image.stringByReplacingOccurrencesOfString(".jpg", withString: ""))
        
        var mode = UIViewContentMode.Top
        if (rect.size.height != containerView.frame.size.height){
            img = img!.imageResize(CGSizeMake(rect.size.width, 160.0))
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
    
    func removeOldImages(){
        for item in containerView.subviews {
            item.removeFromSuperview()
        }
    }
    
    func someAction(sender:UITapGestureRecognizer){
        // do other task
        print(sender.view?.accessibilityIdentifier)
        if let del = self.delegate {
            del.outfitCell(self, typeSelected: sender.view!.accessibilityIdentifier!)
        }
    }
}