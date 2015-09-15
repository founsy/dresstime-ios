//
//  Outfit2ElemsCollectionViewCell.swift
//  DressTime
//
//  Created by Fab on 08/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class OutfitElemsCollectionViewCell: UICollectionViewCell {
    var currentStyle: String?
    
    func setClothe(clothe: Clothe, style: String){
        self.currentStyle = style
    }
    
    func addShadow(view: UIView){
        view.layer.shadowOffset = CGSizeMake(3, 6);
        view.layer.shadowColor = UIColor.blackColor().CGColor
        view.layer.shadowRadius = 8;
        view.layer.shadowOpacity = 0.75;
    }
}

class Outfit2ElemsCollectionViewCell: OutfitElemsCollectionViewCell {

    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var pantsImageView: UIImageView!
    @IBOutlet weak var styleTitle: UILabel!
    
    override func setClothe(clothe: Clothe, style: String){
        super.setClothe(clothe, style: style)
        if let image = UIImage(data: clothe.clothe_image) {
            if (clothe.clothe_type == "top"){
                topImageView.image = image.imageResize(CGSizeMake(360.0, 480.0))
                self.topImageView.layer.cornerRadius = 5.0
                self.topImageView.clipsToBounds = true
            } else if (clothe.clothe_type == "pants"){
                pantsImageView.image = image.imageResize(CGSizeMake(360.0, 480.0))
                self.pantsImageView.layer.cornerRadius = 5.0
                self.pantsImageView.clipsToBounds = true
            }
        }
        styleTitle.text = style.uppercaseString
    }
    
    
}