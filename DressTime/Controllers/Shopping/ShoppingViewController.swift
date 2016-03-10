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

class ShoppingViewController: DTViewController {
    @IBOutlet weak var tableView: UITableView!

    private var brandClotheCell: ClotheSelectionCell?
    private var matchClotheCell: ClotheMatchSelectionCell?
    private var priceSelectionCell: PriceSelectionCell?
    private var textCell : TextSelectionCell?
    
    private let cellIdentifier = "BrandClotheCell"
    private var brandClothes: [BrandClothe]?
    private var typeSelected = "maille"
    
    private var currentBrandClothe: BrandClothe?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.classNameAnalytics = "Shopping"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        loadBrandClothe()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showStore"){
            if let brandClothe = self.currentBrandClothe {
                if let vc = segue.destinationViewController as? StoreViewController {
                    vc.urlShop = brandClothe.clothe_shopUrl
                }
            }
        }
    }
    
    private func loadBrandClothe(){
        ActivityLoader.shared.showProgressView(view)
        let service = DressTimeService()
        service.GetBrandClothes() { (isSuccess, object) -> Void in
            if (isSuccess){
                self.brandClothes = object
                let minValue = self.minPrice(self.typeSelected)
                let maxValue = self.maxPrice(self.typeSelected)
                self.brandClotheCell!.brandClothes = self.sortArrayByPrice(self.brandClothes!)
                self.brandClotheCell!.minValue = minValue
                self.brandClotheCell!.maxValue = maxValue
                self.priceSelectionCell!.minValue = minValue
                self.priceSelectionCell!.maxValue = maxValue
                self.brandClotheCell!.pickerView.reloadData()
                self.brandClotheCell!.pickerView.selectItem(0)
            }
            ActivityLoader.shared.hideProgressView()
        }
    }
    
    private func sortArrayByPrice(list : [BrandClothe]) -> [BrandClothe]{
        return list.sort { (clothe1, clothe2) -> Bool in
            clothe1.clothe_price < clothe2.clothe_price
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
            if let _ = cell as? PriceSelectionCell {
                //c.drawSlider()
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
        } else if (indexPath.row == 2) {
            priceSelectionCell = self.tableView.dequeueReusableCellWithIdentifier("priceSelection")! as! PriceSelectionCell
            priceSelectionCell?.delegate = self
            return priceSelectionCell!
        } else if (indexPath.row == 3){
            self.brandClotheCell = self.tableView.dequeueReusableCellWithIdentifier("clotheSelection")! as? ClotheSelectionCell
            self.brandClotheCell?.delegate = self
            return self.brandClotheCell!
        } else if (indexPath.row == 4){
            self.textCell = self.tableView.dequeueReusableCellWithIdentifier("textCell")! as? TextSelectionCell
            return self.textCell!
        } else if (indexPath.row == 5){
            self.matchClotheCell = self.tableView.dequeueReusableCellWithIdentifier("clotheMatchSelection")! as? ClotheMatchSelectionCell
            return self.matchClotheCell!
        } else {
            return UITableViewCell()
        }
    }
    
    private func minPrice(type : String) -> NSNumber {
        let typeFiltered = self.brandClothes!.filter { (item) -> Bool in
            item.clothe_type == type
        }
        
        var minPrice : NSNumber?
        for (var i = 0; i < typeFiltered.count; i++){
            if (minPrice == nil){
                minPrice = typeFiltered[i].clothe_price
            }
            if (typeFiltered[i].clothe_price < minPrice){
                minPrice = typeFiltered[i].clothe_price
            }
        }
        
        return minPrice != nil ? minPrice! : 0
    }
    
    private func maxPrice(type : String) -> NSNumber {
        let typeFiltered = self.brandClothes!.filter { (item) -> Bool in
            item.clothe_type == type
        }
        
        var maxPrice : NSNumber?
        for (var i = 0; i < typeFiltered.count; i++){
            if (maxPrice == nil){
                maxPrice = typeFiltered[i].clothe_price
            }
            if (typeFiltered[i].clothe_price > maxPrice){
                maxPrice = typeFiltered[i].clothe_price
            }
        }
        
        return maxPrice != nil ? maxPrice! : 1
    }

}


extension ShoppingViewController : PriceSelectionCellDelegate {
    
    /* Delegate */
    func priceSelectionCell(cell: UITableViewCell, valueChanged rangeSlider: RangeSlider) {
        self.brandClotheCell!.minValue = rangeSlider.lowerValue
        self.brandClotheCell!.maxValue = rangeSlider.upperValue
        self.brandClotheCell!.pickerView.reloadData()
        self.brandClotheCell!.pickerView.selectItem(0)
    }
}

extension ShoppingViewController: TypeSelectionCellDelegate {
    func onSelectedType(typeSelected: String) {
        self.brandClotheCell!.selectedType = typeSelected
        self.typeSelected = typeSelected
        let minValue = self.minPrice(self.typeSelected)
        let maxValue = self.maxPrice(self.typeSelected)
        
        self.brandClotheCell!.minValue = minValue
        self.brandClotheCell!.maxValue = maxValue
        
        if (minValue > self.priceSelectionCell!.maxValue){
            self.priceSelectionCell!.maxValue = maxValue
            self.priceSelectionCell!.minValue = minValue
        } else {
            self.priceSelectionCell!.minValue = minValue
            self.priceSelectionCell!.maxValue = maxValue
            
        }
        
        self.brandClotheCell!.pickerView.reloadData()
        self.brandClotheCell!.pickerView.selectItem(0)
    }
}


extension ShoppingViewController: ClotheSelectionCellDelegate {
    func onSelectedBrandClothe(myClothes: [ClotheModel]) {
        self.matchClotheCell?.clothes = myClothes
        if let cell = self.textCell {
            cell.numberOutfit.text = "+\(myClothes.count)"
        }
        self.matchClotheCell?.collectionView.reloadData()
    }
    
    func clotheSelectionCell(cell: ClotheSelectionCell, shopSelected clothe: BrandClothe) {
        self.currentBrandClothe = clothe
        self.performSegueWithIdentifier("showStore", sender: self)
    }
}