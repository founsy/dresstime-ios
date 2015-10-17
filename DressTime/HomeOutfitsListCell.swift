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
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var curveArrow: CurveArrowView!
    @IBOutlet weak var mainView: UIVisualEffectView!
    
    private let cellIdentifier = "OutfitCell"
    var outfitsCollection: JSON?
    let BL = DressTimeBL()
    let service = DressTimeService()
    var delegate: HomeOutfitsListCellDelegate?
    private var dayMoment: [String]?
    private var styleByMoment: [String]?
    
    override func awakeFromNib() {
        self.outfitCollectionView.registerNib(UINib(nibName: "OutfitCell", bundle:nil), forCellWithReuseIdentifier: self.cellIdentifier)
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
                    if (self.outfitsCollection!.count == 0){
                        self.emptyView.hidden = false
                        self.mainView.hidden = true
                    } else {
                        self.emptyView.hidden = true
                        self.mainView.hidden = false
                        self.outfitCollectionView.performBatchUpdates({ () -> Void in
                            self.outfitCollectionView.reloadSections(NSIndexSet(index: 0))
                            }, completion: nil)
                    }
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
        var cell: OutfitCollectionViewCell
        let outfit = outfitElem["outfit"]
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! OutfitCollectionViewCell
            cell.removeOldImages()
            
            for (var i = 0; i < outfit.count; i++){
                let clothe_id = outfit[i]["clothe_id"].string
                if let clothe = dal.fetch(clothe_id!) {
                    let style = BL.getMomentByStyle(self.dayMoment!, style: outfitElem["style"].stringValue) //outfitElem["style"].string
                    cell.outfitStyle =  outfitElem["style"].stringValue
                    cell.setClothe(clothe, style: style, rate: outfitElem["matchingRate"].int!)
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
