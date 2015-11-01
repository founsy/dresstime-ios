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
    @IBOutlet weak var tableView: UITableView!

    
    private let cellIdentifier = "BrandClotheCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
     override func viewDidLayoutSubviews() {
        //slider.frame = CGRectMake(0, 0, rangeSlider.frame.width, 18)
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
            return 44.0
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
            return self.tableView.dequeueReusableCellWithIdentifier("typeSelection")! as! TypeSelectionCell
        } else if (indexPath.row == 2){
            return self.tableView.dequeueReusableCellWithIdentifier("priceSelection")! as! PriceSelectionCell
        } else if (indexPath.row == 3){
            return self.tableView.dequeueReusableCellWithIdentifier("clotheSelection")! as! ClotheSelectionCell
        } else if (indexPath.row == 4){
            return self.tableView.dequeueReusableCellWithIdentifier("textCell")! as UITableViewCell
        } else if (indexPath.row == 5){
            return self.tableView.dequeueReusableCellWithIdentifier("clotheMatchSelection")! as! ClotheMatchSelectionCell
        } else {
            return UITableViewCell()
        }



    }
}