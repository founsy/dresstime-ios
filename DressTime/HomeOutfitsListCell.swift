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

    private let cellIdentifier = "OutfitCell"
    private var outfitsCollection: JSON?
    private var clothesCollection: [Clothe]?
    
    private let BL = DressTimeBL()
    private let service = DressTimeService()
    private var dayMoment: [String]?
    private var styleByMoment: [String]?
    
    private var isEnoughOutfits = true
    
    private let loading = ActivityLoader()
    
    var delegate: HomeOutfitsListCellDelegate?

    override func awakeFromNib() {
        self.outfitCollectionView.registerNib(UINib(nibName: "OutfitCell", bundle:nil), forCellWithReuseIdentifier: self.cellIdentifier)
        self.outfitCollectionView.dataSource = self
        self.outfitCollectionView.delegate = self
    }
    
    func loadTodayOutfits(weather: Weather){
        self.loading.showProgressView(self.contentView)
        self.dayMoment = BL.getDayMoment(weather.hour!)
        self.styleByMoment = BL.getStyleByMoment(self.dayMoment!)
        
        service.GetOutfitsToday(self.styleByMoment!, weather: weather) { (isSuccess, object) -> Void in
            if (isSuccess){
                self.outfitsCollection = object
                if (self.outfitsCollection?.count == 0){
                    self.isEnoughOutfits = false
                    self.notEnoughOutfit()
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.outfitCollectionView.performBatchUpdates({ () -> Void in
                        self.outfitCollectionView.reloadSections(NSIndexSet(index: 0))
                        }, completion: nil)
                })
                if let del = self.delegate {
                    del.loadedOutfits(self.outfitsCollection!.count)
                }
            }
            self.loading.hideProgressView()
        }
    }
    
    private func notEnoughOutfit(){
        //Not enough outfit so create my own
        let clotheDAL = ClothesDAL()
        let tops = clotheDAL.fetch(type: "top")
        let pants = clotheDAL.fetch(type: "pants")
        self.clothesCollection = [Clothe]()
         //Pick 1 top if available -> Create a outfit with 2 elem
        if (tops.count > 0){
            self.clothesCollection!.append(tops[0])
        }
         //Pick 1 bottom if available -> Create a outfit with 2 elem
        if (pants.count > 0){
            self.clothesCollection!.append(pants[0])
        }
    }
    
    private func createOutfitView(outfitElem: JSON, cell: OufitCell){
        var j = 1
        let outfit = outfitElem["outfit"]
        let dal = ClothesDAL()
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
    }
    
    private func createClotheView(clothe: Clothe, cell: OufitCell){
        let width:CGFloat = cell.containerView.frame.width
        let height:CGFloat = 186.6
        let x:CGFloat = 0
        let y:CGFloat = 0
        let rect = CGRectMake(x, y, width, height)
        if (clothe.clothe_type == "top"){
            cell.setLoadNecessaryImage("underwearIconM", rect: CGRectMake(x, cell.containerView.frame.height - height, width, height))
            cell.createClotheView(clothe, style:"", rect: rect)
        }
        if (clothe.clothe_type == "pants"){
            cell.setLoadNecessaryImage("underwearIconM", rect: rect)
            cell.createClotheView(clothe, style:"", rect: CGRectMake(x, cell.containerView.frame.height - height, width, height))
        }
    }
}

extension HomeOutfitsListCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let collection = self.outfitsCollection {
            if (isEnoughOutfits) {
                return collection.count
            } else if let collection = self.clothesCollection {
                return collection.count
            }
        }
        return 0
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! OufitCell
        cell.removeOldImages()
        if (isEnoughOutfits){
            let outfitElem = self.outfitsCollection![indexPath.row]
            createOutfitView(outfitElem, cell: cell)
        } else {
            let clothe = self.clothesCollection![indexPath.row]
            createClotheView(clothe, cell: cell)
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if isEnoughOutfits {
            if let del = self.delegate {
                let outfitElem = self.outfitsCollection![indexPath.row]
                del.showOutfits(outfitElem)
            }
        }
    }
}
