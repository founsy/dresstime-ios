//
//  ClotheTableViewCell.swift
//  DressTime
//
//  Created by Fab on 04/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class ClotheTableViewCell: UITableViewCell{
    
    var isFavorite = false
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var clotheImageView: UIImageView!
    @IBOutlet weak var favorisIcon: UIImageView!
    
    @IBAction func onFavoriteTapped(sender: UIButton) {
        if (favoriteButton.selected){
            favoriteButton.selected = false
            isFavorite = false
            favoriteButton.setImage(UIImage(named: "loveIconOFF"), forState: UIControlState.Normal)
        } else {
            favoriteButton.selected = true
            isFavorite = true
            favoriteButton.setImage(UIImage(named: "loveIconON"), forState: UIControlState.Selected)
        }
    }
    
    override func awakeFromNib() {
        if (isFavorite){
            favoriteButton.imageView?.image = UIImage(named: "loveIconON")
        } else {
            favoriteButton.imageView?.image = UIImage(named: "loveIconOFF")
        }
    }
}