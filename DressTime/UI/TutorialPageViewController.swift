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
    
    private let titleName = ["TutorialPage1Title", "TutorialPage2Title", "TutorialPage3Title", "TutorialPage4Title"]
    private let subTitleName = ["TutorialPage1Msg", "TutorialPage2Msg", "TutorialPage3Msg", "TutorialPage4Msg"]
    
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