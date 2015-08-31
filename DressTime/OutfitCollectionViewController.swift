//
//  OutfitCollectionViewController.swift
//  DressTime
//
//  Created by Fab on 19/07/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import UIKit

class OutfitCollectionViewController : NSObject, UICollectionViewDataSource {
    
    private let reuseIdentifier = "OutfitCell"
    private let sectionInsets = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
    
    var collection: [[String:AnyObject]]!
    var collectionView: UICollectionView
    let clotheDal = ClothesDAL()
    
    init(outfits: [[String:AnyObject]], collectionView: UICollectionView){
        self.collection = outfits
        self.collectionView = collectionView
        
    }
    /*pragma mark - UICollectionView Datasource */
    //1
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //2
    @objc func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collection.count > 4 ? 4 : self.collection.count
    }
    
    //3
    @objc func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UICollectionViewCell
        cell.backgroundColor = UIColor.clearColor()
        if (self.collection.count > 0){
            var elem = self.collection[indexPath.row]
            if let outfit = elem["outfit"] as? NSArray {
                var k = 1;
                for clothe in outfit {
                    let type = clothe["clothe_type"] as! NSString
                    let item = self.clotheDal.fetch(clothe["clothe_id"] as! String)
                    
                    var imageView = cell.viewWithTag(k) as! UIImageView
                    imageView.image = UIImage(data: item!.clothe_image)
                    
                    if let rate:AnyObject = clothe["matchingRate"] {
                        if let rateCell = cell.viewWithTag(4) as? UITextView {
                            rateCell.text = String(format:"%.1f", rate as! Double)
                        }
                    }
                    k = k+1
                }
                if (outfit.count < 3){
                    for var index = outfit.count; index < 4; index++ {
                        if let imageView = cell.viewWithTag(k) as? UIImageView {
                            imageView.image = nil
                        }
                    }
                }
            }
        }
        // Configure the cell
        return cell
    }
}

extension OutfitCollectionViewController : UICollectionViewDelegateFlowLayout {
    //1
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            var widthParent = collectionView.bounds.size.width
            var width = widthParent/2 - 40
            var height = (collectionView.bounds.size.height/2)-10
            
            return CGSize(width: width, height: height)
    }
    
    //3
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return sectionInsets
    }
}

extension OutfitCollectionViewController : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        var cell : UICollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath)!
        println(indexPath.row)
        //(self.targetVC as! ProfilViewController).clotheSelected = self.collection[indexPath.row]
        
        //self.targetVC.performSegueWithIdentifier("showClotheDetail", sender: self.targetVC)
    }
    
}
