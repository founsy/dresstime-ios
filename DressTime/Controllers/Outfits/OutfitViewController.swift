//
//  OutfitsViewController.swift
//  DressTime
//
//  Created by Fab on 09/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

protocol OutfitViewControllerDelegate {
    func outfitViewControllerDelegate(_ outfitViewController: OutfitViewController, didModifyOutfit outfit: Outfit)
}


class OutfitViewController: DTViewController {
    fileprivate let cellIdentifier : String = "ClotheTableCell"
    fileprivate let dal = ClothesDAL()
    fileprivate var currentClothe: Clothe?
    fileprivate var indexPathToAnimate : Int?
    fileprivate var isEditingMode = false
    
    fileprivate var confirmationView: ConfirmSave?
    
    var outfitObject: Outfit?
    var currentOutfits: [ClotheModel]?
    var delegate: OutfitViewControllerDelegate?
    var creationDate = Date()
    var gradient : CAGradientLayer?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dressupButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var onEditTapped: UIBarButtonItem!
    
    @IBAction func onEditTapped(_ sender: AnyObject) {
        isEditingMode = !isEditingMode
        if (isEditingMode){
            self.addDoneBarButton()
        } else {
             self.addEditBarButton()
        }
        tableView.reloadData()
    }
    
    @IBAction func onDressUpTapped(_ sender: AnyObject) {
        if (outfitObject == nil) {
            outfitObject = Outfit(clothes: self.currentOutfits!, updatedDate: self.creationDate, isSuggestion: false, isPutOn: true)
            // TODO - Add style
        } else if (outfitObject!.clothes.count != self.currentOutfits!.count) {
            outfitObject!.clothes = self.currentOutfits!
        }
        
        self.outfitObject?.isPutOn = true
        var isModify = false
        if (currentOutfits!.count == outfitObject!.clothes.count) {
            for i in 0..<currentOutfits!.count {
                isModify = isModify || (currentOutfits![i].clothe_id != outfitObject?.clothes[i].clothe_id)
            }
        } else {
            isModify = true
        }
        
        if (isModify){
            self.outfitObject?.clothes = currentOutfits!
            self.outfitObject?.orderOutfit()
            self.outfitObject?.isSuggestion = false
        }
        
        self.outfitObject?.updatedDate = self.creationDate
        
        let dresstimeClient = DressTimeClient()
        dresstimeClient.saveOutfitWithCompletion(for: self.outfitObject!, withCompletion: {
            result in
            switch result {
            case .success(_):
                self.delegate?.outfitViewControllerDelegate(self, didModifyOutfit: self.outfitObject!)
            case .failure(let error):
                print("\(#function) Error : \(error)")
                NotificationCenter.default.post(name: Notifications.Error.SaveOutfit, object: nil)
            }
        })
        
        self.confirmationView?.layer.transform = CATransform3DMakeScale(0.5 , 0.5, 1.0)
        
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.25, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
            self.confirmationView?.alpha = 1
            self.confirmationView?.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
            }, completion: { (isFinish) -> Void in
                UIView.animate(withDuration: 0.2, animations: { () -> Void in
                    self.confirmationView?.alpha = 0
                    self.confirmationView?.layer.transform = CATransform3DMakeScale(0.5 , 0.5, 1.0)
                    }, completion: { (finish) -> Void in
                         _ = self.navigationController?.popViewController(animated: true)
                })
        })
    }

    // MARK: - LifeCycle Methode
    override func viewDidLoad() {
        self.hideTabBar = true
        super.viewDidLoad()
        self.classNameAnalytics = "Outfit View"
        self.navigationItem.title = "Outfit" //TODO Translate
        
        tableView.register(UINib(nibName: "ClotheTableCell", bundle:nil), forCellReuseIdentifier: ClotheTableViewCell.cellIdentifier)
        ActivityLoader.shared.showProgressView(view)
        
        dressupButton.layer.cornerRadius = 20.0
        dressupButton.layer.shadowOffset = CGSize(width: 0, height: 1);
        dressupButton.layer.shadowColor = UIColor.black.cgColor
        dressupButton.layer.shadowRadius = 5;
        dressupButton.layer.shadowOpacity = 0.5;
        
        if let weather = SharedData.sharedInstance.currentWeater {
            self.backgroundImageView.image = UIImage(named: WeatherHelper.changeBackgroundDependingWeatherCondition(weather.code == nil ? 800 : weather.code!))
        }
        
        if self.currentOutfits == nil {
            self.currentOutfits = self.outfitObject?.clothes ?? [ClotheModel]()
        }
        self.checkOutfitValidation()

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !((self.tabBarController?.tabBar.isHidden)!) {
            self.tabBarController?.tabBar.isHidden = true
            UIApplication.shared.isStatusBarHidden = false
        }
        super.viewWillAppear(animated)
        //Remove Title of Back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Outfit", comment: ""), style: .plain, target: nil, action: nil)
        
        if let animateIndex = self.indexPathToAnimate {
            tableView.reloadRows(at: [IndexPath(row: animateIndex, section: 0)] , with: UITableViewRowAnimation.automatic)
            self.checkOutfitValidation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.confirmationView = Bundle.main.loadNibNamed("ConfirmSave", owner: self, options: nil)?[0] as? ConfirmSave
        self.confirmationView!.frame = CGRect(x: UIScreen.main.bounds.size.width/2.0 - 50, y: UIScreen.main.bounds.size.height/2.0 - 50 - 65, width: 100, height: 100)
        self.confirmationView!.alpha = 0
        self.confirmationView!.layer.cornerRadius = 50
        
        self.view.addSubview(self.confirmationView!)
        ActivityLoader.shared.hideProgressView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.currentClothe = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "detailClothe") {
            let navigationController = segue.destination as! UINavigationController
            if let detailController = navigationController.viewControllers[0] as? DetailClotheViewController {
                detailController.currentClothe =  self.currentClothe
            }
        } else if (segue.identifier == "dressingList") {
            if let detailController = segue.destination as? DetailTypeViewController {
                detailController.typeClothe =  self.currentClothe != nil ? [self.currentClothe!.clothe_type] : typeOfClothesInOutfit()
                detailController.clotheToChange = self.currentClothe
                detailController.isNeedAnimatedFirstElem = true
                detailController.viewMode = ViewMode.selectClothe
                detailController.delegate = self
                self.currentClothe = nil
            }
        }
    }
    
    // MARK: - Check Outfit Validation
    func checkOutfitValidation(){
        
        let types = typeOfClothesInOutfit()
        
        if types.contains(ClotheType.pants.rawValue)
            || (self.currentOutfits!.count == 1 && SharedData.sharedInstance.sexe! == "M") {
            self.dressupButton.isEnabled = false
            self.dressupButton.backgroundColor = UIColor.dressTimeRedDisabled()
        } else {
            self.dressupButton.isEnabled = true
            self.dressupButton.backgroundColor = UIColor.dressTimeRed()
        }
    }
    
    func typeOfClothesInOutfit() -> [String] {
        //Dress + Bottom -> Maille ou Top
        //Dress -> Maille ou Top
        //Top + Bottom -> Maille
        //Top + Dress -> Maille
        //Maille + Dress -> Top
        //Maille + Bottom -> Top
    
        var isTop = false, isMaille = false, isBottom = false, isDress = false
        
        for index in 0..<self.currentOutfits!.count {
            isTop = isTop || self.currentOutfits![index].clothe_type == ClotheType.top.rawValue
            isMaille = isMaille || self.currentOutfits![index].clothe_type == ClotheType.maille.rawValue
            isBottom = isBottom || self.currentOutfits![index].clothe_type == ClotheType.pants.rawValue
            isDress = isDress || self.currentOutfits![index].clothe_type == ClotheType.dress.rawValue
        }
    
        var typeToOpen = [String]()
        if (!isMaille) {
            typeToOpen.append(ClotheType.maille.rawValue)
        }
        if (!isTop){
            typeToOpen.append(ClotheType.top.rawValue)
        }
        if (!isBottom) {
            typeToOpen.append(ClotheType.pants.rawValue)
        }
        if (!isDress && SharedData.sharedInstance.sexe! == "F") {
            typeToOpen.append(ClotheType.dress.rawValue)
        }
        return typeToOpen
    }
    
    // MARK: - Change Bar Button Image
    private func addDoneBarButton(){
        //TODO: Translate button
        let doneBarButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(onEditTapped(_:)))
        self.navigationItem.setRightBarButtonItems([doneBarButton], animated: true)
    }
    
    private func addEditBarButton(){
        //TODO: Translate button
        let doneBarButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(onEditTapped(_:)))
        self.navigationItem.setRightBarButtonItems([doneBarButton], animated: true)
    }
}


