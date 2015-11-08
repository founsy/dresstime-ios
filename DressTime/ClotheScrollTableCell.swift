//
//  ClotheScrollTableCell.swift
//  DressTime
//
//  Created by Fab on 17/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

protocol ClotheScrollTableCellDelegate {
    func didSelectedClothe(clothe: Clothe)
}

class ClotheScrollTableCell: UITableViewCell {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var clotheCollection: [Clothe]?
    var currentOutfit: Clothe?
    var delegate: ClotheScrollTableCellDelegate?
    var numberOfClothesAssos = 0
    
    private var selectedPage = 0
    
    override func awakeFromNib() {
        self.scrollView.pagingEnabled = true
        self.scrollView.delegate = self
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "singleTapped:")
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.enabled = true
        //singleTapGestureRecognizer.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(singleTapGestureRecognizer)
    }
    
    func singleTapped(sender: UITapGestureRecognizer) {
        if let del = self.delegate {
            del.didSelectedClothe(clotheCollection![self.selectedPage])
        }
    }
    
    func setupScrollView(width: CGFloat, height: CGFloat){
        if let collection = self.clotheCollection {
            self.scrollView.contentSize = CGSizeMake(width * CGFloat(collection.count), height)
            for (var i = 0; i < collection.count; i++){
                let view = NSBundle.mainBundle().loadNibNamed("ClotheTableCell", owner: self, options: nil)[0] as! ClotheTableViewCell
                view.frame = CGRectMake(CGFloat(i)*width, 0, width, height)
                let image = UIImage(data: collection[i].clothe_image)!
                view.initFavoriteButton(collection[i].clothe_favorite)
                view.clotheImageView.image = image.imageWithImage(width)
                view.clotheImageView.backgroundColor = UIColor.clearColor()
                view.clotheImageView.clipsToBounds = true
                self.scrollView.addSubview(view)
                if (collection[i].clothe_id == currentOutfit?.clothe_id){
                    self.selectedPage = i
                }
            }
            self.scrollView.setContentOffset(CGPointMake(CGFloat(self.selectedPage)*width, 0), animated: false)
        }
    }

}

extension ClotheScrollTableCell: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width;
        let page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        self.selectedPage = Int(page)
        let xoffset = page * self.scrollView.bounds.size.width;
        self.scrollView.contentOffset = CGPointMake(xoffset, 0);
    }
}