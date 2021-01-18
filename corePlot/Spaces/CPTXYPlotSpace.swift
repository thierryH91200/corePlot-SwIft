//
//  CPTXYPlotSpace.swift
//  corePlot
//
//  Created by thierryH24 on 14/11/2020.
//

import AppKit

class CPTXYPlotSpace: CPTPlotSpace {
    
    var globalXRange: CPTPlotRange?
    var globalYRange: CPTPlotRange?
    var xScaleType : CPTScaleType
    var yScaleType : CPTScaleType
    
    var allowsMomentum: Bool
    var allowsMomentumX: Bool
    var allowsMomentumY: Bool
    var momentumAnimationCurve: CPTAnimationCurve
    var bounceAnimationCurve: CPTAnimationCurve;
    var momentumAcceleration = CGFloat(0)
    var bounceAcceleration = CGFloat(0)
    var minimumDisplacementToDrag = CGFloat(0)
    
    override var isDragging : Bool {
        get { return false }
        set { super.isDragging = newValue }
    }
    
    var  lastDragPoint = CGPoint()
    var  lastDisplacement = CGPoint();
    var  lastDragTime: TimeInterval;
    var  lastDeltaTime: TimeInterval;
    var animations = [CPTAnimationOperation]()
    
    override init()
    {
        super.init()
        xRange           = CPTPlotRange(location:0.0, length:1.0)
        yRange           = CPTPlotRange(location:0.0, length:1.0)
        globalXRange     = nil
        globalYRange     = nil
        xScaleType       = CPTScaleType.linear
        yScaleType       = CPTScaleType.linear
        lastDragPoint    = CGPoint()
        lastDisplacement = CGPoint()
        lastDragTime     = 0.0;
        lastDeltaTime    = 0.0;
        animations       = [CPTAnimationOperation]()
        
        allowsMomentumX           = false;
        allowsMomentumY           = false;
        momentumAnimationCurve    = .QuarticOut
        bounceAnimationCurve      = .QuarticOut;
        momentumAcceleration      = 2000.0;
        bounceAcceleration        = 3000.0;
        minimumDisplacementToDrag = 2.0;
    }
    
    func setPlotRange(_ newRange: CPTPlotRange, for coordinate: CPTCoordinate) {
        switch coordinate {
        case .x:
            xRange = newRange
        case .y:
            yRange = newRange
        default:
            // invalid coordinate--do nothing
            break
        }
    }
    
    override func plotRangeForCoordinate( coordinate: CPTCoordinate) -> CPTPlotRange? {
        var theRange: CPTPlotRange? = nil
        
        switch coordinate {
        case .x:
            theRange = xRange
        case .y:
            theRange = yRange
        default:
            // invalid coordinate
            break
        }
        
        return theRange
    }
    
    override func setScaleType(_ newType: CPTScaleType, for coordinate: CPTCoordinate) {
        switch coordinate {
        case .x:
            xScaleType = newType
        case .y:
            yScaleType = newType
        default:
            // invalid coordinate--do nothing
            break
        }
    }
    
    func scaleType(for coordinate: CPTCoordinate) -> CPTScaleType {
        var theScaleType = CPTScaleType.linear
        
        switch coordinate {
        case .x:
            theScaleType = xScaleType
        case .y:
            theScaleType = yScaleType
        default:
            // invalid coordinate
            break
        }
        return theScaleType
    }
    
    var _xRange: CPTPlotRange
    var xRange: CPTPlotRange {
        get { return _xRange}
        set {
            if  newValue.isEqual(to: xRange)  == false {
                var constrainedRange = CPTPlotRange()
                
                if self.allowsMomentumX == true {
                    constrainedRange = newValue
                }
                else {
                    constrainedRange = self.constrainRange(existingRange: newValue ,toGlobalRange: self.globalXRange!)!
                }
                
                weak var theDelegate = self.delegate
                
                if (( theDelegate?.plotSpace(space: willChangePlotRangeTo: forCoordinate:) ) != nil) {
                    constrainedRange = (theDelegate?.plotSpace(space: self, willChangePlotRangeTo:constrainedRange, forCoordinate:CPTCoordinate.x))!
                }
                
                if constrainedRange.isEqualToRange(otherRange: xRange )  == false {
                    var displacement = self.lastDisplacement.x;
                    var isScrolling     = false
                    
                    if ( _xRange && constrainedRange ) {
                        isScrolling = (constrainedRange.locationDecimal != xRange.locationDecimal) && (constrainedRange.lengthDecimal == xRange.lengthDecimal);
                        
                        if ( isScrolling && (displacement == CGFloat(0.0))) {
                            let theGraph    = self.graph;
                            let  plotArea = theGraph?.plotAreaFrame.plotArea;
                            
                            if (( plotArea ) != nil) {
                                let rangeLength = constrainedRange.lengthDecimal;
                                
                                if ( rangeLength != 0 ) {
                                    let diff = (constrainedRange.locationDecimal - xRange.locationDecimal) / rangeLength
                                    
                                    displacement = (plotArea?.bounds.size.width)! * CGFloat(diff);
                                }
                            }
                        }
                    }
                    _xRange = constrainedRange
                    
                    var userInfo  =   [String: Any]()
                    userInfo[CPTPlotSpaceCoordinateKey] = CPTCoordinate.x.rawValue
                    userInfo[CPTPlotSpaceScrollingKey] = isScrolling
                    userInfo[CPTPlotSpaceDisplacementKey] = displacement
                    
                    NotificationCenter.send(
                        name:     .CPTPlotSpaceCoordinateMappingDidChangeNotification,
                        object:   self,
                        userInfo: userInfo )
                    
                    
                    if ((theDelegate?.plotSpace(space: didChangePlotRangeForCoordinate:)) != nil) {
                        theDelegate?.plotSpace(space: self, didChangePlotRangeForCoordinate:CPTCoordinate.x)
                    }
                    
                    let theGraph = self.graph;
                    if (( theGraph ) != nil) {
                        NotificationCenter.send(
                            name: .CPTGraphNeedsRedrawNotification,
                            object:theGraph)
                    }
                }
            }

        }
    }
    
    
    
    var _yRange: CPTPlotRange
    var yRange: CPTPlotRange {
        get { return _xRange}
        set {
            
            if newValue.isEqual(to: yRange ) == false {
                var  constrainedRange = CPTPlotRange()
                
                if ( self.allowsMomentumY == true) {
                    constrainedRange = newValue
                }
                else {
                    constrainedRange = self.constrainRange(existingRange: newValue, toGlobalRange: self.globalYRange!)!
                }
                
                weak var theDelegate = self.delegate
                
                if ((theDelegate?.plotSpace(space: willChangePlotRangeTo: forCoordinate:)) != nil) {
                    constrainedRange = (theDelegate?.plotSpace(space: self, willChangePlotRangeTo:constrainedRange, forCoordinate:CPTCoordinate.y))!
                }
                
                if constrainedRange.isEqualToRange(otherRange: yRange ) == false  {
                    
                    var displacement = self.lastDisplacement.y
                    var isScrolling     = false
                    
                    if ( yRange && constrainedRange ) {
                        isScrolling = constrainedRange.location == yRange.locationDecimal && constrainedRange.length  == yRange.length
                        
                        if ( isScrolling == true && (displacement == CGFloat(0.0))) {
                            let theGraph    = self.graph;
                            let plotArea = theGraph?.plotAreaFrame.plotArea;
                            
                            if (( plotArea ) != nil) {
                                let rangeLength = constrainedRange.lengthDecimal;
                                
                                if ( rangeLength != CGFloat(0)) {
                                    let diff = (constrainedRange.locationDecimal - yRange.locationDecimal) / rangeLength
                                    displacement = (plotArea?.bounds.size.height)! * CGFloat(diff)
                                }
                            }
                        }
                    }
                    _yRange = constrainedRange
                    
                    var userInfo  =   [String: Any]()
                    userInfo[CPTPlotSpaceCoordinateKey] = CPTCoordinate.y.rawValue
                    userInfo[CPTPlotSpaceScrollingKey] = isScrolling
                    userInfo[CPTPlotSpaceDisplacementKey] = displacement
                    
                    NotificationCenter.send(
                        name:.CPTPlotSpaceCoordinateMappingDidChangeNotification,
                        object:self,
                        userInfo:userInfo )
                    
                    if ((theDelegate?.plotSpace(space: didChangePlotRangeForCoordinate:)) != nil) {
                        theDelegate?.plotSpace(space: self, didChangePlotRangeForCoordinate:CPTCoordinate.y)
                    }
                    
                    let theGraph = self.graph;
                    if ( theGraph  != nil) {
                        NotificationCenter.send(
                            name:.CPTGraphNeedsRedrawNotification,
                            object:theGraph)
                    }
                }
            }
        }
    }
    
