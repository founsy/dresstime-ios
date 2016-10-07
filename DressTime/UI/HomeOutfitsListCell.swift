//
//  HomeOutfitsListCell.swift
//  DressTime
//
//  Created by Fab on 15/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

@objc protocol HomeOutfitsListCellDelegate {
    func homeOutfitsListCell(_ homeOutfitsListCell: HomeOutfitsListCell, loadedOutfits outfitsCount: Int)
    func homeOutfitsListCell(_ homeOutfitsListCell: HomeOutfitsListCell, didSelectItem item: Int)
    func homeOutfitsListCell(_ homeOutfitsListCell: HomeOutfitsListCell, openCaptureType type: String)
}

@objc protocol HomeOutfitsListCellDataSource {
    func numberOfItemsInHomeOutfitsListCell(_ homeOutfitsListCell: HomeOutfitsListCell) -> Int
    func homeOutfitsListCell(_ homeOutfitsListCell: HomeOutfitsListCell, outfitForItem item: Int) -> Outfit
}

class HomeOutfitsListCell: UITableViewCell {
    @IBOutlet weak var outfitCollectionView: UICollectionView!
    //@IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var mainView: UIView!

    fileprivate let cellIdentifier = "OutfitCell"
    fileprivate var outfitsCollection: JSON?
    fileprivate var clothesCollection: [Clothe]?
    
    fileprivate var isEnoughOutfits = true
    var typeClothe = 1
    
    var delegate: HomeOutfitsListCellDelegate?
    var dataSource : HomeOutfitsListCellDataSource?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.outfitCollectionView.register(UINib(nibName: "OutfitCell", bundle:nil), forCellWithReuseIdentifier: self.cellIdentifier)
        self.outfitCollectionView.dataSource = self
        self.outfitCollectionView.delegate = self
    }
}

extension HomeOutfitsListCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let source = self.dataSource {
            return source.numberOfItemsInHomeOutfitsListCell(self)
        }
        return 0
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as! OufitCell
        cell.removeOldImages()
        let outfitElem = self.dataSource!.homeOutfitsListCell(self, outfitForItem: (indexPath as NSIndexPath).row)
        cell.createOutfitView(outfitElem, cell: cell)
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            if let del = self.delegate {
                if isEnoughOutfits {
                    del.homeOutfitsListCell(self, didSelectItem: (indexPath as NSIndexPath).row)
                }
            }
        
    }
}

extension HomeOutfitsListCell: OutfitCellDelegate {
    func outfitCell(_ outfitCell : UICollectionViewCell, typeSelected type: String) {
        if let del = self.delegate {
            del.homeOutfitsListCell(self, openCaptureType: type)
        }
    }
}
