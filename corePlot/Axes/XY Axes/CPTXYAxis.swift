//
//  CPTXYAxis.swift
//  corePlot
//
//  Created by thierryH24 on 14/11/2020.
//

import AppKit

public class CPTXYAxis: CPTAxis {


//    typedef CGPoint (*CPTAlignPointFunction)(__nonnull CGContextRef, CGPoint)

    var orthogonalPosition = CGFloat(0)
    var axisConstraints : CPTConstraints?
    
    // MARK: - Init/Dealloc
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        orthogonalPosition = 0.0
        axisConstraints    = nil
        self.tickDirection = CPTSign.none
    }
    
    override init(layer: Any)    {
        super.init(layer: layer)
        
        let theLayer = CPTXYAxis(layer: layer)
        
        orthogonalPosition = theLayer.orthogonalPosition
        axisConstraints    = theLayer.axisConstraints
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
// MARK: - Coordinate Transforms

    func orthogonalCoordinateViewLowerBound(lower: inout CGFloat, upper: inout CGFloat)
    {
//        var lower = lower
//        var upper = upper
        let orthogonalCoordinate = CPTUtilities.shared.CPTOrthogonalCoordinate(self.coordinate)
        let xyPlotSpace        = self.plotSpace
        let orthogonalRange = xyPlotSpace?.plotRangeForCoordinate(coordinate: orthogonalCoordinate)

        let lowerBoundPoint = self.viewPointForOrthogonalCoordinate(orthogonalCoord: CGFloat(truncating: NSNumber(nonretainedObject: orthogonalRange!.location)), axisCoordinate:0)
        let upperBoundPoint = self.viewPointForOrthogonalCoordinate(orthogonalCoord: CGFloat(truncating: NSNumber(nonretainedObject: orthogonalRange!.end)), axisCoordinate:0)

        switch ( self.coordinate ) {
        case CPTCoordinate.x:
                lower = lowerBoundPoint.y
                upper = upperBoundPoint.y
                break

        case CPTCoordinate.y:
                lower = lowerBoundPoint.x
                upper = upperBoundPoint.x
                break

            default:
                lower = CGFloat.nan
                upper = CGFloat.nan
                break
        }
    }

    func viewPointForOrthogonalCoordinate( orthogonalCoord: CGFloat, axisCoordinate coordinateValue: CGFloat) -> CGPoint {
        
        let myCoordinate = coordinate
        let orthogonalCoordinate = CPTUtilities.shared.CPTOrthogonalCoordinate(myCoordinate)
        
        var plotPoint = [CGFloat]()
        
        plotPoint.insert(coordinateValue,at: myCoordinate.rawValue)
        plotPoint.insert(orthogonalCoord, at: orthogonalCoordinate.rawValue)
        
        let thePlotArea = plotArea
        let point = plotSpace?.plotAreaViewPointForPlotPoint( plotPoint: plotPoint, numberOfCoordinates: 2)
        return convert(point!,  from: thePlotArea)
    }
    
    override func viewPointForCoordinateValue(coordinateValue: CGFloat )-> CGPoint
    {
        var point = self.viewPointForOrthogonalCoordinate(orthogonalCoord: self.orthogonalPosition,
                                                          axisCoordinate:coordinateValue)
        
        let theAxisConstraints = self.axisConstraints
        
        if (( theAxisConstraints ) != nil) {
            var lowerBound = CGFloat(0)
            var upperBound = CGFloat(0)
            self.orthogonalCoordinateViewLowerBound(lower: &lowerBound ,upper: &upperBound)
            let constrainedPosition = theAxisConstraints!.positionFor(lowerBound: lowerBound, upperBound: upperBound)
                
                switch ( self.coordinate ) {
                case CPTCoordinate.x:
                point.y = constrainedPosition
                break
                
                case CPTCoordinate.y:
                point.x = constrainedPosition
                break
                
                default:
                break
                }
        }
        
        if point.x.isNaN || point.y.isNaN {
            print("[CPTXYAxis viewPointForCoordinateValue:%@] was %@", coordinateValue, CPTUtilities.shared.CPTStringFromPoint(point))
            
            if point.x.isNaN {
                point.x = CGFloat(0.0)
            }
            if point.y.isNaN {
                point.y = CGFloat(0.0)
            }
        }
        
        return point
    }

// MARK: Drawing

    func drawTicksInContext(context: CGContext, atLocations locations: CPTNumberSet, withLength length:CGFloat, inRange labeledRange: CPTPlotRange, isMajor major:Bool)
    {
        let lineStyle = (major ? self.majorTickLineStyle : self.minorTickLineStyle)
        
        let lineWidth = lineStyle?.lineWidth
        let alignmentFunction : CPTAlignPointFunction = nil
        
        if ((self.contentsScale > CGFloat(1.0)) && (round(lineWidth!) == lineWidth)) {
            alignmentFunction = CPTAlignIntegralPointToUserSpace
        }
        else {
            alignmentFunction = CPTAlignPointToUserSpace
        }
        
        lineStyle?.setLineStyleInContext(context: context)
        context.beginPath()
        
        for  tickLocation in locations {
            if labeledRange && labeledRange.containsNumber(number: tickLocation) == false {
                continue
            }
            
            // Tick end points
            let baseViewPoint  = self.viewPointForCoordinateValue(coordinateValue: CGFloat(truncating: tickLocation))
            var startViewPoint = baseViewPoint
            var endViewPoint   = baseViewPoint
            
            var startFactor = CGFloat(0.0)
            var endFactor   = CGFloat(0.0)
            switch ( self.tickDirection ) {
            case .positive:
                endFactor = CGFloat(1.0)
                
            case .negative:
                endFactor = CGFloat(-1.0)
                
            case .none:
                startFactor = CGFloat(-0.5)
                endFactor   = CGFloat(0.5)
            }
            
            switch ( self.coordinate ) {
            case CPTCoordinate.x:
                startViewPoint.y += length * startFactor
                endViewPoint.y   += length * endFactor
                
            case CPTCoordinate.y:
                startViewPoint.x += length * startFactor
                endViewPoint.x   += length * endFactor
                
            default:
                print("Invalid coordinate in [", #file ,"]", #function )
            }
            
            startViewPoint = alignmentFunction!(context, startViewPoint)
            endViewPoint   = alignmentFunction!(context, endViewPoint)
            
            // Add tick line
            context.move(to: startViewPoint)
            context.addLine(to: endViewPoint)
        }
        // Stroke tick line
        lineStyle?.strokePathInContext(context: context)
    }

    override func renderAsVectorInContext(context: CGContext)
    {
        guard self.isHidden == false else { return }
        
        super.renderAsVectorInContext(context: context)
        
        self.relabel()
        
        let thePlotRange    = self.plotSpace?.plotRangeForCoordinate(coordinate: self.coordinate)
        var range    = thePlotRange
        let theVisibleRange = self.visibleRange
        
        if (( theVisibleRange ) != nil) {
            range.intersectionPlotRange(theVisibleRange)
        }
        
        let labeledRange : CPTMutablePlotRange?
        
        switch ( self.labelingPolicy ) {
        case .none:
            fallthrough
        case .provided:
            labeledRange = range
            break
            
        default:
            break
        }
        
        // Ticks
        self.drawTicksInContext(context: context, atLocations:self.minorTickLocations, withLength:self.minorTickLength, inRange:labeledRange!, isMajor:false)
        self.drawTicksInContext(context: context, atLocations:self.majorTickLocations, withLength:self.majorTickLength, inRange:labeledRange!, isMajor:true)
        
        // Axis Line
        let theLineStyle = self.axisLineStyle
        let minCap: CPTLineCap?         = self.axisLineCapMin
        let maxCap: CPTLineCap?        = self.axisLineCapMax
        
        if ( (theLineStyle != nil) || (minCap != nil) || (maxCap != nil) ) {
            // If there is a separate axis range given then restrict the axis to that range, overriding the visible range
            // given for grid lines and ticks.
            let theVisibleAxisRange = self.visibleAxisRange
            if (( theVisibleAxisRange ) != nil) {
                range = theVisibleAxisRange
                
            }
            let alignmentFunction : CPTAlignPointFunction = CPTUtilities.shared.CPTAlignPointToUserSpace
            if (( theLineStyle ) != nil) {
                let lineWidth = theLineStyle?.lineWidth
                if ((self.contentsScale > CGFloat(1.0)) && (round(lineWidth!) == lineWidth)) {
                    alignmentFunction = CPTAlignIntegralPointToUserSpace
                }
                
                let startViewPoint = alignmentFunction!(context, self.viewPointForCoordinateValue(coordinateValue: range!.location))
                let endViewPoint   = alignmentFunction!(context, self.viewPointForCoordinateValue(coordinateValue: range!.end()))
                theLineStyle?.setLineStyleInContext(context: context)
                context.beginPath()
                context.move(to: startViewPoint)
                context.addLine(to: endViewPoint)
                theLineStyle?.strokePathInContext(context: context)
            }
            
            var axisDirection = CGPoint()
            if ( (minCap != nil) || (maxCap != nil) ) {
                switch ( self.coordinate ) {
                case CPTCoordinate.x:
                    axisDirection = (range!.lengthDouble >= 0.0) ? CGPoint(x: 1.0, y: 0.0) : CGPoint(x: -1.0, y: 0.0)
                    
                case CPTCoordinate.y:
                    axisDirection = (range!.lengthDouble >= 0.0) ? CGPoint(x: 0.0, y: 1.0) : CGPoint(x: 0.0, y: -1.0)
                    
                default:
                    break
                }
            }
            
            if (( minCap ) != nil) {
                let viewPoint = alignmentFunction!(context, self.viewPointForCoordinateValue(coordinateValue: range!.minLimit()))
                minCap!.renderAsVectorInContext(context: context, center:viewPoint, direction:CGPoint(x: -axisDirection.x, y: -axisDirection.y))
            }
            
            if (( maxCap ) != nil) {
                let viewPoint = alignmentFunction!(context, self.viewPointForCoordinateValue(coordinateValue: range!.maxLimit()))
                maxCap!.renderAsVectorInContext(context: context, center:viewPoint, direction:axisDirection)
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

            let thePlotSpace           = self.plotSpace
            let locations              = (isMajor ? self.majorTickLocations : self.minorTickLocations)
            let selfCoordinate         = self.coordinate
            let orthogonalCoordinate   = CPTUtilities.shared.CPTOrthogonalCoordinate(selfCoordinate)
            let orthogonalRange = thePlotSpace?.plotRangeForCoordinate(coordinate: orthogonalCoordinate) as! CPTMutablePlotRange
            let theGridLineRange       = self.gridLinesRange
            let labeledRange    = CPTMutablePlotRange(location: 0.0, length: 0.0)
            
            switch ( self.labelingPolicy ) {
            case .none:
                fallthrough
            case .provided:
                
                let labeledRange = self.plotSpace?.plotRangeForCoordinate(coordinate: self.coordinate) as! CPTMutablePlotRange
                let theVisibleRange = self.visibleRange
                if (( theVisibleRange ) != nil) {
                    labeledRange.intersectionPlotRange(other: theVisibleRange)
                }
                
            default:
                break
            }
            
            if (( theGridLineRange ) != nil) {
                orthogonalRange.intersectionPlotRange(other: theGridLineRange)
            }
            
            let thePlotArea = self.plotArea
            var startPlotPoint = [CGFloat]()
            var endPlotPoint = [CGFloat]()
            startPlotPoint[orthogonalCoordinate.rawValue] = orthogonalRange.locationDecimal
            endPlotPoint[orthogonalCoordinate.rawValue]   = orthogonalRange.endDecimal
            let originTransformed = self.convert(self.bounds.origin, from:thePlotArea)

            let lineWidth = lineStyle?.lineWidth

            let alignmentFunction : CPTAlignPointFunction?
            if ((self.contentsScale > CGFloat(1.0)) && (round(lineWidth!) == lineWidth)) {
                alignmentFunction = CPTAlignIntegralPointToUserSpace
            }
            else {
                alignmentFunction = CPTAlignPointToUserSpace
            }

            context.beginPath()

            for location in locations {
                let locationDecimal = location

                if ( labeledRange && labeledRange.contains(locationDecimal) == false ) {
                    continue
                }

                startPlotPoint[selfCoordinate.rawValue] = locationDecimal
                endPlotPoint[selfCoordinate.rawValue]   = locationDecimal

                // Start point
                var startViewPoint = thePlotSpace?.plotAreaViewPointForPlotPoint(plotPoint: startPlotPoint, numberOfCoordinates:2)
                startViewPoint?.x += originTransformed.x
                startViewPoint?.y += originTransformed.y

                // End point
                var endViewPoint = thePlotSpace?.plotAreaViewPointForPlotPoint( plotPoint: endPlotPoint, numberOfCoordinates: 2)
                endViewPoint?.x += originTransformed.x
                endViewPoint?.y += originTransformed.y
                
                
                // Align to pixels
                startViewPoint = alignmentFunction!!(context, startViewPoint!)
                endViewPoint   = alignmentFunction!!(context, endViewPoint!)

                // Add grid line
                context.move(to: startViewPoint!)
                context.addLine(to: endViewPoint!)
            }

            // Stroke grid lines
            lineStyle?.setLineStyleInContext(context: context)
            lineStyle?.strokePathInContext(context: context)
        }
    }
    
    // MARK: Background Bands
    func initialBandIndexForSortedLocations(sortedLocations:CPTNumberArray, inRange range:CPTMutablePlotRange )-> Int
    {
        var bandIndex = 0

        let bandAnchor = self.alternatingBandAnchor
        let bandCount = self.alternatingBandFills.count


        if ( (bandAnchor != nil) && (bandCount > 0)) {
            let anchor = bandAnchor

            let theVisibleRange = self.visibleRange
            if (( theVisibleRange ) != nil) {
                range.intersectionPlotRange(other: theVisibleRange)
            }

            var rangeStart = CGFloat(0)
            if ( range.lengthDouble >= 0.0 ) {
                rangeStart = range.minLimitDecimal
            }
            else {
                rangeStart = range.maxLimitDecimal
            }

            let origin = self.labelingOrigin
            let offset = CGFloat(anchor!) - origin
//            NSDecimalRound(&offset, &offset, 0, NSRoundDown)

            let zero = CGFloat(0)

            // Set starting coord--should be the smallest value >= rangeMin that is a whole multiple of majorInterval away from the alternatingBandAnchor
            var coord         = zero
            var majorInterval = zero

            switch ( self.labelingPolicy ) {
            case .automatic:
                fallthrough
            case .divisions:
                if ( sortedLocations.count > 1 ) {
                    if ( range.lengthDouble >= 0.0 ) {
                        majorInterval = sortedLocations[1] - sortedLocations[0]
                    }
                    else {
                        majorInterval = sortedLocations[0] - sortedLocations[1]
                    }
                }
                break
                
            case .fixedInterval:
                majorInterval = self.majorIntervalLength
                
            case .provided:
                fallthrough
            case .none:
                // user provided tick locations they're not guaranteed to be evenly spaced, but band drawing always starts with the first location
                if ( range.lengthDouble >= 0.0 ) {
                    for location in sortedLocations {
                        if anchor! <= location {
                            break
                        }
                        
                        bandIndex += 1
                    }
                }
                else {
                    for location in sortedLocations {
                        if anchor! >= location {
                            break
                        }
                        
                        bandIndex += 1
                    }
                }
                
                bandIndex = bandIndex % bandCount
            }
            
            if majorInterval != zero {
                coord = (CGFloat(rangeStart) - CGFloat(origin)) / majorInterval
                
//                NSDecimalRound(&coord, &coord, 0, NSRoundUp)
                let stepCount = Int(coord) + Int(offset) + 1

                if ( stepCount >= 0 ) {
                    bandIndex = Int(stepCount % bandCount)
                }
                else {
                    bandIndex = Int(-stepCount % bandCount)
                }
            }
        }

        return bandIndex
    }

    override func drawBackgroundBandsInContext(context: CGContext)
    {
        let bandArray = self.alternatingBandFills
        let bandCount    = bandArray.count

        if ( bandCount > 0 ) {
            
//            let myArray = Array(mySet)
            var locations = Array(self.majorTickLocations)

            if ( locations.count > 0 ) {
                let thePlotSpace = self.plotSpace

                let selfCoordinate = self.coordinate
                let range   = thePlotSpace!.plotRangeForCoordinate(coordinate: selfCoordinate) as? CPTMutablePlotRange
                if (( range ) != nil) {
                    let theVisibleRange = self.visibleRange
                    if (( theVisibleRange ) != nil) {
                        range?.intersectionPlotRange(other: theVisibleRange)
                    }
                }

                let orthogonalCoordinate   = CPTUtilities.shared.CPTOrthogonalCoordinate(selfCoordinate)
                let orthogonalRange = thePlotSpace?.plotRangeForCoordinate(coordinate: orthogonalCoordinate) as? CPTMutablePlotRange
                let theGridLineRange       = self.gridLinesRange

                if (( theGridLineRange ) != nil) {
                    orthogonalRange?.intersectionPlotRange(other: theGridLineRange)
                }

                var sortDescriptor = NSSortDescriptor()
                if ( range != nil) {
                    if range!.lengthDecimal >= CGFloat(0) {
                        sortDescriptor = NSSortDescriptor(key:nil, ascending:true)
                    }
                    else {
                        sortDescriptor = NSSortDescriptor(key:nil, ascending: false)
                    }
                }
                else {
                    sortDescriptor = NSSortDescriptor(key:nil, ascending:true)
                }
                
                locations = locations.sorted{ $0 > $1 } // sortedArrayUsingDescriptors:@[sortDescriptor]]

                var bandIndex = self.initialBandIndexForSortedLocations(sortedLocations: locations, inRange: range!)

//                let null = [NSNull null]

                var lastLocation = CGFloat(0)
                if ( range != nil) {
                    lastLocation = range!.locationDecimal
                }
                else {
                    lastLocation = .nan
                }

                var startPlotPoint = [CGFloat]()
                var endPlotPoint = [CGFloat]()
                if (( orthogonalRange ) != nil) {
                    startPlotPoint[orthogonalCoordinate.rawValue] = orthogonalRange!.locationDecimal
                    endPlotPoint[orthogonalCoordinate.rawValue]   = orthogonalRange!.endDecimal
                }
                else {
                    startPlotPoint[orthogonalCoordinate.rawValue] = .nan
                    endPlotPoint[orthogonalCoordinate.rawValue] = .nan
                }

                for location in locations {
                    let currentLocation = location
                    if currentLocation - lastLocation != CGFloat(0) {
                        let bandFill = bandArray[bandIndex]
                        bandIndex += 1
                        bandIndex %= bandCount

//                        if ( bandFill != nil ) {
                            // Start point
                            startPlotPoint[selfCoordinate.rawValue] = currentLocation
                            let startViewPoint = thePlotSpace?.plotAreaViewPointForPlotPoint(plotPoint: startPlotPoint, numberOfCoordinates:2)

                            // End point
                            endPlotPoint[selfCoordinate.rawValue] = lastLocation
                            let endViewPoint = thePlotSpace?.plotAreaViewPointForPlotPoint(plotPoint: endPlotPoint, numberOfCoordinates:2)

                            // Fill band
                            let fillRect = CGRect(x: min(startViewPoint!.x, endViewPoint!.x),
                                                  y: min(startViewPoint!.y, endViewPoint!.y),
                                                  width: abs(endViewPoint!.x - startViewPoint!.x),
                                                  height: abs(endViewPoint!.y - startViewPoint!.y))
                            bandFill.fillRect(rect: CPTUtilities.shared.CPTAlignIntegralRectToUserSpace(context: context, rect: fillRect), context:context)
//                        }
                    }

                    lastLocation = currentLocation
                }

                // Fill space between last location and the range end
                var endLocation = CGFloat(0)
                if (( range ) != nil) {
                    endLocation = range!.endDecimal
                }
                else {
                    endLocation = .nan
                }
                if lastLocation != endLocation {
                    let bandFill = bandArray[bandIndex]

//                    if ( bandFill != nil ) {
                        // Start point
                        startPlotPoint[selfCoordinate.rawValue] = endLocation
                        let startViewPoint = thePlotSpace?.plotAreaViewPointForPlotPoint(plotPoint: startPlotPoint, numberOfCoordinates:2)

                        // End point
                        endPlotPoint[selfCoordinate.rawValue] = lastLocation
                        let endViewPoint = thePlotSpace?.plotAreaViewPointForPlotPoint(plotPoint: endPlotPoint, numberOfCoordinates:2)

                        // Fill band
                        let fillRect = CGRect(x: min(startViewPoint!.x, endViewPoint!.x),
                                              y: min(startViewPoint!.y, endViewPoint!.y),
                                              width: abs(endViewPoint!.x - startViewPoint!.x),
                                              height: abs(endViewPoint!.y - startViewPoint!.y))
                        bandFill.fillRect(rect: CPTUtilities.shared.CPTAlignIntegralRectToUserSpace(context: context, rect: fillRect), context:context)
//                    }
                }
            }
        }
    }

    override func drawBackgroundLimitsInContext(context: CGContext)
    {
        let limitArray = self.backgroundLimitBands

        if ( limitArray.count > 0 ) {
            let thePlotSpace = self.plotSpace

            let selfCoordinate = self.coordinate
            let range   = thePlotSpace?.plotRangeForCoordinate(coordinate: selfCoordinate) as! CPTMutablePlotRange

//            if (( range ) != nil) {
                let theVisibleRange = self.visibleRange
                if (( theVisibleRange ) != nil) {
                    range.intersectionPlotRange(other: theVisibleRange)
                }
//            }

            let orthogonalCoordinate   = CPTUtilities.shared.CPTOrthogonalCoordinate(selfCoordinate)
            let orthogonalRange = thePlotSpace?.plotRangeForCoordinate(coordinate: orthogonalCoordinate) as! CPTMutablePlotRange
            let theGridLineRange       = self.gridLinesRange

            if (( theGridLineRange ) != nil) {
                orthogonalRange.intersectionPlotRange(other: theGridLineRange)
            }

            var startPlotPoint = [CGFloat]()
            var endPlotPoint = [CGFloat]()
            startPlotPoint[orthogonalCoordinate.rawValue] = orthogonalRange.locationDecimal
            endPlotPoint[orthogonalCoordinate.rawValue]   = orthogonalRange.endDecimal

            for band in self.backgroundLimitBands {
                let bandFill = band.fill

                if (( bandFill ) != nil) {
                    let bandRange = band.range as? CPTMutablePlotRange
                    if (( bandRange ) != nil) {
                        bandRange?.intersectionPlotRange(other: range)

                        // Start point
                        startPlotPoint[selfCoordinate.rawValue] = bandRange!.locationDecimal
                        let startViewPoint = thePlotSpace?.plotAreaViewPointForPlotPoint(plotPoint: startPlotPoint, numberOfCoordinates:2)

                        // End point
                        endPlotPoint[selfCoordinate.rawValue] = bandRange!.endDecimal
                        let endViewPoint = thePlotSpace?.plotAreaViewPointForPlotPoint(plotPoint: endPlotPoint, numberOfCoordinates:2)

                        // Fill band
                        let fillRect = CGRect(x: min(startViewPoint!.x, endViewPoint!.x),
                                              y: min(startViewPoint!.y, endViewPoint!.y),
                                              width: abs(endViewPoint!.x - startViewPoint!.x),
                                              height: abs(endViewPoint!.y - startViewPoint!.y))
                        bandFill?.fillRect(rect: CPTUtilities.shared.CPTAlignIntegralRectToUserSpace(context: context, rect: fillRect), context:context)
                    }
                }
            }
        }
    }

    // MARK: - Description
//
//    /// @cond
//
//    -(nullable NSString *)description
//    {
//        CPTPlotRange *range    = [self.plotSpace plotRangeForCoordinate:self.coordinate]
//        CGPoint startViewPoint = [self viewPointForCoordinateValue:range.location]
//        CGPoint endViewPoint   = [self viewPointForCoordinateValue:range.end]
//
//        return [NSString stringWithFormat:@"<%@ with range: %@ viewCoordinates: %@ to %@>",
//                super.description,
//                range,
//                CPTStringFromPoint(startViewPoint),
//                CPTStringFromPoint(endViewPoint)]
//    }
//
//    /// @endcond
//
    // MARK: - Titles

    // Center title in the plot range by default
//    -(nonnull NSNumber *)defaultTitleLocation
//    {
//        NSNumber *location
//
//        CPTPlotSpace *thePlotSpace  = self.plotSpace
//        CPTCoordinate theCoordinate = self.coordinate
//
//        CPTPlotRange *axisRange = [thePlotSpace plotRangeForCoordinate:theCoordinate]
//
//        if ( axisRange ) {
//            CPTScaleType scaleType = [thePlotSpace scaleTypeForCoordinate:theCoordinate]
//
//            switch ( scaleType ) {
//                case CPTScaleTypeLinear:
//                    location = axisRange.midPoint
//                    break
//
//                case CPTScaleTypeLog:
//                {
//                    double loc = axisRange.locationDouble
//                    double end = axisRange.endDouble
//
//                    if ((loc > 0.0) && (end >= 0.0)) {
//                        location = @(pow(10.0, (log10(loc) + log10(end)) / 2.0))
//                    }
//                    else {
//                        location = axisRange.midPoint
//                    }
//                }
//                break
//
//                case CPTScaleTypeLogModulus:
//                {
//                    double loc = axisRange.locationDouble
//                    double end = axisRange.endDouble
//
//                    location = @(CPTInverseLogModulus((CPTLogModulus(loc) + CPTLogModulus(end)) / 2.0))
//                }
//                break
//
//                default:
//                    location = axisRange.midPoint
//                    break
//            }
//        }
//        else {
//            location = @0
//        }
//
//        return location
//    }
//
//    /// @endcond
//
    // MARK: - Accessors
//
//    /// @cond
//
//    -(void)setAxisConstraints:(nullable CPTConstraints *)newConstraints
//    {
//        if ( ![axisConstraints isEqualToConstraint:newConstraints] ) {
//            axisConstraints = newConstraints
//            [self setNeedsDisplay]
//            [self setNeedsLayout]
//        }
//    }
//
//    -(void)setOrthogonalPosition:(nullable NSNumber *)newPosition
//    {
//        BOOL needsUpdate = YES
//
//        if ( newPosition ) {
//            NSNumber *position = newPosition
//            needsUpdate = ![orthogonalPosition isEqualToNumber:position]
//        }
//
//        if ( needsUpdate ) {
//            orthogonalPosition = newPosition
//            [self setNeedsDisplay]
//            [self setNeedsLayout]
//        }
//    }
//
//    -(void)setCoordinate:(CPTCoordinate)newCoordinate
//    {
//        if ( self.coordinate != newCoordinate ) {
//            super.coordinate = newCoordinate
//            switch ( newCoordinate ) {
//                case CPTCoordinateX:
//                    switch ( self.labelAlignment ) {
//                        case CPTAlignmentLeft:
//                        case CPTAlignmentCenter:
//                        case CPTAlignmentRight:
//                            // ok--do nothing
//                            break
//
//                        default:
//                            self.labelAlignment = CPTAlignmentCenter
//                            break
//                    }
//                    break
//
//                case CPTCoordinateY:
//                    switch ( self.labelAlignment ) {
//                        case CPTAlignmentTop:
//                        case CPTAlignmentMiddle:
//                        case CPTAlignmentBottom:
//                            // ok--do nothing
//                            break
//
//                        default:
//                            self.labelAlignment = CPTAlignmentMiddle
//                            break
//                    }
//                    break
//
//                default:
//                    [NSException raise:NSInvalidArgumentException format:@"Invalid coordinate: %lu", (unsigned long)newCoordinate]
//                    break
//            }
//        }
//    }
}
