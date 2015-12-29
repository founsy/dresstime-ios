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
    @IBOutlet weak var bubbleImageView: UIImageView!
    
    private var arrowImageView: UIImageView?
    var controller: HomeViewController?
    
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

    func createArrowImageView(){
        if let imageView = self.arrowImageView {
            imageView.removeFromSuperview()
        }
    
        self.arrowImageView = UIImageView(image: UIImage(named: "arrowIcon"))
        let p = self.bubbleImageView.convertPoint(self.bubbleImageView.frame.origin, toView: self.controller!.view)
        
        let t = self.bubbleImageView.superview!.convertPoint(self.bubbleImageView.frame.origin, toView: nil)
        
        let y = t.y > 300 ? t.y - (self.bubbleImageView.frame.height/2): 186.0 + p.y - 10
        let x = bubbleImageView.frame.width + bubbleImageView.frame.origin.x
        
        self.arrowImageView!.frame = CGRectMake(x, 64.0, 64.0, y)
        self.controller!.view.addSubview(self.arrowImageView!)
    }
}