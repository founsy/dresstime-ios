//
//  NumberCalendarCell.swift
//  DressTime
//
//  Created by Fab on 13/02/2016.
//  Copyright © 2016 Fab. All rights reserved.
//

import Foundation
import UIKit

class NumberCalendarCell: UICollectionViewCell {

    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var label: UILabel!
    
    func selectedStyle(){
        label.font = UIFont.boldSystemFontOfSize(20.0)
        roundView.layer.cornerRadius = 20.0
        roundView.layer.borderWidth = 2.0
        roundView.layer.borderColor = UIColor.whiteColor().CGColor
        roundView.layer.masksToBounds = true
        
    }
    
    func unselectedStyle(){
        label.font = UIFont.systemFontOfSize(16.0)
        roundView.layer.cornerRadius = 0.0
        roundView.layer.borderWidth = 0.0
        roundView.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6).CGColor
        roundView.layer.masksToBounds = true
    }

}