//
//  TypeCell.swift
//  DressTime
//
//  Created by Fab on 30/09/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

protocol TypeCellDelegate {
    func typeCell(typeCell: TypeCell, didSelectType indexPath: NSIndexPath)
}

class TypeCell: UITableViewCell {
    var indexPath: NSIndexPath?
    var delegate: TypeCellDelegate?
    
    var currentType: String?
    var number: Int?
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var viewLongPress: UIView!
    @IBOutlet weak var longPressLabel: UILabel!
    @IBOutlet weak var addTypedButton: UIButton!
    
    
    @IBAction func onAddTypedTapped(sender: AnyObject) {
        if let del = self.delegate {
            self.viewLongPress.hidden = true
            del.typeCell(self, didSelectType: self.indexPath!)
        }
    }
    
    override func awakeFromNib() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TypeCell.tapHandle(_:)))
        self.viewLongPress.addGestureRecognizer(tapGesture)
        self.viewLongPress.hidden = true
    }
    
    func tapHandle(gestureRecognizer: UILongPressGestureRecognizer){
        self.viewLongPress.hidden = true
    }
    
    func removeAllSubviews(){
        for view in self.stackView.subviews{
            view.removeFromSuperview()
        }
    }
    
    func addViews(isStepLeft: Bool){
        self.longPressLabel.text = "\(NSLocalizedString("Add", comment: "")) \(NSLocalizedString(currentType!.uppercaseString, comment: ""))"
        self.backgroundImage.image = UIImage(named: "Background\(currentType!)\(SharedData.sharedInstance.sexe!.uppercaseString)")
        
        let stepView = NSBundle.mainBundle().loadNibNamed("StepsControl", owner: self, options: nil)[0] as! StepsControl
        stepView.currentType = self.currentType
        stepView.number = self.number!
        stepView.updateStepViews(self.number!)
        let numberClotheView = NSBundle.mainBundle().loadNibNamed("NumberClotheControl", owner: self, options: nil)[0] as! NumberClotheControl
        numberClotheView.updateControl(self.number!, type: self.currentType!)
        
        if (isStepLeft){
            self.stackView.addArrangedSubview(stepView)
            self.stackView.addArrangedSubview(numberClotheView)
        } else {
            self.stackView.addArrangedSubview(numberClotheView)
            self.stackView.addArrangedSubview(stepView)
        }

        
    }
}