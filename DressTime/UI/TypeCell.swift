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
    func typeCell(_ typeCell: TypeCell, didSelectType indexPath: IndexPath)
}

class TypeCell: UITableViewCell {
    var indexPath: IndexPath?
    var delegate: TypeCellDelegate?
    
    var currentType: String?
    var number: Int?
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var viewLongPress: UIView!
    @IBOutlet weak var longPressLabel: UILabel!
    @IBOutlet weak var addTypedButton: UIButton!
    
    
    @IBAction func onAddTypedTapped(_ sender: AnyObject) {
        //TODO - Fix the issue on tap long
        /*if let del = self.delegate {
            self.viewLongPress.hidden = true
            del.typeCell(self, didSelectType: self.indexPath!)
        }*/
    }
    
    override func awakeFromNib() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TypeCell.tapHandle(_:)))
        self.viewLongPress.addGestureRecognizer(tapGesture)
        self.viewLongPress.isHidden = true
    }
    
    func tapHandle(_ gestureRecognizer: UILongPressGestureRecognizer){
        self.viewLongPress.isHidden = true
    }
    
    func removeAllSubviews(){
        for view in self.stackView.subviews{
            view.removeFromSuperview()
        }
    }
    
    func addViews(_ isStepLeft: Bool){
        self.longPressLabel.text = "\(NSLocalizedString("Add", comment: "")) \(NSLocalizedString(currentType!.uppercased(), comment: ""))"
        self.backgroundImage.image = UIImage(named: "Background\(currentType!)\(SharedData.sharedInstance.sexe!.uppercased())")
        
        let stepView = Bundle.main.loadNibNamed("StepsControl", owner: self, options: nil)?[0] as! StepsControl
        stepView.currentType = self.currentType
        stepView.number = self.number!
        stepView.updateStepViews(self.number!)
        let numberClotheView = Bundle.main.loadNibNamed("NumberClotheControl", owner: self, options: nil)?[0] as! NumberClotheControl
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
