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
        self.webView = WKWebView(frame: CGRectZero)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        self.hideTabBar = true
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        titleNavBar.title = "Zalando"
        view.addSubview(webView)
        
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        let height = NSLayoutConstraint(item: webView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: webView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
        view.addConstraints([height, width])
        
        let url = NSURL(string: urlShop!)
        let req = NSURLRequest(URL:url!)
        self.webView.loadRequest(req)
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}