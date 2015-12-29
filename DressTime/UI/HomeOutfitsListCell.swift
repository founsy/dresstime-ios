//
//  HomeOutfitsListCell.swift
//  DressTime
//
//  Created by Fab on 15/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

@objc protocol HomeOutfitsListCellDelegate {
    func homeOutfitsListCell(homeOutfitsListCell: HomeOutfitsListCell, loadedOutfits outfitsCount: Int)
    func homeOutfitsListCell(homeOutfitsListCell: HomeOutfitsListCell, didSelectItem item: Int)
    func homeOutfitsListCell(homeOutfitsListCell: HomeOutfitsListCell, openCaptureType type: String)
}

@objc protocol HomeOutfitsListCellDataSource {
    func numberOfItemsInHomeOutfitsListCell(homeOutfitsListCell: HomeOutfitsListCell) -> Int
    func homeOutfitsListCell(homeOutfitsListCell: HomeOutfitsListCell, outfitForItem item: Int) -> Outfit
}

class HomeOutfitsListCell: UITableViewCell {
    @IBOutlet weak var outfitCollectionView: UICollectionView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLabel: UILabel!

    private let cellIdentifier = "OutfitCell"
    private var outfitsCollection: JSON?
    private var clothesCollection: [Clothe]?
    
    private let BL = DressTimeBL()
    private var dayMoment: [String]?
    private var styleByMoment: [String]?
    
    private var isEnoughOutfits = true
    var typeClothe = 1
    
    var delegate: HomeOutfitsListCellDelegate?
    var dataSource : HomeOutfitsListCellDataSource?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.outfitCollectionView.registerNib(UINib(nibName: "OutfitCell", bundle:nil), forCellWithReuseIdentifier: self.cellIdentifier)
        self.outfitCollectionView.dataSource = self
        self.outfitCollectionView.delegate = self
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([NSCalendarUnit.Hour ,NSCalendarUnit.Minute], fromDate: date)
        self.dayMoment = BL.getDayMoment(components.hour)
        self.styleByMoment = BL.getStyleByMoment(self.dayMoment!)
        
    }
    
    private func notEnoughOutfit(){
        //Not enough outfit so create my own
        let clotheDAL = ClothesDAL()
        let tops = clotheDAL.fetch(type: "top")
        let pants = clotheDAL.fetch(type: "pants")
        let maille = clotheDAL.fetch(type: "maille")
        self.clothesCollection = [Clothe]()
         //Pick 1 top if available -> Create a outfit with 3 elem
        if (tops.count > 0){
            self.clothesCollection!.append(tops[0])
        }
         //Pick 1 bottom if available -> Create a outfit with 3 elem
        if (pants.count > 0){
            self.clothesCollection!.append(pants[0])
        }
        //Pick 1 maille if available -> Create a outfit with 3 elem
        if (maille.count > 0){
            self.clothesCollection!.append(maille[0])
        }
    }
    
    private func createOutfitView(outfit: Outfit, cell: OufitCell){
        var j = 1
        //let outfit = outfitElem["outfit"]
        let dal = ClothesDAL()
        for (var i = outfit.outfit.count-1; i >= 0 ; i--){
            let clothe_id = outfit.outfit[i].clothe_id
            if let clothe = dal.fetch(clothe_id) {
                let style = NSLocalizedString(BL.getMomentByStyle(self.dayMoment!, style: outfit.style), comment: "")
                
                let width:CGFloat = cell.containerView.frame.width
                var height:CGFloat = CGFloat(cell.containerView.frame.height/CGFloat(outfit.outfit.count))
                let x:CGFloat = 0
                var y:CGFloat = 0
                
                if (outfit.outfit.count == 1){
                    height = cell.containerView.frame.height
                } else if (outfit.outfit.count == 2){
                    height = 186.6
                } else {
                    height = 143.3
                }
                
                if (i == 0){
                    y = 0
                } else if (outfit.outfit.count-1 == i) {
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
        let height:CGFloat = 143.3
        let heightCard: CGFloat = (cell.containerView.frame.height-height)/2.0
        let x:CGFloat = 0
        
        if (clothe.clothe_type == "top"){
            cell.setLoadNecessaryImage("mailleCard", type: "0", rect: CGRectMake(x, 0, width, heightCard))
            cell.createClotheView(clothe, style:"", rect: CGRectMake(x, heightCard, width, height))
            cell.setLoadNecessaryImage("pantCard", type: "2", rect: CGRectMake(x, cell.containerView.frame.height - heightCard, width, heightCard))
            self.typeClothe = 2
        }
        if (clothe.clothe_type == "pants"){
            cell.setLoadNecessaryImage("mailleCard", type: "0", rect: CGRectMake(x, 0, width, heightCard))
            cell.setLoadNecessaryImage("topCard",  type: "1", rect: CGRectMake(x, heightCard, width, heightCard))
            cell.createClotheView(clothe, style:"", rect: CGRectMake(x, cell.containerView.frame.height - height, width, height))
            self.typeClothe = 1
        }
        if (clothe.clothe_type == "maille"){
            cell.createClotheView(clothe, style:"", rect: CGRectMake(x, 0, width, height))
            cell.setLoadNecessaryImage("topCard", type: "1", rect: CGRectMake(x, height, width, heightCard))
            cell.setLoadNecessaryImage("pantCard", type: "2",rect: CGRectMake(x, cell.containerView.frame.height - heightCard, width, heightCard))
            self.typeClothe = 2
        }
    }
}

extension HomeOutfitsListCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let source = self.dataSource {
            let number = source.numberOfItemsInHomeOutfitsListCell(self)
            if (number == 0){
                self.isEnoughOutfits = false
                self.notEnoughOutfit()
                self.titleLabel.text = NSLocalizedString("SOMETHING MISSING", comment: "")
                return self.clothesCollection!.count
            } else {
                self.isEnoughOutfits = true
                self.titleLabel.text = NSLocalizedString("OUTFIT OF THE DAY", comment: "")
                return number
            }
        }
        return 0
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! OufitCell
        cell.removeOldImages()
        if (isEnoughOutfits){
            let outfitElem = self.dataSource!.homeOutfitsListCell(self, outfitForItem: indexPath.row)
            createOutfitView(outfitElem, cell: cell)
        } else {
            let clothe = self.clothesCollection![indexPath.row]
            createClotheView(clothe, cell: cell)
            cell.delegate = self
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
            if let del = self.delegate {
                if isEnoughOutfits {
                    del.homeOutfitsListCell(self, didSelectItem: indexPath.row)
                }
            }
        
    }
}

extension HomeOutfitsListCell: OutfitCellDelegate {
    func outfitCell(outfitCell : UICollectionViewCell, typeSelected type: String) {
        if let del = self.delegate {
            del.homeOutfitsListCell(self, openCaptureType: type)
        }
    }
}
