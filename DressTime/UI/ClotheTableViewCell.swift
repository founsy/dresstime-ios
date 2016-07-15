//
//  ClotheTableViewCell.swift
//  DressTime
//
//  Created by Fab on 04/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit


enum ViewMode {
    case OutfitView
    case SelectClothe
    case Dressing
}

@objc
protocol ClotheTableViewCellDelegate : NSObjectProtocol {
    optional func onFavoriteClick(isFavorite: Bool)
    optional func removeItem(item: Clothe) -> Void
    optional func detailItem(item: Clothe) -> Void
    optional func changeItem(item: Clothe) -> Void
    optional func selectItem(item: Clothe) -> Void
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
            if let mode = self.viewMode where mode == ViewMode.OutfitView {
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ClotheTableViewCell.finishTapped(_:)))
                self.clotheImageView.addGestureRecognizer(tapGestureRecognizer)
                
                let tapActionGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ClotheTableViewCell.finishTapped(_:)))
                self.actionView.addGestureRecognizer(tapActionGestureRecognizer)
                
                selectButton.hidden = true
            } else if let mode = self.viewMode where mode == ViewMode.SelectClothe {
                selectButton.hidden = false
            } else {
                selectButton.hidden = true
            }
        }
    }
    var delayTime: NSTimeInterval = 0
    
    var isEditingMode : Bool = false {
        didSet {
            if (isEditingMode){
                UIView.animateWithDuration(0.3, delay: delayTime, options: UIViewAnimationOptions.AllowAnimatedContent, animations: {
                    self.actionView.alpha = 1
                    }, completion: nil)
            } else {
                UIView.animateWithDuration(0.3, animations: {
                    self.actionView.alpha = 0
                })
            }
        }
    }
    
    var xFromCenter: Float?
    var originPoint: CGPoint?
    var centerPoint: CGPoint?
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    var timer: NSTimer?
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
    @IBAction func selectButton(sender: AnyObject) {
        self.delegate?.selectItem!(self.clothe!)
    }
    
    @IBAction func confirmationAction(sender: AnyObject) {
        print("confirmation Clic")
        timer?.invalidate()
        let finishPoint: CGPoint = CGPointMake(-500, self.originPoint!.y)
        self.delegate?.removeItem!(self.clothe!)
        UIView.animateWithDuration(0.3, animations: {
            self.mouvingCard.center = finishPoint
            self.confirmationView.alpha = 0
            }, completion: {
                (value: Bool) in
                self.isConfirmeMode = false
        })
    }
    
    @IBAction func onFavoriteTapped(sender: UIButton) {
        if (favoriteButton.selected){
            favoriteButton.selected = false
            favoriteButton.setImage(UIImage(named: "loveIconOFF"), forState: UIControlState.Normal)
        } else {
            favoriteButton.selected = true
            favoriteButton.setImage(UIImage(named: "loveIconON"), forState: UIControlState.Selected)
        }
        if let clo = self.clothe {
            let dal = ClothesDAL()
            clo.clothe_favorite = favoriteButton.selected
            dal.update(clo)
            DressingService().UpdateClothe(clo) { (isSuccess, object) -> Void in
                if (!isSuccess) {
                    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.Error.UpdateClothe, object: nil)
                }
                print("Clothe Sync")
            }
        }
    }
    
    @IBAction func onRemoveTapped(sender: AnyObject) {
        self.delegate?.removeItem!(self.clothe!)
    }
    
    @IBAction func onDetailTapped(sender: AnyObject) {
        self.delegate?.detailItem!(self.clothe!)
    }
    
    @IBAction func onModifyTapped(sender: AnyObject) {
        self.delegate?.changeItem!(self.clothe!)
    }
    
    @IBOutlet weak var onDetailTapped: UIButton!
    @IBOutlet weak var onModifyTapped: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
        
        ACTION_MARGIN = Float(UIScreen.mainScreen().bounds.width) * (1.0/3.0)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self , action: #selector(ClotheTableViewCell.beingDragged(_:)))
        panGestureRecognizer.delegate = self
        self.mouvingCard.addGestureRecognizer(panGestureRecognizer)
        
        backgroundTaskIdentifier = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({
            UIApplication.sharedApplication().endBackgroundTask(self.backgroundTaskIdentifier!)
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
    
    func initFavoriteButton(isFavorite: Bool){
        favoriteButton.selected = isFavorite
        if (isFavorite){
            favoriteButton.imageView?.image = UIImage(named: "loveIconON")
        } else {
            favoriteButton.imageView?.image = UIImage(named: "loveIconOFF")
        }
    }
    
    func finishTapped(gestureRecognizer: UITapGestureRecognizer) -> Void {
        self.isEditingMode = !self.isEditingMode
    }
    
    func beingDragged(gestureRecognizer: UIPanGestureRecognizer) -> Void {
        if (!self.isConfirmeMode){
            if let tim = self.timer where tim.valid {
                timer?.invalidate()
            }
            xFromCenter = Float(gestureRecognizer.translationInView(self.mouvingCard).x)
            
            switch gestureRecognizer.state {
            case UIGestureRecognizerState.Began:
                self.originPoint = self.mouvingCard.center
            case UIGestureRecognizerState.Changed:
                let point = CGPointMake(self.originPoint!.x + CGFloat(xFromCenter!), self.originPoint!.y)
                self.mouvingCard.center = point
                if (xFromCenter < 0) {
                    self.updateOverlay(CGFloat(xFromCenter!))
                }
            case UIGestureRecognizerState.Ended:
                self.afterSwipeAction()
            default:
                break
            }
        }
    }
    
    func updateOverlay(distance: CGFloat) -> Void {
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
            UIView.animateWithDuration(0.3, animations: {() -> Void in
                self.confirmationView.alpha = 0
                self.originPoint = self.contentView.center
                self.mouvingCard.center = self.contentView.center
                self.mouvingCard.transform = CGAffineTransformMakeRotation(0)
            })
        }
    }
    
    func rightAction() -> Void {
        let finishPoint: CGPoint = CGPointMake(2*500, self.originPoint!.y)
        UIView.animateWithDuration(0.3, animations: {
            self.mouvingCard.center = finishPoint
            }, completion: {
                (value: Bool) in
                self.delegate?.changeItem!(self.clothe!)
        })
    }
    
    func leftAction() -> Void {
        //Stop the action
        UIView.animateWithDuration(0.3, animations: {
            let centerPoint = CGPointMake(-(self.clotheImageView.frame.width/4), self.clotheImageView.center.y)
            self.mouvingCard.center = centerPoint
        }) { (value : Bool) in
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ClotheTableViewCell.confirmationDeleting), userInfo: nil, repeats: false)
        }
    }
    
    func confirmationDeleting(){
        print("confirmationDeleting")
        UIView.animateWithDuration(0.3, animations: {
            self.mouvingCard.center = self.originPoint!
            self.confirmationView.alpha = 0
            }, completion: {
                (value: Bool) in
                self.xFromCenter = 0
                self.isConfirmeMode = false
        })
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translationInView(superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        return false
    }
}