    func constrainRange(existingRange: CPTPlotRange?, toGlobalRange globalRange: CPTPlotRange?)-> CPTPlotRange?
    {
        if ( globalRange == nil ) {
            return existingRange;
        }
        if ( existingRange == nil ) {
            return nil;
        }
        
        let theGlobalRange = globalRange;
        
        if ( existingRange!.lengthDecimal >= theGlobalRange!.lengthDecimal) {
            return theGlobalRange
        }
        else {
            let newRange = existingRange as! CPTMutablePlotRange
            newRange.shiftEndToFitInRange(otherRange: theGlobalRange!)
            newRange.shiftLocationToFitInRange(otherRange: theGlobalRange!)
            return newRange
        }
    }
    //
    //    -(void)animateRangeForCoordinate:(CPTCoordinate)coordinate shift:(NSDecimal)shift momentumTime:(CGFloat)momentumTime speed:(CGFloat)speed acceleration:(CGFloat)acceleration
    //    {
    //        CPTMutableAnimationArray *animationArray = self.animations;
    //        CPTAnimationOperation *op;
    //
    //        NSString *property        = nifl;
    //        CPTPlotRange *oldRange    = nil;
    //        CPTPlotRange *globalRange = nil;
    //
    //        switch ( coordinate ) {
    //            case CPTCoordinateX:
    //                property    = @"xRange";
    //                oldRange    = self.xRange;
    //                globalRange = self.globalXRange;
    //                break;
    //
    //            case CPTCoordinateY:
    //                property    = @"yRange";
    //                oldRange    = self.yRange;
    //                globalRange = self.globalYRange;
    //                break;
    //
    //            default:
    //                property = @"";
    //                oldRange = [CPTPlotRange plotRangeWithLocation:@0.0 length:@0];
    //                break;
    //        }
    //
    //        CPTMutablePlotRange *newRange = [oldRange mutableCopy];
    //
    //        CGFloat bounceDelay = CGFloat(0.0);
    //        NSDecimal zero      = CPTDecimalFromInteger(0);
    //        BOOL hasShift       = !CPTDecimalEquals(shift, zero);
    //
    //        if ( hasShift ) {
    //            newRange.locationDecimal = CPTDecimalAdd(newRange.locationDecimal, shift);
    //
    //            op = [CPTAnimation animate:self
    //                              property:property
    //                         fromPlotRange:oldRange
    //                           toPlotRange:newRange
    //                              duration:momentumTime
    //                        animationCurve:self.momentumAnimationCurve
    //                              delegate:self];
    //            [animationArray addObject:op];
    //
    //            bounceDelay = momentumTime;
    //        }
    //
    //        if ( globalRange ) {
    //            CPTPlotRange *constrainedRange = [self.constrainRange:newRange toGlobalRange:globalRange];
    //
    //            if ( ![newRange isEqualToRange:constrainedRange] && ![globalRange containsRange:newRange] ) {
    //                BOOL direction = (CPTDecimalGreaterThan(shift, zero) && CPTDecimalGreaterThan(oldRange.lengthDecimal, zero)) ||
    //                                 (CPTDecimalLessThan(shift, zero) && CPTDecimalLessThan(oldRange.lengthDecimal, zero));
    //
    //                // decelerate at the global range
    //                if ( hasShift ) {
    //                    CGFloat brakingDelay = CPTNAN;
    //
    //                    if ( [globalRange containsRange:oldRange] ) {
    //                        // momentum started inside the global range; coast until we hit the global range
    //                        CGFloat globalPoint = [self.viewCoordinateForRange:globalRange coordinate:coordinate direction:direction];
    //                        CGFloat oldPoint    = [self.viewCoordinateForRange:oldRange coordinate:coordinate direction:direction];
    //
    //                        CGFloat brakingOffset = globalPoint - oldPoint;
    //                        brakingDelay = CPTFirstPositiveRoot(acceleration, speed, brakingOffset);
    //
    //                        if ( !isnan(brakingDelay)) {
    //                            speed -= brakingDelay * acceleration;
    //
    //                            // slow down quickly
    //                            while ( momentumTime > CGFloat(0.1)) {
    //                                acceleration *= CGFloat(2.0);
    //                                momentumTime  = speed / (CGFloat(2.0) * acceleration);
    //                            }
    //
    //                            CGFloat distanceTraveled = speed * momentumTime - CGFloat(0.5) * acceleration * momentumTime * momentumTime;
    //                            CGFloat brakingLength    = globalPoint - distanceTraveled;
    //
    //                            CGPoint brakingPoint = CGPointZero;
    //                            switch ( coordinate ) {
    //                                case CPTCoordinateX:
    //                                    brakingPoint = CPTPointMake(brakingLength, 0.0);
    //                                    break;
    //
    //                                case CPTCoordinateY:
    //                                    brakingPoint = CPTPointMake(0.0, brakingLength);
    //                                    break;
    //
    //                                default:
    //                                    break;
    //                            }
    //
    //                            NSDecimal newPoint[2];
    //                            [self.plotPoint:newPoint numberOfCoordinates:2 forPlotAreaViewPoint:brakingPoint];
    //
    //                            NSDecimal brakingShift = CPTDecimalSubtract(newPoint[coordinate], direction ? globalRange.endDecimal : globalRange.locationDecimal);
    //
    //                            [newRange shiftEndToFitInRange:globalRange];
    //                            [newRange shiftLocationToFitInRange:globalRange];
    //                            newRange.locationDecimal = CPTDecimalAdd(newRange.locationDecimal, brakingShift);
    //                        }
    //                    }
    //                    else {
    //                        // momentum started outside the global range
    //                        brakingDelay = CGFloat(0.0);
    //
    //                        // slow down quickly
    //                        while ( momentumTime > CGFloat(0.1)) {
    //                            momentumTime *= CGFloat(0.5);
    //
    //                            shift = CPTDecimalDivide(shift, CPTDecimalFromInteger(2));
    //                        }
    //
    //                        newRange = [oldRange mutableCopy];
    //
    //                        newRange.locationDecimal = CPTDecimalAdd(newRange.locationDecimal, shift);
    //                    }
    //
    //                    if ( !isnan(brakingDelay)) {
    //                        op = [CPTAnimation animate:self
    //                                          property:property
    //                                     fromPlotRange:constrainedRange
    //                                       toPlotRange:newRange
    //                                          duration:momentumTime
    //                                         withDelay:brakingDelay
    //                                    animationCurve:self.momentumAnimationCurve
    //                                          delegate:self];
    //                        [animationArray addObject:op];
    //
    //                        bounceDelay = momentumTime + brakingDelay;
    //                    }
    //                }
    //
    //                // bounce back to the global range
    //                CGFloat newPoint         = [self.viewCoordinateForRange:newRange coordinate:coordinate direction:!direction];
    //                CGFloat constrainedPoint = [self.viewCoordinateForRange:constrainedRange coordinate:coordinate direction:!direction];
    //
    //                CGFloat offset = constrainedPoint - newPoint;
    //
    //                CGFloat bounceTime = sqrt(ABS(offset) / self.bounceAcceleration);
    //
    //                op = [CPTAnimation animate:self
    //                                  property:property
    //                             fromPlotRange:newRange
    //                               toPlotRange:constrainedRange
    //                                  duration:bounceTime
    //                                 withDelay:bounceDelay
    //                            animationCurve:self.bounceAnimationCurve
    //                                  delegate:self];
    //                [animationArray addObject:op];
    //            }
    //        }
    //    }
    //
    func viewCoordinateForRange(range: CPTPlotRange, coordinate: CPTCoordinate, direction:Bool)-> CGFloat
    {
        let orthogonalCoordinate = CPTUtilities.shared.CPTOrthogonalCoordinate(coordinate)
        
        var point = [CGFloat](repeating: 0.0, count: 2)
        
        point[coordinate.rawValue]           = direction ? range.maxLimitDecimal : range.minLimitDecimal
        point[orthogonalCoordinate.rawValue] = CGFloat(1)
        
        let viewPoint       = self.plotAreaViewPointForPlotPoint(plotPoint: point, numberOfCoordinates:2)
        var pointCoordinate = CGFloat.nan
        
        switch ( coordinate ) {
        case CPTCoordinate.x:
            pointCoordinate = viewPoint.x;
            break;
            
        case CPTCoordinate.y:
            pointCoordinate = viewPoint.y;
            break;
            
        default:
            break;
        }
        
        return pointCoordinate;
    }
    
