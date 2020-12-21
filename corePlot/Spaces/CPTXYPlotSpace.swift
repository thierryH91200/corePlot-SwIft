//
//  CPTXYPlotSpace.swift
//  corePlot
//
//  Created by thierryH24 on 14/11/2020.
//

import AppKit

class CPTXYPlotSpace: CPTPlotSpace {
    
    var xRange: CPTPlotRange;
    var yRange: CPTPlotRange;
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
    
    func plotRange(for coordinate: CPTCoordinate) -> CPTPlotRange? {
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
    
    func setScaleType(_ newType: CPTScaleType, for coordinate: CPTCoordinate) {
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
    
    
    func setXRange(range: CPTPlotRange )
    {
        if  range.isEqual(to: xRange)  == false {
            var constrainedRange = CPTPlotRange(location: 0, length: 0)
            
            if self.allowsMomentumX == true {
                constrainedRange = range
            }
            else {
                constrainedRange = self.constrainRange(existingRange: range ,toGlobalRange: self.globalXRange!)!
            }
            
            let theDelegate = self.delegate;
            
            if ( theDelegate.respondsToSelector(to:#selector(to: plotSpace:willChangePlotRangeTo:forCoordinate:) ) {
                constrainedRange = theDelegate.plotSpace(self, willChangePlotRangeTo:constrainedRange, forCoordinate:CPTCoordinate.x)
            }
            
            if constrainedRange.isEqualToRange(xRange )  == false {
                var displacement = self.lastDisplacement.x;
                var isScrolling     = false
                
                if ( xRange && constrainedRange ) {
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
                
                xRange = constrainedRange
                
                var userInfo  =   [String: Any]()
                userInfo[CPTPlotSpaceCoordinateKey] = CPTCoordinate.x.rawValue
                userInfo[CPTPlotSpaceScrollingKey] = isScrolling
                userInfo[CPTPlotSpaceDisplacementKey] = displacement
                NotificationCenter.send(
                    name:     .CPTPlotSpaceCoordinateMappingDidChangeNotification,
                    object:   self,
                    userInfo: userInfo )
                
                
                if ( theDelegate.respondsToSelector(to: #selector(plotSpace.didChangePlotRangeForCoordinate:))) {
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

    //
    func setYRange(range: CPTPlotRange )
    {
        if  range.isEqual(yRange )   == false{
            var  constrainedRange = CPTPlotRange(location: 0, length: 0)
            
            if ( self.allowsMomentumY ) {
                constrainedRange = range;
            }
            else {
                constrainedRange = self.constrainRange(existingRange: range, toGlobalRange:self.globalYRange!)!
            }
            
            let theDelegate = self.delegate;
            if ( theDelegate.respondsToSelector( to: #selector( plotSpace.willChangePlotRangeForCoordinate:))) {
                constrainedRange = (theDelegate?.plotSpace(space: self, newRange:constrainedRange, coordinate:CPTCoordinate.y))!
            }
            
            if constrainedRange.isEqualToRange(yRange ) == false  {
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
                
                yRange = constrainedRange
                
                var userInfo  =   [String: Any]()
                userInfo[CPTPlotSpaceCoordinateKey] = CPTCoordinate.y.rawValue
                userInfo[CPTPlotSpaceScrollingKey] = isScrolling
                userInfo[CPTPlotSpaceDisplacementKey] = displacement

                NotificationCenter.send(
                    name:.CPTPlotSpaceCoordinateMappingDidChangeNotification,
                    object:self,
                    userInfo:userInfo )
                
                if ( theDelegate.respondsToSelector(to: #selector( plotSpace.didChangePlotRangeForCoordinate:) ) {
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
                    
    func constrainRange(existingRange: CPTPlotRange?, toGlobalRange globalRange: CPTPlotRange?)-> CPTPlotRange?
    {
        if ( !globalRange ) {
            return existingRange;
        }
        if ( !existingRange ) {
            return nil;
        }
        
        let theGlobalRange = globalRange;
        
        if ( existingRange?.lengthDecimal >= theGlobalRange?.lengthDecimal) {
            return theGlobalRange
        }
        else {
            let newRange = existingRange
            newRange.shiftEndToFitInRange(theGlobalRange)
            newRange.shiftLocationToFitInRange(theGlobalRange)
            return newRange
        }
    }
    //
    //    -(void)animateRangeForCoordinate:(CPTCoordinate)coordinate shift:(NSDecimal)shift momentumTime:(CGFloat)momentumTime speed:(CGFloat)speed acceleration:(CGFloat)acceleration
    //    {
    //        CPTMutableAnimationArray *animationArray = self.animations;
    //        CPTAnimationOperation *op;
    //
    //        NSString *property        = nil;
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
    //            CPTPlotRange *constrainedRange = [self constrainRange:newRange toGlobalRange:globalRange];
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
    //                        CGFloat globalPoint = [self viewCoordinateForRange:globalRange coordinate:coordinate direction:direction];
    //                        CGFloat oldPoint    = [self viewCoordinateForRange:oldRange coordinate:coordinate direction:direction];
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
    //                            [self plotPoint:newPoint numberOfCoordinates:2 forPlotAreaViewPoint:brakingPoint];
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
    //                CGFloat newPoint         = [self viewCoordinateForRange:newRange coordinate:coordinate direction:!direction];
    //                CGFloat constrainedPoint = [self viewCoordinateForRange:constrainedRange coordinate:coordinate direction:!direction];
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
    //    -(CGFloat)viewCoordinateForRange:(nullable CPTPlotRange *)range coordinate:(CPTCoordinate)coordinate direction:(BOOL)direction
    //    {
    //        CPTCoordinate orthogonalCoordinate = CPTOrthogonalCoordinate(coordinate);
    //
    //        NSDecimal point[2];
    //
    //        point[coordinate]           = (direction ? range.maxLimitDecimal : range.minLimitDecimal);
    //        point[orthogonalCoordinate] = CPTDecimalFromInteger(1);
    //
    //        CGPoint viewPoint       = [self plotAreaViewPointForPlotPoint:point numberOfCoordinates:2];
    //        CGFloat pointCoordinate = CPTNAN;
    //
    //        switch ( coordinate ) {
    //            case CPTCoordinateX:
    //                pointCoordinate = viewPoint.x;
    //                break;
    //
    //            case CPTCoordinateY:
    //                pointCoordinate = viewPoint.y;
    //                break;
    //
    //            default:
    //                break;
    //        }
    //
    //        return pointCoordinate;
    //    }
    //
    //    // return NAN if no positive roots
    //    CGFloat CPTFirstPositiveRoot(CGFloat a, CGFloat b, CGFloat c)
    //    {
    //        CGFloat root = CPTNAN;
    //
    //        CGFloat discriminant = sqrt(b * b - CGFloat(4.0) * a * c);
    //
    //        CGFloat root1 = (-b + discriminant) / (CGFloat(2.0) * a);
    //        CGFloat root2 = (-b - discriminant) / (CGFloat(2.0) * a);
    //
    //        if ( !isnan(root1) && !isnan(root2)) {
    //            if ( root1 >= CGFloat(0.0)) {
    //                root = root1;
    //            }
    //            if ((root2 >= CGFloat(0.0)) && (isnan(root) || (root2 < root))) {
    //                root = root2;
    //            }
    //        }
    //
    //        return root;
    //    }
    //
    //    -(void)setGlobalXRange:(nullable CPTPlotRange *)newRange
    //    {
    //        if ( ![newRange isEqualToRange:globalXRange] ) {
    //            globalXRange = [newRange copy];
    //            self.xRange  = [self constrainRange:self.xRange toGlobalRange:globalXRange];
    //        }
    //    }
    //
    //    -(void)setGlobalYRange:(nullable CPTPlotRange *)newRange
    //    {
    //        if ( ![newRange isEqualToRange:globalYRange] ) {
    //            globalYRange = [newRange copy];
    //            self.yRange  = [self constrainRange:self.yRange toGlobalRange:globalYRange];
    //        }
    //    }
    //
    //    -(void)scaleToFitPlots:(nullable CPTPlotArray *)plots
    //    {
    //        if ( plots.count == 0 ) {
    //            return;
    //        }
    //
    //        // Determine union of ranges
    //        CPTMutablePlotRange *unionXRange = nil;
    //        CPTMutablePlotRange *unionYRange = nil;
    //
    //        for ( CPTPlot *plot in plots ) {
    //            CPTPlotRange *currentXRange = [plot plotRangeForCoordinate:CPTCoordinateX];
    //            CPTPlotRange *currentYRange = [plot plotRangeForCoordinate:CPTCoordinateY];
    //            if ( !unionXRange ) {
    //                unionXRange = [currentXRange mutableCopy];
    //            }
    //            if ( !unionYRange ) {
    //                unionYRange = [currentYRange mutableCopy];
    //            }
    //            [unionXRange unionPlotRange:currentXRange];
    //            [unionYRange unionPlotRange:currentYRange];
    //        }
    //
    //        // Set range
    //        NSDecimal zero = CPTDecimalFromInteger(0);
    //
    //        if ( unionXRange ) {
    //            if ( CPTDecimalEquals(unionXRange.lengthDecimal, zero)) {
    //                [unionXRange unionPlotRange:self.xRange];
    //            }
    //            self.xRange = unionXRange;
    //        }
    //        if ( unionYRange ) {
    //            if ( CPTDecimalEquals(unionYRange.lengthDecimal, zero)) {
    //                [unionYRange unionPlotRange:self.yRange];
    //            }
    //            self.yRange = unionYRange;
    //        }
    //    }
    //
    func scaleToFitEntirePlots(plots: [ CPTPlot] )
        {
            if ( plots.count == 0 ) {
                return;
            }
    
            // Determine union of ranges
            var unionXRange = [CPTPlotRange]()
            var unionYRange = [CPTPlotRange]()
    
            for  plot in plots {
                let currentXRange = plot.plotRangeEnclosingCoordinate(CPTCoordinate.x);
                let currentYRange = [plot plotRangeEnclosingCoordinate:CPTCoordinateY];
                if ( !unionXRange ) {
                    unionXRange = [currentXRange mutableCopy];
                }
                if ( !unionYRange ) {
                    unionYRange = [currentYRange mutableCopy];
                }
                [unionXRange unionPlotRange:currentXRange];
                [unionYRange unionPlotRange:currentYRange];
            }
    
            // Set range
            let zero = Int(0);
            if ( unionXRange ) {
                if  unionXRange.lengthDecimal == zero {
                    [unionXRange unionPlotRange:self.xRange];
                }
                self.xRange = unionXRange;
            }
            if ( unionYRange ) {
                if ( CPTDecimalEquals(unionYRange.lengthDecimal, zero)) {
                    [unionYRange unionPlotRange:self.yRange];
                }
                self.yRange = unionYRange;
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
    //
    
    
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

        return viewLength * (CGFloat)((logCoord - logLoc) / (CGFloat(logEnd) - logLoc));
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
    

    //    -(NSDecimal)plotCoordinateForViewLength:(NSDecimal)viewLength linearPlotRange:(nonnull CPTPlotRange *)range boundsLength:(NSDecimal)boundsLength
    //    {
    //        const NSDecimal zero = CPTDecimalFromInteger(0);
    //
    //        if ( CPTDecimalEquals(boundsLength, zero)) {
    //            return zero;
    //        }
    //
    //        NSDecimal location = range.locationDecimal;
    //        NSDecimal length   = range.lengthDecimal;
    //
    //        NSDecimal coordinate;
    //
    //        NSDecimalDivide(&coordinate, &viewLength, &boundsLength, NSRoundPlain);
    //        NSDecimalMultiply(&coordinate, &coordinate, &length, NSRoundPlain);
    //        NSDecimalAdd(&coordinate, &coordinate, &location, NSRoundPlain);
    //
    //        return coordinate;
    //    }
    //
    //    -(double)doublePrecisionPlotCoordinateForViewLength:(CGFloat)viewLength linearPlotRange:(nonnull CPTPlotRange *)range boundsLength:(CGFloat)boundsLength
    //    {
    //        if ( boundsLength == CGFloat(0.0)) {
    //            return 0.0;
    //        }
    //
    //        double coordinate = (double)viewLength / (double)boundsLength;
    //
    //        coordinate *= range.lengthDouble;
    //        coordinate += range.locationDouble;
    //
    //        return coordinate;
    //    }
    //
    //    -(double)doublePrecisionPlotCoordinateForViewLength:(CGFloat)viewLength logPlotRange:(nonnull CPTPlotRange *)range boundsLength:(CGFloat)boundsLength
    //    {
    //        if ( boundsLength == CGFloat(0.0)) {
    //            return 0.0;
    //        }
    //
    //        double logLoc = log10(range.locationDouble);
    //        double logEnd = log10(range.endDouble);
    //
    //        double coordinate = (double)viewLength * (logEnd - logLoc) / (double)boundsLength + logLoc;
    //
    //        return pow(10.0, coordinate);
    //    }
    //
    //
    //    -(double)doublePrecisionPlotCoordinateForViewLength:(CGFloat)viewLength logModulusPlotRange:(nonnull CPTPlotRange *)range boundsLength:(CGFloat)boundsLength
    //    {
    //        if ( boundsLength == CGFloat(0.0)) {
    //            return 0.0;
    //        }
    //
    //        double logLoc     = CPTLogModulus(range.locationDouble);
    //        double logEnd     = CPTLogModulus(range.endDouble);
    //        double coordinate = (double)viewLength * (logEnd - logLoc) / (double)boundsLength + logLoc;
    //
    //        return CPTInverseLogModulus(coordinate);
    //    }
    //
    // MARK: - Point Conversion
    override func numberOfCoordinates()-> Int
    {
        return 2
    }
                    //    // Plot area view point for plot point
    override func plotAreaViewPointForPlotPoint(plotPoint:  CPTNumberArray) -> CGPoint
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
        var viewPoint = super.plotAreaViewPointForPlotPoint(plotPoint: plotPoint, numberOfCoordinates: count)
        
        var layerSize = CGSize()
        let theGraph  = self.graph;
        let plotArea  = theGraph?.plotAreaFrame.plotArea
        
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
    
    //    -(CGPoint)plotAreaViewPointForDoublePrecisionPlotPoint:(nonnull double *)plotPoint numberOfCoordinates:(NSUInteger)count
    //    {
    //        CGPoint viewPoint = [super plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:count];
    //
    //        CGSize layerSize;
    //        CPTGraph *theGraph    = self.graph;
    //        CPTPlotArea *plotArea = theGraph.plotAreaFrame.plotArea;
    //
    //        if ( plotArea ) {
    //            layerSize = plotArea.bounds.size;
    //        }
    //        else {
    //            return viewPoint;
    //        }
    //
    //        switch ( self.xScaleType ) {
    //            case CPTScaleTypeLinear:
    //            case CPTScaleTypeCategory:
    //                viewPoint.x = [self viewCoordinateForViewLength:layerSize.width linearPlotRange:self.xRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateX]];
    //                break;
    //
    //            case CPTScaleTypeLog:
    //                viewPoint.x = [self viewCoordinateForViewLength:layerSize.width logPlotRange:self.xRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateX]];
    //                break;
    //
    //            case CPTScaleTypeLogModulus:
    //                viewPoint.x = [self viewCoordinateForViewLength:layerSize.width logModulusPlotRange:self.xRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateX]];
    //                break;
    //
    //            default:
    //                [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
    //        }
    //
    //        switch ( self.yScaleType ) {
    //            case CPTScaleTypeLinear:
    //            case CPTScaleTypeCategory:
    //                viewPoint.y = [self viewCoordinateForViewLength:layerSize.height linearPlotRange:self.yRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateY]];
    //                break;
    //
    //            case CPTScaleTypeLog:
    //                viewPoint.y = [self viewCoordinateForViewLength:layerSize.height logPlotRange:self.yRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateY]];
    //                break;
    //
    //            case CPTScaleTypeLogModulus:
    //                viewPoint.y = [self viewCoordinateForViewLength:layerSize.height logModulusPlotRange:self.yRange doublePrecisionPlotCoordinateValue:plotPoint[CPTCoordinateY]];
    //                break;
    //
    //            default:
    //                [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
    //        }
    //
    //        return viewPoint;
    //    }
    //
        // Plot point for view point
    override func plotPointForPlotAreaViewPoint(point : CGPoint)-> CPTNumberArray
    {
        var plotPoint = super.plotPointForPlotAreaViewPoint(point: point)
        
        var boundsSize = CGSize()
        let theGraph    = self.graph;
        let plotArea = theGraph?.plotAreaFrame.plotArea;
        
        if (( plotArea ) != nil) {
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
            plotPoint[CPTCoordinate.x.rawValue] = decimalNumberWithDecimal(
                self plotCoordinateForViewLength(
            (CPTDecimalFromCGFloat(point.x),
                linearPlotRange:self.xRange,
                boundsLength:plotArea.widthDecima)
                
                case .log:
                plotPoint[CPTCoordinateX] = @([self doublePrecisionPlotCoordinateForViewLength:point.x logPlotRange:self.xRange boundsLength:boundsSize.width]);
                break;
                
                case .logModulus:
                plotPoint[CPTCoordinateX] = @([self doublePrecisionPlotCoordinateForViewLength:point.x logModulusPlotRange:self.xRange boundsLength:boundsSize.width]);
                
                default:
                [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
        }
        
        switch ( self.yScaleType ) {
        case .linear:
            fallthrough
        case .category:
            plotPoint[CPTCoordinate.y.rawValue] =
                decimalNumberWithDecimal(
                    boundsSize,
                    self.plotCoordinateForViewLength(
                        CGFloat(point.y),
                         linearPlotRange:self.yRange,
                       boundsLength:plotArea.heightDecimal))
    
            
        case .log:
            plotPoint?[CPTCoordinate.y.rawValue] =
                self.doublePrecisionPlotCoordinateForViewLength(
                    point.y,
                    logPlotRange:self.yRange,
                    boundsLength:boundsSize.height);
            break;
            
        case .logModulus:
            plotPoint[CPTCoordinate.y.rawValue] =
                self.doublePrecisionPlotCoordinateForViewLength(
                    point.y,
                    logModulusPlotRange:self.yRange,
                    boundsLength:boundsSize.height)
            break;
            
        default:
            print("NSException raise:CPTException format:Scale type not supported in CPTXYPlotSpace")
        }
        return plotPoint!;
    }
    
//        -(void)plotPoint:(nonnull NSDecimal *)plotPoint numberOfCoordinates:(NSUInteger)count forPlotAreaViewPoint:(CGPoint)point
//        {
//            [super plotPoint:plotPoint numberOfCoordinates:count forPlotAreaViewPoint:point];
//
//            CGSize boundsSize;
//            CPTGraph *theGraph    = self.graph;
//            CPTPlotArea *plotArea = theGraph.plotAreaFrame.plotArea;
//
//            if ( plotArea ) {
//                boundsSize = plotArea.bounds.size;
//            }
//            else {
//                NSDecimal zero = CPTDecimalFromInteger(0);
//                plotPoint[CPTCoordinateX] = zero;
//                plotPoint[CPTCoordinateY] = zero;
//                return;
//            }
//
//            switch ( self.xScaleType ) {
//                case CPTScaleTypeLinear:
//                case CPTScaleTypeCategory:
//                    plotPoint[CPTCoordinateX] = [self plotCoordinateForViewLength:CPTDecimalFromCGFloat(point.x) linearPlotRange:self.xRange boundsLength:plotArea.widthDecimal];
//                    break;
//
//                case CPTScaleTypeLog:
//                    plotPoint[CPTCoordinateX] = CPTDecimalFromDouble([self doublePrecisionPlotCoordinateForViewLength:point.x logPlotRange:self.xRange boundsLength:boundsSize.width]);
//                    break;
//
//                case CPTScaleTypeLogModulus:
//                    plotPoint[CPTCoordinateX] = CPTDecimalFromDouble([self doublePrecisionPlotCoordinateForViewLength:point.x logModulusPlotRange:self.xRange boundsLength:boundsSize.width]);
//                    break;
//
//                default:
//                    [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
//            }
//
//            switch ( self.yScaleType ) {
//                case CPTScaleTypeLinear:
//                case CPTScaleTypeCategory:
//                    plotPoint[CPTCoordinateY] = [self plotCoordinateForViewLength:CPTDecimalFromCGFloat(point.y) linearPlotRange:self.yRange boundsLength:plotArea.heightDecimal];
//                    break;
//
//                case CPTScaleTypeLog:
//                    plotPoint[CPTCoordinateY] = CPTDecimalFromDouble([self doublePrecisionPlotCoordinateForViewLength:point.y logPlotRange:self.yRange boundsLength:boundsSize.height]);
//                    break;
//
//                case CPTScaleTypeLogModulus:
//                    plotPoint[CPTCoordinateY] = CPTDecimalFromDouble([self doublePrecisionPlotCoordinateForViewLength:point.y logModulusPlotRange:self.yRange boundsLength:boundsSize.height]);
//                    break;
//
//                default:
//                    [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
//            }
//        }
//
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
//                    plotPoint[CPTCoordinateX] = [self doublePrecisionPlotCoordinateForViewLength:point.x linearPlotRange:self.xRange boundsLength:boundsSize.width];
//                    break;
//
//                case CPTScaleTypeLog:
//                    plotPoint[CPTCoordinateX] = [self doublePrecisionPlotCoordinateForViewLength:point.x logPlotRange:self.xRange boundsLength:boundsSize.width];
//                    break;
//
//                case CPTScaleTypeLogModulus:
//                    plotPoint[CPTCoordinateX] = [self doublePrecisionPlotCoordinateForViewLength:point.x logModulusPlotRange:self.xRange boundsLength:boundsSize.width];
//                    break;
//
//                default:
//                    [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
//            }
//
//            switch ( self.yScaleType ) {
//                case CPTScaleTypeLinear:
//                case CPTScaleTypeCategory:
//                    plotPoint[CPTCoordinateY] = [self doublePrecisionPlotCoordinateForViewLength:point.y linearPlotRange:self.yRange boundsLength:boundsSize.height];
//                    break;
//
//                case CPTScaleTypeLog:
//                    plotPoint[CPTCoordinateY] = [self doublePrecisionPlotCoordinateForViewLength:point.y logPlotRange:self.yRange boundsLength:boundsSize.height];
//                    break;
//
//                case CPTScaleTypeLogModulus:
//                    plotPoint[CPTCoordinateY] = [self doublePrecisionPlotCoordinateForViewLength:point.y logModulusPlotRange:self.yRange boundsLength:boundsSize.height];
//                    break;
//
//                default:
//                    [NSException raise:CPTException format:@"Scale type not supported in CPTXYPlotSpace"];
//            }
//        }
//    //
    //    // Plot area view point for event
    //    -(CGPoint)plotAreaViewPointForEvent:(nonnull CPTNativeEvent *)event
    //    {
    //        CGPoint plotAreaViewPoint = CGPointZero;
    //
    //        CPTGraph *theGraph                  = self.graph;
    //        CPTGraphHostingView *theHostingView = theGraph.hostingView;
    //        CPTPlotArea *thePlotArea            = theGraph.plotAreaFrame.plotArea;
    //
    //        if ( theHostingView && thePlotArea ) {
    //    #if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
    //            CGPoint interactionPoint = [[[event touchesForView:theHostingView] anyObject] locationInView:theHostingView];
    //            if ( theHostingView.collapsesLayers ) {
    //                interactionPoint.y = theHostingView.frame.size.height - interactionPoint.y;
    //                plotAreaViewPoint  = [theGraph convertPoint:interactionPoint toLayer:thePlotArea];
    //            }
    //            else {
    //                plotAreaViewPoint = [theHostingView.layer convertPoint:interactionPoint toLayer:thePlotArea];
    //            }
    //    #else
    //            CGPoint interactionPoint = NSPointToCGPoint([theHostingView convertPoint:event.locationInWindow fromView:nil]);
    //            plotAreaViewPoint = [theHostingView.layer convertPoint:interactionPoint toLayer:thePlotArea];
    //    #endif
    //        }
    //
    //        return plotAreaViewPoint;
    //    }
    //
    //    // Plot point for event
    //    -(nullable CPTNumberArray *)plotPointForEvent:(nonnull CPTNativeEvent *)event
    //    {
    //        return [self plotPointForPlotAreaViewPoint:[self plotAreaViewPointForEvent:event]];
    //    }
    //
    //    -(void)plotPoint:(nonnull NSDecimal *)plotPoint numberOfCoordinates:(NSUInteger)count forEvent:(nonnull CPTNativeEvent *)event
    //    {
    //        [self plotPoint:plotPoint numberOfCoordinates:count forPlotAreaViewPoint:[self plotAreaViewPointForEvent:event]];
    //    }
    //
    //    -(void)doublePrecisionPlotPoint:(nonnull double *)plotPoint numberOfCoordinates:(NSUInteger)count forEvent:(nonnull CPTNativeEvent *)event
    //    {
    //        [self doublePrecisionPlotPoint:plotPoint numberOfCoordinates:count forPlotAreaViewPoint:[self plotAreaViewPointForEvent:event]];
    //    }
    //
    //    /// @endcond
    //
    //    #pragma mark -
    //    #pragma mark Scaling
    //
    //    /// @cond
    //
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
    //            shouldScale = [theDelegate plotSpace:self shouldScaleBy:interactionScale aboutPoint:plotAreaPoint];
    //        }
    //        if ( !shouldScale ) {
    //            return;
    //        }
    //
    //        // Determine point in plot coordinates
    //        NSDecimal const decimalScale = CPTDecimalFromCGFloat(interactionScale);
    //        NSDecimal plotInteractionPoint[2];
    //
    //        [self plotPoint:plotInteractionPoint numberOfCoordinates:2 forPlotAreaViewPoint:plotAreaPoint];
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
    //
    //    /// @endcond
    //
    //    #pragma mark -
    //    #pragma mark Interaction
    //
    //    /// @name User Interaction
    //    /// @{
    //
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
    //                    [self plotPoint:lastPoint numberOfCoordinates:2 forPlotAreaViewPoint:pointInPlotArea];
    //                    [self plotPoint:newPoint numberOfCoordinates:2 forPlotAreaViewPoint:CGPointMake(pointInPlotArea.x + distanceTraveled * scaleX,
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
    //            [self animateRangeForCoordinate:CPTCoordinateX
    //                                      shift:shiftX
    //                               momentumTime:momentumTime
    //                                      speed:speed * scaleX
    //                               acceleration:acceleration * scaleX];
    //
    //            // Y range
    //            [self animateRangeForCoordinate:CPTCoordinateY
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
    //                displacement = [theDelegate plotSpace:self willDisplaceBy:displacement];
    //                pointToUse   = CPTPointMake(lastDraggedPoint.x + displacement.x, lastDraggedPoint.y + displacement.y);
    //            }
    //
    //            NSDecimal lastPoint[2], newPoint[2];
    //            [self plotPoint:lastPoint numberOfCoordinates:2 forPlotAreaViewPoint:lastDraggedPoint];
    //            [self plotPoint:newPoint numberOfCoordinates:2 forPlotAreaViewPoint:pointToUse];
    //
    //            // X range
    //            NSDecimal shiftX        = CPTDecimalSubtract(lastPoint[CPTCoordinateX], newPoint[CPTCoordinateX]);
    //            CPTPlotRange *newRangeX = [self shiftRange:self.xRange
    //                                                    by:shiftX
    //                                         usingMomentum:self.allowsMomentumX
    //                                         inGlobalRange:self.globalXRange
    //                                      withDisplacement:&displacement.x];
    //
    //            // Y range
    //            NSDecimal shiftY        = CPTDecimalSubtract(lastPoint[CPTCoordinateY], newPoint[CPTCoordinateY]);
    //            CPTPlotRange *newRangeY = [self shiftRange:self.yRange
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
    //
    //    /// @cond
    //
    //    -(nullable CPTPlotRange *)shiftRange:(nonnull CPTPlotRange *)oldRange by:(NSDecimal)shift usingMomentum:(BOOL)momentum inGlobalRange:(nullable CPTPlotRange *)globalRange withDisplacement:(CGFloat *)displacement
    //    {
    //        CPTMutablePlotRange *newRange = [oldRange mutableCopy];
    //
    //        newRange.locationDecimal = CPTDecimalAdd(newRange.locationDecimal, shift);
    //
    //        if ( globalRange ) {
    //            CPTPlotRange *constrainedRange = [self constrainRange:newRange toGlobalRange:globalRange];
    //
    //            if ( momentum ) {
    //                if ( ![newRange isEqualToRange:constrainedRange] ) {
    //                    // reduce the shift as we get farther outside the global range
    //                    NSDecimal rangeLength = newRange.lengthDecimal;
    //
    //                    if ( !CPTDecimalEquals(rangeLength, CPTDecimalFromInteger(0))) {
    //                        NSDecimal diff = CPTDecimalDivide(CPTDecimalSubtract(constrainedRange.locationDecimal, newRange.locationDecimal), rangeLength);
    //                        diff = CPTDecimalMax(CPTDecimalMin(CPTDecimalMultiply(diff, CPTDecimalFromDouble(2.5)), CPTDecimalFromInteger(1)), CPTDecimalFromInteger(-1));
    //
    //                        newRange.locationDecimal = CPTDecimalSubtract(newRange.locationDecimal, CPTDecimalMultiply(shift, CPTDecimalAbs(diff)));
    //
    //                        *displacement = *displacement * (CGFloat(1.0) - ABS(CPTDecimalCGFloatValue(diff)));
    //                    }
    //                }
    //            }
    //            else {
    //                newRange = (CPTMutablePlotRange *)constrainedRange;
    //            }
    //        }
    //
    //        return newRange;
    //    }
    //
    //    /// @endcond
    //
    //    #if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
    //    #else
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
    //            displacement = [theDelegate plotSpace:self willDisplaceBy:displacement];
    //            pointToUse   = CPTPointMake(fromPointInPlotArea.x + displacement.x, fromPointInPlotArea.y + displacement.y);
    //        }
    //
    //        NSDecimal lastPoint[2], newPoint[2];
    //
    //        [self plotPoint:lastPoint numberOfCoordinates:2 forPlotAreaViewPoint:fromPointInPlotArea];
    //        [self plotPoint:newPoint numberOfCoordinates:2 forPlotAreaViewPoint:pointToUse];
    //
    //        // X range
    //        NSDecimal shiftX        = CPTDecimalSubtract(lastPoint[CPTCoordinateX], newPoint[CPTCoordinateX]);
    //        CPTPlotRange *newRangeX = [self shiftRange:self.xRange
    //                                                by:shiftX
    //                                     usingMomentum:NO
    //                                     inGlobalRange:self.globalXRange
    //                                  withDisplacement:&displacement.x];
    //
    //        // Y range
    //        NSDecimal shiftY        = CPTDecimalSubtract(lastPoint[CPTCoordinateY], newPoint[CPTCoordinateY]);
    //        CPTPlotRange *newRangeY = [self shiftRange:self.yRange
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
    //    #endif
    //
    //    /**
    //     *  @brief Reset the dragging state and cancel any active animations.
    //     **/
    //    -(void)cancelAnimations
    //    {
    //        self.isDragging = false
    //        for ( CPTAnimationOperation *op in self.animations ) {
    //            [[CPTAnimation sharedInstance] removeAnimationOperation:op];
    //        }
    //    }
    //
    //    /// @}
    //
    //    #pragma mark -
    //    #pragma mark Accessors
    //
    //    /// @cond
    //
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
    //    /// @endcond
    //
    //    #pragma mark -
    //    #pragma mark Animation Delegate
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
    //    #pragma mark -
    //    #pragma mark Debugging
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
    //
    //    /// @endcond
    //
    //    @end
    
    
}
