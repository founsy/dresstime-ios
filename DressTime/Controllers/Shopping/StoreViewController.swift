//
//  StoreViewController.swift
//  DressTime
//
//  Created by Fab on 28/02/2016.
//  Copyright © 2016 Fab. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class StoreViewController: DTViewController {

    var urlShop: String?
    
    var webView: WKWebView
    
    @IBOutlet weak var titleNavBar: UINavigationItem!
    required init?(coder aDecoder: NSCoder) {
        self.webView = WKWebView(frame: CGRect.zero)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        self.hideTabBar = true
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        titleNavBar.title = "Zalando"
        view.addSubview(webView)
        
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        let height = NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0)
        view.addConstraints([height, width])
        
        let url = URL(string: urlShop!)
        let req = URLRequest(url:url!)
        self.webView.load(req)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
