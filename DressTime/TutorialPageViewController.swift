//
//  TutorialView.swift
//  DressTime
//
//  Created by Fab on 24/11/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class TutorialPageViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    private let titleName = ["CAPTURE", "CHECK", "GET", "GET"]
    private let subTitleName = ["YOUR CLOTHES", "THAT IT MATCHES", "SMART OUTFITS", "SMART SHOPPING LIST"]
    var index:Int = 0 {
        didSet {
            imageView.image = UIImage(named: "background\(index+1)")
            titleLabel.text = NSLocalizedString(titleName[index], comment: "Title")
            subTitleLabel.text = NSLocalizedString(subTitleName[index], comment: "Title")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}