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
    
    func createOutfitView(_ outfit: Outfit){
        var j = 1
        if (outfit.clothes.count > 0){
            //Be sure the order of clothes are ok
            outfit.orderOutfit()
            let dal = ClothesDAL()
            
            for i in stride(from: (outfit.clothes.count-1), through: 0, by: -1) {
                let clothe_id = outfit.clothes[i].clothe_id
                if let clothe = dal.fetch(clothe_id) {
                    let width:CGFloat = self.containerView.frame.width
                    var height:CGFloat = CGFloat(self.containerView.frame.height/CGFloat(outfit.clothes.count))
                    let x:CGFloat = 0
                    var y:CGFloat = 0
                    
                    if (outfit.clothes.count == 1){
                        height = self.containerView.frame.height
                    } else if (outfit.clothes.count == 2){
                        height = 126.6
                    } else {
                        height = 123.3
                    }
                    
                    if (i == 0){
                        y = 0
                    } else if (outfit.clothes.count-1 == i) {
                        y = self.containerView.frame.height - height
                    } else {
                        y = self.containerView.frame.height - (height * CGFloat(j)) + (height/2.0)
                    }
                    
                    let rect = CGRect(x: x, y: y, width: width, height: height)
                    j += 1
                    
                    self.createClotheView(clothe, rect: rect)
                }
            }
        }
    }
    
    func createClotheView(_ clothe: Clothe, rect: CGRect){
        let view = UIView(frame: rect)
        view.backgroundColor = UIColor.clear
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height))
        imageView.contentMode = UIViewContentMode.scaleToFill
        
        DispatchQueue.main.async {
            let img = clothe.getImage()
            imageView.image = img
        }
        
        view.addSubview(imageView)
        self.containerView.layer.cornerRadius = 5.0
        self.containerView.clipsToBounds = true
        self.containerView.addSubview(view)
    }
    
    func removeOldImages(){
        for item in self.containerView.subviews {
            item.removeFromSuperview()
        }
    }
}
