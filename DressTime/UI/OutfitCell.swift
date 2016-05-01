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
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var containerMomentImage: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var momentLabel: UILabel!
    
    var delegate: OutfitCellDelegate?
    private let BL = DressTimeBL()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkImageView.hidden = true
        containerMomentImage.roundCorners(.AllCorners, radius: 27.5)
    }
    
    func createOutfitView(outfit: Outfit, cell: OufitCell){
        var j = 1
        let dal = ClothesDAL()
        for i in (outfit.clothes.count-1).stride(to: 0, by: -1) {
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
        self.setMomentIcon(outfit.moment!)
        self.putOnStyle(outfit.isPutOn)
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
        
    private func putOnStyle(isPutOn: Bool){
        if (isPutOn){
            self.containerView.layer.borderWidth = 5.0
            self.containerView.layer.cornerRadius = 3.0
            self.containerView.layer.borderColor = UIColor.dressTimeOrange().CGColor
            checkImageView.hidden = false
        } else {
            self.containerView.layer.borderWidth = 0.0
            self.containerView.layer.cornerRadius = 0.0
            self.containerView.layer.borderColor = UIColor.clearColor().CGColor
            checkImageView.hidden = true
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