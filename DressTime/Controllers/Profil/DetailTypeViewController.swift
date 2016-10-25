//
//  DetailTypeViewController.swift
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

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol DetailTypeViewControllerDelegate {
    func detailTypeViewController(_ selectedItem : Clothe)
}

class DetailTypeViewController: DTViewController {
    fileprivate var clothesList: [Clothe]?
    fileprivate var currentSection = -1
    fileprivate let height:CGFloat = 220.0
    fileprivate var indexPathToAnimate: IndexPath?
    fileprivate var isAlreadyOpened = false
    
    var isNeedAnimatedFirstElem = false
    var typeClothe: [String]?
    var clotheToChange: Clothe?
    var viewMode: ViewMode?
    var delegate : DetailTypeViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleNav: UINavigationItem!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyViewLabel: UILabel!
    @IBOutlet weak var emptyViewButton: UIButton!
    @IBOutlet weak var emptyViewImage: UIImageView!
    @IBOutlet weak var buttonCapture: UIButton!
    
    @IBAction func onCaptureTapped(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "showCapture", sender: self)
    }
    
    override func viewDidLoad() {
        self.hideTabBar = true
        
        super.viewDidLoad()
        self.classNameAnalytics = "DetailType"
        tableView.register(UINib(nibName: "ClotheTableCell", bundle:nil), forCellReuseIdentifier: ClotheTableViewCell.cellIdentifier)
        
        tableView!.delegate = self
        tableView!.dataSource = self
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        //TODO Manage Localization
        var title = ""
        for type in self.typeClothe! {
            title = "\(title) \(NSLocalizedString(type, comment:"").uppercased())"
        }
        titleNav.title = "\(NSLocalizedString("detailTypeMyMsg", comment: "")) \(title)!"
        emptyViewLabel.text = NSLocalizedString("detailTypeEmptyMsg", comment: "")
        
        
        emptyViewButton.layer.cornerRadius = 10.0
        emptyViewButton.layer.borderColor = UIColor.white.cgColor
        emptyViewButton.layer.borderWidth = 1.0
        emptyViewImage.image = UIImage(named: "underwearIcon\(SharedData.sharedInstance.sexe!.uppercased())")
        
        self.buttonCapture.layer.cornerRadius = 20.0
        self.buttonCapture.layer.shadowOffset = CGSize(width: 0, height: 1);
        self.buttonCapture.layer.shadowColor = UIColor.black.cgColor
        self.buttonCapture.layer.shadowRadius = 5;
        self.buttonCapture.layer.shadowOpacity = 0.5;
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.alpha = 1.0
        
        initData()
        tableView.reloadData()
        if (clothesList?.count > 0){
            self.emptyView.isHidden = true
            self.backgroundImageView.isHidden = false
            self.tableView.isHidden = false
            self.buttonCapture.isHidden = false
        } else {
            self.emptyView.isHidden = false
            self.backgroundImageView.isHidden = true
            self.tableView.isHidden = true
            self.buttonCapture.isHidden = true

        }

        if (viewMode == ViewMode.selectClothe){
            self.buttonCapture.isHidden = true
            titleNav.title = "Select your \(self.typeClothe![0])..."
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "Outfit", style: .plain, target: nil, action: nil) //TODO Translate
            
                if let weather = SharedData.sharedInstance.currentWeater {
                    self.backgroundImageView.image = UIImage(named: WeatherHelper.changeBackgroundDependingWeatherCondition(weather.code == nil ? 800 : weather.code!))
                }
            
        } else {
            self.buttonCapture.isHidden = false
            //Remove Title of Back button
            navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("detailTypeBackBtn", comment: ""), style: .plain, target: nil, action: nil)
            
            setBackgroundImage()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.clothesList = nil
        self.clotheToChange = nil
    }
    
    fileprivate func setBackgroundImage(){
        if let types = self.typeClothe , types.count == 1 {
            switch types[0] {
            case ClotheType.maille.rawValue:
                self.backgroundImageView.image = UIImage(named: "BackgroundMaille\(SharedData.sharedInstance.sexe!.uppercased())")
                break
            case ClotheType.top.rawValue:
                self.backgroundImageView.image = UIImage(named: "BackgroundTop\(SharedData.sharedInstance.sexe!.uppercased())")
                break
            case ClotheType.pants.rawValue:
                self.backgroundImageView.image = UIImage(named: "BackgroundPants\(SharedData.sharedInstance.sexe!.uppercased())")
                break
            case ClotheType.dress.rawValue:
                self.backgroundImageView.image = UIImage(named: "BackgroundDressF")
                break
            default:
                break
            }
        }
    }
    
    func initData(){
        let dal = ClothesDAL()
        if let types = self.typeClothe {
            self.clothesList = dal.fetch(types: types)
            self.clothesList!.sort(by: { (elem1, elem2) -> Bool in
                return DressTimeBL.getClotheOrder(withType: elem1.clothe_type) < DressTimeBL.getClotheOrder(withType: elem2.clothe_type)
            })
            if let clothe = clotheToChange {
                self.clothesList?.sort { (element1, element2) -> Bool in
                    return element1.clothe_id == clothe.clothe_id
                }
            }
        }
    }
    
    fileprivate func openEditClotheView(){
        DispatchQueue.main.async(execute: { () -> Void in
            self.performSegue(withIdentifier: "detailClothe", sender: self)
        })
    }
    
    fileprivate func deleteClothe(_ indexPath: IndexPath){
        guard let currentClothe = self.clothesList?[indexPath.row] else {
            return
        }
        
        let dressTimeClient = DressTimeClient()
        dressTimeClient.deleteClotheWithCompletion(for: currentClothe.clothe_id) { (result) in
            switch result {
            case .success(_):
                print("Clothe deleted")
                _ = ClothesDAL().delete(currentClothe)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ClotheDeletedNotification"), object: self, userInfo: ["type": currentClothe.clothe_type])
            case .failure(let error):
                print("\(#function) Error : \(error)")
            }
        }
        
        self.clothesList!.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        if (clothesList?.count > 0){
            self.emptyView.isHidden = true
            self.tableView.isHidden = false
        } else {
            self.emptyView.isHidden = false
            self.tableView.isHidden = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "detailClothe") {
            let navigationController = segue.destination as! UINavigationController
            if let detailController = navigationController.viewControllers[0] as? DetailClotheViewController {
                detailController.currentClothe =  self.clotheToChange
                detailController.delegate = self
            }
        } else if (segue.identifier == "showCapture"){
            let navController = segue.destination as! UINavigationController
            let targetVC = navController.topViewController as! TypeViewController
            targetVC.openItem(getTypeClothe(typeClothe![0]))
        }
    }
    
    fileprivate func getTypeClothe(_ typeClothe: String) -> Int {
        switch(typeClothe.lowercased()){
            case "maille":
                return 0
            case "top":
                return 1
            case "pants":
                return 2
            case "dress":
                return 3
            default:
                return -1
        }
    }
}