extension OutfitViewController: ClotheTableViewCellDelegate {
    // MARK: - ClotheTableView Deletage
    
    func removeItem(_ item: Clothe) -> Void {
        //Remove clohes
        var index = 0
        for i in 0..<self.currentOutfits!.count {
            if currentOutfits![i].clothe_id == item.clothe_id {  // note: === not ==
                index = i
                break
            }
        }
        // could removeAtIndex in the loop but keep it here for when indexOfObject works
        currentOutfits!.remove(at: index)
        
        // use the UITableView to animate the removal of this row
        tableView.beginUpdates()
        let indexPathForRow = IndexPath(row: index, section: 0)
        tableView.deleteRows(at: [indexPathForRow], with: .fade)
        tableView.endUpdates()
        tableView.reloadData()
        if (self.currentOutfits!.count == 0) {
            onEditTapped.title = "Edit"
            isEditingMode = false
        }
        
        //Verify if the outfit reach the minimum clothe combination
        self.checkOutfitValidation()
    }
    
    func changeItem(_ item: Clothe) -> Void {
        //Open dressing details
        self.currentClothe = item
        var index = 0
        for i in 0..<self.currentOutfits!.count {
            if currentOutfits![i].clothe_id == item.clothe_id {  // note: === not ==
                index = i
                break
            }
        }
        self.indexPathToAnimate = index
        self.performSegue(withIdentifier: "dressingList", sender: self)
    }
    
