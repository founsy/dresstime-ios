//
//  ClotheSelectionCell.swift
//  DressTime
//
//  Created by Fab on 30/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

protocol ClotheSelectionCellDelegate {
    func onSelectedBrandClothe(myClothes: JSON)
}

class ClotheSelectionCell: UITableViewCell {
    private let cellIdentifier = "BrandClotheCell"
    @IBOutlet weak var collectionView: UICollectionView!
    
    var brandClothe: JSON?
    var selectedType:String = "maille"
    var delegate : ClotheSelectionCellDelegate?
    private var selectedClothe: [JSON]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.registerNib(UINib(nibName: "BrandClotheCell", bundle:nil), forCellWithReuseIdentifier: self.cellIdentifier)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
}

extension ClotheSelectionCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let clothes = self.brandClothe {
            self.selectedClothe = clothes.array?.filter { (clothe : JSON) -> Bool in
                return clothe["brandClothe"]["clothe_type"].stringValue == selectedType
            }
            return self.selectedClothe!.count
        } else {
            return 0
        }
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! BrandClotheCell
        if let selected = self.selectedClothe {
            let clothe = selected[indexPath.row]
            cell.imageView.image = UIImage(named:clothe["brandClothe"]["clothe_image"].stringValue.stringByReplacingOccurrencesOfString(".jpg", withString: ""))
        }
        
        cell.priceView.layer.cornerRadius = 20
        cell.priceView.layer.borderWidth = 1.0
        cell.priceView.layer.borderColor = UIColor.blackColor().CGColor
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let selected = self.selectedClothe {
            if let del = self.delegate {
                let clothe = selected[indexPath.row]
                del.onSelectedBrandClothe(clothe)
            }
        }
    }
}