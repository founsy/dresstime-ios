//
//  TypeTableViewCell.swift
//  DressTime
//
//  Created by Fab on 05/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class IndexedCollectionView: UICollectionView {
    
    var indexPath: IndexPath!
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}

class TypeTableViewCell: UITableViewCell {

    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var labelTypeText: UILabel!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var blackView: UIView!
    
    var collectionView: IndexedCollectionView!
    fileprivate let kCellReuse : String = "SubTypeCell"
    fileprivate let collectionCellWidth:CGFloat = 114.0
    var collectionWidth: CGFloat!
    var currentSection: Int!
    var isLoaded = false
    
    var data: [String]! {
        didSet{
            self.isLoaded = true
        }
    }

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initialize()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func initialize(){
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        collectionLayout.itemSize = CGSize(width: self.collectionCellWidth, height: 90);
        collectionLayout.scrollDirection = UICollectionViewScrollDirection.vertical
        
        collectionView = IndexedCollectionView(frame: CGRect.zero, collectionViewLayout: collectionLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clear
        
        //collectionView.dataSource = self
        //collectionView.delegate = self
        
        let customCell = UINib(nibName: "SubTypeCell", bundle: nil)
        self.collectionView.register(customCell, forCellWithReuseIdentifier: kCellReuse)
        self.contentView.addSubview(self.collectionView)
        self.collectionView.isHidden = true
    }
    
    func showCollectionView(){
        self.iconImageView.isHidden = true
        self.labelTypeText.isHidden = true
        self.collectionView.reloadData()
        self.collectionView.isHidden = false
        //self.blurView.hidden = false
        self.blackView.isHidden = false
    }
    
    func hideCollectionView(){
        self.iconImageView.isHidden = false
        self.labelTypeText.isHidden = false
        self.collectionView.isHidden = true
        //self.blurView.hidden = true
         self.blackView.isHidden = true
    }
    
    func calculateCollectionViewHeight() -> CGFloat {
        let cellHeight = 90.0
        let height = round(Double(data.count)/2.0) * cellHeight
        return CGFloat(height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let collectionViewWidth = CGFloat(self.collectionCellWidth*2)
        let frame = self.contentView.bounds
        let margin = CGFloat((frame.width - collectionViewWidth)/2)
        
        self.collectionView.frame = CGRect(x: margin, y: 10, width: CGFloat(self.collectionCellWidth*2), height: calculateCollectionViewHeight())
    }
    
    func setCollectionViewDataSourceDelegate(dataSourceDelegate delegate: UICollectionViewDelegate & UICollectionViewDataSource, index: NSInteger) {
        self.collectionView.dataSource = delegate
        self.collectionView.delegate = delegate
        self.collectionView.tag = index
        self.collectionView.reloadData()
    }
    
    func setCollectionViewDataSourceDelegate(dataSourceDelegate delegate: UICollectionViewDelegate & UICollectionViewDataSource, indexPath: IndexPath) {
        self.collectionView.dataSource = delegate
        self.collectionView.delegate = delegate
        self.collectionView.indexPath = indexPath
        self.collectionView.tag = (indexPath as NSIndexPath).section
        self.collectionView.reloadData()
    }
}
