//
//  CPTAnimation.swift
//  corePlot
//
//  Created by thierryH24 on 14/11/2020.
//

import AppKit

enum CPTAnimationCurve : Int {
    case `default`         ///< Use the default animation curve.
    case linear           ///< Linear animation curve.
    case BackIn          ///< Backing in animation curve.
    case BackOut          ///< Backing out animation curve.
    case BackInOut        ///< Backing in and out animation curve.
    case BounceIn         ///< Bounce in animation curve.
    case BounceOut        ///< Bounce out animation curve.
    case BounceInOut      ///< Bounce in and out animation curve.
    case CircularIn       ///< Circular in animation curve.
    case CircularOut      ///< Circular out animation curve.
    case CircularInOut    ///< Circular in and out animation curve.
    case ElasticIn        ///< Elastic in animation curve.
    case ElasticOut       ///< Elastic out animation curve.
    case ElasticInOut     ///< Elastic in and out animation curve.
    case ExponentialIn    ///< Exponential in animation curve.
    case ExponentialOut   ///< Exponential out animation curve.
    case ExponentialInOut ///< Exponential in and out animation curve.
    case SinusoidalIn     ///< Sinusoidal in animation curve.
    case SinusoidalOut    ///< Sinusoidal out animation curve.
    case SinusoidalInOut  ///< Sinusoidal in and out animation curve.
    case CubicIn          ///< Cubic in animation curve.
    case CubicOut         ///< Cubic out animation curve.
    case CubicInOut       ///< Cubic in and out animation curve.
    case QuadraticIn      ///< Quadratic in animation curve.
    case QuadraticOut     ///< Quadratic out animation curve.
    case QuadraticInOut   ///< Quadratic in and out animation curve.
    case QuarticIn        ///< Quartic in animation curve.
    case QuarticOut       ///< Quartic out animation curve.
    case QuarticInOut     ///< Quartic in and out animation curve.
    case QuinticIn        ///< Quintic in animation curve.
    case QuinticOut       ///< Quintic out animation curve.
    case QuinticInOut      ///< Quintic in and out animation curve.
};


protocol CPTAnimationDelegate {
    
    func animationDidStart(operation: CPTAnimationOperation )
    func animationDidFinish(operation: CPTAnimationOperation )
    func animationCancelled(operation: CPTAnimationOperation )
    func animationWillUpdate(operation: CPTAnimationOperation )
    func animationDidUpdate(operation: CPTAnimationOperation )
}

class CPTAnimation: NSObject {
    
    //    typedef CGFloat (*CPTAnimationTimingFunction)(CGFloat, CGFloat);
    typealias CPTAnimationTimingFunction = (CGFloat, CGFloat)-> (CGFloat)
    
    let shared = CPTAnimation()
    let CPTAnimationOperationKey  = "CPTAnimationOperationKey"
    let CPTAnimationValueKey      = "CPTAnimationValueKey"
    let CPTAnimationValueClassKey = "CPTAnimationValueClassKey"
    let CTAnimationStartedKey    = "CPTAnimationStartedKey"
    let CPTAnimationFinishedKey   = "CPTAnimationFinishedKey"
    
    let kCPTAnimationFrameRate = CGFloat(1.0 / 60.0)  // 60 frames per second
    
    var CPTAnimationOperation = NSObject()
    var timer : Timer?
    
    var timeOffset: CGFloat
    var defaultAnimationCurve = CPTAnimationCurve.default
    var animationOperations = [CPTAnimationOperation]
    var runningAnimationOperations = [CPTAnimationOperation]
    
    override init()
    {
        animationOperations        = []
        runningAnimationOperations = []
        timer                      = nil
        timeOffset                 = CGFloat(0.0)
        defaultAnimationCurve      = .linear
        
        animationQueue = dispatch_queue_create("CorePlot.CPTAnimation.animationQueue", NULL);
        
    }
    
    class func animate(_ object: Any, property: String, period: CPTAnimationPeriod, animationCurve: CPTAnimationCurve, delegate: CPTAnimationDelegate?) -> CPTAnimationOperation {
        let animationOperation = CPTAnimationOperation (
            animationPeriod: period,
            animationCurve: animationCurve,
            object: object,
            getter: NSSelectorFromString(property),
            setter: CPTAnimation.setter(fromProperty: property))
        
        animationOperation.delegate = delegate
        CPTAnimation.shared.add(animationOperation)
        
        return animationOperation
    }
    
    // MARK:  Animation Management
    