        // return NAN if no positive roots
    func CPTFirstPositiveRoot(a:CGFloat, b: CGFloat, c: CGFloat)-> CGFloat
    {
        var root = CGFloat.nan
        
        let discriminant = sqrt(b * b - CGFloat(4.0) * a * c);
        
        let root1 = (-b + discriminant) / (CGFloat(2.0) * a);
        let root2 = (-b - discriminant) / (CGFloat(2.0) * a);
        
        if !root1.isNaN && !root2.isNaN {
            if ( root1 >= CGFloat(0.0)) {
                root = root1;
            }
            if (root2 >= CGFloat(0.0)) && (root.isNaN || root2 < root) {
                root = root2;
            }
        }
        return root;
    }
    
    func setGlobalXRange(newRange: CPTPlotRange)
    {
        if  !newRange.isEqualToRange(otherRange: globalXRange ) {
            globalXRange = newRange
            self.xRange  = self.constrainRange(existingRange: self.xRange, toGlobalRange:globalXRange)!
        }
    }
    func setGlobalYRange(newRange: CPTPlotRange)
    {
        if  !newRange.isEqualToRange(otherRange: globalYRange ) {
            globalYRange = newRange
            self.yRange  = self.constrainRange(existingRange: self.yRange, toGlobalRange:globalYRange)!
        }
    }

    override func scaleToFitPlots(plots:[ CPTPlot]  )
    {
        guard plots.isEmpty == false else { return }

        // Determine union of ranges
        var unionXRange : CPTMutablePlotRange?
        var unionYRange : CPTMutablePlotRange?

        for plot in plots {
            let currentXRange = plot.plotRangeForCoordinate(coord: CPTCoordinate.x)
            let currentYRange = plot.plotRangeForCoordinate(coord: CPTCoordinate.y)
            
            if ( unionXRange != nil) {
                unionXRange = currentXRange as? CPTMutablePlotRange
            }
            if ( unionYRange != nil) {
                unionYRange = currentYRange as? CPTMutablePlotRange
            }
            unionXRange?.unionPlotRange(other: currentXRange)
            unionYRange?.unionPlotRange(other: currentYRange)
        }

        // Set range
        let zero = CGFloat(0);

        if ( unionXRange == nil ) {
            if unionXRange?.lengthDecimal == zero {
                unionXRange?.unionPlotRange(other: self.xRange)
            }
            self.xRange = unionXRange!;
        }
        if ( unionYRange == nil ) {
            if unionYRange?.lengthDecimal == zero {
                unionYRange?.unionPlotRange(other: self.yRange)
            }
            self.yRange = unionYRange!;
        }
    }
    
    override func scaleToFitEntirePlots(plots: [ CPTPlot] )
    {
        guard plots.isEmpty == false else { return }
        
        // Determine union of ranges
        var unionXRange : CPTMutablePlotRange?
        var unionYRange : CPTMutablePlotRange?
        
        for  plot in plots {
            let currentXRange = plot.plotRangeEnclosingCoordinate(coord: CPTCoordinate.x);
            let currentYRange = plot.plotRangeEnclosingCoordinate(coord: CPTCoordinate.y)
            
            if (unionXRange == nil) {
                unionXRange = currentXRange as? CPTMutablePlotRange
            }
            if (unionYRange == nil) {
                unionYRange = currentYRange as? CPTMutablePlotRange
            }
            unionXRange?.unionPlotRange(other: currentXRange)
            unionYRange?.unionPlotRange(other: currentYRange)
        }
        
        // Set range
        let zero = CGFloat(0);
        if unionXRange != nil {
            if  unionXRange?.lengthDecimal == zero {
                unionXRange?.unionPlotRange(other: self.xRange)
            }
            self.xRange = unionXRange!;
        }
        if unionYRange != nil {
            if unionYRange?.lengthDecimal == zero {
                unionYRange?.unionPlotRange(other: self.yRange)
            }
            self.yRange = unionYRange!;
        }
    }
    
    func setXScaleType(newScaleType: CPTScaleType)
    {
        var userInfo  =   [String: Int]()
        userInfo[CPTPlotSpaceCoordinateKey] = CPTCoordinate.x.rawValue
        
        if ( newScaleType != xScaleType ) {
            xScaleType = newScaleType;
            
            NotificationCenter.send(
                name:.CPTPlotSpaceCoordinateMappingDidChangeNotification,
                object:self,
                userInfo: userInfo )
            
            let theGraph = self.graph;
            if (( theGraph ) != nil) {
                NotificationCenter.send(
                    name: .CPTGraphNeedsRedrawNotification,
                    object:theGraph)
            }
        }
    }
    
    func setYScaleType( newScaleType : CPTScaleType  )
    {
        var userInfo  =   [String: Int]()
        userInfo[CPTPlotSpaceCoordinateKey] = CPTCoordinate.y.rawValue

        if ( newScaleType != yScaleType ) {
            yScaleType = newScaleType;
            
            NotificationCenter.send(
                name:.CPTPlotSpaceCoordinateMappingDidChangeNotification,
                object:self,
                userInfo: userInfo)
            
            let theGraph = self.graph;
            if (( theGraph ) != nil) {
                NotificationCenter.send(
                    name:.CPTGraphNeedsRedrawNotification,
                    object:theGraph)
            }
        }
    }

    // MARK: - Point Conversion (private utilities)    
    
    // MARK: Linear
    func viewCoordinateForViewLength( viewLength: CGFloat,
                                      linearPlotRange range: CPTPlotRange?,
                                      plotCoordinateValue plotCoord: CGFloat) -> CGFloat
    {
        guard range != nil else { return CGFloat(0.0)}
        
        var factor = (plotCoord - range!.locationDecimal) / range!.lengthDecimal
        if factor.isNaN {
            factor = 0
        }
        let viewCoordinate = viewLength * factor
        return viewCoordinate
    }
    
    // MARK: - Log
    // Log (only one version since there are no transcendental functions for NSDecimal)
    func viewCoordinateForViewLength( viewLength: CGFloat,
                                      logPlotRange range: CPTPlotRange?,
                                      plotCoordinateValue plotCoord: CGFloat) -> CGFloat {
        
        if ((range!.minLimitDouble <= 0.0) || (range!.maxLimitDouble <= 0.0) || (plotCoord <= 0.0)) {
            return CGFloat(0.0);
        }

        let logLoc   = log10(range!.locationDouble);
        let logCoord = log10(plotCoord);
        let logEnd   = log10(range!.endDouble);

        return viewLength * CGFloat(logCoord) - CGFloat(logLoc) / CGFloat(logEnd - logLoc);
    }
    
    // MARK: - Log-modulus
    //(only one version since there are no transcendental functions for NSDecimal)
    func viewCoordinateForViewLength( viewLength: CGFloat,
                                      logModulusPlotRange range: CPTPlotRange?,
                                      plotCoordinateValue plotCoord : CGFloat) -> CGFloat
    {
        guard range != nil else { return CGFloat(0.0)}

        let logLoc   = CPTUtilities.shared.CPTLogModulus(Double(range!.locationDouble))
        let logCoord = CPTUtilities.shared.CPTLogModulus(Double(plotCoord))
        let logEnd   = CPTUtilities.shared.CPTLogModulus(Double(range!.endDouble))
        
        return viewLength * (CGFloat)((logCoord - logLoc) / (logEnd - logLoc))
    }
    

    func plotCoordinateForViewLength(viewLength: CGFloat, linearPlotRange range: CPTPlotRange, boundsLength: CGFloat) -> CGFloat {
        
        let zero = CGFloat(0);
        guard boundsLength != zero else { return zero }
        
        let location = range.locationDecimal;
        let length   = range.lengthDecimal;
        
        var coordinate = zero
        
        coordinate = viewLength / boundsLength
        coordinate = coordinate * length
        coordinate = coordinate + location
        
        return coordinate
    }
    
    func doublePrecisionPlotCoordinateForViewLength( viewLength: CGFloat, logPlotRange range: CPTPlotRange, boundsLength: CGFloat) -> CGFloat {
        
        let zero = CGFloat(0);
        guard boundsLength != zero else { return zero }
        
        let logLoc = log10(range.locationDecimal);
        let logEnd = log10(range.endDecimal)
        
        let coordinate = viewLength * (logEnd - logLoc) / boundsLength + logLoc;
        
        return pow(10.0, coordinate)
    }
    
    
    func doublePrecisionPlotCoordinateForViewLength( viewLength: CGFloat, logModulusPlotRange range: CPTPlotRange, boundsLength: CGFloat) -> CGFloat {
        
        let zero = CGFloat(0);
        guard boundsLength != zero else { return zero }
        
        let logLoc     = CPTUtilities.shared.CPTLogModulus(Double(range.locationDecimal))
        let logEnd     = CPTUtilities.shared.CPTLogModulus(Double(range.endDecimal))
        let coordinate = viewLength * CGFloat((logEnd - logLoc)) / boundsLength + CGFloat(logLoc)
        
        return CGFloat(CPTUtilities.shared.CPTInverseLogModulus(value: Double(coordinate)));
    }
    
