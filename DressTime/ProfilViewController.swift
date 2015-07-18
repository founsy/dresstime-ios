//  ProfilViewController.swift
//  DressTime
//
//  Created by Fab on 17/07/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class ProfilViewController : UIViewController {

    @IBOutlet weak var mailleCollectionView: UICollectionView!
    @IBOutlet weak var topCollectionView: UICollectionView!
    @IBOutlet weak var pantsCollectionView: UICollectionView!
    
    var mailleDataSource: CollectionViewController!
    var topDataSource: CollectionViewController!
    var pantsDataSource: CollectionViewController!
    
    var clotheSelected: Clothe!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       /* mailleCollection = clothesDAL.fetch("maille")
        topCollection = clothesDAL.fetch("top")
        pantsCollection = clothesDAL.fetch("pants") */
        
        self.mailleDataSource = CollectionViewController(type: "maille", targetVC: self, collectionView: mailleCollectionView)
        mailleCollectionView.dataSource = self.mailleDataSource
        mailleCollectionView.delegate = self.mailleDataSource
        self.topDataSource = CollectionViewController(type: "top", targetVC: self, collectionView: topCollectionView)
        topCollectionView.dataSource = self.topDataSource
        topCollectionView.delegate = self.topDataSource
        self.pantsDataSource = CollectionViewController(type: "pants", targetVC: self, collectionView: pantsCollectionView)
        pantsCollectionView.dataSource = self.pantsDataSource
        pantsCollectionView.delegate = self.pantsDataSource
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if(segue.identifier == "showClotheDetail") {
            //var clotheDetail = segue.sourceViewController as! ClotheDetailController
            var clotheDetail = segue.destinationViewController as! ClotheDetailController
            clotheDetail.currentClothe = clotheSelected
            if (clotheSelected.clothe_type == "maille"){
                clotheDetail.delegate = self.mailleDataSource
            } else if (clotheSelected.clothe_type == "top"){
                clotheDetail.delegate = self.topDataSource
            } else if (clotheSelected.clothe_type == "pants"){
                clotheDetail.delegate = self.pantsDataSource
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
