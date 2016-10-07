//
//  NoClotheCell.swift
//  DressTime
//
//  Created by Fab on 15/02/2016.
//  Copyright © 2016 Fab. All rights reserved.
//

import Foundation
import UIKit


protocol NoClotheCalendarCellDelegate {
    func noClotheCalendarCell(_ noClotheCalendarCell : NoClotheCalendarCell, didCreateOutfit item: IndexPath)
}

class NoClotheCalendarCell: UITableViewCell {

    @IBOutlet weak var addOutfit: UIButton!
    @IBOutlet weak var commentsCalendar: UILabel!
    
    var date: Date?
    var delegate: NoClotheCalendarCellDelegate?
    var indexPath: IndexPath?
    
    
    @IBAction func createOutfit(_ sender: AnyObject) {
        delegate?.noClotheCalendarCell(self, didCreateOutfit: indexPath!)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addOutfit.layer.borderColor = UIColor.white.cgColor
        addOutfit.layer.borderWidth = 1.0
        addOutfit.layer.cornerRadius = 8.0
        
        // Translation
        commentsCalendar.text = NSLocalizedString("calendarDoYouRemember", comment: "")
    }
    
}
