//
//  HomeBrandOutfitsListCell.swift
//  DressTime
//
//  Created by Fab on 15/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

protocol HomeBrandOutfitsListCellDelegate {
    func loadedBrandOutfits(outfitsCount: Int)
    func showBrandOutfits(currentStyle: String)
}

class HomeBrandOutfitsListCell: UITableViewCell {
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let cellIdentifier = "OutfitCell"
    private var outfitsCollection: JSON?
    private var dayMoment: [String]?
    private var styleByMoment: [String]?
    private let BL = DressTimeBL()
    private let loading = ActivityLoader()
    
    var delegate: HomeBrandOutfitsListCellDelegate?
    
    
    override func awakeFromNib() {
        self.collectionView.registerNib(UINib(nibName: "OutfitCell", bundle:nil), forCellWithReuseIdentifier: self.cellIdentifier)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    func loadTodayBrandOutfits(weather: Weather){
        self.loading.showProgressView(self.contentView)
        self.dayMoment = BL.getDayMoment(weather.hour!)
        self.styleByMoment = BL.getStyleByMoment(self.dayMoment!)
        
        DressTimeService().GetBrandOutfitsToday { (isSuccess, object) -> Void in
            if (isSuccess){
                self.outfitsCollection = object
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.collectionView.reloadData()
                })
                if let del = self.delegate {
                    del.loadedBrandOutfits(self.outfitsCollection!.count)
                }
            }
            self.loading.hideProgressView()
        }
    }
}

extension HomeBrandOutfitsListCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let collection = self.outfitsCollection {
            return collection.count
        } else {    
            return 0
        }
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! OufitCell
        cell.removeOldImages()
        var outfitElem = self.outfitsCollection![indexPath.row]
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        let width:CGFloat = cell.containerView.frame.width
        let height:CGFloat = cell.containerView.frame.height
        let x:CGFloat = 0
        let y:CGFloat = 0
        let rect = CGRectMake(x, y, width, height)
        let clothe_image = outfitElem["clothe_image"].string
        cell.setBrandClothe(clothe_image!, partnerName: outfitElem["clothe_partnerName"].stringValue, rate: 0, rect: rect)
         return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let del = self.delegate {
            del.showBrandOutfits("")
        }
    }
}