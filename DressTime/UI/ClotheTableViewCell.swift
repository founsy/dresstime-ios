//
//  ClotheTableViewCell.swift
//  DressTime
//
//  Created by Fab on 04/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
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



enum ViewMode {
    case outfitView
    case selectClothe
    case dressing
}

@objc
protocol ClotheTableViewCellDelegate : NSObjectProtocol {
    @objc optional func onFavoriteClick(_ isFavorite: Bool)
    @objc optional func removeItem(_ item: Clothe) -> Void
    @objc optional func detailItem(_ item: Clothe) -> Void
    @objc optional func changeItem(_ item: Clothe) -> Void
    @objc optional func selectItem(_ item: Clothe) -> Void
}

class ClotheTableViewCell: UITableViewCell{
    static let cellIdentifier = "clotheTableViewCell"
    
    
    var clothe: Clothe? {
        didSet {
            self.setupView()
        }
    }
    var viewMode: ViewMode? {
        didSet {
            if let mode = self.viewMode , mode == ViewMode.outfitView || mode == ViewMode.dressing {
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ClotheTableViewCell.finishTapped(_:)))
                self.clotheImageView.addGestureRecognizer(tapGestureRecognizer)
                
                let tapActionGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ClotheTableViewCell.finishTapped(_:)))
                self.actionView.addGestureRecognizer(tapActionGestureRecognizer)
                
                let panGestureRecognizer = UIPanGestureRecognizer(target: self , action: #selector(ClotheTableViewCell.beingDragged(_:)))
                panGestureRecognizer.delegate = self
                self.mouvingCard.addGestureRecognizer(panGestureRecognizer)
                
                selectButton.isHidden = true
            } else if let mode = self.viewMode , mode == ViewMode.selectClothe {
                selectButton.isHidden = false
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ClotheTableViewCell.detailTapped(_:)))
                self.clotheImageView.addGestureRecognizer(tapGestureRecognizer)
                
            }
        }
    }
    var delayTime: Foundation.TimeInterval = 0
    
    var isEditingMode : Bool = false {
        didSet {
            if (isEditingMode){
                UIView.animate(withDuration: 0.3, delay: delayTime, options: UIViewAnimationOptions.allowAnimatedContent, animations: {
                    self.actionView.alpha = 1
                    self.delayTime = 0
                    }, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.actionView.alpha = 0
                    self.delayTime = 0
                })
            }
        }
    }
    
    var xFromCenter: Float?
    var originPoint: CGPoint?
    var centerPoint: CGPoint?
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    var timer: Timer?
    var isConfirmeMode = false
    var ACTION_MARGIN: Float = 120      //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
    
    var delegate: ClotheTableViewCellDelegate?
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var clotheImageView: UIImageView!
    @IBOutlet weak var favorisIcon: UIImageView!
    @IBOutlet weak var confirmationView: UIView!
    @IBOutlet weak var actionView: UIView!
    @IBOutlet weak var mouvingCard: UIView!
    @IBOutlet weak var selectButton: UIButton!
    
    //Actions
    @IBAction func selectButton(_ sender: AnyObject) {
        self.delegate?.selectItem!(self.clothe!)
    }
    
    @IBAction func confirmationAction(_ sender: AnyObject) {
        print("confirmation Clic")
        timer?.invalidate()
        let finishPoint: CGPoint = CGPoint(x: -500, y: self.originPoint!.y)
        self.delegate?.removeItem!(self.clothe!)
        UIView.animate(withDuration: 0.3, animations: {
            self.mouvingCard.center = finishPoint
            self.confirmationView.alpha = 0
            }, completion: {
                (value: Bool) in
                self.isConfirmeMode = false
        })
    }
    
    @IBAction func onFavoriteTapped(_ sender: UIButton) {
        if (favoriteButton.isSelected){
            favoriteButton.isSelected = false
            favoriteButton.setImage(UIImage(named: "loveIconOFF"), for: UIControlState())
        } else {
            favoriteButton.isSelected = true
            favoriteButton.setImage(UIImage(named: "loveIconON"), for: UIControlState.selected)
        }
        if let clo = self.clothe {
            let dal = ClothesDAL()
            clo.clothe_favorite = favoriteButton.isSelected
            dal.update(clo)
            let dressTimeClient = DressTimeClient()
            dressTimeClient.updateClotheWithCompletion(for: clo, withCompletion: { (result) in
                switch result {
                case .success(_):
                    print("Clothe updated")
                case .failure(let error):
                    NotificationCenter.default.post(name: Notifications.Error.UpdateClothe, object: nil)
                    print("\(#function) Error : \(error)")
                }
            })
        }
    }
    
    @IBAction func onRemoveTapped(_ sender: AnyObject) {
        self.delegate?.removeItem!(self.clothe!)
    }
    
    @IBAction func onDetailTapped(_ sender: AnyObject) {
        self.delegate?.detailItem!(self.clothe!)
    }
    
    @IBAction func onModifyTapped(_ sender: AnyObject) {
        self.delegate?.changeItem!(self.clothe!)
    }
    
    @IBOutlet weak var onDetailTapped: UIButton!
    @IBOutlet weak var onModifyTapped: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
        
        ACTION_MARGIN = Float(UIScreen.main.bounds.width) * (1.0/3.0)
        
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier!)
        })
       

    }
    
    func setupView() -> Void {
        self.mouvingCard.layer.cornerRadius = 13
        self.mouvingCard.center = self.contentView.center
        self.clotheImageView.clipsToBounds = true
        
        xFromCenter = 0
        confirmationView.alpha = 0
        actionView.alpha = 0
        self.actionView.layer.cornerRadius = 13
        self.selectButton.layer.cornerRadius = 8
    }
    
    func initFavoriteButton(_ isFavorite: Bool){
        favoriteButton.isSelected = isFavorite
        if (isFavorite){
            favoriteButton.imageView?.image = UIImage(named: "loveIconON")
        } else {
            favoriteButton.imageView?.image = UIImage(named: "loveIconOFF")
        }
    }
    
    func detailTapped(_ gestureRecognizer: UITapGestureRecognizer) -> Void {
        self.delegate?.detailItem!(self.clothe!)
    }
    
    func finishTapped(_ gestureRecognizer: UITapGestureRecognizer) -> Void {
        self.isEditingMode = !self.isEditingMode
    }
    
    func beingDragged(_ gestureRecognizer: UIPanGestureRecognizer) -> Void {
        if (!self.isConfirmeMode){
            if let tim = self.timer , tim.isValid {
                timer?.invalidate()
            }
            xFromCenter = Float(gestureRecognizer.translation(in: self.mouvingCard).x)
                        
            switch gestureRecognizer.state {
            case UIGestureRecognizerState.began:
                self.originPoint = self.mouvingCard.center
            case UIGestureRecognizerState.changed:
                let point = CGPoint(x: self.originPoint!.x + CGFloat(xFromCenter!), y: self.originPoint!.y)
                self.mouvingCard.center = point
                if (xFromCenter < 0) {
                    self.updateOverlay(CGFloat(xFromCenter!))
                }
            case UIGestureRecognizerState.ended:
                self.afterSwipeAction()
            default:
                break
            }
        }
    }
    
    func updateOverlay(_ distance: CGFloat) -> Void {
        let alpha = CGFloat(min(fabsf(Float(distance))/200, 1))
        confirmationView.alpha = alpha
    }
    
    func afterSwipeAction() -> Void {
        let floatXFromCenter = Float(xFromCenter!)
        
        if floatXFromCenter > ACTION_MARGIN {
            self.isConfirmeMode = false
            self.rightAction()
        } else if floatXFromCenter < -ACTION_MARGIN {
            self.isConfirmeMode = true
            self.leftAction()
        } else {
            UIView.animate(withDuration: 0.3, animations: {() -> Void in
                self.confirmationView.alpha = 0
                self.originPoint = self.contentView.center
                self.mouvingCard.center = self.contentView.center
                self.mouvingCard.transform = CGAffineTransform(rotationAngle: 0)
            })
        }
    }
    
    func rightAction() -> Void {
        let finishPoint: CGPoint = CGPoint(x: 2*500, y: self.originPoint!.y)
        UIView.animate(withDuration: 0.3, animations: {
            self.mouvingCard.center = finishPoint
            }, completion: {
                (value: Bool) in
                self.delegate?.changeItem!(self.clothe!)
        })
    }
    
    func leftAction() -> Void {
        //Stop the action
        UIView.animate(withDuration: 0.3, animations: {
            let centerPoint = CGPoint(x: -(self.clotheImageView.frame.width/4), y: self.clotheImageView.center.y)
            self.mouvingCard.center = centerPoint
        }, completion: { (value : Bool) in
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ClotheTableViewCell.confirmationDeleting), userInfo: nil, repeats: false)
        }) 
    }
    
    func confirmationDeleting(){
        print("confirmationDeleting")
        UIView.animate(withDuration: 0.3, animations: {
            self.mouvingCard.center = self.originPoint!
            self.confirmationView.alpha = 0
            }, completion: {
                (value: Bool) in
                self.xFromCenter = 0
                self.isConfirmeMode = false
        })
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        return false
    }
}
