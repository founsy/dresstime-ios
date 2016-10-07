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
    func outfitCell(_ outfitCell : UICollectionViewCell, typeSelected type: String)
}

class OufitCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerMomentImage: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var momentLabel: UILabel!
    
    var delegate: OutfitCellDelegate?
    fileprivate let BL = DressTimeBL()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerMomentImage.layer.cornerRadius = 27.5
    }
    
    func createOutfitView(_ outfit: Outfit, cell: OufitCell){
        var j = 1
        let dal = ClothesDAL()
        for i in stride(from: (outfit.clothes.count-1), through: 0, by: -1) {
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
                
                let rect = CGRect(x: x, y: y, width: width, height: height)
                j += 1
                
                self.createClotheView(clothe, rect: rect)
            }
        }
        self.putOnStyle(outfit.isPutOn, style: outfit.style)
    }
    
    fileprivate func createClotheView(_ clothe: Clothe, rect: CGRect){
        let view = UIView(frame: rect)
        view.backgroundColor = UIColor.clear
            
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height))
        imageView.contentMode = UIViewContentMode.scaleToFill
        
        DispatchQueue.main.async {
            let img = clothe.getImage()
            imageView.image = img
        }

        view.addSubview(imageView)
        self.containerView.layer.cornerRadius = 5.0
        self.containerView.clipsToBounds = true
        self.containerView.addSubview(view)
    }
    
    fileprivate func putOnStyle(_ isPutOn: Bool, style: String){
        if (isPutOn){
            self.containerView.layer.borderColor = UIColor.dressTimeRedBrand().cgColor
            self.containerMomentImage.backgroundColor = UIColor.dressTimeRedBrand()
            self.imageView.image = UIImage(named: "checkSelected")
            self.imageView.tintColor = UIColor.white
            self.momentLabel.textColor = UIColor.white
        } else {
            self.containerMomentImage.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            self.imageView.tintColor = UIColor.white
            self.momentLabel.textColor = UIColor.white
        }
        self.momentLabel.text = NSLocalizedString(style, comment: "style").lowercased()
    }
    
    func removeOldImages(){
        for item in containerView.subviews {
            item.removeFromSuperview()
        }
    }
}
