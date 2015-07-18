//  ProfilViewController.swift
//  DressTime
//
//  Created by Fab on 17/07/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class ProfilViewController : UIViewController, UICollectionViewDataSource, CameraOverlayViewDelegate {

    @IBOutlet weak var mailleCollectionView: UICollectionView!
    @IBOutlet weak var topCollectionView: UICollectionView!
    @IBOutlet weak var pantsCollectionView: UICollectionView!
    
    private let reuseIdentifier = "CustomCell"
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)

    var mailleCollection: [Clothe]!
    var topCollection: [Clothe]!
    var pantsCollection: [Clothe]!
    
    let clothesDAL = ClothesDAL()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mailleCollection = clothesDAL.fetch("maille")
        topCollection = clothesDAL.fetch("top")
        pantsCollection = clothesDAL.fetch("pants")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*pragma mark - UICollectionView Datasource */
    //1
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1 //self.mailleCollection.count
    }
    
    //2
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mailleCollection.count + 1
    }
    
    //3
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UICollectionViewCell
        cell.backgroundColor = UIColor.clearColor()
        println(indexPath.row)
        if (indexPath.row == self.mailleCollection.count) {
            println("initializing button!")
            var addCellButton = UIButton(frame: CGRectMake(0, 0, 50, 50))
            addCellButton.setTitle("Add", forState: UIControlState.Normal)
            addCellButton.addTarget(self, action: "addCellButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
            addCellButton.backgroundColor = UIColor.redColor()
            cell.addSubview(addCellButton)
        } else {
            if (cell.subviews.count > 1){
                if let view = cell.subviews[1] as? UIButton {
                    view.removeFromSuperview()
                }
            }
            (cell as! ClothPhotoCell).imageView.image = UIImage(data: self.mailleCollection[indexPath.row].clothe_image)
        }
        
        // Configure the cell
        return cell
    }
    
    func addCellButtonPressed() {
        var captureView = CameraOverlayView()
        captureView.delegate = self
        captureView.typeCloth = "maille"
        self.presentViewController(captureView, animated: true, completion: nil)
    }
    
    func CameraOverlayViewResult(resultCapture: [String: AnyObject]) {
        var dal = ClothesDAL()
        dal.save(resultCapture["clothe_partnerid"] as! NSNumber, partnerName: resultCapture["clothe_partnerName"] as! String, type: resultCapture["clothe_type"] as! String, subType: resultCapture["clothe_subtype"] as! String, name: resultCapture["clothe_name"] as! String, isUnis: resultCapture["clothe_isUnis"] as! Bool, pattern: resultCapture["clothe_pattern"] as! String, cut: resultCapture["clothe_cut"] as! String, image: resultCapture["clothe_image"] as! NSData, colors: resultCapture["clothe_colors"] as! String)
    }
}
    extension ProfilViewController : UICollectionViewDelegateFlowLayout {
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
