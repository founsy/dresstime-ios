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
    func onSelectedType(_ typeSelected: String)
}

class TypeSelectionCell: UITableViewCell {
    @IBOutlet var buttonType: [UIButton]!
    
    var delegate: TypeSelectionCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if (SharedData.sharedInstance.sexe == "M"){
            for i in 0 ..< buttonType.count {
                if (buttonType[i].accessibilityIdentifier == "dress"){
                    buttonType[i].isHidden = true
                }
            }
        }
        for i in 0 ..< buttonType.count{
            buttonType[i].setTitle(NSLocalizedString(buttonType[i].accessibilityIdentifier!, comment: "").uppercased(), for: UIControlState())
        }
    }
    
    func drawBorderButton(){
        for i in 0 ..< buttonType.count {
            if (buttonType[i].isSelected){
                 createBorder(buttonType[i])
            }
            buttonType[i].addTarget(self, action: #selector(TypeSelectionCell.createBorderButton(_:)), for: UIControlEvents.touchUpInside)
        }
    }
    
    func createBorderButton(_ btn: UIButton){
        removeBorder()
        btn.isSelected = true
        createBorder(btn)
        if let del = self.delegate {
            del.onSelectedType(btn.accessibilityIdentifier!)
        }
    }
    
    fileprivate func createBorder(_ btn: UIButton){
        let height:CGFloat = 3.0
        let color = UIColor(red: 235/255, green: 175/255, blue: 73/255, alpha: 1.0)
        let lineView = UIView(frame: CGRect(x: 10, y: btn.frame.size.height - height, width: btn.frame.size.width - 20.0, height: height))
        lineView.backgroundColor = color
        btn.addSubview(lineView)
    }

    fileprivate func removeBorder(){
        for i in 0 ..< buttonType.count{
            buttonType[i].isSelected = false
            for subView in buttonType[i].subviews {
                if (!subView.isKind(of: UILabel.self)){
                    subView.removeFromSuperview()
                }
            }
        }
    }

}
