//
//  HomeBrandOutfitsListCell.swift
//  DressTime
//
//  Created by Fab on 15/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class HomeBrandOutfitsListCell: UITableViewCell {
    let cellHeight = 300.0

    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        self.blurView.layer.cornerRadius = 10
        self.blurView.layer.masksToBounds = true
    }
}