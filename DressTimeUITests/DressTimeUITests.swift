//
//  DressTimeUITests.swift
//  DressTimeUITests
//
//  Created by Fab on 03/03/2016.
//  Copyright © 2016 Fab. All rights reserved.
//

import XCTest

class DressTimeUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func validateTabBar() {
        // Use recording to get started writing UI tests.
        let app = XCUIApplication()
        let tabBarsQuery = app.tabBars
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssert(tabBarsQuery.buttons["Wardrobe"].exists)
        XCTAssert(tabBarsQuery.buttons["Daily"].exists)
    }
    
    func validateWardrobeScreen(){
        let app = XCUIApplication()
        let tabBarsQuery = app.tabBars
        let wardrobeButton = tabBarsQuery.buttons["Wardrobe"]
        wardrobeButton.tap()
        
        XCTAssert(tabBarsQuery.buttons["Wardrobe"].exists)
    }
    
}
