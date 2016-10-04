//
//  NSDate+DressTime.swift
//  DressTime
//
//  Created by Fab on 8/4/16.
//  Copyright © 2016 Fab. All rights reserved.
//

import Foundation

extension NSDate {
    func toS(let format:String) -> String? {
        let formatter:NSDateFormatter = NSDateFormatter()
        //formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.timeZone = NSTimeZone()
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }
}

struct TimeInterval {
    var interval: Int
    var unit: TimeIntervalUnit
    
    init(interval: Int, unit: TimeIntervalUnit) {
        self.interval = interval
        self.unit = unit
    }
}

enum TimeIntervalUnit {
    case Seconds, Minutes, Hours, Days, Months, Years
    
    func dateComponents(interval: Int) -> NSDateComponents {
        let components:NSDateComponents = NSDateComponents()
        
        switch (self) {
        case .Seconds:
            components.second = interval
        case .Minutes:
            components.minute = interval
        case .Days:
            components.day = interval
        case .Months:
            components.month = interval
        case .Years:
            components.year = interval
        default:
            components.day = interval
        }
        return components
    }
}

func - (let left:NSDate, let right:TimeInterval) -> NSDate {
    let calendar = NSCalendar.currentCalendar()
    let components = right.unit.dateComponents(-right.interval)
    return calendar.dateByAddingComponents(components, toDate: left, options: [])!
}

func + (let left:NSDate, let right:TimeInterval) -> NSDate {
    let calendar = NSCalendar.currentCalendar()
    let components = right.unit.dateComponents(+right.interval)
    return calendar.dateByAddingComponents(components, toDate: left, options: [])!
}

func < (let left:NSDate, let right: NSDate) -> Bool {
    let result:NSComparisonResult = left.compare(right)
    var isEarlier = false
    if (result == NSComparisonResult.OrderedAscending) {
        isEarlier = true
    }
    return isEarlier
}

func > (let left:NSDate, let right: NSDate) -> Bool {
    let result:NSComparisonResult = left.compare(right)
    var isEarlier = false
    if (result == NSComparisonResult.OrderedDescending) {
        isEarlier = true
    }
    return isEarlier
}