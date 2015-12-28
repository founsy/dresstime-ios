//
//  HomeEmptyAnimationCell.swift
//  DressTime
//
//  Created by Fab on 27/12/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class HomeEmptyAnimationCell: UITableViewCell {
    
    @IBOutlet weak var imageViewAnimation: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageViewAnimation.animationImages = self.loadAnimateImage()
        self.imageViewAnimation.animationDuration = 3.5
        self.imageViewAnimation.startAnimating()
    }
    
    private func loadAnimateImage() -> [UIImage] {
        let imagesListArray :NSMutableArray = []
        for position in 0...296{
            var i = String(position)
            if (i.characters.count == 1){
                i = "00" + i
            } else if (i.characters.count == 2){
                i =  "0" + i
            }
            
            let strImageName : String = "men_00\(i).png"
            let image  = UIImage(named:strImageName)
            imagesListArray.addObject(image!)
        }
        return imagesListArray as AnyObject as! [UIImage]
    }


}