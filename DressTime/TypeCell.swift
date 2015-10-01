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
    func onAddTypedTapped(indexPath: NSIndexPath)
}

class TypeCell: UITableViewCell {
    var indexPath: NSIndexPath?
    var delegate: TypeCellDelegate?
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var rightLabelName: UILabel!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var leftLabelName: UILabel!
    @IBOutlet weak var viewLongPress: UIView!
    @IBOutlet weak var longPressLabel: UILabel!
    @IBOutlet weak var addTypedButton: UIButton!
    
    
    @IBAction func onAddTypedTapped(sender: AnyObject) {
        if let del = self.delegate {
            self.viewLongPress.hidden = true
            del.onAddTypedTapped(self.indexPath!)
        }
    }
    
    override func awakeFromNib() {
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapHandle:")
        self.viewLongPress.addGestureRecognizer(tapGesture)
    }
    
    func tapHandle(gestureRecognizer: UILongPressGestureRecognizer){
        self.viewLongPress.hidden = true
    }
}