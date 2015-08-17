//
//  FilterView.swift
//  DressTime
//
//  Created by Fab on 16/08/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

@objc protocol FilterViewDelegate {
    func onMoreFilterClick()
    func onGetDressedClothe(type: Int)
}

class FilterView: UIView {
    
    private var datePickerView: AKPickerView?
    private var cityPickerView: AKPickerView?
    private var stylePickerView: AKPickerView?
    
    private var styles = [ "WORK - Business style", "BE CHIC - Casual style", "RELAX - Sportswear style", "PARTY - Fashion style" ]
    private let city = ["Paris", "Maisons-Laffitte"]
    private let date = ["Today", "Tomorrow"]
    private let styleData = ["business", "casual", "sportwear", "fashion"]
    
    private var currentStyle = 0
    private var constraintsView: [AnyObject]?
    
    var delegate: FilterViewDelegate?
    
    @IBOutlet weak var filterViewContainer: UIView!
    @IBOutlet weak var dateContainer: UIView!
    @IBOutlet weak var cityContainer: UIView!
    @IBOutlet weak var styleContainer: UIView!
    @IBOutlet weak var circleKnittingIcon: UIView!
    
    @IBAction func onGetDressedTouch(sender: AnyObject) {
        delegate!.onGetDressedClothe(currentStyle)
    }
    
    
    @IBAction func onMoreFilterTouch(sender: AnyObject) {
        delegate!.onMoreFilterClick()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        /*var ct = UIGraphicsGetCurrentContext()
        var holeRectIntersection = CGRectIntersection(self.circleKnittingIcon.frame,  self.filterViewContainer.frame)
        
        CGContextAddEllipseInRect(ct, self.circleKnittingIcon.frame)
        CGContextClip(ct)
        CGContextClearRect(ct, self.circleKnittingIcon.frame)
        //CGContextSetFillColorWithColor( ct, UIColor.clearColor().CGColor)
        //CGContextFillRect( ct, self.circleKnittingIcon.frame)
        UIGraphicsEndImageContext() */
    }
    
    func initialize(){
        createPickerView(&self.datePickerView, subView: self.dateContainer)
        createPickerView(&self.cityPickerView, subView: self.cityContainer)
        createPickerView(&self.stylePickerView, subView:self.styleContainer)
        
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOpacity = 0.8
        self.layer.shadowRadius = 3.0
        self.layer.shadowOffset = CGSizeMake(2.0, 2.0)
    }
    
    func drawIconViewCircle(){
        self.circleKnittingIcon.layer.cornerRadius = 12.5
        self.circleKnittingIcon.clipsToBounds = true
        self.circleKnittingIcon.layer.shadowColor = UIColor.blackColor().CGColor
        self.circleKnittingIcon.layer.shadowOpacity = 0.8
        self.circleKnittingIcon.layer.shadowRadius = 3.0
        self.circleKnittingIcon.layer.shadowOffset = CGSizeMake(2.0, 2.0)
    
    }

    private func createPickerView(inout picker: AKPickerView?, subView: UIView){
        picker = AKPickerView(frame: subView.bounds)
        picker!.delegate = self;
        picker!.dataSource = self;
        picker!.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight;
        subView.addSubview(picker!)
        
        picker!.font = UIFont(name: "HelveticaNeue-Light", size: 20.0)! //[UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        picker!.highlightedFont =  UIFont(name: "HelveticaNeue", size:20)!
        picker!.interitemSpacing = 20.0
        picker!.textColor = UIColor.grayColor()
        picker!.highlightedTextColor = UIColor.grayColor()
        //self.pickerView.fisheyeFactor = 0.001
        picker!.pickerViewStyle = AKPickerViewStyle.Wheel
        picker!.maskDisabled = false
    }
    
    func showConstrainte(parentView: UIView){
        if let const = self.constraintsView {
            self.removeConstraints(const)
            NSLayoutConstraint.deactivateConstraints(const)
            self.constraintsView = nil
        }

        
        let widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: parentView, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
        
        let heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: parentView, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
        
        let pinBottom = NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal,
            toItem: parentView.superview!, attribute: .Bottom, multiplier: 1.0, constant: 0)
        
        let pinTop = NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal,
            toItem: parentView, attribute: .Top, multiplier: 1.0, constant: 0)
        
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.constraintsView = [widthConstraint , heightConstraint, pinBottom, /*heightContraints ,*/ pinTop]
        
        //IOS 8
        //activate the constrains.
        //we pass an array of all the contraints
        NSLayoutConstraint.activateConstraints(self.constraintsView!)
        
    }
    
    func hideContrainte(parentView: UIView){
        if let const = self.constraintsView {
            self.removeConstraints(const)
            NSLayoutConstraint.deactivateConstraints(const)
            self.constraintsView = nil
        }
        
        let leftConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: parentView, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
        
        let rightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: parentView, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
        
        let pinBottom = NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal,
            toItem: parentView.superview! , attribute: .Bottom, multiplier: 1.0, constant: parentView.frame.height-40.0)

        let heightContraints = NSLayoutConstraint(item: self, attribute:
            .Height, relatedBy: .Equal, toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0,
            constant: parentView.frame.height)

        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.constraintsView = [leftConstraint , rightConstraint, pinBottom, heightContraints]
        //IOS 8
        //activate the constrains.
        //we pass an array of all the contraints
        NSLayoutConstraint.activateConstraints(self.constraintsView!)
       
    }

}

extension FilterView: AKPickerViewDelegate, AKPickerViewDataSource {
    func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int {
        if (pickerView === self.datePickerView) {
            return self.date.count
        } else if (pickerView === self.cityPickerView) {
            return self.city.count
        } else if (pickerView === self.stylePickerView) {
            return self.styles.count
        }
        return 0
    }
    
    func pickerView(pickerView: AKPickerView, titleForItem item: Int) -> String {
        if (pickerView === self.datePickerView) {
            return self.date[item]
        } else if (pickerView === self.cityPickerView) {
            return self.city[item]
        } else if (pickerView === self.stylePickerView) {
            return self.styles[item]
        }
        return ""
    }
    
    func pickerView(pickerView: AKPickerView, didSelectItem item: Int) {
        if (pickerView === self.stylePickerView) {
            self.currentStyle = item
        }
        
    }
}
