//
//  Int+DressTime.swift
//  DressTime
//
//  Created by Fab on 8/4/16.
//  Copyright © 2016 Fab. All rights reserved.
//

import Foundation

extension Int {
    var months: TimeInterval {
        return TimeInterval(interval: self, unit: TimeIntervalUnit.months);
    }
    
    var day: TimeInterval {
        return TimeInterval(interval: self, unit: TimeIntervalUnit.days);
    }
    
    var days: Foundation.TimeInterval {
        let DAY_IN_SECONDS = 60 * 60 * 24
        let days:Double = Double(DAY_IN_SECONDS) * Double(self)
        return days
    }
}
