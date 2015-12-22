//
//  PriceSelectionCell.swift
//  DressTime
//
//  Created by Fab on 30/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class PriceSelectionCell: UITableViewCell {

    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var rangeView: UIView!
    private let slider = RangeSlider(frame: CGRectZero)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        slider.trackHighlightTintColor = UIColor(red: 235/255, green: 175/255, blue: 73/255, alpha: 1)
        rangeView.addSubview(slider)
        /* rangeSlider.addTarget(self, action: "rangeSliderValueChanged:",
        forControlEvents: .ValueChanged) */
    }
    
    func drawSlider(){
        rangeView.setNeedsLayout()
        rangeView.layoutIfNeeded()
        slider.frame = CGRectMake(0, 0, rangeView.frame.width, 18)
    }
}