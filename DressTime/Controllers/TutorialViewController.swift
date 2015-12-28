//
//  TutorialViewController.swift
//  DressTime
//
//  Created by Fab on 24/11/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class TutorialViewController : DTViewController {
    var pageController: UIPageViewController?
    private var currentPage = 0
    private var nexIndex = 0
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var letstartButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    @IBAction func closeTutorial(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.classNameAnalytics = "Tutorial"
        
        pageController = UIPageViewController(
            transitionStyle: .Scroll,
            navigationOrientation: .Horizontal,
            options: nil)
        
        pageController!.delegate = self
        pageController!.dataSource = self
        self.pageController!.view.frame = CGRectMake(0, 0,  self.view.bounds.size.width,  self.view.bounds.size.height + 37)
        
        let initialViewController = self.viewControllerAtIndex(0)
        let viewControllers = [initialViewController]
        self.pageController!.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        self.addChildViewController(self.pageController!)
        self.view.addSubview(self.pageController!.view)
        self.pageController!.didMoveToParentViewController(self)
        
        self.pageControl.currentPage = currentPage
        self.pageControl.numberOfPages = 4
        
        self.letstartButton.hidden = true
        self.letstartButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.letstartButton.layer.borderWidth = 1.0
        self.letstartButton.layer.cornerRadius = 5.0
        
        self.view.bringSubviewToFront(self.pageControl)
        self.view.bringSubviewToFront(self.letstartButton)
        self.view.bringSubviewToFront(self.skipButton)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    private func viewControllerAtIndex(index: Int) -> TutorialPageViewController {
        let childViewController =  NSBundle.mainBundle().loadNibNamed("TutorialPageViewController", owner: self, options: nil)[0] as! TutorialPageViewController
        childViewController.index = index
        return childViewController
    }
}

extension TutorialViewController : UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! TutorialPageViewController).index
        if (index == 0) {
            return nil
        }
        index--
        return self.viewControllerAtIndex(index)
    
    }
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! TutorialPageViewController).index
        index++
        
        if (index == 4) {
            return nil
        }
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if (completed) {
            self.pageControl.currentPage = (pageViewController.viewControllers?.last as! TutorialPageViewController).index
            
             self.letstartButton.hidden = (self.pageControl.currentPage != 3)
        }
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 4
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}