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
    func clotheScrollTableCell(_ clotheScrollTableCell : ClotheScrollTableCell, didTouchClothe clothe: Clothe)
    func clotheScrollTableCell(_ clotheScrollTableCell : ClotheScrollTableCell, didSelectedClothe clothe: Clothe)
}

class ClotheScrollTableCell: UITableViewCell {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var clotheCollection: [Clothe]?
    var currentOutfit: Clothe?
    var delegate: ClotheScrollTableCellDelegate?
    var numberOfClothesAssos = 0
    
    fileprivate var selectedPage = 0
    
    override func awakeFromNib() {
        self.scrollView.isPagingEnabled = true
        self.scrollView.delegate = self
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ClotheScrollTableCell.singleTapped(_:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        //singleTapGestureRecognizer.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(singleTapGestureRecognizer)
        
        self.scrollView.clipsToBounds = true
    }
    
    func singleTapped(_ sender: UITapGestureRecognizer) {
        if let del = self.delegate {
            del.clotheScrollTableCell(self, didTouchClothe: clotheCollection![self.selectedPage])
        }
    }
    
    func setupScrollView(_ width: CGFloat, height: CGFloat){
        if let collection = self.clotheCollection {
            self.scrollView.contentSize = CGSize(width: width * CGFloat(collection.count), height: height)
            for i in 0 ..< collection.count{
                let view = Bundle.main.loadNibNamed("ClotheTableCell", owner: self, options: nil)?[0] as! ClotheTableViewCell
                view.frame = CGRect(x: CGFloat(i)*width, y: 0, width: width, height: height+1)
                
                DispatchQueue.main.async {
                    let image = collection[i].getImage()
                    view.clotheImageView.image = image.imageWithImage(width)
                }

                view.initFavoriteButton(collection[i].clothe_favorite)
                view.clotheImageView.backgroundColor = UIColor.clear
                view.clotheImageView.clipsToBounds = true
                self.scrollView.addSubview(view)
                if (collection[i].clothe_id == currentOutfit?.clothe_id){
                    self.selectedPage = i
                }
            }
            UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                self.scrollView.setContentOffset(CGPoint(x: CGFloat(self.selectedPage)*width, y: 0), animated: false)
            }, completion: nil)
            
        }
        
     
    }

}

extension ClotheScrollTableCell: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width;
        let page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        self.selectedPage = Int(page)
        let xoffset = page * self.scrollView.bounds.size.width;
        self.scrollView.contentOffset = CGPoint(x: xoffset, y: 0);
        if let del = self.delegate{
            del.clotheScrollTableCell(self, didSelectedClothe: clotheCollection![self.selectedPage])
        }
    }
}
