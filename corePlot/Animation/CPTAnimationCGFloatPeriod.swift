//
//  CPTAnimationCGFloatPeriod.swift
//  corePlot
//
//  Created by thierryH24 on 14/11/2020.
//

import Cocoa

class CPTAnimationCGFloatPeriod: CPTAnimationPeriod {



    func CPTCurrentFloatValue(id __nonnull boundObject, SEL __nonnull boundGetter)-> CGFloat
    {
        let invocation = [NSInvocation invocationWithMethodSignature:[boundObject methodSignatureForSelector:boundGetter]];

        invocation.target   = boundObject;
        invocation.selector = boundGetter;

        [invocation invoke];

        CGFloat value;

        [invocation getReturnValue:&value];

        return value;
    }

    func setStartValueFromObject:(nonnull id)boundObject propertyGetter:(nonnull SEL)boundGetter
    {
        self.startValue = @(CPTCurrentFloatValue(boundObject, boundGetter));
    }

    func canStartWithValueFromObject(boundObject: Any, propertyGetter: Selector(boundGetter)) -> Bool
    {
        vat current = CPTCurrentFloatValue(boundObject, boundGetter);
        var start = CGFloat (0)
        var end; = CGFloat (0)

        if ( !self.startValue ) {
            [self setStartValueFromObject:boundObject propertyGetter:boundGetter];
        }

        [self.startValue getValue:&start];
        [self.endValue getValue:&end];

        return ((current >= start) && (current <= end)) || ((current >= end) && (current <= start));
    }

    func tweenedValueForProgress(progress: CGFloat) -> CGFloat
    {
        let start = startValue
        var end = endValue

//        self.startValue getValue:&start];
//        [self.endValue getValue:&end];

        let tweenedValue = start + progress * (end - start);

        return tweenedValue
    }}
