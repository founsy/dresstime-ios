//
//  ClotheScrollTableCell.swift
//  DressTime
//
//  Created by Fab on 17/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class ClotheScrollTableCell: UITableViewCell {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var clotheCollection: [Clothe]?
    var currentOutfit: Clothe?
    
    override func awakeFromNib() {
        self.scrollView.pagingEnabled = true
        self.scrollView.delegate = self
    }
    
    func setupScrollView(width: CGFloat, height: CGFloat){
        if let collection = self.clotheCollection {
            self.scrollView.contentSize = CGSizeMake(width * CGFloat(collection.count), height)
            var selectedPage = 0
            for (var i = 0; i < collection.count; i++){
                let imageView = UIImageView(frame: CGRectMake(CGFloat(i)*width, 0, width, height))
                imageView.contentMode = .Top
                imageView.image = UIImage(data: collection[i].clothe_image)!.imageWithImage(480.0)
                imageView.backgroundColor = UIColor.clearColor()
                imageView.clipsToBounds = true
                self.scrollView.addSubview(imageView)
                if (collection[i].clothe_id == currentOutfit?.clothe_id){
                    selectedPage = i
                }
            }
            self.scrollView.setContentOffset(CGPointMake(CGFloat(selectedPage)*width, 0), animated: false)
        }
    }

}

extension ClotheScrollTableCell: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width;
        let page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        NSLog("Current page -> %d",page);
        let xoffset = page * self.scrollView.bounds.size.width;
        self.scrollView.contentOffset = CGPointMake(xoffset, 0);
    }
}