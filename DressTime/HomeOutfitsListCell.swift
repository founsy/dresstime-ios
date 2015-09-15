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
    func showOutfits(currentStyle: String)
}

class HomeOutfitsListCell: UITableViewCell {
    @IBOutlet weak var outfitCollectionView: UICollectionView!
    
    private let cell3Identifier = "Outfit3ElemsCell"
    private let cell2Identifier = "Outfit2ElemsCell"
    private var outfitsCollection: [[String:AnyObject]]!
    
    let cellHeight = 300.0
    
    var delegate: HomeOutfitsListCellDelegate?
    
    override func awakeFromNib() {
        self.outfitCollectionView.registerNib(UINib(nibName: "Outfit3ElemsCell", bundle:nil), forCellWithReuseIdentifier: self.cell3Identifier)
        self.outfitCollectionView.registerNib(UINib(nibName: "Outfit2ElemsCell", bundle:nil), forCellWithReuseIdentifier: self.cell2Identifier)
        self.outfitCollectionView.dataSource = self
        self.outfitCollectionView.delegate = self
    }
    
    func loadTodayOutfits(){
        DressTimeService.getOutfitsToday(SharedData.sharedInstance.currentUserId!, todayCompleted: { (succeeded: Bool, msg: [[String: AnyObject]]) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.outfitsCollection = msg
                self.outfitCollectionView.reloadData()
            })
        })
        
    }
}

extension HomeOutfitsListCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let collection = self.outfitsCollection {
            if let error = self.outfitsCollection[0]["error"] {
                return 0
            } else {
                return self.outfitsCollection.count
            }
        } else {
            return 0
        }
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var outfitElem = self.outfitsCollection[indexPath.row]
        let dal = ClothesDAL()
        var cell: OutfitElemsCollectionViewCell
        if let outfit = outfitElem["outfit"] as? NSArray {
            if (outfit.count == 2){
                cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cell2Identifier, forIndexPath: indexPath) as! Outfit2ElemsCollectionViewCell
            } else {
                cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cell3Identifier, forIndexPath: indexPath) as! Outfit3ElemsCollectionViewCell
                
            }
            for (var i = 0; i < outfit.count; i++){
                if let clothe = dal.fetch(outfit[i]["clothe_id"] as! String) {
                   cell.setClothe(clothe, style: outfitElem["style"] as! String)
                }
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let del = self.delegate {
            var cell = collectionView.cellForItemAtIndexPath(indexPath) as! OutfitElemsCollectionViewCell
            del.showOutfits(cell.currentStyle!)
        }
    }
    
}
