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
    //@IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var mainView: UIView!

    private let cellIdentifier = "OutfitCell"
    private var outfitsCollection: JSON?
    private var clothesCollection: [Clothe]?
    
    private var isEnoughOutfits = true
    var typeClothe = 1
    
    var delegate: HomeOutfitsListCellDelegate?
    var dataSource : HomeOutfitsListCellDataSource?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.outfitCollectionView.registerNib(UINib(nibName: "OutfitCell", bundle:nil), forCellWithReuseIdentifier: self.cellIdentifier)
        self.outfitCollectionView.dataSource = self
        self.outfitCollectionView.delegate = self
    }
}

extension HomeOutfitsListCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let source = self.dataSource {
            return source.numberOfItemsInHomeOutfitsListCell(self)
        }
        return 0
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! OufitCell
        cell.removeOldImages()
        let outfitElem = self.dataSource!.homeOutfitsListCell(self, outfitForItem: indexPath.row)
        cell.createOutfitView(outfitElem, cell: cell)
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
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
