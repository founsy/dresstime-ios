//
//  ClotheCalendarCell.swift
//  DressTime
//
//  Created by Fab on 13/02/2016.
//  Copyright © 2016 Fab. All rights reserved.
//

import Foundation
import UIKit

class ClotheCalendarCell : UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.containerView.layer.cornerRadius = 5.0
        self.containerView.clipsToBounds = true
    }
    
    func createClotheView(_ clothe: Clothe, rect: CGRect){
        let view = UIView(frame: rect)
        view.backgroundColor = UIColor.clear
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height))
    
        DispatchQueue.main.async {
            var img = clothe.getImage()
            
            var mode = UIViewContentMode.top
            if (rect.size.height != self.containerView.frame.size.height){
                img = img.imageResize(CGSize(width: rect.size.width, height: rect.size.height))
            } else {
                mode = UIViewContentMode.scaleToFill
            }
            imageView.image = img
            imageView.contentMode = mode
        }
        
        view.addSubview(imageView)
        self.containerView.addSubview(view)
    }
    
    func setLoadNecessaryImage(_ imageNamed: String, type: String, rect: CGRect){
        let view = UIView(frame: rect)
        view.backgroundColor = UIColor.clear
        view.layer.cornerRadius = 5.0
        view.layer.masksToBounds = true
        view.accessibilityIdentifier = type
        
        let img = UIImage(named: imageNamed)!
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height))
        imageView.backgroundColor = UIColor.clear
        imageView.isOpaque = false
        imageView.image = img
        imageView.contentMode = UIViewContentMode.scaleToFill
        view.addSubview(imageView)
        self.contentView.addSubview(view)
    }
    
    
    func removeOldImages(){
        for item in self.containerView.subviews {
            item.removeFromSuperview()
        }
    }
}
