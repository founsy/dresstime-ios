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
    fileprivate let cellIdentifier = "ClotheCell"
    @IBOutlet weak var collectionView: UICollectionView!
    
    var clothes: [ClotheModel]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.register(UINib(nibName: "ClotheCell", bundle:nil), forCellWithReuseIdentifier: self.cellIdentifier)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
}

extension ClotheMatchSelectionCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let clothesMatched = self.clothes {
            return clothesMatched.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as! ClotheCell
        if let clothesMatched = self.clothes {
            let clothe_id = clothesMatched[(indexPath as NSIndexPath).row].clothe_id
            let dal = ClothesDAL()
            if let clothe = dal.fetch(clothe_id) {
                cell.imageView.image = clothe.getImage()
            }
        }
        
        return cell
    }
    
}
