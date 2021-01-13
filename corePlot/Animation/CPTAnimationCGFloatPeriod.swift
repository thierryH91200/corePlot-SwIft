//
//  CPTAnimationCGFloatPeriod.swift
//  corePlot
//
//  Created by thierryH24 on 14/11/2020.
//

import CocAppKitoa

class CPTAnimationCGFloatPeriod: CPTAnimationPeriod {
    
    func CPTCurrentFloatValue( boundObject: Any, boundGetter: Selector) -> CGFloat {
        let invocation = NSInvocation(methodSignature: boundObject.methodSignature(for: boundGetter))
        
        invocation.target = boundObject
        invocation.selector = boundGetter
        
        invocation.invoke()
        
        var value: CGFloat
        invocation.getReturnValue(&value)
        
        return value
    }
    
    func setStartValueFromObject(boundObject: Any, propertyGetter: Selector(boundGetter))
    {
        self.startValue = CPTCurrentFloatValue(boundObject, boundGetter)
    }
    
    func canStartWithValueFromObject(boundObject: Any, propertyGetter: Selector(boundGetter)) -> Bool
    {
        var current = CPTCurrentFloatValue(boundObject, boundGetter);
        var start = CGFloat (0)
        var end = CGFloat (0)
        
        if ( !self.startValue ) {
            self.setStartValueFromObject(boundObject, propertyGetter:boundGetter)
        }
        
        return ((current >= start) && (current <= end)) || ((current >= end) && (current <= start));
    }
    
    func tweenedValueForProgress(progress: CGFloat) -> CGFloat
    {
        let start = startValue
        let end = endValue
                
        let tweenedValue = start + progress * (end - start);
        return tweenedValue
    }
    
}
