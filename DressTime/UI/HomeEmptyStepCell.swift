//
//  HomeEmptyStepCell.swift
//  DressTime
//
//  Created by Fab on 27/12/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

protocol HomeEmptyStepCellDelegate {
    func homeEmptyStepCell(homeEmptyStepCell: HomeEmptyStepCell, didSelectItem item: String)
}

class HomeEmptyStepCell: UITableViewCell {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var messageHomeEmpty: UILabel!
    
    var delegate: HomeEmptyStepCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let type = SharedData.sharedInstance.getType(SharedData.sharedInstance.sexe!)
        let clotheDAL = ClothesDAL()
        
        for i in 0 ..< type.count {
            let number = clotheDAL.fetch(type: type[i].lowercaseString).count
            let view = NSBundle.mainBundle().loadNibNamed("EmptyTypeView", owner: self, options: nil)[0] as! EmptyTypeView
            view.iconImage.image = UIImage(named: getImageName(type[i]))
            view.currentType = type[i].lowercaseString
            view.updateStepViews(number)
            view.delegate = self
            stackView.addArrangedSubview(view)
        }
        messageHomeEmpty.text = NSLocalizedString("homeEmptyMessage", comment: "")
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
                return "TypeDressIcon"
            default:
                return ""
        }
    }
}

extension HomeEmptyStepCell : EmptyTypeViewDelegate {
    func emptyTypeView(emptyTypeView: EmptyTypeView, didSelectItem item: String) {
        if let del = self.delegate {
            del.homeEmptyStepCell(self, didSelectItem: item)
        }
    }
}