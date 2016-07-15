//
//  HeaderOutfitView.swift
//  DressTime
//
//  Created by Fab on 7/15/16.
//  Copyright © 2016 Fab. All rights reserved.
//

import Foundation
import UIKit

protocol  HeaderOutfitViewDelegate {
    func headerOutfitView(didSelectedAdd : Bool)
}

class HeaderOutfitView: UIView {
    var delegate: HeaderOutfitViewDelegate?
    
    @IBOutlet weak var addButton: UIButton!
    @IBAction func onTappedAdd(sender: AnyObject) {
        delegate?.headerOutfitView(true)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
}