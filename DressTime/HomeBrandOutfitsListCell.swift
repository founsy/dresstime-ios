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
    
    private let cellIdentifier = "OutfitCell"
    var outfitsCollection: JSON?
    var delegate: HomeOutfitsListCellDelegate?
    
    override func awakeFromNib() {
        self.collectionView.registerNib(UINib(nibName: "OutfitCell", bundle:nil), forCellWithReuseIdentifier: self.cellIdentifier)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    func loadTodayBrandOutfits(){
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
        var cell: OutfitCollectionViewCell
        let outfit = outfitElem["outfit"]
        cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! OutfitCollectionViewCell
        cell.removeOldImages()
        
        for (var i = 0; i < outfit.count; i++){
            let clothe_image = outfit[i]["clothe_image"].string
            let style = outfitElem["style"].string
            cell.setBrandClothe(clothe_image!, style: style!, rate: outfitElem["matchingRate"].int!)
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