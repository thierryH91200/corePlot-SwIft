//
//  CPTXYAxis.swift
//  corePlot
//
//  Created by thierryH24 on 14/11/2020.
//

import Cocoa

public class CPTXYAxis: CPTAxis {


//    typedef CGPoint (*CPTAlignPointFunction)(__nonnull CGContextRef, CGPoint);

    var orthogonalPosition = CGFloat(0)
    var axisConstraints : CPTConstraints?
    
    // MARK: - Init/Dealloc
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        orthogonalPosition = 0.0;
        axisConstraints    = nil;
        self.tickDirection = CPTSign.none;
    }
    
    override init(layer: Any)    {
        super.init(layer: layer)
        
        let theLayer = CPTXYAxis(layer: layer)
        
        orthogonalPosition = theLayer.orthogonalPosition;
        axisConstraints    = theLayer.axisConstraints;
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
// MARK: - Coordinate Transforms

    func orthogonalCoordinateViewLowerBound(lower: CGFloat, upper: CGFloat)
    {
        var lower = lower
        var upper = upper
        let orthogonalCoordinate = CPTUtilities.shared.CPTOrthogonalCoordinate(self.coordinate);
        let xyPlotSpace        = self.plotSpace
        let orthogonalRange = xyPlotSpace?.plotRangeForCoordinate(coordinate: orthogonalCoordinate)


        let lowerBoundPoint = self.viewPointForOrthogonalCoordinate(orthogonalCoord: orthogonalRange?.location, axisCoordinate:0)
        let upperBoundPoint = self.viewPointForOrthogonalCoordinate(orthogonalCoord: orthogonalRange?.end, axisCoordinate:0)

        switch ( self.coordinate ) {
        case CPTCoordinate.x:
                lower = lowerBoundPoint.y;
                upper = upperBoundPoint.y;
                break;

        case CPTCoordinate.y:
                lower = lowerBoundPoint.x;
                upper = upperBoundPoint.x;
                break;

            default:
                lower = CGFloat.nan
                upper = CGFloat.nan
                break;
        }
    }

    func viewPointForOrthogonalCoordinate( orthogonalCoord: CGFloat?, axisCoordinate coordinateValue: CGFloat?) -> CGPoint {
        let myCoordinate = coordinate
        let orthogonalCoordinate = CPTUtilities.shared.CPTOrthogonalCoordinate(myCoordinate)
        
        var plotPoint = [CGFloat]()
        
        plotPoint.append(coordinateValue!)
        plotPoint.append(orthogonalCoord!)
        
        let thePlotArea = plotArea
        
        return convertPoint(plotSpace.plotAreaViewPointForPlotPoint( plotPoint, numberOfCoordinates: 2), from: thePlotArea)
    }
    
    
    
    override func viewPointForCoordinateValue(coordinateValue: CGFloat )-> CGPoint
    {
        var point = self.viewPointForOrthogonalCoordinate(orthogonalCoord: self.orthogonalPosition,
                                                          axisCoordinate:coordinateValue)
        
        let theAxisConstraints = self.axisConstraints
        
        if (( theAxisConstraints ) != nil) {
            var lowerBound = CGFloat(0)
            var upperBound = CGFloat(0);
            self.orthogonalCoordinateViewLowerBound(lower: lowerBound ,upper: upperBound)
            let constrainedPosition = theAxisConstraints!.positionFor(lowerBound: lowerBound, upperBound: upperBound)
                
                switch ( self.coordinate ) {
                case CPTCoordinate.x:
                point.y = constrainedPosition;
                break;
                
                case CPTCoordinate.y:
                point.x = constrainedPosition;
                break;
                
                default:
                break;
                }
        }
        
        if point.x.isNaN || point.y.isNaN {
            print("[CPTXYAxis viewPointForCoordinateValue:%@] was %@", coordinateValue, CPTStringFromPoint(point));
            
            if point.x.isNaN {
                point.x = CGFloat(0.0);
            }
            if point.y.isNaN {
                point.y = CGFloat(0.0);
            }
        }
        
        return point;
    }

// MARK: Drawing

    func drawTicksInContext(context: CGContextRef, atLocations locations: CPTNumberSet, withLength length:CGFloat, inRange labeledRange: CPTPlotRange, isMajor major:Bool)
    {
        let lineStyle = (major ? self.majorTickLineStyle : self.minorTickLineStyle)

        if ( !lineStyle ) {
            return;
        }

        let lineWidth = lineStyle.lineWidth;

        CPTAlignPointFunction alignmentFunction = NULL;

        if ((self.contentsScale > CGFloat(1.0)) && (round(lineWidth) == lineWidth)) {
            alignmentFunction = CPTAlignIntegralPointToUserSpace;
        }
        else {
            alignmentFunction = CPTAlignPointToUserSpace;
        }

        lineStyle.setLineStyleInContext(context)
        CGContextBeginPath(context);

        for  tickLocation in locations {
            if labeledRange && labeledRange.containsNumber(tickLocation) == false {
                continue;
            }

            // Tick end points
            let baseViewPoint  = self.viewPointForCoordinateValue(tickLocation)
            let startViewPoint = baseViewPoint
            let endViewPoint   = baseViewPoint

            var startFactor = CGFloat(0.0);
            var endFactor   = CGFloat(0.0);
            switch ( self.tickDirection ) {
            case .positive:
                    endFactor = CGFloat(1.0);
                    break;

            case .negative:
                    endFactor = CGFloat(-1.0);
                    break;

            case .none:
                    startFactor = CGFloat(-0.5);
                    endFactor   = CGFloat(0.5);
                    break;
            }

            switch ( self.coordinate ) {
            case CPTCoordinate.x:
                    startViewPoint.y += length * startFactor;
                    endViewPoint.y   += length * endFactor;
                    break;

            case CPTCoordinate.y:
                    startViewPoint.x += length * startFactor;
                    endViewPoint.x   += length * endFactor;
                    break;

                default:
                    print("Invalid coordinate in [CPTXYAxis drawTicksInContext:]")
            }

            startViewPoint = alignmentFunction(context, startViewPoint);
            endViewPoint   = alignmentFunction(context, endViewPoint);

            // Add tick line
            CGContextMoveToPoint(context, startViewPoint.x, startViewPoint.y);
            CGContextAddLineToPoint(context, endViewPoint.x, endViewPoint.y);
        }
        // Stroke tick line
        lineStyle.strokePathInContext(context)
    }

    override func renderAsVectorInContext(context: CGContext)
    {
        guard self.isHidden == false else { return }
        
        super.renderAsVectorInContext(context: context)
        
        self.relabel()
        
        let thePlotRange    = self.plotSpace?.plotRangeForCoordinate(coordinate: self.coordinate)
        var range    = thePlotRange
        let theVisibleRange = self.visibleRange;
        
        if (( theVisibleRange ) != nil) {
            range.intersectionPlotRange(theVisibleRange)
        }
        
        let labeledRange : CPTMutablePlotRange?
        
        switch ( self.labelingPolicy ) {
        case .none:
            fallthrough
        case .provided:
            labeledRange = range;
            break;
            
        default:
            break;
        }
        
        // Ticks
        self.drawTicksInContext(context, atLocations:self.minorTickLocations, withLength:self.minorTickLength, inRange:labeledRange, isMajor:false)
        self.drawTicksInContext(context, atLocations:self.majorTickLocations, withLength:self.majorTickLength, inRange:labeledRange, isMajor:true)
        
        // Axis Line
        let theLineStyle = self.axisLineStyle
        let minCap: CPTLineCap?         = self.axisLineCapMin
        let maxCap: CPTLineCap?        = self.axisLineCapMax
        
        if ( (theLineStyle != nil) || (minCap != nil) || (maxCap != nil) ) {
            // If there is a separate axis range given then restrict the axis to that range, overriding the visible range
            // given for grid lines and ticks.
            let theVisibleAxisRange = self.visibleAxisRange;
            if (( theVisibleAxisRange ) != nil) {
                range = theVisibleAxisRange
                
            }
            let alignmentFunction : CPTAlignPointFunction = CPTUtilities.shared.CPTAlignPointToUserSpace
            if ( theLineStyle ) {
                let lineWidth = theLineStyle?.lineWidth;
                if ((self.contentsScale > CGFloat(1.0)) && (round(lineWidth) == lineWidth)) {
                    alignmentFunction = CPTAlignIntegralPointToUserSpace;
                }
                
                let startViewPoint = alignmentFunction(context, self.viewPointForCoordinateValue(range.location))
                let endViewPoint   = alignmentFunction(context, self.viewPointForCoordinateValue(range.end))
                theLineStyle?.setLineStyleInContext(context: context)
                context.beginPath();
                CGContextMoveToPoint(context, startViewPoint.x, startViewPoint.y);
                CGContextAddLineToPoint(context, endViewPoint.x, endViewPoint.y);
                theLineStyle?.strokePathInContext(context: context)
            }
            
            var axisDirection = CGPoint()
            if ( (minCap != nil) || (maxCap != nil) ) {
                switch ( self.coordinate ) {
                case CPTCoordinate.x:
                    axisDirection = (range!.lengthDouble >= 0.0) ? CGPoint(x: 1.0, y: 0.0) : CGPoint(x: -1.0, y: 0.0)
                    
                case CPTCoordinate.y:
                    axisDirection = (range!.lengthDouble >= 0.0) ? CGPoint(x: 0.0, y: 1.0) : CGPoint(x: 0.0, y: -1.0);
                    
                default:
                    break;
                }
            }
            
            if (( minCap ) != nil) {
                let viewPoint = alignmentFunction(context, self.viewPointForCoordinateValue(range.minLimit))
                minCap.renderAsVectorInContext(context, atPoint:viewPoint, inDirection:CGPoint(-axisDirection.x, -axisDirection.y))
            }
            
            if (( maxCap ) != nil) {
                let viewPoint = alignmentFunction(context, self.viewPointForCoordinateValue(range.maxLimit))
                maxCap.renderAsVectorInContext(context, atPoint:viewPoint, inDirection:axisDirection)
            }
        }
    }

// MARK: - Grid Lines
    override func drawGridLinesInContext(context:  CGContext, isMajor: Bool)
    {
        let lineStyle = isMajor ? self.majorGridLineStyle : self.minorGridLineStyle

        if (( lineStyle ) != nil) {
            super.renderAsVectorInContext(context: context)

            self.relabel()

            let thePlotSpace           = self.plotSpace;
            let locations              = (isMajor ? self.majorTickLocations : self.minorTickLocations);
            let selfCoordinate         = self.coordinate;
            let orthogonalCoordinate   = CPTOrthogonalCoordinate(selfCoordinate);
            let orthogonalRange = thePlotSpace.plotRangeForCoordinate(orthogonalCoordinate)
            let theGridLineRange       = self.gridLinesRange;
            let labeledRange    = CPTMutablePlotRange(location: 0, length: 0)

            switch ( self.labelingPolicy ) {
            case .none:
            case .provided:
                
                let labeledRange = self.plotSpace?.plotRangeForCoordinate(coordinate: self.coordinate)
                    let theVisibleRange = self.visibleRange
                if (( theVisibleRange ) != nil) {
                        labeledRange.intersectionPlotRange(theVisibleRange)
                    }
                
                break;

                default:
                    break;
            }

            if (( theGridLineRange ) != nil) {
                orthogonalRange.intersectionPlotRange(theGridLineRange)
            }

            let thePlotArea = self.plotArea;
            var startPlotPoint = [CGFloat]()
            var endPlotPoint = [CGFloat]()
            startPlotPoint[orthogonalCoordinate] = orthogonalRange.locationDecimal;
            endPlotPoint[orthogonalCoordinate]   = orthogonalRange.endDecimal;
            let originTransformed = self.convert(self.bounds.origin, from:thePlotArea)

            let lineWidth = lineStyle?.lineWidth;

            let alignmentFunction : CPTUtilities.shared.CPTAlignPointFunction?
            if ((self.contentsScale > CGFloat(1.0)) && (round(lineWidth) == lineWidth)) {
                alignmentFunction = CPTAlignIntegralPointToUserSpace;
            }
            else {
                alignmentFunction = CPTAlignPointToUserSpace;
            }

            context.beginPath();

            for location in locations {
                let locationDecimal = location.decimalValue;

                if ( labeledRange && !labeledRange.contains(locationDecimal )) {
                    continue;
                }

                startPlotPoint[selfCoordinate] = locationDecimal;
                endPlotPoint[selfCoordinate]   = locationDecimal;

                // Start point
                let startViewPoint = thePlotSpace.plotAreaViewPointForPlotPoint(plotPoint: startPlotPoint, numberOfCoordinates:2)
                startViewPoint.x += originTransformed.x;
                startViewPoint.y += originTransformed.y;

                // End point
                var endViewPoint = thePlotSpace.plotAreaViewPointForPlotPoint( plotPoint: endPlotPoint, numberOfCoordinates: 2)
                endViewPoint.x += originTransformed.x
                endViewPoint.y += originTransformed.y
                
                
                // Align to pixels
                startViewPoint = alignmentFunction(context, startViewPoint);
                endViewPoint   = alignmentFunction(context, endViewPoint);

                // Add grid line
                CGContextMoveToPoint(context, startViewPoint.x, startViewPoint.y);
                CGContextAddLineToPoint(context, endViewPoint.x, endViewPoint.y);
            }

            // Stroke grid lines
            lineStyle?.setLineStyleInContext(context: context)
            lineStyle?.strokePathInContext(context: context)
        }
    }
    
    // MARK: Background Bands
//    -(NSUInteger)initialBandIndexForSortedLocations:(CPTNumberArray *)sortedLocations inRange:(CPTMutablePlotRange *)range
//    {
//        NSUInteger bandIndex = 0;
//
//        NSNumber *bandAnchor = self.alternatingBandAnchor;
//        NSUInteger bandCount = self.alternatingBandFills.count;
//
//        if ( bandAnchor && (bandCount > 0)) {
//            NSDecimal anchor = bandAnchor.decimalValue;
//
//            CPTPlotRange *theVisibleRange = self.visibleRange;
//            if ( theVisibleRange ) {
//                [range intersectionPlotRange:theVisibleRange];
//            }
//
//            NSDecimal rangeStart;
//            if ( range.lengthDouble >= 0.0 ) {
//                rangeStart = range.minLimitDecimal;
//            }
//            else {
//                rangeStart = range.maxLimitDecimal;
//            }
//
//            NSDecimal origin = self.labelingOrigin.decimalValue;
//            NSDecimal offset = CPTDecimalSubtract(anchor, origin);
//            NSDecimalRound(&offset, &offset, 0, NSRoundDown);
//
//            const NSDecimal zero = CPTDecimalFromInteger(0);
//
//            // Set starting coord--should be the smallest value >= rangeMin that is a whole multiple of majorInterval away from the alternatingBandAnchor
//            NSDecimal coord         = zero;
//            NSDecimal majorInterval = zero;
//
//            switch ( self.labelingPolicy ) {
//                case CPTAxisLabelingPolicyAutomatic:
//                case CPTAxisLabelingPolicyEqualDivisions:
//                    if ( sortedLocations.count > 1 ) {
//                        if ( range.lengthDouble >= 0.0 ) {
//                            majorInterval = CPTDecimalSubtract(sortedLocations[1].decimalValue, sortedLocations[0].decimalValue);
//                        }
//                        else {
//                            majorInterval = CPTDecimalSubtract(sortedLocations[0].decimalValue, sortedLocations[1].decimalValue);
//                        }
//                    }
//                    break;
//
//                case CPTAxisLabelingPolicyFixedInterval:
//                {
//                    majorInterval = self.majorIntervalLength.decimalValue;
//                }
//                break;
//
//                case CPTAxisLabelingPolicyLocationsProvided:
//                case CPTAxisLabelingPolicyNone:
//                {
//                    // user provided tick locations; they're not guaranteed to be evenly spaced, but band drawing always starts with the first location
//                    if ( range.lengthDouble >= 0.0 ) {
//                        for ( NSNumber *location in sortedLocations ) {
//                            if ( CPTDecimalLessThan(anchor, location.decimalValue)) {
//                                break;
//                            }
//
//                            bandIndex++;
//                        }
//                    }
//                    else {
//                        for ( NSNumber *location in sortedLocations ) {
//                            if ( CPTDecimalGreaterThanOrEqualTo(anchor, location.decimalValue)) {
//                                break;
//                            }
//
//                            bandIndex++;
//                        }
//                    }
//
//                    bandIndex = bandIndex % bandCount;
//                }
//                break;
//            }
//
//            if ( !CPTDecimalEquals(majorInterval, zero)) {
//                coord = CPTDecimalDivide(CPTDecimalSubtract(rangeStart, origin), majorInterval);
//                NSDecimalRound(&coord, &coord, 0, NSRoundUp);
//                NSInteger stepCount = CPTDecimalIntegerValue(coord) + CPTDecimalIntegerValue(offset) + 1;
//
//                if ( stepCount >= 0 ) {
//                    bandIndex = (NSUInteger)(stepCount % (NSInteger)bandCount);
//                }
//                else {
//                    bandIndex = (NSUInteger)(-stepCount % (NSInteger)bandCount);
//                }
//            }
//        }
//
//        return bandIndex;
//    }
//
//    -(void)drawBackgroundBandsInContext:(nonnull CGContextRef)context
//    {
//        CPTFillArray *bandArray = self.alternatingBandFills;
//        NSUInteger bandCount    = bandArray.count;
//
//        if ( bandCount > 0 ) {
//            CPTNumberArray *locations = self.majorTickLocations.allObjects;
//
//            if ( locations.count > 0 ) {
//                CPTPlotSpace *thePlotSpace = self.plotSpace;
//
//                CPTCoordinate selfCoordinate = self.coordinate;
//                CPTMutablePlotRange *range   = [[thePlotSpace plotRangeForCoordinate:selfCoordinate] mutableCopy];
//                if ( range ) {
//                    CPTPlotRange *theVisibleRange = self.visibleRange;
//                    if ( theVisibleRange ) {
//                        [range intersectionPlotRange:theVisibleRange];
//                    }
//                }
//
//                CPTCoordinate orthogonalCoordinate   = CPTOrthogonalCoordinate(selfCoordinate);
//                CPTMutablePlotRange *orthogonalRange = [[thePlotSpace plotRangeForCoordinate:orthogonalCoordinate] mutableCopy];
//                CPTPlotRange *theGridLineRange       = self.gridLinesRange;
//
//                if ( theGridLineRange ) {
//                    [orthogonalRange intersectionPlotRange:theGridLineRange];
//                }
//
//                const NSDecimal zero             = CPTDecimalFromInteger(0);
//                NSSortDescriptor *sortDescriptor = nil;
//                if ( range ) {
//                    if ( CPTDecimalGreaterThanOrEqualTo(range.lengthDecimal, zero)) {
//                        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
//                    }
//                    else {
//                        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:NO];
//                    }
//                }
//                else {
//                    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
//                }
//                locations = [locations sortedArrayUsingDescriptors:@[sortDescriptor]];
//
//                NSUInteger bandIndex = [self initialBandIndexForSortedLocations:locations inRange:range];
//
//                const id null = [NSNull null];
//
//                NSDecimal lastLocation;
//                if ( range ) {
//                    lastLocation = range.locationDecimal;
//                }
//                else {
//                    lastLocation = CPTDecimalNaN();
//                }
//
//                NSDecimal startPlotPoint[2];
//                NSDecimal endPlotPoint[2];
//                if ( orthogonalRange ) {
//                    startPlotPoint[orthogonalCoordinate] = orthogonalRange.locationDecimal;
//                    endPlotPoint[orthogonalCoordinate]   = orthogonalRange.endDecimal;
//                }
//                else {
//                    startPlotPoint[orthogonalCoordinate] = CPTDecimalNaN();
//                    endPlotPoint[orthogonalCoordinate]   = CPTDecimalNaN();
//                }
//
//                for ( NSDecimalNumber *location in locations ) {
//                    NSDecimal currentLocation = location.decimalValue;
//                    if ( !CPTDecimalEquals(CPTDecimalSubtract(currentLocation, lastLocation), zero)) {
//                        CPTFill *bandFill = bandArray[bandIndex++];
//                        bandIndex %= bandCount;
//
//                        if ( bandFill != null ) {
//                            // Start point
//                            startPlotPoint[selfCoordinate] = currentLocation;
//                            CGPoint startViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:startPlotPoint numberOfCoordinates:2];
//
//                            // End point
//                            endPlotPoint[selfCoordinate] = lastLocation;
//                            CGPoint endViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:endPlotPoint numberOfCoordinates:2];
//
//                            // Fill band
//                            CGRect fillRect = CPTRectMake(MIN(startViewPoint.x, endViewPoint.x),
//                                                          MIN(startViewPoint.y, endViewPoint.y),
//                                                          ABS(endViewPoint.x - startViewPoint.x),
//                                                          ABS(endViewPoint.y - startViewPoint.y));
//                            [bandFill fillRect:CPTAlignIntegralRectToUserSpace(context, fillRect) inContext:context];
//                        }
//                    }
//
//                    lastLocation = currentLocation;
//                }
//
//                // Fill space between last location and the range end
//                NSDecimal endLocation;
//                if ( range ) {
//                    endLocation = range.endDecimal;
//                }
//                else {
//                    endLocation = CPTDecimalNaN();
//                }
//                if ( !CPTDecimalEquals(lastLocation, endLocation)) {
//                    CPTFill *bandFill = bandArray[bandIndex];
//
//                    if ( bandFill != null ) {
//                        // Start point
//                        startPlotPoint[selfCoordinate] = endLocation;
//                        CGPoint startViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:startPlotPoint numberOfCoordinates:2];
//
//                        // End point
//                        endPlotPoint[selfCoordinate] = lastLocation;
//                        CGPoint endViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:endPlotPoint numberOfCoordinates:2];
//
//                        // Fill band
//                        CGRect fillRect = CPTRectMake(MIN(startViewPoint.x, endViewPoint.x),
//                                                      MIN(startViewPoint.y, endViewPoint.y),
//                                                      ABS(endViewPoint.x - startViewPoint.x),
//                                                      ABS(endViewPoint.y - startViewPoint.y));
//                        [bandFill fillRect:CPTAlignIntegralRectToUserSpace(context, fillRect) inContext:context];
//                    }
//                }
//            }
//        }
//    }
//
//    -(void)drawBackgroundLimitsInContext:(nonnull CGContextRef)context
//    {
//        CPTLimitBandArray *limitArray = self.backgroundLimitBands;
//
//        if ( limitArray.count > 0 ) {
//            CPTPlotSpace *thePlotSpace = self.plotSpace;
//
//            CPTCoordinate selfCoordinate = self.coordinate;
//            CPTMutablePlotRange *range   = [[thePlotSpace plotRangeForCoordinate:selfCoordinate] mutableCopy];
//
//            if ( range ) {
//                CPTPlotRange *theVisibleRange = self.visibleRange;
//                if ( theVisibleRange ) {
//                    [range intersectionPlotRange:theVisibleRange];
//                }
//            }
//
//            CPTCoordinate orthogonalCoordinate   = CPTOrthogonalCoordinate(selfCoordinate);
//            CPTMutablePlotRange *orthogonalRange = [[thePlotSpace plotRangeForCoordinate:orthogonalCoordinate] mutableCopy];
//            CPTPlotRange *theGridLineRange       = self.gridLinesRange;
//
//            if ( theGridLineRange ) {
//                [orthogonalRange intersectionPlotRange:theGridLineRange];
//            }
//
//            NSDecimal startPlotPoint[2];
//            NSDecimal endPlotPoint[2];
//            startPlotPoint[orthogonalCoordinate] = orthogonalRange.locationDecimal;
//            endPlotPoint[orthogonalCoordinate]   = orthogonalRange.endDecimal;
//
//            for ( CPTLimitBand *band in self.backgroundLimitBands ) {
//                CPTFill *bandFill = band.fill;
//
//                if ( bandFill ) {
//                    CPTMutablePlotRange *bandRange = [band.range mutableCopy];
//                    if ( bandRange ) {
//                        [bandRange intersectionPlotRange:range];
//
//                        // Start point
//                        startPlotPoint[selfCoordinate] = bandRange.locationDecimal;
//                        CGPoint startViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:startPlotPoint numberOfCoordinates:2];
//
//                        // End point
//                        endPlotPoint[selfCoordinate] = bandRange.endDecimal;
//                        CGPoint endViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:endPlotPoint numberOfCoordinates:2];
//
//                        // Fill band
//                        CGRect fillRect = CPTRectMake(MIN(startViewPoint.x, endViewPoint.x),
//                                                      MIN(startViewPoint.y, endViewPoint.y),
//                                                      ABS(endViewPoint.x - startViewPoint.x),
//                                                      ABS(endViewPoint.y - startViewPoint.y));
//                        [bandFill fillRect:CPTAlignIntegralRectToUserSpace(context, fillRect) inContext:context];
//                    }
//                }
//            }
//        }
//    }
//
//    /// @endcond
//
//    #pragma mark -
//    #pragma mark Description
//
//    /// @cond
//
//    -(nullable NSString *)description
//    {
//        CPTPlotRange *range    = [self.plotSpace plotRangeForCoordinate:self.coordinate];
//        CGPoint startViewPoint = [self viewPointForCoordinateValue:range.location];
//        CGPoint endViewPoint   = [self viewPointForCoordinateValue:range.end];
//
//        return [NSString stringWithFormat:@"<%@ with range: %@ viewCoordinates: %@ to %@>",
//                super.description,
//                range,
//                CPTStringFromPoint(startViewPoint),
//                CPTStringFromPoint(endViewPoint)];
//    }
//
//    /// @endcond
//
//    #pragma mark -
//    #pragma mark Titles
//
//    /// @cond
//
//    // Center title in the plot range by default
//    -(nonnull NSNumber *)defaultTitleLocation
//    {
//        NSNumber *location;
//
//        CPTPlotSpace *thePlotSpace  = self.plotSpace;
//        CPTCoordinate theCoordinate = self.coordinate;
//
//        CPTPlotRange *axisRange = [thePlotSpace plotRangeForCoordinate:theCoordinate];
//
//        if ( axisRange ) {
//            CPTScaleType scaleType = [thePlotSpace scaleTypeForCoordinate:theCoordinate];
//
//            switch ( scaleType ) {
//                case CPTScaleTypeLinear:
//                    location = axisRange.midPoint;
//                    break;
//
//                case CPTScaleTypeLog:
//                {
//                    double loc = axisRange.locationDouble;
//                    double end = axisRange.endDouble;
//
//                    if ((loc > 0.0) && (end >= 0.0)) {
//                        location = @(pow(10.0, (log10(loc) + log10(end)) / 2.0));
//                    }
//                    else {
//                        location = axisRange.midPoint;
//                    }
//                }
//                break;
//
//                case CPTScaleTypeLogModulus:
//                {
//                    double loc = axisRange.locationDouble;
//                    double end = axisRange.endDouble;
//
//                    location = @(CPTInverseLogModulus((CPTLogModulus(loc) + CPTLogModulus(end)) / 2.0));
//                }
//                break;
//
//                default:
//                    location = axisRange.midPoint;
//                    break;
//            }
//        }
//        else {
//            location = @0;
//        }
//
//        return location;
//    }
//
//    /// @endcond
//
//    #pragma mark -
//    #pragma mark Accessors
//
//    /// @cond
//
//    -(void)setAxisConstraints:(nullable CPTConstraints *)newConstraints
//    {
//        if ( ![axisConstraints isEqualToConstraint:newConstraints] ) {
//            axisConstraints = newConstraints;
//            [self setNeedsDisplay];
//            [self setNeedsLayout];
//        }
//    }
//
//    -(void)setOrthogonalPosition:(nullable NSNumber *)newPosition
//    {
//        BOOL needsUpdate = YES;
//
//        if ( newPosition ) {
//            NSNumber *position = newPosition;
//            needsUpdate = ![orthogonalPosition isEqualToNumber:position];
//        }
//
//        if ( needsUpdate ) {
//            orthogonalPosition = newPosition;
//            [self setNeedsDisplay];
//            [self setNeedsLayout];
//        }
//    }
//
//    -(void)setCoordinate:(CPTCoordinate)newCoordinate
//    {
//        if ( self.coordinate != newCoordinate ) {
//            super.coordinate = newCoordinate;
//            switch ( newCoordinate ) {
//                case CPTCoordinateX:
//                    switch ( self.labelAlignment ) {
//                        case CPTAlignmentLeft:
//                        case CPTAlignmentCenter:
//                        case CPTAlignmentRight:
//                            // ok--do nothing
//                            break;
//
//                        default:
//                            self.labelAlignment = CPTAlignmentCenter;
//                            break;
//                    }
//                    break;
//
//                case CPTCoordinateY:
//                    switch ( self.labelAlignment ) {
//                        case CPTAlignmentTop:
//                        case CPTAlignmentMiddle:
//                        case CPTAlignmentBottom:
//                            // ok--do nothing
//                            break;
//
//                        default:
//                            self.labelAlignment = CPTAlignmentMiddle;
//                            break;
//                    }
//                    break;
//
//                default:
//                    [NSException raise:NSInvalidArgumentException format:@"Invalid coordinate: %lu", (unsigned long)newCoordinate];
//                    break;
//            }
//        }
//    }
//
//    /// @endcond
//
//    @en/
}
