//
//  CollectionViewController.swift
//  DressTime
//
//  Created by Fab on 18/07/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import UIKit

class CollectionViewController : NSObject, UICollectionViewDataSource {
    
    private let reuseIdentifier = "CustomCell"
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    var collection: [Clothe]!
    var type: String!
    var targetVC: UIViewController
    let clothesDAL = ClothesDAL()
    var collectionView: UICollectionView
    
    init(type: String, targetVC: UIViewController, collectionView: UICollectionView){
        self.type = type
        self.targetVC = targetVC
        self.collection = clothesDAL.fetch(self.type)
        self.collectionView = collectionView
        
    }
    /*pragma mark - UICollectionView Datasource */
    //1
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //2
    @objc func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collection.count + 1
    }
    
    //3
    @objc func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UICollectionViewCell
        cell.backgroundColor = UIColor.clearColor()
        for view in cell.subviews{
            view.removeFromSuperview()
        }
        if (indexPath.row == self.collection.count) {
            var addCellButton = UIButton(frame: CGRectMake(0, 0, cell.frame.width, cell.frame.height))
            addCellButton.setTitle("Add", forState: UIControlState.Normal)
            addCellButton.addTarget(self, action: "addCellButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
            addCellButton.backgroundColor = UIColor.redColor()
            cell.addSubview(addCellButton)
        } else {
            var imageView = UIImageView(frame: CGRectMake(0, 0, cell.frame.width, cell.frame.height))
            imageView.contentMode =  UIViewContentMode.ScaleAspectFit
            imageView.image = UIImage(data: self.collection[indexPath.row].clothe_image)
            cell.addSubview(imageView)
        }
        
        // Configure the cell
        return cell
    }
    
    func addCellButtonPressed() {
        self.targetVC.performSegueWithIdentifier("AddClothe", sender: self.targetVC)
    }
}

extension CollectionViewController : ClotheDetailControllerDelegate {
    func onDeleteCloth() {
        self.collection = clothesDAL.fetch(self.type)
        self.collectionView.reloadData()
    }
}


extension CollectionViewController : CameraOverlayViewDelegate {
    func CameraOverlayViewResult(resultCapture: [String: AnyObject]) {
        var dal = ClothesDAL()
        let clotheId = NSUUID().UUIDString
        dal.save(clotheId, partnerId: resultCapture["clothe_partnerid"] as! NSNumber, partnerName: resultCapture["clothe_partnerName"] as! String, type: resultCapture["clothe_type"] as! String, subType: resultCapture["clothe_subtype"] as! String, name: resultCapture["clothe_name"] as! String, isUnis: resultCapture["clothe_isUnis"] as! Bool, pattern: resultCapture["clothe_pattern"] as! String, cut: resultCapture["clothe_cut"] as! String, image: resultCapture["clothe_image"] as! NSData, colors: resultCapture["clothe_colors"] as! String)
        self.collection = clothesDAL.fetch(self.type)
        self.collectionView.reloadData()
        
        DressTimeService.saveClothe(SharedData.sharedInstance.currentUserId!, clotheId: clotheId, dressingCompleted: { (succeeded: Bool, msg: [[String: AnyObject]]) -> () in
            //println(msg)
        })
    }
}

extension CollectionViewController : UICollectionViewDelegateFlowLayout {
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
            return CGSize(width: 100, height: 100)
    }
    
    //3
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return sectionInsets
    }
}

extension CollectionViewController : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        var cell : UICollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath)!
        println(indexPath.row)
        (self.targetVC as! ProfilViewController).clotheSelected = self.collection[indexPath.row]
        
        self.targetVC.performSegueWithIdentifier("showClotheDetail", sender: self.targetVC)
    }

}