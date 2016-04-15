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
    func noClotheCalendarCell(noClotheCalendarCell : NoClotheCalendarCell, didCreateOutfit item: NSIndexPath)
}

class NoClotheCalendarCell: UITableViewCell {

    @IBOutlet weak var addOutfit: UIButton!
    @IBOutlet weak var commentsCalendar: UILabel!
    
    var date: NSDate?
    var delegate: NoClotheCalendarCellDelegate?
    var indexPath: NSIndexPath?
    
    
    @IBAction func createOutfit(sender: AnyObject) {
        delegate?.noClotheCalendarCell(self, didCreateOutfit: indexPath!)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addOutfit.layer.borderColor = UIColor.whiteColor().CGColor
        addOutfit.layer.borderWidth = 1.0
        addOutfit.layer.cornerRadius = 8.0
        
        // Translation
        commentsCalendar.text = NSLocalizedString("calendarDoYouRemember", comment: "")
    }
    
}