//
//  NSDate+DressTime.swift
//  DressTime
//
//  Created by Fab on 8/4/16.
//  Copyright © 2016 Fab. All rights reserved.
//

import Foundation

extension Date {
    func toS(_ format:String) -> String? {
        let formatter:DateFormatter = DateFormatter()
        //formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = format
        return formatter.string(from: self)
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
    case seconds, minutes, hours, days, months, years
    
    func dateComponents(_ interval: Int) -> DateComponents {
        var components:DateComponents = DateComponents()
        
        switch (self) {
        case .seconds:
            components.second = interval
        case .minutes:
            components.minute = interval
        case .days:
            components.day = interval
        case .months:
            components.month = interval
        case .years:
            components.year = interval
        default:
            components.day = interval
        }
        return components
    }
}

func - (left:Date, right:TimeInterval) -> Date {
    let calendar = Calendar.current
    let components = right.unit.dateComponents(-right.interval)
    return (calendar as NSCalendar).date(byAdding: components, to: left, options: [])!
}

func + (left:Date, right:TimeInterval) -> Date {
    let calendar = Calendar.current
    let components = right.unit.dateComponents(+right.interval)
    return (calendar as NSCalendar).date(byAdding: components, to: left, options: [])!
}

func < (left:Date, right: Date) -> Bool {
    let result:ComparisonResult = left.compare(right)
    var isEarlier = false
    if (result == ComparisonResult.orderedAscending) {
        isEarlier = true
    }
    return isEarlier
}

func lowerDate (left:Date, right: Date) -> Bool {
    let result:ComparisonResult = left.compare(right)
    var isEarlier = false
    if (result == ComparisonResult.orderedDescending) {
        isEarlier = true
    }
    return isEarlier
}
