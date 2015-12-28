//
//  HomeEmptyStepCell.swift
//  DressTime
//
//  Created by Fab on 27/12/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class HomeEmptyStepCell: UITableViewCell {
    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let type = SharedData.sharedInstance.getType(SharedData.sharedInstance.sexe!)
        let clotheDAL = ClothesDAL()
        
        for (var i = 0; i < type.count; i++) {
            let number = clotheDAL.fetch(type: type[i]).count
            let view = NSBundle.mainBundle().loadNibNamed("EmptyTypeView", owner: self, options: nil)[0] as! EmptyTypeView
            view.iconImage.image = UIImage(named: getImageName(type[i]))
            view.titleLabel.text = "\(number) \(type[i])"
            view.currentType = type[i]
            
            view.updateStepViews(number)
            stackView.addArrangedSubview(view)
        }
       // stackView.translatesAutoresizingMaskIntoConstraints = false;
    }
    
    private func getImageName(type: String) -> String{
        switch (type.lowercaseString){
            case "maille":
                return "sweaterIcon"
            case "top":
                return "poloIcon"
            case "pants":
                return "jeansIcon"
            case "dress":
                return ""
            default:
                return ""
        }
    }

}