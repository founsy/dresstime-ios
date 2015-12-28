//
//  EmptyTypeView.swift
//  DressTime
//
//  Created by Fab on 27/12/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class EmptyTypeView : UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet var viewSteps: [UIView]!
    @IBOutlet weak var checkImage: UIImageView!
    
    var currentType: String?
    var number = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        for (var i = 0; i < viewSteps.count; i++){
            viewSteps[i].layer.borderColor = UIColor.whiteColor().CGColor
            viewSteps[i].layer.borderWidth = 1
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"updateValue:", name: "NewClotheAddedNotification", object: nil)
    }
    
    func updateValue(notification: NSNotification) {
        let userInfo = notification.userInfo as! [String: AnyObject]
        var type = userInfo["type"] as! String
        if (type.lowercaseString == currentType!.lowercaseString){
            number++
            updateStepViews(number)
            
        }
    }
    
    func updateStepViews(number: Int){
        self.titleLabel.text = "\(number) \(self.currentType!.uppercaseString)"
        for (var j = 0; j < self.viewSteps.count; j++){
            if (j < number){
                self.viewSteps[j].backgroundColor = UIColor.dressTimeOrange()
            } else {
                self.viewSteps[j].backgroundColor = UIColor.clearColor()
            }
        }
        checkImage.hidden = !(number == self.viewSteps.count)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}