//
//  ClotheCalendarCell.swift
//  DressTime
//
//  Created by Fab on 13/02/2016.
//  Copyright © 2016 Fab. All rights reserved.
//

import Foundation
import UIKit

class ClotheCalendarCell : UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.containerView.roundCorners(UIRectCorner.AllCorners, radius: 5.0)
        self.containerView.layer.masksToBounds = true
        self.containerView.clipsToBounds = true
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
    
    
    func createClotheView(clothe: Clothe, rect: CGRect){
        let view = UIView(frame: rect)
        view.backgroundColor = UIColor.clearColor()
        view.roundCorners(UIRectCorner.AllCorners, radius: 5.0)
        view.layer.masksToBounds = true
        
        var img = clothe.getImage()
        
        var mode = UIViewContentMode.Top
        if (rect.size.height != self.containerView.frame.size.height){
            img = img.imageResize(CGSizeMake(rect.size.width, rect.size.height))
            //img = img.resize(CGSizeMake(rect.size.width, rect.size.height))!
        } else {
            mode = UIViewContentMode.ScaleToFill
        }
        
        let imageView = UIImageView(frame: CGRectMake(0, 0, rect.size.width, rect.size.height))
        imageView.image = img
        imageView.contentMode = mode
        
        applyPlainShadow(view)
        view.addSubview(imageView)
        self.containerView.addSubview(view)
    }
    
    func setLoadNecessaryImage(imageNamed: String, type: String, rect: CGRect){
        let view = UIView(frame: rect)
        view.backgroundColor = UIColor.clearColor()
        view.roundCorners(UIRectCorner.AllCorners, radius: 5.0)
        view.layer.masksToBounds = true
        view.accessibilityIdentifier = type
        let gesture = UITapGestureRecognizer(target: self, action: #selector(ClotheCalendarCell.someAction(_:)))
        view.addGestureRecognizer(gesture)
        
        let img = UIImage(named: imageNamed)!
        let imageView = UIImageView(frame: CGRectMake(0, 0, rect.size.width, rect.size.height))
        imageView.backgroundColor = UIColor.clearColor()
        imageView.opaque = false
        imageView.image = img
        imageView.contentMode = UIViewContentMode.ScaleToFill
        view.addSubview(imageView)
        self.contentView.addSubview(view)
    }
    
    
    func removeOldImages(){
        for item in self.containerView.subviews {
            item.removeFromSuperview()
        }
    }
    
    func someAction(sender:UITapGestureRecognizer){
        // do other task
        print(sender.view?.accessibilityIdentifier)
       /* if let del = self.delegate {
            del.outfitCell(self, typeSelected: sender.view!.accessibilityIdentifier!)
        } */
    }
}