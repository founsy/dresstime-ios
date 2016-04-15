//
//  NumberClotheControl.swift
//  DressTime
//
//  Created by Fab on 28/12/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class NumberClotheControl: UIView {

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    func updateControl(number: Int, type: String){
        self.numberLabel.text = "\(number)"
        self.typeLabel.text = NSLocalizedString(type, comment: "Translate type").uppercaseString
    }
}