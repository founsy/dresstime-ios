//
//  BrandClotheCell.swift
//  DressTime
//
//  Created by Fab on 29/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit


protocol BrandClotheCellDelegate {
    func brandClotheCell(cell: BrandClotheCell, selectedItem clothe: BrandClothe)
}

class BrandClotheCell: UICollectionViewCell {

    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var brandIcon: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    
    var delegate: BrandClotheCellDelegate?
    
    @IBAction func shopTapped(sender: AnyObject) {
        if let del = self.delegate {
            del.brandClotheCell(self, selectedItem: brandClotheModel!)
            print(brandClotheModel?.clothe_shopUrl)
        }
       
    }
    
    @IBAction func dislikeTapped(sender: AnyObject) {
    }
    
    var brandClotheModel: BrandClothe? {
        didSet{
            self.updateView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func updateView(){
        let currency = brandClotheModel!.clothe_currency
        
        self.priceLabel.text = "\(brandClotheModel!.clothe_price) \(currency == "EUR" ? "€" : "")"
        
        if let imageURL = NSURL(string: (brandClotheModel?.clothe_image)!) {
            self.imageView.setImageWithURL(imageURL)
        }
        if let imageURL = NSURL(string: (brandClotheModel?.clothe_brandLogo)!) {
            self.brandIcon.setImageWithURL(imageURL)
        }
    
        self.roundCorners(UIRectCorner.AllCorners, radius: 5.0)
        self.priceView.layer.cornerRadius = 20
        self.priceView.layer.borderWidth = 1.0
        self.priceView.layer.borderColor = UIColor.blackColor().CGColor
    }
}