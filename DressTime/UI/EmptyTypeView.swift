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
    func emptyTypeView(_ emptyTypeView: EmptyTypeView, didSelectItem item: String)
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
        
        for i in 0 ..< viewSteps.count {
            viewSteps[i].layer.borderColor = UIColor.white.cgColor
            viewSteps[i].layer.borderWidth = 1
        }
        
        NotificationCenter.default.addObserver(self, selector:#selector(EmptyTypeView.updateValue(_:)), name: NSNotification.Name(rawValue: "NewClotheAddedNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(EmptyTypeView.updateValue(_:)), name: NSNotification.Name(rawValue: "ClotheDeletedNotification"), object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(EmptyTypeView.handleTap(_:)))
        self.addGestureRecognizer(tap)
    }
    
    func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if let del = self.delegate {
            del.emptyTypeView(self, didSelectItem: self.currentType!)
        }
    }
    
    func updateValue(_ notification: Foundation.Notification) {
        let userInfo = (notification as NSNotification).userInfo as! [String: AnyObject]
        let dal = ClothesDAL()
        let type = userInfo["type"] as! String
        if (type.lowercased() == currentType!.lowercased()){
            number = dal.fetch(type: currentType!.lowercased()).count
            updateStepViews(number)
            
        }
    }
    
    func updateStepViews(_ number: Int){
        let calculNumber = viewSteps.count - number <= 0 ? 0 : viewSteps.count - number
        
        self.titleLabel.text = "\(calculNumber) \(NSLocalizedString(self.currentType!, comment: "").uppercased())"
        for j in 0 ..< self.viewSteps.count {
            if (j < number){
                self.viewSteps[j].backgroundColor = UIColor.dressTimeRedBrand()
            } else {
                self.viewSteps[j].backgroundColor = UIColor.clear
            }
        }
        checkImage.isHidden = (calculNumber > 0)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
