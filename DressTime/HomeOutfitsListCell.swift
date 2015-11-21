//
//  HomeOutfitsListCell.swift
//  DressTime
//
//  Created by Fab on 15/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

protocol HomeOutfitsListCellDelegate {
    func loadedOutfits(outfitsCount: Int)
    func showOutfits(outfit: JSON)
}

class HomeOutfitsListCell: UITableViewCell {
    @IBOutlet weak var outfitCollectionView: UICollectionView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var curveArrow: CurveArrowView!
    @IBOutlet weak var mainView: UIView!

    private let cellIdentifier = "NewOutfitCell"
    var outfitsCollection: JSON?
    let BL = DressTimeBL()
    let service = DressTimeService()
    var delegate: HomeOutfitsListCellDelegate?
    private var dayMoment: [String]?
    private var styleByMoment: [String]?
    
    override func awakeFromNib() {
        self.outfitCollectionView.registerNib(UINib(nibName: "NewOutfitCell", bundle:nil), forCellWithReuseIdentifier: self.cellIdentifier)
        self.outfitCollectionView.dataSource = self
        self.outfitCollectionView.delegate = self
    }
    
    func loadTodayOutfits(weather: Weather){
        self.dayMoment = BL.getDayMoment(weather.hour!)
        self.styleByMoment = BL.getStyleByMoment(self.dayMoment!)
        
        service.GetOutfitsToday(self.styleByMoment!, weather: weather) { (isSuccess, object) -> Void in
            if (isSuccess){
                self.outfitsCollection = object
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.outfitCollectionView.performBatchUpdates({ () -> Void in
                        self.outfitCollectionView.reloadSections(NSIndexSet(index: 0))
                        }, completion: nil)
                })
                if let del = self.delegate {
                    del.loadedOutfits(self.outfitsCollection!.count)
                }
            }
        }
    }
}

extension HomeOutfitsListCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let collection = self.outfitsCollection {
            return collection.count
        } else {
            return 0
        }
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var outfitElem = self.outfitsCollection![indexPath.row]
        let dal = ClothesDAL()
        var cell: NewOufitCell
        let outfit = outfitElem["outfit"]
        cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! NewOufitCell
        cell.removeOldImages()
        var j = 1
        
        for (var i = outfit.count-1; i >= 0 ; i--){
            let clothe_id = outfit[i]["clothe_id"].string
            if let clothe = dal.fetch(clothe_id!) {
                let style = BL.getMomentByStyle(self.dayMoment!, style: outfitElem["style"].stringValue)
                
                let width:CGFloat = cell.containerView.frame.width
                var height:CGFloat = CGFloat(cell.containerView.frame.height/CGFloat(outfit.count))
                let x:CGFloat = 0
                var y:CGFloat = 0
                
                if (outfit.count == 1){
                    height = cell.containerView.frame.height
                } else if (outfit.count == 2){
                    height = 186.6
                } else {
                    height = 143.3
                }
                
                if (i == 0){
                    y = 0
                } else if (outfit.count-1 == i) {
                    y = cell.containerView.frame.height - height
                } else {
                    y = cell.containerView.frame.height - (height * CGFloat(j)) + (height/2.0)
                }
                
                let rect = CGRectMake(x, y, width, height)
                j++
                
                cell.createClotheView(clothe, style:style, rect: rect)
            }
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let del = self.delegate {
            let outfitElem = self.outfitsCollection![indexPath.row]
            del.showOutfits(outfitElem)
        }
    }
}
