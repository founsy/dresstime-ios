//
//  ClotheTableViewCell.swift
//  DressTime
//
//  Created by Fab on 04/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

protocol ClotheTableViewCellDelegate {
    func onFavoriteClick(isFavorite: Bool)
}

class ClotheTableViewCell: UITableViewCell{
    
    var clothe: Clothe?
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var clotheImageView: UIImageView!
    @IBOutlet weak var favorisIcon: UIImageView!
    
    @IBAction func onFavoriteTapped(sender: UIButton) {
        if (favoriteButton.selected){
            favoriteButton.selected = false
            favoriteButton.setImage(UIImage(named: "loveIconOFF"), forState: UIControlState.Normal)
        } else {
            favoriteButton.selected = true
            favoriteButton.setImage(UIImage(named: "loveIconON"), forState: UIControlState.Selected)
        }
        if let clo = self.clothe {
            let dal = ClothesDAL()
            clo.clothe_favorite = favoriteButton.selected

            dal.update(clo)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func initFavoriteButton(isFavorite: Bool){
        favoriteButton.selected = isFavorite
        if (isFavorite){
            favoriteButton.imageView?.image = UIImage(named: "loveIconON")
        } else {
            favoriteButton.imageView?.image = UIImage(named: "loveIconOFF")
        }
    }
}