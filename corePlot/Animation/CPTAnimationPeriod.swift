//
//  CPTAnimationPeriod.swift
//  corePlot
//
//  Created by thierryH24 on 14/11/2020.
//

import AppKit

class CPTAnimationPeriod: NSObject {
    
    var startValue = CGFloat(0)
    var endValue = CGFloat(0)
    var duration = CGFloat(0)
    var delay = CGFloat(0)
    var startOffset = CGFloat(0)
    
    
    init ( startValue:CGFloat , endValue: CGFloat , ofClass:(Class)class duration:CGFloat, aDelay:CGFloat)
    {
        initWithStartValue:aStartValue, endValue:anEndValue ofClass:class duration:aDuration withDelay:aDelay];
    }
    
    
    func periodWithStartNumber( aStartNumber: CGFloat,endNumber: CGFloat, duration: GFloat, aDuration :CGFloat)
    {
    return (CPTAnimationNSNumberPeriod(periodWithStartValue:aStartNumber
    endValue:anEndNumber
    ofClass:[NSNumber class]
    duration:aDuration
    withDelay:aDelay])
    }
    
    
}
