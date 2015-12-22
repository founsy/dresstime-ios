//
//  WeatherCell.swift
//  DressTime
//
//  Created by Fab on 09/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class WeatherCell: UICollectionViewCell {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var weatherIcon: UILabel!
    @IBOutlet weak var timeText: UILabel!
    @IBOutlet weak var temperatureText: UILabel!
    
    override func awakeFromNib() {
        viewContainer.layer.cornerRadius = 37.5
    }
}