//
//  HeaderShoppingCell.swift
//  DressTime
//
//  Created by Fab on 06/03/2016.
//  Copyright © 2016 Fab. All rights reserved.
//

import Foundation
import UIKit

class HeaderShoppingCell: UITableViewCell {
    
    @IBOutlet weak var headerMsgLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        headerMsgLabel.text = NSLocalizedString("shoppingHeaderMsg", comment: "")
    }
}