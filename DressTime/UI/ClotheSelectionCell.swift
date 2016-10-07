//
//  ClotheSelectionCell.swift
//  DressTime
//
//  Created by Fab on 30/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit
import MapleBacon

protocol ClotheSelectionCellDelegate {
    func onSelectedBrandClothe(_ myClothes: [ClotheModel])
    func clotheSelectionCell(_ cell: ClotheSelectionCell, shopSelected clothe: BrandClothe)
}

class ClotheSelectionCell: UITableViewCell {
    fileprivate let cellIdentifier = "BrandClotheCell"
    @IBOutlet weak var collectionView: UICollectionView!
    
    var brandClothes: [BrandClothe]?
    var selectedType:String = "maille"
    var minValue : NSNumber?
    var maxValue : NSNumber?
    var delegate : ClotheSelectionCellDelegate?
    fileprivate var selectedClothe: [BrandClothe]?
    var pickerView: AKPickerView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.register(UINib(nibName: "BrandClotheCell", bundle:nil), forCellWithReuseIdentifier: self.cellIdentifier)
        createPickerView()
    }
    
    fileprivate func createPickerView(){
        self.pickerView = AKPickerView(frame: self.contentView.bounds)
        self.pickerView.delegate = self;
        self.pickerView.dataSource = self;
        self.pickerView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight];
        
        self.contentView.addSubview(self.pickerView)
        
        self.pickerView.font = UIFont(name: "HelveticaNeue-Light", size: 20.0)! //[UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        self.pickerView.highlightedFont =  UIFont(name: "HelveticaNeue", size:20)!
        self.pickerView.interitemSpacing = 32.0
        self.pickerView.textColor = UIColor.white
        self.pickerView.highlightedTextColor = UIColor.white
        //self.pickerView.fisheyeFactor = 0.001
        self.pickerView.pickerViewStyle = AKPickerViewStyle.wheel
        self.pickerView.maskDisabled = false
        
    }
    
}

extension ClotheSelectionCell: BrandClotheCellDelegate {
    func brandClotheCell(_ cell: BrandClotheCell, selectedItem clothe: BrandClothe) {
        if let del = self.delegate {
            del.clotheSelectionCell(self, shopSelected: clothe)
        }
    }
}

extension ClotheSelectionCell : AKPickerViewDataSource {
    
    func numberOfItemsInPickerView(_ pickerView: AKPickerView) -> Int {
        if let clothes = self.brandClothes {
            self.selectedClothe = clothes.filter({(clothe) -> Bool in
                return clothe.clothe_type == selectedType && (minValue != nil && clothe.clothe_price.doubleValue >= minValue!.doubleValue) && (maxValue != nil && clothe.clothe_price.doubleValue <= maxValue!.doubleValue)
            })
            return self.selectedClothe!.count
        } else {
            return 0
        }

    }
    
    func pickerView(_ pickerView: AKPickerView, viewForItem item: Int) -> UIView {
        let view = Bundle.main.loadNibNamed("BrandClotheCell", owner: self, options: nil)?[0] as! BrandClotheCell
        view.frame = CGRect(x: 0, y: 0, width: 207, height: 240)
        view.delegate = self
        if (item < self.selectedClothe!.count){
            if let selected = self.selectedClothe {
                view.brandClotheModel = selected[item]
            }
        }
        return view
    }
    
}

extension ClotheSelectionCell : AKPickerViewDelegate {
    func pickerView(_ pickerView: AKPickerView, didSelectItem item: Int){
        if let selected = self.selectedClothe {
            if (selected.count > 0){
                if let del = self.delegate {
                    let brandClothe = selected[item]
                    del.onSelectedBrandClothe(brandClothe.clothes)
                }
            }
        }
    }
}