    func detailItem(_ item: Clothe) {
        self.currentClothe = item
        self.performSegue(withIdentifier: "detailClothe", sender: self)
    }
    
    func selectItem(_ item: Clothe) -> Void {
    
    }
}

extension OutfitViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Calendar
        guard let outfits = self.currentOutfits else {
            return 100.0
        }
        
        if (SharedData.sharedInstance.sexe == "M" && outfits.count != 3)
         || (SharedData.sharedInstance.sexe == "F" && outfits.count != 4) {
            return 100.0
        }
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let view = UIView.loadFromNibNamed("HeaderOutfitView") as? HeaderOutfitView {
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.delegate = self
            view.setNeedsLayout()
            view.layoutIfNeeded()
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if let outfits = self.currentOutfits {
           return outfits.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ClotheTableViewCell.cellIdentifier, for: indexPath) as! ClotheTableViewCell
        if let clothe = dal.fetch(self.currentOutfits![indexPath.row].clothe_id) {
            DispatchQueue.main.async {
                cell.clotheImageView.image = clothe.getImage().imageWithImage(480.0)
            }
            cell.initFavoriteButton(clothe.clothe_favorite)
            cell.clothe = clothe
            cell.clotheImageView.clipsToBounds = true
            cell.delegate = self
            cell.viewMode = ViewMode.outfitView
            cell.delayTime = 0.3 * Double(indexPath.row)
            cell.isEditingMode = self.isEditingMode

            //Remove edge insets to have full width separtor line
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            
            if (indexPathToAnimate == indexPath.row) {
                let centerPoint = CGPoint(x: (cell.mouvingCard.frame.width + (cell.mouvingCard.frame.width * 3/4)), y: cell.mouvingCard.center.y)
                cell.mouvingCard.center = centerPoint
                UIView.animate(withDuration: 0.3, animations: {
                    cell.mouvingCard.center = cell.contentView.center
                    }, completion: {
                        (value: Bool) in
                        self.indexPathToAnimate = nil
                })
            }
        }
        return cell
    }
}

extension OutfitViewController: HeaderOutfitViewDelegate {
    func headerOutfitView(_ didSelectedAdd : Bool) {        
        self.performSegue(withIdentifier: "dressingList", sender: self)
    }
}

extension OutfitViewController: DetailTypeViewControllerDelegate {
    func detailTypeViewController(_ selectedItem : Clothe) {
        print("Add Item")
        var isAdded = false
        for index in 0..<self.currentOutfits!.count {
            if (self.currentOutfits![index].clothe_type == selectedItem.clothe_type){
                self.currentOutfits![index] = ClotheModel(clothe: selectedItem)
                isAdded = true
                break
            }
        }
        if (!isAdded){
            self.currentOutfits!.append(ClotheModel(clothe: selectedItem))
        }
        self.outfitObject = Outfit(clothes: self.currentOutfits!, updatedDate: self.creationDate, isSuggestion: false, isPutOn: false)
        self.outfitObject!.orderOutfit()
        self.currentOutfits = self.outfitObject!.clothes
        for i in 0..<self.outfitObject!.clothes.count {
            if (self.outfitObject!.clothes[i].clothe_id == selectedItem.clothe_id){
                indexPathToAnimate = i
            }
        }
        
        //Verify if the outfit reach the minimum clothe combination
        self.checkOutfitValidation()
        
        self.tableView.reloadData()
    }
}

class SegueFromLeft: UIStoryboardSegue {
    
    override func perform() {
        let src: UIViewController = self.source
        let dst: UIViewController = self.destination
        let transition: CATransition = CATransition()
        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.3
        transition.timingFunction = timeFunc
        transition.type = kCATransitionFromBottom
        //transition.subtype = kCATransitionFromRight
        src.navigationController!.view.layer.add(transition, forKey: kCATransition)
        src.navigationController!.pushViewController(dst, animated: false)
    }
    
}
