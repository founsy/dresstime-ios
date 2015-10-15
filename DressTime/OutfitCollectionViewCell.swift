//
//  OutfitCollectionViewCell.swift
//  DressTime
//
//  Created by Fab on 13/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class OutfitCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var pointText: UILabel!
    @IBOutlet weak var styleText: UILabel!
    @IBOutlet weak var weatherIcon: UILabel!
    @IBOutlet weak var imageContainer: UIStackView!
    
    var currentStyle: String?
    
    override func awakeFromNib() {
        pointText.layer.borderColor = UIColor.whiteColor().CGColor
        pointText.layer.cornerRadius = 10.5
        pointText.layer.borderWidth = 1.0
        pointText.layer.masksToBounds = true
    }
        
    func setClothe(clothe: Clothe, style: String, rate: Int){
        if let image = UIImage(data: clothe.clothe_image) {
            let imageView = UIImageView()
            imageView.contentMode = .Top
            imageView.image = image.imageResize(CGSizeMake(120.0, 160.0))
            imageContainer.addArrangedSubview(imageView)
        }
        currentStyle = style
        styleText.text = style.uppercaseString
        pointText.text = "\(rate)"
    }
    
    func setBrandClothe(image: String, style: String, rate: Int){
        if let data: NSData = NSData(base64EncodedString: image, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters) {
            let image = UIImage(data: data)
            let imageView = UIImageView()
            imageView.contentMode = .Top
            imageView.image = image!.imageResize(CGSizeMake(120.0, 160.0))
            imageContainer.addArrangedSubview(imageView)
            currentStyle = style
            styleText.text = style.uppercaseString
            pointText.text = "\(rate)"
        }
        
    }
    
    func removeOldImages(){
        for var item in imageContainer.subviews {
            item.removeFromSuperview()
        }
    }
}