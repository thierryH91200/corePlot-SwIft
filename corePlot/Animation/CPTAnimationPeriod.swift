//
//  CPTAnimationPeriod.swift
//  corePlot
//
//  Created by thierryH24 on 14/11/2020.
//

import AppKit

class CPTAnimationPeriod: NSObject {
    
    static let shared = CPTAnimationPeriod()
    
    var startValue = CGFloat(0)
    var endValue = CGFloat(0)
    var duration = CGFloat(0)
    var delay = CGFloat(0)
    var startOffset = CGFloat(0)
    
    override init() {
        
    }

    
    init ( startValue:CGFloat , endValue: CGFloat , ofClass:(Class)class duration:CGFloat, aDelay:CGFloat)
    {
        initWithStartValue(aStartValue, endValue anEndValue, ofClass:class, duration: aDuration , withDelay:aDelay)
    }
    
    
    func periodWithStartNumber( aStartNumber: CGFloat,endNumber: CGFloat, duration: CGFloat, aDuration :CGFloat) -> Self
    {
        return CPTAnimationNSNumberPeriod(startValue:aStartNumber,
                                           endValue:endNumber,
                                           ofClass: CGFloat.self,
                                           duration:aDuration,
                                           withDelay:aDelay)
    }
    
    class func period(withStart aStartPlotRange: CPTPlotRange, end anEndPlotRange: CPTPlotRange, duration aDuration: CGFloat, withDelay aDelay: CGFloat) -> Self {
        
        var startRange = aStartPlotRange
        if aStartPlotRange.locationDouble.isNaN || aStartPlotRange.lengthDouble.isNaN {
            startRange = nil
        }

        return CPTAnimationPlotRangePeriod.period(
            withStart: startRange ,
            end: anEndPlotRange ,
            ofClass: CPTPlotRange.self,
            duration: aDuration,
            withDelay: aDelay)
    }
}
