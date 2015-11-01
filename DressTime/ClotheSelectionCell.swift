//
//  ClotheSelectionCell.swift
//  DressTime
//
//  Created by Fab on 30/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class ClotheSelectionCell: UITableViewCell {
    private let cellIdentifier = "BrandClotheCell"
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.registerNib(UINib(nibName: "BrandClotheCell", bundle:nil), forCellWithReuseIdentifier: self.cellIdentifier)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
}

extension ClotheSelectionCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! BrandClotheCell
        cell.priceView.layer.cornerRadius = 20
        cell.priceView.layer.borderWidth = 1.0
        cell.priceView.layer.borderColor = UIColor.blackColor().CGColor
        return cell
    }
    
}