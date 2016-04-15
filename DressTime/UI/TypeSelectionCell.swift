//
//  TypeSelectionCell.swift
//  DressTime
//
//  Created by Fab on 30/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

protocol TypeSelectionCellDelegate {
    func onSelectedType(typeSelected: String)
}

class TypeSelectionCell: UITableViewCell {
    @IBOutlet var buttonType: [UIButton]!
    
    var delegate: TypeSelectionCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if (SharedData.sharedInstance.sexe == "M"){
            for var i = 0; i < buttonType.count; i++ {
                if (buttonType[i].accessibilityIdentifier == "dress"){
                    buttonType[i].hidden = true
                }
            }
        }
        for (var i = 0; i < buttonType.count; i++){
            buttonType[i].setTitle(NSLocalizedString(buttonType[i].accessibilityIdentifier!, comment: "").uppercaseString, forState: .Normal)
        }
    }
    
    func drawBorderButton(){
        for (var i = 0; i < buttonType.count; i++){
            if (buttonType[i].selected){
                 createBorder(buttonType[i])
            }
            buttonType[i].addTarget(self, action: "createBorderButton:", forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
    
    func createBorderButton(btn: UIButton){
        removeBorder()
        btn.selected = true
        createBorder(btn)
        if let del = self.delegate {
            del.onSelectedType(btn.accessibilityIdentifier!)
        }
    }
    
    private func createBorder(btn: UIButton){
        let height:CGFloat = 3.0
        let color = UIColor(red: 235/255, green: 175/255, blue: 73/255, alpha: 1.0)
        let lineView = UIView(frame: CGRectMake(10, btn.frame.size.height - height, btn.frame.size.width - 20.0, height))
        lineView.backgroundColor = color
        btn.addSubview(lineView)
    }

    private func removeBorder(){
        for (var i = 0; i < buttonType.count; i++){
            buttonType[i].selected = false
            for subView in buttonType[i].subviews {
                if (!subView.isKindOfClass(UILabel)){
                    subView.removeFromSuperview()
                }
            }
        }
    }

}