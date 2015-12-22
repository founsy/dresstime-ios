//
//  ClotheSelectionCell.swift
//  DressTime
//
//  Created by Fab on 30/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

protocol ClotheSelectionCellDelegate {
    func onSelectedBrandClothe(myClothes: JSON)
}

class ClotheSelectionCell: UITableViewCell {
    private let cellIdentifier = "BrandClotheCell"
    @IBOutlet weak var collectionView: UICollectionView!
    
    var brandClothe: JSON?
    var selectedType:String = "maille"
    var delegate : ClotheSelectionCellDelegate?
    private var selectedClothe: [JSON]?
    var pickerView: AKPickerView!
    
    private let images = ["HM_m_sweat1", "HM_m_sweat2", "HM_m_sweat3", "HM_m_sweat4"]
    
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
    
    private func applySelect(item: Int){
        for (var j=0; j < self.images.count; j++){
            if let cell = pickerView.collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: j, inSection: 0)) as? AKCollectionViewCell{
                for (var i = 0; i < cell.view.subviews.count; i++){
                    if let view = cell.view.subviews[i] as? BrandClotheCell {
                        if (item == j) {
                            
                            let scale = 240/view.frame.size.height
                            
                            UIView.animateWithDuration(0.2, animations: { () -> Void in
                                 view.transform = CGAffineTransformScale(view.transform, scale, scale);
                            })
                        } else {
                            let scale = 205/view.frame.size.height
                            UIView.animateWithDuration(0.2, animations: { () -> Void in
                                view.transform = CGAffineTransformScale(view.transform, scale, scale);
                            })
                        }
                        //view.needsUpdateConstraints()
                    }
                }
            }
        }
    }
}

extension ClotheSelectionCell : AKPickerViewDataSource {
    
    func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int {
        if let clothes = self.brandClothe {
            self.selectedClothe = clothes.array?.filter { (clothe : JSON) -> Bool in
                return clothe["brandClothe"]["clothe_type"].stringValue == selectedType
            }
            return self.selectedClothe!.count
        } else {
            return 0
        }

    }
    
    func pickerView(pickerView: AKPickerView, viewForItem item: Int) -> UIView {
        let view = NSBundle.mainBundle().loadNibNamed("BrandClotheCell", owner: self, options: nil)[0] as! BrandClotheCell
        view.frame = CGRectMake(0, 0, 207, 240)
        if (item < self.selectedClothe!.count){
            if let selected = self.selectedClothe {
                
                let clothe = selected[item]
                view.priceLabel.text = clothe["brandClothe"]["clothe_price"].stringValue
                view.imageView.image = UIImage(named:clothe["brandClothe"]["clothe_image"].stringValue.stringByReplacingOccurrencesOfString(".jpg", withString: ""))
                let named = clothe["brandClothe"]["clothe_partnerName"].stringValue.stringByReplacingOccurrencesOfString(" ", withString: "")
                view.brandIcon.image = UIImage(named:"brand\(named)")
            }
            
            view.roundCorners(UIRectCorner.AllCorners, radius: 5.0)
            view.priceView.layer.cornerRadius = 20
            view.priceView.layer.borderWidth = 1.0
            view.priceView.layer.borderColor = UIColor.blackColor().CGColor
        }
        return view
    }
    
}

extension ClotheSelectionCell : AKPickerViewDelegate {
    func pickerView(pickerView: AKPickerView, didSelectItem item: Int){
        NSLog("\(item)")
        /* NSLog(self.patternData[item]);
        self.selectedPattern = item*/
        applySelect(item)
        
        if let selected = self.selectedClothe {
            if let del = self.delegate {
                let clothe = selected[item]
                del.onSelectedBrandClothe(clothe)
            }
        }
    }
}