    // MARK: - Point Conversion
    override func numberOfCoordinates()-> Int
    {
        return 2
    }
    
//    func plotAreaViewPoint(forPlotPoint plotPoint: Decimal, numberOfCoordinates count: Int) -> CGPoint {
//    }
    
    
    //    // Plot area view point for plot point
    override func plotAreaViewPointForPlotPoint(plotPoint:  [CGFloat]) -> CGPoint
    {
        var viewPoint = super.plotAreaViewPointForPlotPoint(plotPoint: plotPoint)
        
        var layerSize = CGSize()
        let theGraph    = self.graph;
        let plotArea = theGraph?.plotAreaFrame.plotArea
        
        if (( plotArea ) != nil) {
            layerSize = (plotArea?.bounds.size)!
        }
        else {
            return viewPoint;
        }
        
        switch ( self.xScaleType ) {
        case .linear:
            fallthrough
        case .category:
            viewPoint.x = self.viewCoordinateForViewLength(
                viewLength          : plotArea!.widthDecimal,
                linearPlotRange     : self.xRange,
                plotCoordinateValue : plotPoint[CPTCoordinate.x.rawValue])
            break;
            
        case .log:
            viewPoint.x = self.viewCoordinateForViewLength(
                viewLength         : layerSize.width,
                logPlotRange       : self.xRange,
                plotCoordinateValue: plotPoint[CPTCoordinate.x.rawValue])
            break;
            
        case .logModulus:
            viewPoint.x = self.viewCoordinateForViewLength(
                viewLength         : layerSize.width,
                logModulusPlotRange: self.xRange,
                plotCoordinateValue: plotPoint[CPTCoordinate.x.rawValue])
            break;
            
        default:
            print("NSException raise:CPTException format:@Scale type not supported in CPTXYPlotSpace")
        }
        
        switch ( self.yScaleType ) {
        case .linear:
            fallthrough
        case .category:
            viewPoint.y = self.viewCoordinateForViewLength(
                viewLength   : plotArea!.heightDecimal,
                linearPlotRange: self.yRange,
                plotCoordinateValue:plotPoint[CPTCoordinate.y.rawValue])
            
        case .log:
            viewPoint.y = self.viewCoordinateForViewLength(
                viewLength   : layerSize.height,
                logPlotRange : self.yRange,
                plotCoordinateValue: plotPoint[CPTCoordinate.y.rawValue])

        case .logModulus:
            viewPoint.y = self.viewCoordinateForViewLength(
                viewLength   : layerSize.height,
                logModulusPlotRange: yRange,
                plotCoordinateValue: plotPoint[CPTCoordinate.y.rawValue])
        
        default:
            print("[NSException raise:CPTException format:Scale type not supported in CPTXYPlotSpace")
        }
        
        return viewPoint;
    }

    override func plotAreaViewPointForPlotPoint(plotPoint: [CGFloat] , numberOfCoordinates count: Int)-> CGPoint
    {
        var viewPoint = super.plotAreaViewPointForPlotPoint(
            plotPoint: plotPoint,
            numberOfCoordinates: count)
        
        var layerSize = CGSize()
        let theGraph  = self.graph;
        let plotArea  = theGraph?.plotAreaFrame?.plotArea
        
        if ( plotArea  != nil) {
            layerSize = plotArea!.bounds.size;
        }
        else {
            return viewPoint;
        }
    
        switch ( self.xScaleType ) {
        case .linear:
            fallthrough
        case .category:
            viewPoint.x = self.viewCoordinateForViewLength(
                viewLength: plotArea!.widthDecimal,
                linearPlotRange:self.xRange,
                plotCoordinateValue:plotPoint[CPTCoordinate.x.rawValue])
            break;
            
        case .log:
            let x = plotPoint[CPTCoordinate.x.rawValue]
            viewPoint.x = self.viewCoordinateForViewLength(
                viewLength: layerSize.width,
                logPlotRange:self.xRange,
                plotCoordinateValue : x )
            break;
            
        case .logModulus:
            let x = plotPoint[CPTCoordinate.x.rawValue]
            viewPoint.x = self.viewCoordinateForViewLength(
                viewLength: layerSize.width,
                logModulusPlotRange:self.xRange,
                plotCoordinateValue: x )
            
        default:
            print("NSException raise:CPTException format:@Scale type not supported in CPTXYPlotSpace")
        }
        
        switch ( self.yScaleType ) {
        case .linear:
            fallthrough
        case .category:
            viewPoint.y = self.viewCoordinateForViewLength(
                viewLength: plotArea!.heightDecimal,
                linearPlotRange:self.yRange,
                plotCoordinateValue:plotPoint[CPTCoordinate.y.rawValue])
            
        case .log:
            let y = plotPoint[CPTCoordinate.y.rawValue]
            viewPoint.y = self.viewCoordinateForViewLength(
                viewLength: layerSize.height,
                logPlotRange:self.yRange,
                plotCoordinateValue : y)
            
        case .logModulus:
            let y = plotPoint[CPTCoordinate.y.rawValue]
            viewPoint.y = self.viewCoordinateForViewLength(
                viewLength: layerSize.height,
                logModulusPlotRange:self.yRange,
                plotCoordinateValue : y)
            
        default:
            print("NSException raise:CPTException format:@Scale type not supported in CPTXYPlotSpace")
        }
        return viewPoint;
    }
    
    override func plotAreaViewPointForDoublePrecisionPlotPoint(plotPoint: [Double], numberOfCoordinates count:Int)-> CGPoint
    {
        var viewPoint = super.plotAreaViewPointForDoublePrecisionPlotPoint(plotPoint: plotPoint, numberOfCoordinates:count)
        
        var layerSize = CGSize()
        let theGraph    = self.graph
        let plotArea = theGraph?.plotAreaFrame.plotArea
        
        if (( plotArea ) != nil) {
            layerSize = (plotArea?.bounds.size)!;
        }
        else {
            return viewPoint;
        }
        
        switch ( self.xScaleType ) {
        case CPTScaleType.linear:
            fallthrough
        case CPTScaleType.category:
            viewPoint.x = self.viewCoordinateForViewLength(viewLength: layerSize.width, linearPlotRange:self.xRange, plotCoordinateValue:CGFloat(plotPoint[CPTCoordinate.x.rawValue]))
            break;
            
        case CPTScaleType.log:
            viewPoint.x = self.viewCoordinateForViewLength(viewLength: layerSize.width, logPlotRange:self.xRange, plotCoordinateValue:CGFloat(plotPoint[CPTCoordinate.x.rawValue]))
            break;
            
        case CPTScaleType.logModulus:
            viewPoint.x = self.viewCoordinateForViewLength(viewLength: layerSize.width, logModulusPlotRange:self.xRange, plotCoordinateValue:CGFloat(plotPoint[CPTCoordinate.x.rawValue]))
            break;
            
        default:
            print("[NSException raise:CPTException format:@ Scale type not supported in CPTXYPlotSpace")
        }
        
        switch ( self.yScaleType ) {
        case CPTScaleType.linear:
            fallthrough
        case CPTScaleType.category:
            viewPoint.y = self.viewCoordinateForViewLength(viewLength: layerSize.height, linearPlotRange:self.yRange, plotCoordinateValue:CGFloat(plotPoint[CPTCoordinate.y.rawValue]))
            break;
            
        case CPTScaleType.log:
            viewPoint.y = self.viewCoordinateForViewLength(viewLength: layerSize.height, logPlotRange:self.yRange, plotCoordinateValue:CGFloat(plotPoint[CPTCoordinate.y.rawValue]))
            break;
            
        case CPTScaleType.logModulus:
            viewPoint.y = self.viewCoordinateForViewLength(viewLength: layerSize.height, logModulusPlotRange:self.yRange, plotCoordinateValue:CGFloat(plotPoint[CPTCoordinate.y.rawValue]))
            break;
            
        default:
            print("[NSException raise:CPTException format:@Scale type not supported in CPTXYPlotSpace")
        }
        
        return viewPoint;
    }
    
