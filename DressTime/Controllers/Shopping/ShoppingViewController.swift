//
//  ShoppingViewController.swift
//  DressTime
//
//  Created by Fab on 28/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit
import Parse

class ShoppingViewController: UIDTViewController {
    @IBOutlet weak var tableView: UITableView!

    private var brandClotheCell: ClotheSelectionCell?
    private var matchClotheCell: ClotheMatchSelectionCell?
    
    private let cellIdentifier = "BrandClotheCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.classNameAnalytics = "Shopping"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }
    
     override func viewDidLayoutSubviews() {
        //slider.frame = CGRectMake(0, 0, rangeSlider.frame.width, 18)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        ActivityLoader.shared.showProgressView(view)
        loadBrandClothe()
    }
    
    private func loadBrandClothe(){
        let service = DressTimeService()
        service.GetBrandClothes() { (isSuccess, object) -> Void in
            if (isSuccess){
                self.brandClotheCell!.brandClothe = object
                self.brandClotheCell!.pickerView.reloadData()
            }
            ActivityLoader.shared.hideProgressView()
        }
    }
    
}

extension ShoppingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row == 3){
            return 250.0
        } else if (indexPath.row == 5){
            return 150.0
        }else {
            if (UIScreen.mainScreen().bounds.height == 736){
                return 55.0
            } else {
                return 44.0
            }
        }

    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == 2){
            if let c = cell as? PriceSelectionCell {
                c.drawSlider()
            }
        } else if (indexPath.row == 1){
            if let c = cell as? TypeSelectionCell {
                cell.layoutIfNeeded()
                c.drawBorderButton()
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row == 0){
            return self.tableView.dequeueReusableCellWithIdentifier("textHeader")! as UITableViewCell
        } else if (indexPath.row == 1){
            let typeCell = self.tableView.dequeueReusableCellWithIdentifier("typeSelection")! as! TypeSelectionCell
            typeCell.delegate = self
            return typeCell
        } else if (indexPath.row == 2){
            return self.tableView.dequeueReusableCellWithIdentifier("priceSelection")! as! PriceSelectionCell
        } else if (indexPath.row == 3){
            self.brandClotheCell = self.tableView.dequeueReusableCellWithIdentifier("clotheSelection")! as? ClotheSelectionCell
            
            self.brandClotheCell?.delegate = self
            return self.brandClotheCell!
        } else if (indexPath.row == 4){
            return self.tableView.dequeueReusableCellWithIdentifier("textCell")! as! TextSelectionCell
        } else if (indexPath.row == 5){
            self.matchClotheCell = self.tableView.dequeueReusableCellWithIdentifier("clotheMatchSelection")! as? ClotheMatchSelectionCell
            return self.matchClotheCell!
        } else {
            return UITableViewCell()
        }



    }
}

extension ShoppingViewController: TypeSelectionCellDelegate {
    func onSelectedType(typeSelected: String) {
        self.brandClotheCell!.selectedType = typeSelected
        self.brandClotheCell!.pickerView.reloadData()
    }
}


extension ShoppingViewController: ClotheSelectionCellDelegate {
    func onSelectedBrandClothe(myClothes: JSON) {
        self.matchClotheCell?.clothes = myClothes;
        self.matchClotheCell?.collectionView.reloadData()
    }
}