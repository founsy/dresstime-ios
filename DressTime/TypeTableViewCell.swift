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
    
    var indexPath: NSIndexPath!
    
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
    
    var collectionView: IndexedCollectionView!
    private let kCellReuse : String = "SubTypeCell"
    private let collectionCellWidth:CGFloat = 114.0
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
        collectionLayout.itemSize = CGSizeMake(self.collectionCellWidth, 90);
        collectionLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        
        collectionView = IndexedCollectionView(frame: CGRectZero, collectionViewLayout: collectionLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clearColor()
        
        //collectionView.dataSource = self
        //collectionView.delegate = self
        
        let customCell = UINib(nibName: "SubTypeCell", bundle: nil)
        self.collectionView.registerNib(customCell, forCellWithReuseIdentifier: kCellReuse)
        self.contentView.addSubview(self.collectionView)
        self.collectionView.hidden = true
    }
    
    func showCollectionView(){
        self.iconImageView.hidden = true
        self.labelTypeText.hidden = true
        self.collectionView.reloadData()
        self.collectionView.hidden = false
    }
    
    func hideCollectionView(){
        self.iconImageView.hidden = false
        self.labelTypeText.hidden = false
        self.collectionView.hidden = true
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
        
        self.collectionView.frame = CGRectMake(margin, 10, CGFloat(self.collectionCellWidth*2), calculateCollectionViewHeight())
    }
    
    func setCollectionViewDataSourceDelegate(dataSourceDelegate delegate: protocol<UICollectionViewDelegate,UICollectionViewDataSource>, index: NSInteger) {
        self.collectionView.dataSource = delegate
        self.collectionView.delegate = delegate
        self.collectionView.tag = index
        self.collectionView.reloadData()
    }
    
    func setCollectionViewDataSourceDelegate(dataSourceDelegate delegate: protocol<UICollectionViewDelegate,UICollectionViewDataSource>, indexPath: NSIndexPath) {
        self.collectionView.dataSource = delegate
        self.collectionView.delegate = delegate
        self.collectionView.indexPath = indexPath
        self.collectionView.tag = indexPath.section
        self.collectionView.reloadData()
    }
}