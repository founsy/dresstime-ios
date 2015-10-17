//
//  OutfitsViewController.swift
//  DressTime
//
//  Created by Fab on 09/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class OutfitsViewController : UIViewController {

    private var pageViewController: UIPageViewController?
    private var controllers = [OutfitViewController]()
    private var currentSection: Int = 0
    
    var styleOutfits: String?
    var outfit: JSON?
    var currentWeather: Weather?


    //@IBOutlet weak var pageControl: UIPageControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageViewController = UIPageViewController(
            transitionStyle: .PageCurl,
            navigationOrientation: .Horizontal,
            options: nil)
        
        pageViewController?.delegate = self
        pageViewController?.dataSource = self
        
        self.populateControllersArray()
        self.createPageViewController()
    }

    private func populateControllersArray() {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("OutfitViewController") as! OutfitViewController
        controller.currentOutfits = outfit!["outfit"].arrayObject
        controller.itemIndex = Int(1)
        self.view.layoutIfNeeded()
        //controller.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        
        controllers.append(controller)
        
    }

    private func createPageViewController() {
        
        let pageController = self.storyboard!.instantiateViewControllerWithIdentifier("PageController") as! UIPageViewController
        pageController.dataSource = self
        pageController.delegate = self
        
        //self.view.layoutIfNeeded()
        pageController.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        
        if !controllers.isEmpty {
            pageController.setViewControllers([controllers[0]], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        }
        
        pageViewController = pageController
        addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
    }
}

extension OutfitsViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let controller = viewController as? OutfitViewController {
            if controller.itemIndex > 0 {
                return controllers[controller.itemIndex - 1]
            }
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if let controller = viewController as? OutfitViewController {
            if controller.itemIndex < controllers.count - 1 {
                return controllers[controller.itemIndex + 1]
            }
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        //let itemController = pageViewController.viewControllers[0] as! OutfitViewController
        
        //self.pageControl.currentPage = itemController.itemIndex
    }
    
}