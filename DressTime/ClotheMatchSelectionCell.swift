//
//  ClotheMatchSelectionCell.swift
//  DressTime
//
//  Created by Fab on 30/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class ClotheMatchSelectionCell: UITableViewCell {
    private let cellIdentifier = "ClotheCell"
    @IBOutlet weak var collectionView: UICollectionView!
    
    var clothes: JSON?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.registerNib(UINib(nibName: "ClotheCell", bundle:nil), forCellWithReuseIdentifier: self.cellIdentifier)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
}

extension ClotheMatchSelectionCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let clothesMatched = self.clothes {
            return clothesMatched["clothes"].arrayValue.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! ClotheCell
        if let clothesMatched = self.clothes {
            let clothe_id = clothesMatched["clothes"][indexPath.row]["clothe"]["clothe_id"].stringValue
            let dal = ClothesDAL()
            if let clothe = dal.fetch(clothe_id) {
                cell.imageView.image = UIImage(data: clothe.clothe_image)
            }
        }
        
        return cell
    }
    
}