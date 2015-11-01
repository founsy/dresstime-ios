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
    private var clotheCollection = [Clothe]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.registerNib(UINib(nibName: "ClotheCell", bundle:nil), forCellWithReuseIdentifier: self.cellIdentifier)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        initData()
    }
    
    func initData(){
        let dal = ClothesDAL()
        let clothes = dal.fetch(type: "pants")
        for (var i=0; i < 3; i++){
            
            let value = randomInt(0, max: clothes.count-1)
            self.clotheCollection.append(clothes[value])
        }
    }
    
    func randomInt(min: Int, max:Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
}

extension ClotheMatchSelectionCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! ClotheCell
        cell.imageView.image = UIImage(data: self.clotheCollection[indexPath.row].clothe_image)
        
        return cell
    }
    
}