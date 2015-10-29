//
//  ShoppingViewController.swift
//  DressTime
//
//  Created by Fab on 28/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class ShoppingViewController: UIViewController {

    @IBOutlet weak var rangeSlider: UIView!
    @IBOutlet weak var collectionView: UICollectionView!

    private let slider = RangeSlider(frame: CGRectZero)
    private let cellIdentifier = "BrandClotheCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        slider.trackHighlightTintColor = UIColor(red: 235/255, green: 175/255, blue: 73/255, alpha: 1)
        rangeSlider.addSubview(slider)
       /* rangeSlider.addTarget(self, action: "rangeSliderValueChanged:",
            forControlEvents: .ValueChanged) */
        
        self.collectionView.registerNib(UINib(nibName: "BrandClotheCell", bundle:nil), forCellWithReuseIdentifier: self.cellIdentifier)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
     override func viewDidLayoutSubviews() {
        slider.frame = CGRectMake(0, 0, rangeSlider.frame.width, 18)
    }
}

extension ShoppingViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! BrandClotheCell
        cell.priceView.layer.cornerRadius = 20
        cell.priceView.layer.borderWidth = 1.0
        cell.priceView.layer.borderColor = UIColor.blackColor().CGColor
        return cell
    }

}