    /** @brief Adds an animation operation to the animation queue.
     *  @param animationOperation The animation operation to add.
     *  @return The queued animation operation.
     **/
    func add(_ animationOperation: CPTAnimationOperation) -> CPTAnimationOperation? {
        
        let boundObject = animationOperation.boundObject
        let period = animationOperation.period
        
        if animationOperation.delegate || (boundObject != nil && period != nil && !(period?.startValue == period?.endValue)) {
            animationQueue.async(execute: { [self] in
                animationOperations.append(animationOperation)
                
                if !timer {
                    startTimer()
                }
            })
        }
        return animationOperation
    }
    /** @brief Removes an animation operation from the animation queue.
     *  @param animationOperation The animation operation to remove.
     **/
    
    func removeAnimationOperation( animationOperation: CPTAnimationOperation )
    {
        if ( animationOperation ) {
            dispatch_async(self.animationQueue, ^{
                animationOperation.canceled = YES;
            });
        }
    }
    
    /** @brief Removes all animation operations from the animation queue.
     **/
    func removeAllAnimationOperations()
    {
        for  animationOperation in self.animationOperations  {
            animationOperation.canceled = true;
        }
    }
    
    // MARK: - Retrieving Animation Operations
    
    /** @brief Gets the animation operation with the given identifier from the animation operation array.
     *  @param identifier An animation operation identifier.
     *  @return The animation operation with the given identifier or @nil if it was not found.
     **/
    func operationWithIdentifier(identifier: Any?)-> CPTAnimationOperation?
    {
        for  operation in self.animationOperations {
            if operation.identifier.isEqual(identifier ) {
                return operation
            }
        }
        return nil
    }
    
    // MARK: - Animation Update
    
    func update()
    {
        self.timeOffset += kCPTAnimationFrameRate;
        
        let theAnimationOperations = self.animationOperations;
        let runningOperations      = self.runningAnimationOperations;
        let expiredOperations      = [[NSMutableArray alloc] init];
        
        CGFloat currentTime      = self.timeOffset;
        CPTStringArray *runModes = @[NSRunLoopCommonModes];
        
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        
        // Update all waiting and running animation operations
        for animationOperation in theAnimationOperations {
            let animationDelegate = animationOperation.delegate;
            
            let period = animationOperation.period;
            
            let  duration  = period.duration;
            let startTime = period.startOffset;
            let delay     = period.delay;
            
            if ( isnan(delay)) {
                if ( [period canStartWithValueFromObject:animationOperation.boundObject propertyGetter:animationOperation.boundGetter] ) {
                    period.delay = currentTime - startTime;
                    startTime    = currentTime;
                }
                else {
                    startTime = CPTNAN;
                }
            }
            else {
                startTime += delay;
            }
            let endTime = startTime + duration;
            
            if ( animationOperation.isCanceled ) {
                [expiredOperations addObject:animationOperation];
                
                if ( [animationDelegate respondsToSelector:@selector(animationCancelled:)] ) {
                    dispatch_async(mainQueue, ^{
                        [animationDelegate animationCancelled:animationOperation];
                    });
                }
            }
            else if ( currentTime >= startTime ) {
                let boundObject = animationOperation.boundObject;
                
                let timingFunction = self.timingFunctionForAnimationCurve(animationOperation.animationCurve)
                
                if ( boundObject && timingFunction ) {
                    var started = false;
                    
                    if runningOperations.containsObject(animationOperation) == false{
                        // Remove any running animations for the same property
                        let boundGetter = animationOperation.boundGetter
                        let boundSetter = animationOperation.boundSetter
                        
                        for operation in runningOperations {
                            if ( operation.boundObject == boundObject ) {
                                if ((operation.boundGetter == boundGetter) && (operation.boundSetter == boundSetter)) {
                                    operation.canceled = true;
                                }
                            }
                        }
                        
                        
                        
                        
                        
                        
                        // Start the new animation
                        runningOperations.addObject(animationOperation)
                        started = true;
                    }
                    if ( !animationOperation.isCanceled ) {
                        if ( !period.startValue ) {
                            period.setStartValueFromObject(animationOperation.boundObject, propertyGetter:animationOperation.boundGetter)
                        }
                        
                        let valueClass = period.valueClass;
                        let progress = timingFunction(currentTime - startTime, duration);
                        
                        typealias CPTDictionary = [String : Any?]
                        var parameters = [
                            CPTAnimationOperationKey  : animationOperation,
                            CPTAnimationValueKey      : period.tweenedValue(forProgress: progress),
                            CPTAnimationValueClassKey : valueClass ? valueClass : NSNull(),
                            CPTAnimationStartedKey    : started),
                            CPTAnimationFinishedKey: NSNumber(value: currentTime >= endTime)
                        ] as? CPTDictionary
                        
                        
                        
                        
                        
                        
                        // Used -performSelectorOnMainThread:... instead of GCD to ensure the animation continues to run in all run loop common modes.
                        [self performSelectorOnMainThread:@selector(updateOnMainThreadWithParameters:)
                        withObject:parameters
                        waitUntilDone:false,
                        modes:runModes];
                        
                        if ( currentTime >= endTime ) {
                            [expiredOperations addObject:animationOperation];
                        }
                    }
                }
            }
        }
        
