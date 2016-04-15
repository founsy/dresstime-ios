//
//  TextSelectionCell.swift
//  DressTime
//
//  Created by Fab on 24/11/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class TextSelectionCell: UITableViewCell {
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var numberOutfit: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.layer.cornerRadius = 15.0
        messageLabel.text = NSLocalizedString("shoppingNumberOfMatching", comment: "")
        
    }
}