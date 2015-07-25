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
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
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
        return self.collection.count
    }
    
    //3
    @objc func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UICollectionViewCell
        cell.backgroundColor = UIColor.clearColor()
        if (self.collection.count > 0){
            var elem = self.collection[indexPath.row]
            if let outfit: AnyObject = elem["outfit"] {
                println(outfit)
                if let maille: AnyObject = outfit["maille"]{
                    if let item = self.clotheDal.fetch(maille["clothe_id"] as! String){
                        var maille = cell.viewWithTag(1) as! UIImageView
                        maille.image = UIImage(data: item.clothe_image)
                    }
                }
                if let top: AnyObject = outfit["top"]{
                    if let item = self.clotheDal.fetch(top["clothe_id"] as! String){
                        var top = cell.viewWithTag(2) as! UIImageView
                        top.image = UIImage(data: item.clothe_image)
                    }
                }
                if let pants: AnyObject = outfit["pants"]{
                    if let item = self.clotheDal.fetch(pants["clothe_id"] as! String){
                        var pants = cell.viewWithTag(3) as! UIImageView
                        pants.image = UIImage(data: item.clothe_image)
                    }
                }
                if let rate:AnyObject = elem["matchingRate"] {
                    var rateCell = cell.viewWithTag(4) as! UITextView
                    rateCell.text = String(format:"%.1f", rate as! Double)
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
            
            /*let flickrPhoto =  photoForIndexPath(indexPath)
            //2
            if var size = flickrPhoto.thumbnail?.size {
            size.width += 10
            size.height += 10
            return size
            } */
            return CGSize(width: 100, height: 190)
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
