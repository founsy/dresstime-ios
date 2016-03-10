//
//  EmptyTypeView.swift
//  DressTime
//
//  Created by Fab on 27/12/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

protocol EmptyTypeViewDelegate {
    func emptyTypeView(emptyTypeView: EmptyTypeView, didSelectItem item: String)
}

class EmptyTypeView : UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet var viewSteps: [UIView]!
    @IBOutlet weak var checkImage: UIImageView!
    
    var currentType: String?
    var number = 0
    
    var delegate: EmptyTypeViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        for (var i = 0; i < viewSteps.count; i++){
            viewSteps[i].layer.borderColor = UIColor.whiteColor().CGColor
            viewSteps[i].layer.borderWidth = 1
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"updateValue:", name: "NewClotheAddedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"updateValue:", name: "ClotheDeletedNotification", object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        self.addGestureRecognizer(tap)
    }
    
    func handleTap(sender: UITapGestureRecognizer? = nil) {
        if let del = self.delegate {
            del.emptyTypeView(self, didSelectItem: self.currentType!)
        }
    }
    
    func updateValue(notification: NSNotification) {
        let userInfo = notification.userInfo as! [String: AnyObject]
        let dal = ClothesDAL()
        let type = userInfo["type"] as! String
        if (type.lowercaseString == currentType!.lowercaseString){
            number = dal.fetch(type: currentType!.lowercaseString).count
            updateStepViews(number)
            
        }
    }
    
    func updateStepViews(number: Int){
        let calculNumber = viewSteps.count - number <= 0 ? 0 : viewSteps.count - number
        
        self.titleLabel.text = "\(calculNumber) \(NSLocalizedString(self.currentType!, comment: "").uppercaseString)"
        for (var j = 0; j < self.viewSteps.count; j++){
            if (j < number){
                self.viewSteps[j].backgroundColor = UIColor.dressTimeOrange()
            } else {
                self.viewSteps[j].backgroundColor = UIColor.clearColor()
            }
        }
        checkImage.hidden = (calculNumber > 0)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}