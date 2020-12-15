//
//  CPTAnimationOperation.swift
//  corePlot
//
//  Created by thierryH24 on 14/11/2020.
//

import Cocoa

class CPTAnimationOperation: NSObject {
    
    // MARK:  Animation Timing
    var period: CPTAnimationPeriod
    var animationCurve: CPTAnimationCurve?
    var boundObject: Any
    var boundGetter : Selector
    var boundSetter: Selector
    var delegate : CPTAnimationDelegate?
    var isCanceled = false
    
    
    // MARK:  Identification
    var identifier: NSObject?
    var userInfo: Dictionary<String, Any>?
    
    init(animationPeriod: CPTAnimationPeriod, animationCurve curve: CPTAnimationCurve, object: Any, getter: Selector, setter: Selector) {
        super.init()
        period = animationPeriod
        animationCurve = curve
        boundObject = object
        boundGetter = getter
        boundSetter = setter
        delegate = nil
        isCanceled = false
        identifier = nil
        userInfo = nil
    }
    
    override convenience init() {
        assert(false, "Must call -initWithAnimationPeriod:animationCurve:object:getter:setter: to initialize a CPTAnimationOperation.")
        
        self.init(
            animationPeriod: CPTAnimationPeriod(),
            animationCurve: CPTAnimationCurve.default,
            object: NSObject(),
            getter: #selector(init(_:)),
            setter: #selector(init(_:)) )
    }
    
    init(animationPeriod: CPTAnimationPeriod, animationCurve curve: CPTAnimationCurve, object: Any, getter: Selector, setter: Selector) {
        super.init()
            period = animationPeriod
            animationCurve = curve
            boundObject = object
            boundGetter = getter
            boundSetter = setter
            delegate = nil
            isCanceled = false
            identifier = nil
            userInfo = nil
    }}
