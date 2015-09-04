//
//  DetailTypeViewController.swift
//  DressTime
//
//  Created by Fab on 04/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class DetailTypeViewController: UIViewController {
    private let cellIdentifier : String = "ClotheCell"
    private var clothesList: [Clothe]?
    var typeClothe: String?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dal = ClothesDAL()
        if let type = self.typeClothe {
            self.clothesList = dal.fetch(type: type)
        }
        tableView.registerNib(UINib(nibName: "ClotheTableCell", bundle:nil), forCellReuseIdentifier: self.cellIdentifier)
        tableView!.delegate = self
        tableView!.dataSource = self
    }
}

extension DetailTypeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
   /* func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150.0
    }*/ 
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if let list = self.clothesList {
            return list.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! ClotheTableViewCell
        
        let clothe = self.clothesList![indexPath.row]
        cell.clotheImageView.image = UIImage(data: clothe.clothe_image);
        cell.layer.shadowOffset = CGSizeMake(3, 6);
        cell.layer.shadowColor = UIColor.blackColor().CGColor
        cell.layer.shadowRadius = 8;
        cell.layer.shadowOpacity = 0.75;
        cell.clotheImageView.clipsToBounds = true
        cell.favorisIcon.clipsToBounds = true
        return cell;
        
    }
    
}