        // Plot point for view point
    override func plotPointForPlotAreaViewPoint(point : CGPoint)-> CPTNumberArray
    {
        var plotPoint = super.plotPointForPlotAreaViewPoint(point: point)
        
        var boundsSize = CGSize()
        let theGraph    = self.graph;
        let plotArea = theGraph?.plotAreaFrame.plotArea;
        
        if (plotArea  != nil) {
            boundsSize = plotArea!.bounds.size;
        }
        else {
            return [0, 0]
        }
        
        if ( (plotPoint == nil) ) {
            plotPoint = [ CGFloat]()
        }
        
        switch ( self.xScaleType ) {
        case .linear:
            fallthrough
        case .category:
            plotPoint?[CPTCoordinate.x.rawValue] = CGFloat(
                self.plotCoordinateForViewLength(
                    viewLength:         point.x,
                    linearPlotRange:    self.xRange,
                    boundsLength:       plotArea!.widthDecimal))
            
        case .log:
            plotPoint?[CPTCoordinate.x.rawValue] = self.doublePrecisionPlotCoordinateForViewLength(
                        viewLength: point.x,
                        logPlotRange:self.xRange,
                        boundsLength:boundsSize.width)
                
                case .logModulus:
                    plotPoint?[CPTCoordinate.x.rawValue] = self.doublePrecisionPlotCoordinateForViewLength(
                        viewLength: point.x,
                        logModulusPlotRange:self.xRange,
                        boundsLength:boundsSize.width);
                
                default:
                print("NSException raise:CPTException format:@Scale type not supported in CPTXYPlotSpace")
        }
        
        switch ( self.yScaleType ) {
        case .linear:
            fallthrough
        case .category:
            plotPoint?[CPTCoordinate.y.rawValue] =
                CGFloat(
                    
                    self.plotCoordinateForViewLength(
                        viewLength      : CGFloat(point.y),
                        linearPlotRange : self.yRange,
                        boundsLength    : plotArea!.heightDecimal))
    
            
        case .log:
            plotPoint?[CPTCoordinate.y.rawValue] =
                self.doublePrecisionPlotCoordinateForViewLength(
                    viewLength: point.y,
                    logPlotRange:self.yRange,
                    boundsLength:boundsSize.height);
            break;
            
        case .logModulus:
            plotPoint?[CPTCoordinate.y.rawValue] =
                self.doublePrecisionPlotCoordinateForViewLength(
                    viewLength: point.y,
                    logModulusPlotRange:self.yRange,
                    boundsLength:boundsSize.height)
            break;
            
        default:
            print("NSException raise:CPTException format:Scale type not supported in CPTXYPlotSpace")
        }
        return plotPoint!;
    }
    
    
    func plotPoint(plotPoint: CGFloat, numberOfCoordinatescount : Int, forPlotAreaViewPoint point:CGPoint)
    {
    }
    
