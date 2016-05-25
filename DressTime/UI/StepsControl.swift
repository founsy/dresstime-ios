//
//  StepsControl.swift
//  DressTime
//
//  Created by Fab on 28/12/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class StepsControl: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var stepsViewCollections: [UIView]!
    
    var currentType: String?
    var number = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        for i in 0 ..< stepsViewCollections.count {
            stepsViewCollections[i].layer.borderColor = UIColor.whiteColor().CGColor
            stepsViewCollections[i].layer.borderWidth = 1
            stepsViewCollections[i].backgroundColor = UIColor.clearColor()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(StepsControl.updateValue(_:)), name: "NewClotheAddedNotification", object: nil)
    }
    
    func updateValue(notification: NSNotification) {
        let userInfo = notification.userInfo as! [String: AnyObject]
        let type = userInfo["type"] as! String
        if (type.lowercaseString == currentType!.lowercaseString){
            number += 1
            updateStepViews(number)
            
        }
    }
    

    
    func updateStepViews(number: Int){
        if (number > self.stepsViewCollections.count) {
            self.titleLabel.hidden = true
            for j in 0 ..< self.stepsViewCollections.count{
                self.stepsViewCollections[j].hidden = true
            }
            return
        }
        
        var mutableString: NSMutableAttributedString
        if (number >= 0 && number <= 2) {
            mutableString = NSMutableAttributedString(string: "\(stepsViewCollections.count - number) \(getLabel(number))"
            ,attributes: [NSFontAttributeName:UIFont.systemFontOfSize(19.0)])
            mutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.dressTimeRedBrand(), range: NSRange(location:0, length:  1))
        } else {
            mutableString = NSMutableAttributedString(string: "\(getLabel(number))"
                ,attributes: [NSFontAttributeName:UIFont.systemFontOfSize(19.0)])
            mutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.dressTimeRedBrand(), range: NSRange(location:0, length:  mutableString.length))

        }
        self.titleLabel.attributedText = mutableString
        
        for j in 0 ..< self.stepsViewCollections.count {
            self.stepsViewCollections[j].hidden = false
            if (j < number){
                self.stepsViewCollections[j].backgroundColor = UIColor.dressTimeOrange()
            } else {
                self.stepsViewCollections[j].backgroundColor = UIColor.clearColor()
            }
        }
    }
    
    private func getLabel(number: Int) -> String {
        if (number >= 0 && number <= 2){
            return NSLocalizedString("profilStepMore", comment: "")
        } else if (number == 3) {
            return NSLocalizedString("profilStepWellDone", comment: "")
        } else {
            return ""
        }
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}