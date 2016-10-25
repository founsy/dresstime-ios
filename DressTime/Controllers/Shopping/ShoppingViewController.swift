//
//  ShoppingViewController.swift
//  DressTime
//
//  Created by Fab on 28/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ShoppingViewController: DTViewController {
    @IBOutlet weak var tableView: UITableView!

    fileprivate var brandClotheCell: ClotheSelectionCell?
    fileprivate var matchClotheCell: ClotheMatchSelectionCell?
    fileprivate var priceSelectionCell: PriceSelectionCell?
    fileprivate var textCell : TextSelectionCell?
    
    fileprivate let cellIdentifier = "BrandClotheCell"
    fileprivate var brandClothes: [BrandClothe]?
    fileprivate var typeSelected = "maille"
    
    fileprivate var currentBrandClothe: BrandClothe?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.classNameAnalytics = "Shopping"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        loadBrandClothe()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showStore"){
            if let brandClothe = self.currentBrandClothe {
                if let vc = segue.destination as? StoreViewController {
                    vc.urlShop = brandClothe.clothe_shopUrl
                }
            }
        }
    }
    
    fileprivate func loadBrandClothe(){
        ActivityLoader.shared.showProgressView(view)
       /* let service = DressTimeService()
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
        } */
    }
    
    fileprivate func sortArrayByPrice(_ list : [BrandClothe]) -> [BrandClothe]{
        return list.sorted { (clothe1, clothe2) -> Bool in
            clothe1.clothe_price.doubleValue < clothe2.clothe_price.doubleValue
        }
    }
}

extension ShoppingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if ((indexPath as NSIndexPath).row == 3){
            return 250.0
        } else if ((indexPath as NSIndexPath).row == 5){
            return 150.0
        }else {
            if (UIScreen.main.bounds.height == 736){
                return 55.0
            } else {
                return 44.0
            }
        }

    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if ((indexPath as NSIndexPath).row == 2){
            if let _ = cell as? PriceSelectionCell {
                //c.drawSlider()
            }
        } else if ((indexPath as NSIndexPath).row == 1){
            if let c = cell as? TypeSelectionCell {
                cell.layoutIfNeeded()
                c.drawBorderButton()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if ((indexPath as NSIndexPath).row == 0){
            return self.tableView.dequeueReusableCell(withIdentifier: "textHeader")! as UITableViewCell
        } else if ((indexPath as NSIndexPath).row == 1){
            let typeCell = self.tableView.dequeueReusableCell(withIdentifier: "typeSelection")! as! TypeSelectionCell
            typeCell.delegate = self
            return typeCell
        } else if ((indexPath as NSIndexPath).row == 2) {
            priceSelectionCell = self.tableView.dequeueReusableCell(withIdentifier: "priceSelection")! as? PriceSelectionCell
            priceSelectionCell?.delegate = self
            return priceSelectionCell!
        } else if ((indexPath as NSIndexPath).row == 3){
            self.brandClotheCell = self.tableView.dequeueReusableCell(withIdentifier: "clotheSelection")! as? ClotheSelectionCell
            self.brandClotheCell?.delegate = self
            return self.brandClotheCell!
        } else if ((indexPath as NSIndexPath).row == 4){
            self.textCell = self.tableView.dequeueReusableCell(withIdentifier: "textCell")! as? TextSelectionCell
            return self.textCell!
        } else if ((indexPath as NSIndexPath).row == 5){
            self.matchClotheCell = self.tableView.dequeueReusableCell(withIdentifier: "clotheMatchSelection")! as? ClotheMatchSelectionCell
            return self.matchClotheCell!
        } else {
            return UITableViewCell()
        }
    }
    
    fileprivate func minPrice(_ type : String) -> NSNumber {
        let typeFiltered = self.brandClothes!.filter { (item) -> Bool in
            item.clothe_type == type
        }
        
        var minPrice : NSNumber?
        for i in 0...typeFiltered.count-1 {
            if (minPrice == nil){
                minPrice = typeFiltered[i].clothe_price
            }
            if (typeFiltered[i].clothe_price.doubleValue < minPrice?.doubleValue){
                minPrice = typeFiltered[i].clothe_price
            }
        }
        
        return minPrice != nil ? minPrice! : 0
    }
    
    fileprivate func maxPrice(_ type : String) -> NSNumber {
        let typeFiltered = self.brandClothes!.filter { (item) -> Bool in
            item.clothe_type == type
        }
        
        var maxPrice : NSNumber?
        for i in 0...typeFiltered.count-1 {
            if (maxPrice == nil){
                maxPrice = typeFiltered[i].clothe_price
            }
            if (typeFiltered[i].clothe_price.doubleValue > maxPrice?.doubleValue){
                maxPrice = typeFiltered[i].clothe_price
            }
        }
        
        return maxPrice != nil ? maxPrice! : 1
    }

}


extension ShoppingViewController : PriceSelectionCellDelegate {
    
    /* Delegate */
    func priceSelectionCell(_ cell: UITableViewCell, valueChanged rangeSlider: RangeSlider) {
        self.brandClotheCell!.minValue = rangeSlider.lowerValue as NSNumber?
        self.brandClotheCell!.maxValue = rangeSlider.upperValue as NSNumber?
        self.brandClotheCell!.pickerView.reloadData()
        self.brandClotheCell!.pickerView.selectItem(0)
    }
}

extension ShoppingViewController: TypeSelectionCellDelegate {
    func onSelectedType(_ typeSelected: String) {
        self.brandClotheCell!.selectedType = typeSelected
        self.typeSelected = typeSelected
        let minValue = self.minPrice(self.typeSelected)
        let maxValue = self.maxPrice(self.typeSelected)
        
        self.brandClotheCell!.minValue = minValue
        self.brandClotheCell!.maxValue = maxValue
        
        if (minValue.doubleValue > self.priceSelectionCell!.maxValue?.doubleValue){
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
    func onSelectedBrandClothe(_ myClothes: [ClotheModel]) {
        self.matchClotheCell?.clothes = myClothes
        if let cell = self.textCell {
            cell.numberOutfit.text = "+\(myClothes.count)"
        }
        self.matchClotheCell?.collectionView.reloadData()
    }
    
    func clotheSelectionCell(_ cell: ClotheSelectionCell, shopSelected clothe: BrandClothe) {
        self.currentBrandClothe = clothe
        self.performSegue(withIdentifier: "showStore", sender: self)
    }
}
