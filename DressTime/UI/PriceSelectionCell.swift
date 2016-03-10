//
//  PriceSelectionCell.swift
//  DressTime
//
//  Created by Fab on 30/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit


protocol PriceSelectionCellDataSource {
    func priceSelectionCell(cell: UITableViewCell, minValueForSelectedType type: String) -> NSNumber?
    func priceSelectionCell(cell: UITableViewCell, maxValueForSelectedType type: String) -> NSNumber?
}

protocol PriceSelectionCellDelegate {
    func priceSelectionCell(cell: UITableViewCell, valueChanged rangeSlider: RangeSlider)
}

class PriceSelectionCell: UITableViewCell {

    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var rangeView: UIView!
    private let slider = RangeSlider(frame: CGRectZero)
    
    var dataSource: PriceSelectionCellDataSource?
    var delegate: PriceSelectionCellDelegate?
    
    var minValue : NSNumber? {
        didSet {
            slider.minimumValue = (minValue?.doubleValue)!
            slider.lowerValue = (minValue?.doubleValue)!
            minLabel.text = "\(minValue!) €"
           
        }
    }
    var maxValue : NSNumber? {
        didSet {
            slider.maximumValue = (maxValue?.doubleValue)!
            slider.upperValue = (maxValue?.doubleValue)!
            maxLabel.text = "\(maxValue!) €"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        slider.trackHighlightTintColor = UIColor(red: 235/255, green: 175/255, blue: 73/255, alpha: 1)
        rangeView.addSubview(slider)
        slider.addTarget(self, action: "rangeSliderValueChanged:", forControlEvents: .ValueChanged)
        slider.addTarget(self, action: "touchUp:", forControlEvents: .TouchUpInside)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        drawSlider()
    }
    
    func drawSlider(){
        rangeView.setNeedsLayout()
        rangeView.layoutIfNeeded()
        slider.minimumValue = 0.0
        slider.lowerValue = 0.0
        slider.maximumValue = 150.0
        slider.upperValue = 150.0
        slider.frame = CGRectMake(0, 0, rangeView.frame.width, 18)
    }
    
    func touchUp(rangeSlider: RangeSlider) {
        if let del = self.delegate {
            del.priceSelectionCell(self, valueChanged: rangeSlider)
        }
    }
    
    func rangeSliderValueChanged(rangeSlider: RangeSlider) {
        let lower = Int(rangeSlider.lowerValue * 100) / 100
        let upper = Int(rangeSlider.upperValue * 100) / 100
        minLabel.text = "\(lower) €"
        maxLabel.text = "\(upper) €"
        
    }
}