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
    func homeBrandOutfitsListCell(homeBrandOutfitsListCell: HomeBrandOutfitsListCell, didSelectItem item: Int)
    
}

@objc protocol HomeBrandOutfitsListCellDataSource {
    func numberOfItemsInHomeBrandOutfitsListCell(homeBrandOutfitsListCell: HomeBrandOutfitsListCell) -> Int
    func homeBrandOutfitsListCell(homeBrandOutfitsListCell: HomeBrandOutfitsListCell, clotheForItem item: Int) -> ClotheModel
}

public class HomeBrandOutfitsListCell: UITableViewCell {
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let cellIdentifier = "OutfitCell"
    private var outfitsCollection: [ClotheModel]?
    private var dayMoment: [String]?
    private var styleByMoment: [String]?
    private let BL = DressTimeBL()
    private let loading = ActivityLoader()
    
    var delegate: HomeBrandOutfitsListCellDelegate?
    var dataSource: HomeBrandOutfitsListCellDataSource?
    
    override public func awakeFromNib() {
        self.collectionView.registerNib(UINib(nibName: "OutfitCell", bundle:nil), forCellWithReuseIdentifier: self.cellIdentifier)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([NSCalendarUnit.Hour ,NSCalendarUnit.Minute], fromDate: date)
        self.dayMoment = BL.getDayMoment(components.hour)
        self.styleByMoment = BL.getStyleByMoment(self.dayMoment!)
    }
}

extension HomeBrandOutfitsListCell: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let data = self.dataSource {
            return data.numberOfItemsInHomeBrandOutfitsListCell(self)
        }
        return 0
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! OufitCell
        cell.removeOldImages()
        
        if let data = self.dataSource {
            let clothe = data.homeBrandOutfitsListCell(self, clotheForItem: indexPath.row)
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            let width:CGFloat = cell.containerView.frame.width
            let height:CGFloat = cell.containerView.frame.height
            let x:CGFloat = 0
            let y:CGFloat = 0
            let rect = CGRectMake(x, y, width, height)
            
            cell.setBrandClothe(clothe.clothe_image, partnerName: clothe.clothe_partnerName, rate: 0, rect: rect)
        }
        
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let del = self.delegate {
           del.homeBrandOutfitsListCell(self, didSelectItem: indexPath.row)
        }
    }
}