    override func plotPoint(plotPoint: [CGFloat], numberOfCoordinates count:Int, forPlotAreaViewPoint point: CGPoint)
    {
        super.plotPoint(plotPoint: plotPoint, numberOfCoordinates:count, forPlotAreaViewPoint:point)
        
        var plotPoint = plotPoint
        var  boundsSize = CGSize()
        let theGraph    = self.graph;
        let plotArea = theGraph?.plotAreaFrame.plotArea;
        
        if plotArea  != nil {
            boundsSize = (plotArea?.bounds.size)!;
        }
        else {
            let zero = CGFloat(0)
            plotPoint[CPTCoordinate.x.rawValue] = zero
            plotPoint[CPTCoordinate.y.rawValue] = zero
            return;
        }
        
        switch ( self.xScaleType ) {
        case .linear:
            fallthrough
        case .category:
            plotPoint[CPTCoordinate.x.rawValue] = self.plotCoordinateForViewLength(
                viewLength: CGFloat(point.x),
                linearPlotRange:self.xRange,
                boundsLength:plotArea!.widthDecimal)
            
        case .log:
            plotPoint[CPTCoordinate.x.rawValue] = CGFloat(self.doublePrecisionPlotCoordinateForViewLength(
                                                            viewLength: point.x,
                                                            logPlotRange:self.xRange,
                                                            boundsLength:boundsSize.width))
            
        case .logModulus:
            plotPoint[CPTCoordinate.x.rawValue] = CGFloat(self.doublePrecisionPlotCoordinateForViewLength(
                                                            viewLength: point.x,
                                                            logModulusPlotRange:self.xRange,
                                                            boundsLength:boundsSize.width))
            
        default:
            print("NSException raise:CPTException format:@Scale type not supported in CPTXYPlotSpace : ", #function )
        }
        
        switch ( self.yScaleType ) {
        case .linear:
            fallthrough
        case .category:
            plotPoint[CPTCoordinate.y.rawValue] = self.plotCoordinateForViewLength(
                viewLength: CGFloat(point.y),
                linearPlotRange: self.yRange,
                boundsLength: plotArea!.heightDecimal)
            
        case .log:
            plotPoint[CPTCoordinate.y.rawValue] = self.doublePrecisionPlotCoordinateForViewLength(
                viewLength: point.y,
                logPlotRange:self.yRange,
                boundsLength:boundsSize.height)
            
        case .logModulus:
            plotPoint[CPTCoordinate.y.rawValue] = CGFloat(self.doublePrecisionPlotCoordinateForViewLength(
                                                            viewLength: point.y,
                                                            logModulusPlotRange:self.yRange,
                                                            boundsLength:boundsSize.height))
            
        default:
            print("NSException raise:CPTException format:@Scale type not supported in CPTXYPlotSpace : ", #function )
        }
    }

//        -(void)doublePrecisionPlotPoint:(nonnull double *)plotPoint numberOfCoordinates:(NSUInteger)count forPlotAreaViewPoint:(CGPoint)point
//        {
//            [super doublePrecisionPlotPoint:plotPoint numberOfCoordinates:count forPlotAreaViewPoint:point];
//
//            CGSize boundsSize;
//            CPTGraph *theGraph    = self.graph;
//            CPTPlotArea *plotArea = theGraph.plotAreaFrame.plotArea;
//
//            if ( plotArea ) {
//                boundsSize = plotArea.bounds.size;
//            }
//            else {
//                plotPoint[CPTCoordinateX] = 0.0;
//                plotPoint[CPTCoordinateY] = 0.0;
//                return;
//            }
//
//            switch ( self.xScaleType ) {
//                case CPTScaleTypeLinear:
//                case CPTScaleTypeCategory:
//                    plotPoint[CPTCoordinateX] = [self.doublePrecisionPlotCoordinateForViewLength:point.x linearPlotRange:self.xRange boundsLength:boundsSize.width];
//                    break;
//
//                case CPTScaleTypeLog:
//                    plotPoint[CPTCoordinateX] = [self.doublePrecisionPlotCoordinateForViewLength:point.x logPlotRange:self.xRange boundsLength:boundsSize.width];
//                    break;
//
//                case CPTScaleTypeLogModulus:
//                    plotPoint[CPTCoordinateX] = [self.doublePrecisionPlotCoordinateForViewLength:point.x logModulusPlotRange:self.xRange boundsLength:boundsSize.width];
//                    break;
//
//                default:
//                    [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
//            }
//
//            switch ( self.yScaleType ) {
//                case CPTScaleTypeLinear:
//                case CPTScaleTypeCategory:
//                    plotPoint[CPTCoordinateY] = [self.doublePrecisionPlotCoordinateForViewLength:point.y linearPlotRange:self.yRange boundsLength:boundsSize.height];
//                    break;
//
//                case CPTScaleTypeLog:
//                    plotPoint[CPTCoordinateY] = [self.doublePrecisionPlotCoordinateForViewLength:point.y logPlotRange:self.yRange boundsLength:boundsSize.height];
//                    break;
//
//                case CPTScaleTypeLogModulus:
//                    plotPoint[CPTCoordinateY] = [self.doublePrecisionPlotCoordinateForViewLength:point.y logModulusPlotRange:self.yRange boundsLength:boundsSize.height];
//                    break;
//
//                default:
//                    [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
//            }
//        }
//    //
    
    
        // Plot area view point for event
    func plotAreaViewPoint(for event: CPTNativeEvent) -> CGPoint {
        
        var plotAreaViewPoint = CGPoint()
        
        let theGraph                  = self.graph;
        let theHostingView = theGraph?.hostingView
        let thePlotArea    = theGraph?.plotAreaFrame.plotArea
        
        if ( (theHostingView != nil) && (thePlotArea != nil) ) {
            #if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
            let interactionPoint = event.touchesForView(theHostingView, locationInView:theHostingView)
            if ( theHostingView.collapsesLayers ) {
                interactionPoint.y = theHostingView.frame.size.height - interactionPoint.y;
                plotAreaViewPoint  = theGraph.convert(interactionPoint, to:thePlotArea)
            }
            else {
                plotAreaViewPoint = theHostingView.layer.convert(nteractionPoint, to:thePlotArea)
            }
            #else
            let interactionPoint = NSPointToCGPoint((theHostingView?.convert(event.locationInWindow, from:nil))!)
            plotAreaViewPoint = (theHostingView?.layer?.convert(interactionPoint, to:thePlotArea))!
            #endif
        }
        
        return plotAreaViewPoint
    }
    
        // Plot point for event
    override func plotPointForEvent(event: CPTNativeEvent ) -> CPTNumberArray
    {
        return self.plotPointForPlotAreaViewPoint(point: self.plotAreaViewPointForEvent(event: event))
    }
    
    override func plotPoint(plotPoint: CGFloat, numberOfCoordinates count: Int, forEvent event: CPTNativeEvent)
    {
        self.plotPoint(plotPoint: plotPoint, numberOfCoordinates:count, forPlotAreaViewPoint: self.plotAreaViewPointForEvent(event: event))
    }
    
    override func doublePrecisionPlotPoint(plotPoint: Double, numberOfCoordinates count: Int, forEvent event: CPTNativeEvent)
    {
        self.doublePrecisionPlotPoint(plotPoint, numberOfCoordinates:count, forPlotAreaViewPoint: self.plotAreaViewPointForEvent(event: event))
    }


    // MARK: - Scaling
    //    -(void)scaleBy:(CGFloat)interactionScale aboutPoint:(CGPoint)plotAreaPoint
    //    {
    //        CPTGraph *theGraph    = self.graph;
    //        CPTPlotArea *plotArea = theGraph.plotAreaFrame.plotArea;
    //
    //        if ( !plotArea || (interactionScale <= CGFloat(1.e-6))) {
    //            return;
    //        }
    //        if ( ![plotArea containsPoint:plotAreaPoint] ) {
    //            return;
    //        }
    //
    //        // Ask the delegate if it is OK
    //        id<CPTPlotSpaceDelegate> theDelegate = self.delegate;
    //
    //        BOOL shouldScale = YES;
    //
    //        if ( [theDelegate respondsToSelector:@selector(plotSpace:shouldScaleBy:aboutPoint:)] ) {
    //            shouldScale = [theDelegate plotSpace:self.shouldScaleBy:interactionScale aboutPoint:plotAreaPoint];
    //        }
    //        if ( !shouldScale ) {
    //            return;
    //        }
    //
    //        // Determine point in plot coordinates
    //        NSDecimal const decimalScale = CPTDecimalFromCGFloat(interactionScale);
    //        NSDecimal plotInteractionPoint[2];
    //
    //        [self.plotPoint:plotInteractionPoint numberOfCoordinates:2 forPlotAreaViewPoint:plotAreaPoint];
    //
    //        // Cache old ranges
    //        CPTPlotRange *oldRangeX = self.xRange;
    //        CPTPlotRange *oldRangeY = self.yRange;
    //
    //        // Lengths are scaled by the pinch gesture inverse proportional
    //        NSDecimal newLengthX = CPTDecimalDivide(oldRangeX.lengthDecimal, decimalScale);
    //        NSDecimal newLengthY = CPTDecimalDivide(oldRangeY.lengthDecimal, decimalScale);
    //
    //        // New locations
    //        NSDecimal newLocationX;
    //
    //        if ( CPTDecimalGreaterThanOrEqualTo(oldRangeX.lengthDecimal, CPTDecimalFromInteger(0))) {
    //            NSDecimal oldFirstLengthX = CPTDecimalSubtract(plotInteractionPoint[CPTCoordinateX], oldRangeX.minLimitDecimal); // x - minX
    //            NSDecimal newFirstLengthX = CPTDecimalDivide(oldFirstLengthX, decimalScale);                                     // (x - minX) / scale
    //            newLocationX = CPTDecimalSubtract(plotInteractionPoint[CPTCoordinateX], newFirstLengthX);
    //        }
    //        else {
    //            NSDecimal oldSecondLengthX = CPTDecimalSubtract(oldRangeX.maxLimitDecimal, plotInteractionPoint[0]); // maxX - x
    //            NSDecimal newSecondLengthX = CPTDecimalDivide(oldSecondLengthX, decimalScale);                       // (maxX - x) / scale
    //            newLocationX = CPTDecimalAdd(plotInteractionPoint[CPTCoordinateX], newSecondLengthX);
    //        }
    //
    //        NSDecimal newLocationY;
    //
    //        if ( CPTDecimalGreaterThanOrEqualTo(oldRangeY.lengthDecimal, CPTDecimalFromInteger(0))) {
    //            NSDecimal oldFirstLengthY = CPTDecimalSubtract(plotInteractionPoint[CPTCoordinateY], oldRangeY.minLimitDecimal); // y - minY
    //            NSDecimal newFirstLengthY = CPTDecimalDivide(oldFirstLengthY, decimalScale);                                     // (y - minY) / scale
    //            newLocationY = CPTDecimalSubtract(plotInteractionPoint[CPTCoordinateY], newFirstLengthY);
    //        }
    //        else {
    //            NSDecimal oldSecondLengthY = CPTDecimalSubtract(oldRangeY.maxLimitDecimal, plotInteractionPoint[1]); // maxY - y
    //            NSDecimal newSecondLengthY = CPTDecimalDivide(oldSecondLengthY, decimalScale);                       // (maxY - y) / scale
    //            newLocationY = CPTDecimalAdd(plotInteractionPoint[CPTCoordinateY], newSecondLengthY);
    //        }
    //
    //        // New ranges
    //        CPTPlotRange *newRangeX = [[CPTPlotRange alloc] initWithLocationDecimal:newLocationX lengthDecimal:newLengthX];
    //        CPTPlotRange *newRangeY = [[CPTPlotRange alloc] initWithLocationDecimal:newLocationY lengthDecimal:newLengthY];
    //
    //        BOOL oldMomentum = self.allowsMomentumX;
    //
    //        self.allowsMomentumX = false
    //        self.xRange          = newRangeX;
    //        self.allowsMomentumX = oldMomentum;
    //
    //        oldMomentum          = self.allowsMomentumY;
    //        self.allowsMomentumY = false
    //        self.yRange          = newRangeY;
    //        self.allowsMomentumY = oldMomentum;
    //    }


    // MARK: - Interaction


    //    /**
    //     *  @brief Informs the receiver that the user has
    //     *  @if MacOnly pressed the mouse button. @endif
    //     *  @if iOSOnly touched the screen. @endif
    //     *
    //     *
    //     *  If the receiver has a @ref delegate and the delegate handles the event,
    //     *  this method always returns @YES.
    //     *  If @ref allowsUserInteraction is @NO
    //     *  or the graph does not have a @link CPTPlotAreaFrame::plotArea plotArea @endlink layer,
    //     *  this method always returns @NO.
    //     *  Otherwise, if the @par{interactionPoint} is within the bounds of the
    //     *  @link CPTPlotAreaFrame::plotArea plotArea @endlink, a drag operation starts and
    //     *  this method returns @YES.
    //     *
    //     *  @param event The OS event.
    //     *  @param interactionPoint The coordinates of the interaction.
    //     *  @return Whether the event was handled or not.
    //     **/
    //    -(BOOL)pointingDeviceDownEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
    //    {
    //        self.isDragging = false
    //
    //        BOOL handledByDelegate = [super pointingDeviceDownEvent:event atPoint:interactionPoint];
    //
    //        if ( handledByDelegate ) {
    //            return YES;
    //        }
    //
    //        CPTGraph *theGraph    = self.graph;
    //        CPTPlotArea *plotArea = theGraph.plotAreaFrame.plotArea;
    //
    //        if ( !self.allowsUserInteraction || !plotArea ) {
    //            return false
    //        }
    //
    //        CGPoint pointInPlotArea = [theGraph convertPoint:interactionPoint toLayer:plotArea];
    //
    //        if ( [plotArea containsPoint:pointInPlotArea] ) {
    //            // Handle event
    //            self.lastDragPoint    = pointInPlotArea;
    //            self.lastDisplacement = CGPointZero;
    //            self.lastDragTime     = event.timestamp;
    //            self.lastDeltaTime    = 0.0;
    //
    //            // Clear any previous animations
    //            CPTMutableAnimationArray *animationArray = self.animations;
    //            for ( CPTAnimationOperation *op in animationArray ) {
    //                [[CPTAnimation sharedInstance] removeAnimationOperation:op];
    //            }
    //            [animationArray removeAllObjects];
    //
    //            return YES;
    //        }
    //
    //        return false
    //    }
    //
    //    /**
    //     *  @brief Informs the receiver that the user has
    //     *  @if MacOnly released the mouse button. @endif
    //     *  @if iOSOnly lifted their finger off the screen. @endif
    //     *
    //     *
    //     *  If the receiver has a @ref delegate and the delegate handles the event,
    //     *  this method always returns @YES.
    //     *  If @ref allowsUserInteraction is @NO
    //     *  or the graph does not have a @link CPTPlotAreaFrame::plotArea plotArea @endlink layer,
    //     *  this method always returns @NO.
    //     *  Otherwise, if a drag operation is in progress, it ends and
    //     *  this method returns @YES.
    //     *
    //     *  @param event The OS event.
    //     *  @param interactionPoint The coordinates of the interaction.
    //     *  @return Whether the event was handled or not.
    //     **/
    //    -(BOOL)pointingDeviceUpEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
    //    {
    //        BOOL handledByDelegate = [super pointingDeviceUpEvent:event atPoint:interactionPoint];
    //
    //        if ( handledByDelegate ) {
    //            return YES;
    //        }
    //
    //        CPTGraph *theGraph    = self.graph;
    //        CPTPlotArea *plotArea = theGraph.plotAreaFrame.plotArea;
    //
    //        if ( !self.allowsUserInteraction || !plotArea ) {
    //            return false
    //        }
    //
    //        if ( self.isDragging ) {
    //            self.isDragging = false
    //
    //            CGFloat acceleration = CGFloat(0.0);
    //            CGFloat speed        = CGFloat(0.0);
    //            CGFloat momentumTime = CGFloat(0.0);
    //
    //            NSDecimal shiftX = CPTDecimalFromInteger(0);
    //            NSDecimal shiftY = CPTDecimalFromInteger(0);
    //
    //            CGFloat scaleX = CGFloat(0.0);
    //            CGFloat scaleY = CGFloat(0.0);
    //
    //            if ( self.allowsMomentum ) {
    //                NSTimeInterval deltaT     = event.timestamp - self.lastDragTime;
    //                NSTimeInterval lastDeltaT = self.lastDeltaTime;
    //
    //                if ((deltaT > 0.0) && (deltaT < 0.05) && (lastDeltaT > 0.0)) {
    //                    CGPoint pointInPlotArea = [theGraph convertPoint:interactionPoint toLayer:plotArea];
    //                    CGPoint displacement    = self.lastDisplacement;
    //
    //                    acceleration = self.momentumAcceleration;
    //                    speed        = sqrt(displacement.x * displacement.x + displacement.y * displacement.y) / CGFloat(lastDeltaT);
    //                    momentumTime = speed / (CGFloat(2.0) * acceleration);
    //                    CGFloat distanceTraveled = speed * momentumTime - CGFloat(0.5) * acceleration * momentumTime * momentumTime;
    //                    distanceTraveled = MAX(distanceTraveled, CGFloat(0.0));
    //
    //                    CGFloat theta = atan2(displacement.y, displacement.x);
    //                    scaleX = cos(theta);
    //                    scaleY = sin(theta);
    //
    //                    NSDecimal lastPoint[2], newPoint[2];
    //                    [self.plotPoint:lastPoint numberOfCoordinates:2 forPlotAreaViewPoint:pointInPlotArea];
    //                    [self.plotPoint:newPoint numberOfCoordinates:2 forPlotAreaViewPoint:CGPointMake(pointInPlotArea.x + distanceTraveled * scaleX,
    //                                                                                                    pointInPlotArea.y + distanceTraveled * scaleY)];
    //
    //                    if ( self.allowsMomentumX ) {
    //                        shiftX = CPTDecimalSubtract(lastPoint[CPTCoordinateX], newPoint[CPTCoordinateX]);
    //                    }
    //                    if ( self.allowsMomentumY ) {
    //                        shiftY = CPTDecimalSubtract(lastPoint[CPTCoordinateY], newPoint[CPTCoordinateY]);
    //                    }
    //                }
    //            }
    //
    //            // X range
    //            [self.animateRangeForCoordinate:CPTCoordinateX
    //                                      shift:shiftX
    //                               momentumTime:momentumTime
    //                                      speed:speed * scaleX
    //                               acceleration:acceleration * scaleX];
    //
    //            // Y range
    //            [self.animateRangeForCoordinate:CPTCoordinateY
    //                                      shift:shiftY
    //                               momentumTime:momentumTime
    //                                      speed:speed * scaleY
    //                               acceleration:acceleration * scaleY];
    //
    //            return YES;
    //        }
    //
    //        return false
    //    }
    //
    //    /**
    //     *  @brief Informs the receiver that the user has moved
    //     *  @if MacOnly the mouse with the button pressed. @endif
    //     *  @if iOSOnly their finger while touching the screen. @endif
    //     *
    //     *
    //     *  If the receiver has a @ref delegate and the delegate handles the event,
    //     *  this method always returns @YES.
    //     *  If @ref allowsUserInteraction is @NO
    //     *  or the graph does not have a @link CPTPlotAreaFrame::plotArea plotArea @endlink layer,
    //     *  this method always returns @NO.
    //     *  Otherwise, if a drag operation commences or is in progress, the @ref xRange
    //     *  and @ref yRange are shifted to follow the drag and
    //     *  this method returns @YES.
    //     *
    //     *  @param event The OS event.
    //     *  @param interactionPoint The coordinates of the interaction.
    //     *  @return Whether the event was handled or not.
    //     **/
    //    -(BOOL)pointingDeviceDraggedEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
    //    {
    //        BOOL handledByDelegate = [super pointingDeviceDraggedEvent:event atPoint:interactionPoint];
    //
    //        if ( handledByDelegate ) {
    //            return YES;
    //        }
    //
    //        CPTGraph *theGraph    = self.graph;
    //        CPTPlotArea *plotArea = theGraph.plotAreaFrame.plotArea;
    //
    //        if ( !self.allowsUserInteraction || !plotArea ) {
    //            return false
    //        }
    //
    //        CGPoint lastDraggedPoint = self.lastDragPoint;
    //        CGPoint pointInPlotArea  = [theGraph convertPoint:interactionPoint toLayer:plotArea];
    //        CGPoint displacement     = CPTPointMake(pointInPlotArea.x - lastDraggedPoint.x, pointInPlotArea.y - lastDraggedPoint.y);
    //
    //        if ( !self.isDragging ) {
    //            // Have we started dragging, i.e., has the interactionPoint moved sufficiently to indicate a drag has started?
    //            CGFloat displacedBy = sqrt(displacement.x * displacement.x + displacement.y * displacement.y);
    //            self.isDragging = (displacedBy > self.minimumDisplacementToDrag);
    //        }
    //
    //        if ( self.isDragging ) {
    //            CGPoint pointToUse = pointInPlotArea;
    //
    //            id<CPTPlotSpaceDelegate> theDelegate = self.delegate;
    //
    //            // Allow delegate to override
    //            if ( [theDelegate respondsToSelector:@selector(plotSpace:willDisplaceBy:)] ) {
    //                displacement = [theDelegate plotSpace:self.willDisplaceBy:displacement];
    //                pointToUse   = CPTPointMake(lastDraggedPoint.x + displacement.x, lastDraggedPoint.y + displacement.y);
    //            }
    //
    //            NSDecimal lastPoint[2], newPoint[2];
    //            [self.plotPoint:lastPoint numberOfCoordinates:2 forPlotAreaViewPoint:lastDraggedPoint];
    //            [self.plotPoint:newPoint numberOfCoordinates:2 forPlotAreaViewPoint:pointToUse];
    //
    //            // X range
    //            NSDecimal shiftX        = CPTDecimalSubtract(lastPoint[CPTCoordinateX], newPoint[CPTCoordinateX]);
    //            CPTPlotRange *newRangeX = [self.shiftRange:self.xRange
    //                                                    by:shiftX
    //                                         usingMomentum:self.allowsMomentumX
    //                                         inGlobalRange:self.globalXRange
    //                                      withDisplacement:&displacement.x];
    //
    //            // Y range
    //            NSDecimal shiftY        = CPTDecimalSubtract(lastPoint[CPTCoordinateY], newPoint[CPTCoordinateY]);
    //            CPTPlotRange *newRangeY = [self.shiftRange:self.yRange
    //                                                    by:shiftY
    //                                         usingMomentum:self.allowsMomentumY
    //                                         inGlobalRange:self.globalYRange
    //                                      withDisplacement:&displacement.y];
    //
    //            self.lastDragPoint    = pointInPlotArea;
    //            self.lastDisplacement = displacement;
    //
    //            NSTimeInterval currentTime = event.timestamp;
    //            self.lastDeltaTime = currentTime - self.lastDragTime;
    //            self.lastDragTime  = currentTime;
    //
    //            self.xRange = newRangeX;
    //            self.yRange = newRangeY;
    //
    //            return YES;
    //        }
    //
    //        return false
    //    }


    func shiftRange(oldRange: CPTPlotRange, by shift: CGFloat,  usingMomentum momentum:Bool, inGlobalRange globalRange: CPTPlotRange?, withDisplacement displacement :CGFloat ) -> CPTPlotRange
    {
        var newRange = oldRange
        var displacement = displacement
        
        newRange.locationDecimal = newRange.locationDecimal + shift
        
        if (( globalRange ) != nil) {
            let constrainedRange = self.constrainRange(existingRange: newRange, toGlobalRange:globalRange)
            
            if ( momentum ) {
                if  newRange.isEqualToRange(otherRange: constrainedRange ) == false {
                    // reduce the shift as we get farther outside the global range
                    let rangeLength = newRange.lengthDecimal;
                    
                    if rangeLength != CGFloat(0) {
                        var diff = ( constrainedRange!.locationDecimal -  newRange.locationDecimal) / rangeLength
                        
                        
                        diff = max(min(diff * CGFloat(2.5), CGFloat(1)), CGFloat(-1))
                        
                        newRange.locationDecimal = newRange.locationDecimal - (shift * abs(diff))
                        
                        displacement = displacement * (CGFloat(1.0) - abs(CGFloat(diff)))
                    }
                }
            }
            else {
                newRange = constrainedRange!;
            }
        }
        
        return newRange;
    }
    
    //    /// @endcond
    //
        #if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
        #else
    //
    //    /**
    //     *  @brief Informs the receiver that the user has moved the scroll wheel.
    //     *
    //     *
    //     *  If the receiver does not have a @ref delegate,
    //     *  this method always returns @NO. Otherwise, the
    //     *  @link CPTPlotSpaceDelegate::plotSpace:shouldHandleScrollWheelEvent:fromPoint:toPoint: -plotSpace:shouldHandleScrollWheelEvent:fromPoint:toPoint: @endlink
    //     *  delegate method is called. If it returns @NO, this method returns @YES
    //     *  to indicate that the event has been handled and no further processing should occur.
    //     *
    //     *  @param event The OS event.
    //     *  @param fromPoint The starting coordinates of the interaction.
    //     *  @param toPoint The ending coordinates of the interaction.
    //     *  @return Whether the event was handled or not.
    //     **/
    //    -(BOOL)scrollWheelEvent:(nonnull CPTNativeEvent *)event fromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint
    //    {
    //        BOOL handledByDelegate = [super scrollWheelEvent:event fromPoint:fromPoint toPoint:toPoint];
    //
    //        if ( handledByDelegate ) {
    //            return YES;
    //        }
    //
    //        CPTGraph *theGraph    = self.graph;
    //        CPTPlotArea *plotArea = theGraph.plotAreaFrame.plotArea;
    //
    //        if ( !self.allowsUserInteraction || !plotArea ) {
    //            return false
    //        }
    //
    //        CGPoint fromPointInPlotArea = [theGraph convertPoint:fromPoint toLayer:plotArea];
    //        CGPoint toPointInPlotArea   = [theGraph convertPoint:toPoint toLayer:plotArea];
    //        CGPoint displacement        = CPTPointMake(toPointInPlotArea.x - fromPointInPlotArea.x, toPointInPlotArea.y - fromPointInPlotArea.y);
    //        CGPoint pointToUse          = toPointInPlotArea;
    //
    //        id<CPTPlotSpaceDelegate> theDelegate = self.delegate;
    //
    //        // Allow delegate to override
    //        if ( [theDelegate respondsToSelector:@selector(plotSpace:willDisplaceBy:)] ) {
    //            displacement = [theDelegate plotSpace:self.willDisplaceBy:displacement];
    //            pointToUse   = CPTPointMake(fromPointInPlotArea.x + displacement.x, fromPointInPlotArea.y + displacement.y);
    //        }
    //
    //        NSDecimal lastPoint[2], newPoint[2];
    //
    //        [self.plotPoint:lastPoint numberOfCoordinates:2 forPlotAreaViewPoint:fromPointInPlotArea];
    //        [self.plotPoint:newPoint numberOfCoordinates:2 forPlotAreaViewPoint:pointToUse];
    //
    //        // X range
    //        NSDecimal shiftX        = CPTDecimalSubtract(lastPoint[CPTCoordinateX], newPoint[CPTCoordinateX]);
    //        CPTPlotRange *newRangeX = [self.shiftRange:self.xRange
    //                                                by:shiftX
    //                                     usingMomentum:NO
    //                                     inGlobalRange:self.globalXRange
    //                                  withDisplacement:&displacement.x];
    //
    //        // Y range
    //        NSDecimal shiftY        = CPTDecimalSubtract(lastPoint[CPTCoordinateY], newPoint[CPTCoordinateY]);
    //        CPTPlotRange *newRangeY = [self.shiftRange:self.yRange
    //                                                by:shiftY
    //                                     usingMomentum:NO
    //                                     inGlobalRange:self.globalYRange
    //                                  withDisplacement:&displacement.y];
    //
    //        self.xRange = newRangeX;
    //        self.yRange = newRangeY;
    //
    //        return YES;
    //    }
    //
        #endif
    //
        /**
         *  @brief Reset the dragging state and cancel any active animations.
         **/
        func cancelAnimations()
        {
            self.isDragging = false
            for op in self.animations  {
                CPTAnimation.shared.removeAnimationOperation(animationOperation: op)
            }
        }

    // MARK: -  Accessors


    //    -(void)setAllowsMomentum:(BOOL)newMomentum
    //    {
    //        self.allowsMomentumX = newMomentum;
    //        self.allowsMomentumY = newMomentum;
    //    }
    //
    //    -(BOOL)allowsMomentum
    //    {
    //        return self.allowsMomentumX || self.allowsMomentumY;
    //    }
    //
    // MARK: - Animation Delegate
    //
    //    /// @cond
    //
    //    -(void)animationDidFinish:(nonnull CPTAnimationOperation *)operation
    //    {
    //        [self.animations removeObjectIdenticalTo:operation];
    //    }
    //
    //    /// @endcond
    //
    // MARK: -  Debugging
    //
    //    /// @cond
    //
    //    -(nullable id)debugQuickLookObject
    //    {
    //        // Plot space
    //        NSString *plotAreaDesc = [super debugQuickLookObject];
    //
    //        // X-range
    //        NSString *xScaleTypeDesc = nil;
    //
    //        switch ( self.xScaleType ) {
    //            case CPTScaleTypeLinear:
    //                xScaleTypeDesc = @"CPTScaleTypeLinear";
    //                break;
    //
    //            case CPTScaleTypeLog:
    //                xScaleTypeDesc = @"CPTScaleTypeLog";
    //                break;
    //
    //            case CPTScaleTypeLogModulus:
    //                xScaleTypeDesc = @"CPTScaleTypeLogModulus";
    //                break;
    //
    //            case CPTScaleTypeAngular:
    //                xScaleTypeDesc = @"CPTScaleTypeAngular";
    //                break;
    //
    //            case CPTScaleTypeDateTime:
    //                xScaleTypeDesc = @"CPTScaleTypeDateTime";
    //                break;
    //
    //            case CPTScaleTypeCategory:
    //                xScaleTypeDesc = @"CPTScaleTypeCategory";
    //                break;
    //        }
    //
    //        NSString *xRangeDesc = [NSString stringWithFormat:@"xRange:\n%@\nglobalXRange:\n%@\nxScaleType: %@",
    //                                [self.xRange debugQuickLookObject],
    //                                [self.globalXRange debugQuickLookObject],
    //                                xScaleTypeDesc];
    //
    //        // Y-range
    //        NSString *yScaleTypeDesc = nil;
    //
    //        switch ( self.yScaleType ) {
    //            case CPTScaleTypeLinear:
    //                yScaleTypeDesc = @"CPTScaleTypeLinear";
    //                break;
    //
    //            case CPTScaleTypeLog:
    //                yScaleTypeDesc = @"CPTScaleTypeLog";
    //                break;
    //
    //            case CPTScaleTypeLogModulus:
    //                yScaleTypeDesc = @"CPTScaleTypeLogModulus";
    //                break;
    //
    //            case CPTScaleTypeAngular:
    //                yScaleTypeDesc = @"CPTScaleTypeAngular";
    //                break;
    //
    //            case CPTScaleTypeDateTime:
    //                yScaleTypeDesc = @"CPTScaleTypeDateTime";
    //                break;
    //
    //            case CPTScaleTypeCategory:
    //                yScaleTypeDesc = @"CPTScaleTypeCategory";
    //                break;
    //        }
    //
    //        NSString *yRangeDesc = [NSString stringWithFormat:@"yRange:\n%@\nglobalYRange:\n%@\nyScaleType: %@",
    //                                [self.yRange debugQuickLookObject],
    //                                [self.globalYRange debugQuickLookObject],
    //                                yScaleTypeDesc];
    //
    //        return [NSString stringWithFormat:@"%@\n\nX:\n%@\n\nY:\n%@", plotAreaDesc, xRangeDesc, yRangeDesc];
    //    }

    
}
