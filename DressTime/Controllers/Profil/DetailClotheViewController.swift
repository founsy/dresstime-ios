//
//  DetailClotheViewController.swift
//  DressTime
//
//  Created by Fab on 27/09/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

protocol DetailClotheViewControllerDelegate {
    func detailClotheView(_ detailClotheview : DetailClotheViewController, itemDeleted item: String)
    func detailClotheView(_ detailClotheView : DetailClotheViewController, noAction item: Clothe)
}

class DetailClotheViewController: DTViewController {
    
    var currentClothe: Clothe!
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var color1View: UIView!
    @IBOutlet weak var color2View: UIView!
    @IBOutlet weak var color3View: UIView!
    @IBOutlet weak var clotheName: UILabel!
    
    @IBOutlet weak var createOutfitButton: UIButton!
    @IBOutlet weak var onTap: UIButton!
    
    var delegate: DetailClotheViewControllerDelegate?
    
    @IBAction func onTapped(_ sender: AnyObject) {
        self.delegate?.detailClotheView(self, noAction: self.currentClothe!)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onRemoveTapped(_ sender: AnyObject) {
        if let del = self.delegate {
            del.detailClotheView(self, itemDeleted: self.currentClothe.clothe_id)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCreateOutfitTapped(_ sender: AnyObject) {
    }
    
    @IBAction func onFavoriteTapped(_ sender: AnyObject) {
        if (favoriteButton.isSelected){
            favoriteButton.isSelected = false
            favoriteButton.setImage(UIImage(named: "loveIconOFF"), for: UIControlState())
        } else {
            favoriteButton.isSelected = true
            favoriteButton.setImage(UIImage(named: "loveIconON"), for: UIControlState.selected)
        }
        if let clo = self.currentClothe {
            let dal = ClothesDAL()
            clo.clothe_favorite = favoriteButton.isSelected
            
            dal.update(clo)
        }

    }
    
    @IBAction func onEditTapped(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "showEditView", sender: self)
    }
    
    
    @IBAction func onClickDelete(_ sender: AnyObject) {
        DressingService().DeleteClothe(currentClothe.clothe_id) { (isSuccess, object) -> Void in
            print("Clothe deleted")
            let dal = ClothesDAL()
            _ = dal.delete(self.currentClothe)
            DispatchQueue.main.sync(execute: {
                //self.delegate?.onDeleteCloth!()
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.classNameAnalytics = "DetailClothe"
        
        self.navigationController?.navigationBar.alpha = 1.0
        self.navigationController?.isNavigationBarHidden = true
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        imageView.image = currentClothe.getImage()
        imageView.clipsToBounds = true
        self.viewContainer.layer.cornerRadius = 10.0
        self.viewContainer.layer.masksToBounds = true
        
        self.color1View.layer.cornerRadius = 5.0
        self.color1View.layer.borderWidth = 1.0
        self.color1View.layer.borderColor = UIColor.white.cgColor
        self.color2View.layer.cornerRadius = 5.0
        self.color2View.layer.borderWidth = 1.0
        self.color2View.layer.borderColor = UIColor.white.cgColor
        self.color3View.layer.cornerRadius = 5.0
        self.color3View.layer.borderWidth = 1.0
        self.color3View.layer.borderColor = UIColor.white.cgColor
        
        self.clotheName.text = self.currentClothe.clothe_name
        self.updateColors(currentClothe.clothe_colors)
        
        self.createOutfitButton.layer.cornerRadius = 5.0
        
        
        //Remove Title of Back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showEditView"){
            let controller = segue.destination as! CaptureConfirmationViewController
            controller.currentClothe = self.currentClothe
            controller.previousController = self
        }
    }

    
    func updateColors(_ colors: String){
        let colors = self.splitHexColor(colors)
        color1View.backgroundColor = UIColor.colorWithHexString(colors[0] as String)
        if (colors.count > 1){
            color2View.backgroundColor = UIColor.colorWithHexString(colors[1] as String)
        }
        if (colors.count > 2){
            color3View.backgroundColor = UIColor.colorWithHexString(colors[2] as String)
        }
    }
    
    fileprivate func splitHexColor(_ colors: String) -> [String]{
        let arrayColors = colors.components(separatedBy: ",")
        return arrayColors
    }
    
    
}
