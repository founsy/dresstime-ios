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
    
    @IBAction func onLogoutClick(sender: AnyObject) {
        let profilDal = ProfilsDAL()
        if let user = profilDal.fetch(SharedData.sharedInstance.currentUserId!) {
            
            let jsonObject: [String: AnyObject] = [
                "access_token": user.access_token
            ]
            
            LoginService.logoutMethod(jsonObject, getCompleted: { (succeeded: Bool, result: [String: AnyObject]) -> () in
                if (succeeded){
                    let dal = ProfilsDAL()
                    let profilOld = dal.fetch(user.userid)
                    if let profil = profilOld {
                        profil.access_token = ""
                        profil.refresh_token = ""
                        profil.expire_in = 0
                        dal.update(profil)
                    }
                    dispatch_async(dispatch_get_main_queue(),  { () -> Void in
                        //Go back to login window
                        var rootController:UIViewController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("LoginViewController") as! UIViewController
                        self.presentViewController(rootController, animated: true, completion: nil)
                    })
                }
            })
        }
    }
    
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
