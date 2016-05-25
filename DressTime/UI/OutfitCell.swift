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
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerMomentImage: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var momentLabel: UILabel!
    
    var delegate: OutfitCellDelegate?
    private let BL = DressTimeBL()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerMomentImage.roundCorners(.AllCorners, radius: 27.5)
    }
    
    func createOutfitView(outfit: Outfit, cell: OufitCell){
        var j = 1
        let dal = ClothesDAL()
        for i in (outfit.clothes.count-1).stride(through: 0, by: -1) {
            let clothe_id = outfit.clothes[i].clothe_id
            if let clothe = dal.fetch(clothe_id) {
                let width:CGFloat = cell.containerView.frame.width
                var height:CGFloat = CGFloat(cell.containerView.frame.height/CGFloat(outfit.clothes.count))
                let x:CGFloat = 0
                var y:CGFloat = 0
                
                if (outfit.clothes.count == 1){
                    height = cell.containerView.frame.height
                } else if (outfit.clothes.count == 2){
                    height = 186.6
                } else {
                    height = 143.3
                }
                
                if (i == 0){
                    y = 0
                } else if (outfit.clothes.count-1 == i) {
                    y = self.containerView.frame.height - height
                } else {
                    y = self.containerView.frame.height - (height * CGFloat(j)) + (height/2.0)
                }
                
                let rect = CGRectMake(x, y, width, height)
                j += 1
                
                self.createClotheView(clothe, rect: rect)
            }
        }
        self.putOnStyle(outfit.isPutOn, moment: outfit.moment!)
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

    
    private func createClotheView(clothe: Clothe, rect: CGRect){
         let view = UIView(frame: rect)
            view.backgroundColor = UIColor.clearColor()
            view.roundCorners(UIRectCorner.AllCorners, radius: 5.0)
            view.layer.masksToBounds = true
        
            var img = clothe.getImage()
        
            var mode = UIViewContentMode.Top
            if (rect.size.height != self.containerView.frame.size.height){
                img = img.imageResize(CGSizeMake(rect.size.width, rect.size.height))
            } else {
                mode = UIViewContentMode.ScaleToFill
            }
            
            let imageView = UIImageView(frame: CGRectMake(0, 0, rect.size.width, rect.size.height))
        
                imageView.image = img
                imageView.contentMode = mode
        
            self.applyPlainShadow(view)
            view.addSubview(imageView)
            self.containerView.addSubview(view)
    }
    
    private func setMomentIcon(moment: String){
        if (moment == "onParty"){
            momentLabel.text = NSLocalizedString("Moment_Party", comment: "PARTY").uppercaseString
            imageView.image = UIImage(named: "baloonIcon")
        } else if (moment == "atWork"){
            momentLabel.text = NSLocalizedString("Moment_Work", comment: "WORK").uppercaseString
             imageView.image = UIImage(named: "lampOutfitIcon")
            
        } else if (moment == "relax"){
            momentLabel.text = NSLocalizedString("Moment_Relax", comment: "RELAX").uppercaseString
            imageView.image = UIImage(named: "reclinerIcon")
            
        }
    
    }
        
    private func putOnStyle(isPutOn: Bool, moment: String){
        if (isPutOn){
            self.containerView.layer.borderWidth = 3.0
            self.containerView.layer.cornerRadius = 2.0
            self.containerView.layer.borderColor = UIColor.whiteColor().CGColor
            self.containerMomentImage.backgroundColor = UIColor.whiteColor()
            self.imageView.image = UIImage(named: "crossIcon")
            self.imageView.tintColor = UIColor.dressTimeRedBrand()
            self.momentLabel.textColor = UIColor.dressTimeRedBrand()
        } else {
            self.containerView.layer.borderWidth = 0.0
            self.containerView.layer.cornerRadius = 0.0
            self.containerView.layer.borderColor = UIColor.clearColor().CGColor
            self.containerMomentImage.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            setMomentIcon(moment)
            self.imageView.tintColor = UIColor.whiteColor()
            self.momentLabel.textColor = UIColor.whiteColor()
        }
    
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