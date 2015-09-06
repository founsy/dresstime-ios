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
    }
    
}