//
//  RegisterSexeViewController.swift
//  DressTime
//
//  Created by Fab on 22/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class RegisterSexeViewController: DTViewController {
    var email: String?
    var password: String?
    fileprivate var sexe: String?
    
    var user: User?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func onCancelTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.classNameAnalytics = "RegisterSexe"
        self.navigationController?.isNavigationBarHidden = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "selectStyle"){
            if let viewController = segue.destination as? SelectStyleViewController {
                viewController.user = self.user
            }
        }
    }
}

extension RegisterSexeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        NSLog("\((indexPath as NSIndexPath).row)")
        if ((indexPath as NSIndexPath).row == 0){
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "sexeCell") as! RegisterSexeTableViewCell
            cell.titleLabel.text = NSLocalizedString("registerSexeWomen", comment: "").uppercased()
            cell.imageViewBackground.image = UIImage(named: "RegisterBgWomen")
            return cell
        } else if ((indexPath as NSIndexPath).row == 1){
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "sexeCell") as! RegisterSexeTableViewCell
            cell.titleLabel.text = NSLocalizedString("registerSexeMen", comment: "").uppercased()
            cell.imageViewBackground.image = UIImage(named: "RegisterBgMen")
            return cell
        }
        return UITableViewCell()
    }
}

extension RegisterSexeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.frame.height/2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if ((indexPath as NSIndexPath).row == 0){
            self.user?.gender = "F"
            sexe = "F"
        } else if ((indexPath as NSIndexPath).row == 1){
            sexe = "M"
            self.user?.gender = "M"
        }
        self.performSegue(withIdentifier: "selectStyle", sender: self)
    }
    
}
