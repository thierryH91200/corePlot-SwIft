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
    private(set) var valueClass: AnyClass?
    
    // MARK: - Factory Methods
    
    class func periodWithStartValue(
        startValue: CGFloat?,
        endValue  : CGFloat?,
        ofCclass  : AnyClass,
        duration  : CGFloat,
        delay     : CGFloat) -> CPTAnimationPeriod {
        
        return self.init(startValue: startValue!,
                         endValue: endValue!,
                         ofClass: ofCclass,
                         duration: duration,
                         delay: delay)
    }
    
    
    override init() {
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
            ofClass: CPTPlotRange,
            duration: aDuration,
            withDelay: aDelay)
    }
}
