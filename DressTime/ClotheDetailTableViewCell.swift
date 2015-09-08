//
//  ClotheDetailViewController.swift
//  DressTime
//
//  Created by Fab on 05/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

protocol ClotheDetailTableViewCellDelegate{
    func onEditClothe(indexPath: NSIndexPath)
}

class ClotheDetailTableViewCell: UITableViewCell{
    
    @IBOutlet weak var clotheImageView: UIImageView!
    @IBOutlet weak var onCreateOutfit: UIButton!
    @IBOutlet weak var clotheNameText: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var onEdit: NSLayoutConstraint!
    @IBOutlet weak var color1View: UIView!
    @IBOutlet weak var color2View: UIView!
    @IBOutlet weak var color3View: UIView!
    
    @IBAction func onEdit(sender: AnyObject) {
        if let del = delegate {
            del.onEditClothe(indexPath!)
        }
    }
    var delegate: ClotheDetailTableViewCellDelegate?
    var indexPath: NSIndexPath?
    
    func roundTopCorner(){
        self.topView.roundCorners(UIRectCorner.TopLeft | UIRectCorner.TopRight, radius: 10.0)
        self.clotheImageView.roundCorners(UIRectCorner.AllCorners, radius: 10.0)
        self.onCreateOutfit.roundCorners(UIRectCorner.AllCorners, radius: 5.0)
        
        self.color1View.layer.cornerRadius = 5.0
        self.color1View.layer.borderWidth = 1.0
        self.color1View.layer.borderColor = UIColor.whiteColor().CGColor
        self.color2View.layer.cornerRadius = 5.0
        self.color2View.layer.borderWidth = 1.0
        self.color2View.layer.borderColor = UIColor.whiteColor().CGColor
        self.color3View.layer.cornerRadius = 5.0
        self.color3View.layer.borderWidth = 1.0
        self.color3View.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    func updateColors(colors: String){
        let colors = self.splitHexColor(colors)
        color1View.backgroundColor = UIColor.colorWithHexString(colors[0] as String)
        if (colors.count > 1){
            color2View.backgroundColor = UIColor.colorWithHexString(colors[1] as String)
        }
        if (colors.count > 2){
            color3View.backgroundColor = UIColor.colorWithHexString(colors[2] as String)
        }
    }
    
    private func splitHexColor(colors: String) -> [String]{
        var arrayColors = split(colors) {$0 == ","}
        return arrayColors
    }
    
}