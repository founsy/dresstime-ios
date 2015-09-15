//
//  Outfit3ElemsCollectionViewCell.swift
//  DressTime
//
//  Created by Fab on 08/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit


class Outfit3ElemsCollectionViewCell: OutfitElemsCollectionViewCell {
    
    @IBOutlet weak var mailleImageView: UIImageView!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var pantsImageView: UIImageView!
    @IBOutlet weak var styleTitle: UILabel!
    
    override func setClothe(clothe: Clothe, style: String){
        if let image = UIImage(data: clothe.clothe_image) {
            if (clothe.clothe_type == "maille"){
                mailleImageView.image = image.imageResize(CGSizeMake(360.0, 480.0))
                self.mailleImageView.layer.cornerRadius = 5.0
                addShadow(self.mailleImageView)
                self.mailleImageView.clipsToBounds = true
            } else if (clothe.clothe_type == "top"){
                topImageView.image = image.imageResize(CGSizeMake(360.0, 480.0))
                self.topImageView.layer.cornerRadius = 5.0
                addShadow(self.mailleImageView)
                self.topImageView.clipsToBounds = true
            } else if (clothe.clothe_type == "pants"){
                pantsImageView.image = image.imageResize(CGSizeMake(360.0, 480.0))
                self.pantsImageView.layer.cornerRadius = 5.0
                addShadow(self.mailleImageView)
                self.pantsImageView.clipsToBounds = true
                
            }
        }
        styleTitle.text = style.uppercaseString
    }
}