        for ( animationOperation in expiredOperations ) {
            [runningOperations removeObjectIdenticalTo:animationOperation];
            [theAnimationOperations removeObjectIdenticalTo:animationOperation];
        }
        
        if ( theAnimationOperations.count == 0 ) {
            [self cancelTimer];
        }
    }
    
    // This method must be called from the main thread.
    func updateOnMainThreadWithParameters(parameters: CPTDictionary)
    {
        let animationOperation = parameters[CPTAnimationOperationKey]

    var canceled: Bool

    animationQueue.sync(execute: {
        canceled = animationOperation?.isCanceled ?? false
    })
        
        
        
        
    if ( !canceled ) {
    @try {
    Class valueClass = parameters[CPTAnimationValueClassKey];
    if ( [valueClass isKindOfClass:[NSNull class]] ) {
    valueClass = Nil;
    }
    
  let delegate = animationOperation.delegate
        
    let started = parameters[CPTAnimationStartedKey];
    if ( started.boolValue ) {
    
    
    
    
    
    if ( [delegate respondsToSelector:@selector(animationDidStart:)] ) {
    [delegate animationDidStart:animationOperation];
    }
    }
    
    if ( [delegate respondsToSelector:@selector(animationWillUpdate:)] ) {
    [delegate animationWillUpdate:animationOperation];
    }
    
        
    let boundSetter = animationOperation.boundSetter
    let boundObject = animationOperation.boundObject
    let tweenedValue = parameters[CPTAnimationValueKey]
        
    
    if ( !valueClass && [tweenedValue isKindOfClass:[NSDecimalNumber class]] ) {
    NSDecimal buffer = ((NSDecimalNumber *)tweenedValue).decimalValue;
    
    typedef void (*SetterType)(id, SEL, NSDecimal);
    SetterType setterMethod = (SetterType)[boundObject methodForSelector:boundSetter];
    setterMethod(boundObject, boundSetter, buffer);
    }
    else if ( valueClass && [tweenedValue isKindOfClass:[NSNumber class]] ) {
    NSNumber *value = (NSNumber *)tweenedValue;
    
    typedef void (*NumberSetterType)(id, SEL, NSNumber *);
    NumberSetterType setterMethod = (NumberSetterType)[boundObject methodForSelector:boundSetter];
    setterMethod(boundObject, boundSetter, value);
    }
    else if ( [tweenedValue isKindOfClass:[CPTPlotRange class]] ) {
    CPTPlotRange *range = (CPTPlotRange *)tweenedValue;
    
    typedef void (*RangeSetterType)(id, SEL, CPTPlotRange *);
    RangeSetterType setterMethod = (RangeSetterType)[boundObject methodForSelector:boundSetter];
    setterMethod(boundObject, boundSetter, range);
    }
    else {
    // wrapped scalars and structs
    NSValue *value = (NSValue *)tweenedValue;
    
    NSUInteger bufferSize = 0;
    NSGetSizeAndAlignment(value.objCType, &bufferSize, NULL);
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[boundObject methodSignatureForSelector:boundSetter]];
    invocation.target   = boundObject;
    invocation.selector = boundSetter;
    
    void *buffer = calloc(1, bufferSize);
    [value getValue:buffer];
    [invocation setArgument:buffer atIndex:2];
    free(buffer);
    
    [invocation invoke];
    }
    
    if ( [delegate respondsToSelector:@selector(animationDidUpdate:)] ) {
    [delegate animationDidUpdate:animationOperation];
    }
    
    NSNumber *finished = parameters[CPTAnimationFinishedKey];
    if ( finished.boolValue ) {
    if ( [delegate respondsToSelector:@selector(animationDidFinish:)] ) {
    [delegate animationDidFinish:animationOperation];
    }
    }
    }
    @catch ( NSException *__unused exception ) {
    // something went wrong; don't run this operation any more
    dispatch_async(self.animationQueue, ^{
    animationOperation.canceled = YES;
    });
    }
    }
    }
    
    func startTimer()
    {
        dispatch_source_t newTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.animationQueue);
        
        if ( newTimer ) {
            dispatch_source_set_timer(newTimer, dispatch_time(DISPATCH_TIME_NOW, 0), (uint64_t)(kCPTAnimationFrameRate * NSEC_PER_SEC), 0);
            dispatch_source_set_event_handler(newTimer, ^{
                [self update];
            });
            dispatch_resume(newTimer);
            
            self.timer = newTimer;
        }
    }
    
    func cancelTimer()
    {
        
        if ( theTimer ) {
            self.timer = NULL;
        }
    }
    
    /// @endcond
    
    // MARK: - Timing Functions
    func timingFunction(for animationCurve: CPTAnimationCurve) -> CPTAnimationTimingFunction? {
        
//        typealias CPTAnimationTimingFunction = (CGFloat, CGFloat)-> (CGFloat)
        
        
        var timingFunction :  CPTAnimationTimingFunction
        
        if ( animationCurve == .default ) {
            animationCurve = self.defaultAnimationCurve
        }
        
        switch ( animationCurve ) {
        case .linear:
            timingFunction = CPTAnimationTimingFunctionLinear
            
        case .BackIn:
            timingFunction = CPTAnimationTimingFunctionBackIn
            
        case .BackOut:
            timingFunction = CPTAnimationTimingFunctionBackOut
            
        case .BackInOut:
            timingFunction = CPTAnimationTimingFunctionBackInOut
            
        case .BounceIn:
            timingFunction = CPTAnimationTimingFunctionBounceIn
            
            
        case .BounceOut:
            timingFunction = CPTAnimationTimingFunctionBounceOut
            break;
            
        case .BounceInOut:
            timingFunction = CPTAnimationTimingFunctionBounceInOut
            break;
            
        case .CircularIn:
            timingFunction = CPTAnimationTimingFunctionCircularIn
            break;
            
        case .CircularOut:
            timingFunction = CPTAnimationTimingFunctionCircularOut
            break;
            
        case .CircularInOut:
            timingFunction = CPTAnimationTimingFunctionCircularInOut;
            break;
            
        case .ElasticIn:
            timingFunction = CPTAnimationTimingFunctionElasticIn;
            
        case .ElasticOut:
            timingFunction = CPTAnimationTimingFunctionElasticOut;
            
        case .ElasticInOut:
            timingFunction = CPTAnimationTimingFunctionElasticInOut;
            
        case .ExponentialIn:
            timingFunction = CPTAnimationTimingFunctionExponentialIn;
            
        case .ExponentialOut:
            timingFunction = CPTAnimationTimingFunctionExponentialOut;
            break;
            
        case .ExponentialInOut:
            timingFunction = CPTAnimationTimingFunctionExponentialInOut;
            break;
            
        case .SinusoidalIn:
            timingFunction = CPTAnimationTimingFunctionSinusoidalIn;
            
        case .SinusoidalOut:
            timingFunction = CPTAnimationTimingFunctionSinusoidalOut;
            
        case .SinusoidalInOut:
            timingFunction = CPTAnimationTimingFunctionSinusoidalInOut;
            
        case .CubicIn:
            timingFunction = CPTAnimationTimingFunctionCubicIn;
            
        case .CubicOut:
            timingFunction = CPTAnimationTimingFunctionCubicOut;
            
        case .CubicInOut:
            timingFunction = CPTAnimationTimingFunctionCubicInOut;
            
        case .QuadraticIn:
            timingFunction = CPTAnimationTimingFunctionQuadraticIn;
            
        case .QuadraticOut:
            timingFunction = CPTAnimationTimingFunctionQuadraticOut;
            
        case .QuadraticInOut:
            timingFunction = CPTAnimationTimingFunctionQuadraticInOut;
            
        case .QuarticIn:
            timingFunction = CPTAnimationTimingFunctionQuarticIn
            break;
            
        case .QuarticOut:
            timingFunction = CPTAnimationTimingFunctionQuarticOut
            
        case .QuarticInOut:
            timingFunction = CPTAnimationTimingFunctionQuarticInOut
            break;
            
        case .QuinticIn:
            timingFunction = CPTAnimationTimingFunctionQuinticIn
            
        case .QuinticOut:
            timingFunction = CPTAnimationTimingFunctionQuinticOut
            
        case .QuinticInOut:
            timingFunction = CPTAnimationTimingFunctionQuinticInOut
            
        default:
            timingFunction = CPTAnimationTimingFunctionLinear
        }
        
        return timingFunction
    }
    
    
}
