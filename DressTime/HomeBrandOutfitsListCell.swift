//
//  HomeBrandOutfitsListCell.swift
//  DressTime
//
//  Created by Fab on 15/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

protocol HomeBrandOutfitsListCelllDelegate {
    func loadedBrandOutfits(outfitsCount: Int)
    func showBrandOutfits(currentStyle: String)
}

class HomeBrandOutfitsListCell: UITableViewCell {
    let cellHeight = 300.0

    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let cellIdentifier = "NewOutfitCell"
    var outfitsCollection: JSON?
    var delegate: HomeOutfitsListCellDelegate?
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
                    del.loadedOutfits(self.outfitsCollection!.count)
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
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var outfitElem = self.outfitsCollection![indexPath.row]
        var cell: NewOufitCell
        let outfit = outfitElem["outfit"]
        let dal = ClothesDAL()
        cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! NewOufitCell
        cell.removeOldImages()
        var j = 1
        
        for (var i = outfit.count-1; i >= 0 ; i--){
            let style = BL.getMomentByStyle(self.dayMoment!, style: outfitElem["style"].stringValue) //outfitElem["style"].string
            cell.styleLabel.text = style
                
            let width:CGFloat = cell.containerView.frame.width
            var height:CGFloat = CGFloat(cell.containerView.frame.height/CGFloat(outfit.count))
            let x:CGFloat = 0
            var y:CGFloat = 0
            if (i == 0){
                y = 0
                if (outfit.count == 2){
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
            cell.setBrandClothe(clothe_image!, style: style, rate: outfitElem["matchingRate"].intValue, rect: rect)
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        /*if let del = self.delegate {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! OutfitCollectionViewCell
            del.showOutfits(cell.currentStyle!)
        } */
    }
}