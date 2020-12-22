# corePlot-Swift

work in progress

🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧


# who wants to help me ?? to convert from objective c to swit the 'coreplot' framework


# Update

A Objective C version available [core-plot]https://github.com/core-plot/core-plot) by [core-plot](https://github.com/core-plot/)

https://github.com/core-plot/core-plot



# Introduction

Core Plot is a 2D plotting framework for macOS, iOS, and tvOS. It is highly customizable and capable of drawing many types of plots. See the Example Graphs wiki page and the example applications for examples of some of its capabilities.

https://i.stack.imgur.com/3pKlb.png



# problem encountered

## NSInvocation                                   
corePlot/Source/Animation/CPTAnimationCGFloatPeriod

## NSValue

## CPTPlotRange

## class CPTColor

## KVO
https://nalexn.github.io/kvo-guide-for-key-value-observing/
CPTFunctionDataSource/observeValueForKeyPath


Swift has inherited the support for the KVO from Objective-C, but unlike the latter, KVO is disabled in Swift classes by default.


## class CPTMutablePlotRange

// https://izziswift.com/what-is-the-swift-equivalent-of-respondstoselector/
func pointingDeviceDownEven(event: CPTNativeEvent, atPoint interactionPoint:CGPoint)-> Bool
{
    let theDelegate = self.delegate
    guard let handledByDelegate = theDelegate?.plotSpace(space: self, shouldHandlePointingDeviceDownEvent: event, atPoint: interactionPoint)
    else { return false}
    return handledByDelegate;
}



-(void)cacheNumbers:(nullable id)numbers forField:(NSUInteger)fieldEnum
{
    NSNumber *cacheKey = @(fieldEnum);

    CPTCoordinate coordinate   = [self coordinateForFieldIdentifier:fieldEnum];
    CPTPlotSpace *thePlotSpace = self.plotSpace;

    if ( numbers ) {
    
    


# Add change 



number errors = 270

com 201204 : CPTXYPlotSpace

com201204 : CPTAxisTitle / CPTAxisLabel

com201205 : 
CPTXYAxis
CPTGridLineGroup   ok

CPTTextLayer ok

##CPTPlotSpace ligne 154

### I’ve googled but not been able to find out what the swift equivalent to respondsToSelector: is.

This is the only thing I could find (Swift alternative to respondsToSelector:) but isn’t too relevant in my case as its checking the existence of the delegate, I don’t have a delegate I just want to check if a new API exists or not when running on the device and if not fall back to a previous version of the api.

 https://izziswift.com/what-is-the-swift-equivalent-of-respondstoselector/

https://nshipster.com/nil/

CPTAnimationCurve

// Returns a singleton class object
let nl:NSNull = NSNull()

if ( [labelAnnotation isKindOfClass:nullClass] ) {
    labelAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:thePlotSpace anchorPlotPoint:nil];
    labelArray[i]   = labelAnnotation;
    [self addAnnotation:labelAnnotation];
}

class CPTLegendEntry : ok
