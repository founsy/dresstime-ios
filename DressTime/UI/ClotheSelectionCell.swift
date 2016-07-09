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
    func onSelectedBrandClothe(myClothes: [ClotheModel])
    func clotheSelectionCell(cell: ClotheSelectionCell, shopSelected clothe: BrandClothe)
}

class ClotheSelectionCell: UITableViewCell {
    private let cellIdentifier = "BrandClotheCell"
    @IBOutlet weak var collectionView: UICollectionView!
    
    var brandClothes: [BrandClothe]?
    var selectedType:String = "maille"
    var minValue : NSNumber?
    var maxValue : NSNumber?
    var delegate : ClotheSelectionCellDelegate?
    private var selectedClothe: [BrandClothe]?
    var pickerView: AKPickerView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.registerNib(UINib(nibName: "BrandClotheCell", bundle:nil), forCellWithReuseIdentifier: self.cellIdentifier)
        createPickerView()
    }
    
    private func createPickerView(){
        self.pickerView = AKPickerView(frame: self.contentView.bounds)
        self.pickerView.delegate = self;
        self.pickerView.dataSource = self;
        self.pickerView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight];
        
        self.contentView.addSubview(self.pickerView)
        
        self.pickerView.font = UIFont(name: "HelveticaNeue-Light", size: 20.0)! //[UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        self.pickerView.highlightedFont =  UIFont(name: "HelveticaNeue", size:20)!
        self.pickerView.interitemSpacing = 32.0
        self.pickerView.textColor = UIColor.whiteColor()
        self.pickerView.highlightedTextColor = UIColor.whiteColor()
        //self.pickerView.fisheyeFactor = 0.001
        self.pickerView.pickerViewStyle = AKPickerViewStyle.Wheel
        self.pickerView.maskDisabled = false
        
    }
    
}

extension ClotheSelectionCell: BrandClotheCellDelegate {
    func brandClotheCell(cell: BrandClotheCell, selectedItem clothe: BrandClothe) {
        if let del = self.delegate {
            del.clotheSelectionCell(self, shopSelected: clothe)
        }
    }
}

extension ClotheSelectionCell : AKPickerViewDataSource {
    
    func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int {
        if let clothes = self.brandClothes {
            self.selectedClothe = clothes.filter({(clothe) -> Bool in
                return clothe.clothe_type == selectedType && (minValue != nil && clothe.clothe_price.doubleValue >= minValue!.doubleValue) && (maxValue != nil && clothe.clothe_price.doubleValue <= maxValue!.doubleValue)
            })
            return self.selectedClothe!.count
        } else {
            return 0
        }

    }
    
    func pickerView(pickerView: AKPickerView, viewForItem item: Int) -> UIView {
        let view = NSBundle.mainBundle().loadNibNamed("BrandClotheCell", owner: self, options: nil)[0] as! BrandClotheCell
        view.frame = CGRectMake(0, 0, 207, 240)
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
    func pickerView(pickerView: AKPickerView, didSelectItem item: Int){
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