extension DetailTypeViewController: ClotheTableViewCellDelegate {
    func selectItem(_ item: Clothe) -> Void {
        self.delegate?.detailTypeViewController(item)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func changeItem(_ item: Clothe) -> Void {
        if let mode = self.viewMode , mode == ViewMode.dressing {
            //Go to Edit
            self.clotheToChange = item
            self.openEditClotheView()
        }
    }
    
    func detailItem(_ item: Clothe) {
        self.clotheToChange = item
        self.openEditClotheView()
    }
    
    func removeItem(_ item: Clothe) -> Void {
        if let mode = self.viewMode , mode == ViewMode.dressing {
            //Go to delete
            if let clothes = self.clothesList {
                for index in 0..<clothes.count {
                    if (clothes[index].clothe_id == item.clothe_id){
                        self.deleteClothe(IndexPath(row: index, section: 0))
                        break
                    }
                }
            }
        }
    }
}

extension DetailTypeViewController: DetailClotheViewControllerDelegate {
    func detailClotheView(_ detailClotheview : DetailClotheViewController, itemDeleted item: String) {
        self.deleteClothe(IndexPath(row: self.currentSection, section: 0))
    }
    
    func detailClotheView(_ detailClotheView : DetailClotheViewController, noAction result: Clothe) {
        if let clothes = self.clothesList {
            for i in 0..<clothes.count {
                if (clothes[i].clothe_id == result.clothe_id){
                    self.indexPathToAnimate = IndexPath(row: i, section: 0)
                    break
                }
                self.indexPathToAnimate = nil
            }
            tableView.reloadData()
        }
        
    }
}

extension DetailTypeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.height
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if let list = self.clothesList {
            return list.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ClotheTableViewCell.cellIdentifier, for: indexPath) as! ClotheTableViewCell
    
        let clothe = self.clothesList![(indexPath as NSIndexPath).row]
        
        DispatchQueue.main.async {
            let img = clothe.getImage()//.resize(CGSize(width: 480.0, height: 250))
            cell.clotheImageView.image = img//clothe.getImage().imageWithImage(480.0)
        }
        cell.clotheImageView.contentMode = .scaleAspectFill
        cell.initFavoriteButton(clothe.clothe_favorite)
        cell.clothe = clothe
        cell.clotheImageView.clipsToBounds = true
        cell.viewMode = self.viewMode
        cell.delegate = self
        
        //Remove edge insets to have full width separtor line
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell;
    }
}

