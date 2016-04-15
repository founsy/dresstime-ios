//
//  UIActivityLoader.swift
//  DressTime
//
//  Created by Fab on 06/12/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class UIActivityLoader: UIView {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var progessIndicator: UIActivityIndicatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}