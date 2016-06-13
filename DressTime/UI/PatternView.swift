//
//  PatternView.swift
//  DressTime
//
//  Created by Fab on 11/11/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class PatternView: UIView {

    @IBOutlet weak var patternImage: UIImageView!
    @IBOutlet weak var patternLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        patternImage.tintColor = UIColor.whiteColor()
    }
}