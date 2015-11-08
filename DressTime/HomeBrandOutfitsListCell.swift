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
    
    private let cellIdentifier = "NewOutfitCell"
    var outfitsCollection: JSON?
    var delegate: HomeBrandOutfitsListCellDelegate?
    private var dayMoment: [String]?
    private var styleByMoment: [String]?
    private let BL = DressTimeBL()
    
    override func awakeFromNib() {
        self.collectionView.registerNib(UINib(nibName: "NewOutfitCell", bundle:nil), forCellWithReuseIdentifier: self.cellIdentifier)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    func loadTodayBrandOutfits(weather: Weather){
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
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let newCell = cell as! NewOufitCell
        
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: NewOufitCell
        cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! NewOufitCell
        cell.removeOldImages()
        var outfitElem = self.outfitsCollection![indexPath.row]
        let outfit = outfitElem["outfit"]
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        var j = 1
        
        for (var i = outfit.count-1; i >= 0 ; i--){
            let width:CGFloat = cell.containerView.frame.width
            var height:CGFloat = CGFloat(cell.containerView.frame.height/CGFloat(outfit.count))
            let x:CGFloat = 0
            var y:CGFloat = 0
            if (i == 0){
                y = 0
                if (outfit.count == 1){
                    height = cell.containerView.frame.height
                } else if (outfit.count == 2){
                    height = 110
                } else {
                    height = 80
                }
                
            } else {
                if (outfit.count == 2){
                    height = 90
                } else {
                    height = 65
                }
                
                if (i == (outfit.count-1)){
                    y = cell.containerView.frame.height - (height * CGFloat(j))
                } else {
                    y = cell.containerView.frame.height - (height * CGFloat(j)) + 10.0
                }
                
            }
            
            let rect = CGRectMake(x, y, width, height)
            j++
            let clothe_image = outfit[i]["clothe_image"].string
            cell.setBrandClothe(clothe_image!, partnerName: outfit[i]["clothe_partnerName"].stringValue, rate: outfitElem["matchingRate"].intValue, rect: rect)
        }

        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let del = self.delegate {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! NewOufitCell
            del.showBrandOutfits("")
        }
    }
}