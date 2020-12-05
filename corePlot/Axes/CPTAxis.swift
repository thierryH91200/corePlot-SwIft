//
//  CPTGraph.swift
//  corePlot
//
//  Created by thierryH24 on 09/11/2020.
//

import Cocoa


class CPTAxis : CPTLayer {
    
    enum CPTAxisLabelingPolicy: Int  {
        case none              ///< No labels provided; user sets labels and tick locations.
        case provided ///< User sets tick locations; axis makes labels.
        case fixedInterval    ///< Fixed interval labeling policy.
        case automatic        ///< Automatic labeling policy.
        case divisions     ///< Divide the plot range into equal parts.
    }
    typealias CPTAxisLabelSet = Set<CPTAxisLabel>
    
    
    // MARK: Title
    var titleTextStyle = CPTTextStyle()
    var axisTitle: CPTAxisTitle?
    var titleOffset =  CGFloat(0)
    var title = "title"
    var attributedTitle =  NSAttributedString(string: "")
    var titleRotation :  CGFloat?
    var titleDirection : CPTSign = .none
    var titleLocation = 0
    var defaultTitleLocation = 0
    
    // MARK: -
    var axisLineStyle = CPTLineStyle()
    
    // MARK: Axis.m
    var needsRelabel = false
    var pointingDeviceDownLabel: CPTAxisLabel?
    var pointingDeviceDownTickLabel:CPTAxisLabel?
    var labelFormatterChanged = false
    var minorLabelFormatterChanged = false
    //    var  mutableBackgroundLimitBands: CPTMutableLimitBandArray
    var tickOffset = CGFloat(0)
    var inTitleUpdate = false
    var labelsUpdated = false
    
    // MARK: Axis
    var coordinate : CPTCoordinate
    var labelingOrigin : NSNumber
    var tickDirection : CPTSign
    var visibleRange : CPTPlotRange?
    var visibleAxisRange : CPTPlotRange?
    var axisLineCapMin : CPTLineCap
    var axisLineCapMax : CPTLineCap
    
    
    // MARK: Labels
    var labelingPolicy =  CPTAxisLabelingPolicy.automatic
    var labelOffset = CGFloat(0.0)
    var minorTickLabelOffset: CGFloat
    var labelRotation: CGFloat
    var minorTickLabelRotation: CGFloat
    var labelAlignment: CPTAlignment
    var minorTickLabelAlignment: CPTAlignment
    var labelTextStyle :CPTTextStyle
    var minorTickLabelTextStyle: CPTTextStyle
    var tickLabelDirection = CPTSign.none
    var minorTickLabelDirection = CPTSign.none
    var labelFormatter: Formatter?
    var minorTickLabelFormatter: Formatter?
    
//    var axisLabels: CPTAxisLabelSet
//    var minorTickAxisLabels : CPTAxisLabelSet
//    var needsRelabel = false
//    var labelExclusionRanges = [CPTPlotRange]()
//    var labelShadow: CPTShadow
//    var minorTickLabelShadow: CPTShadow
    
    // MARK:  Major Ticks
    var majorIntervalLength = 0
    var majorTickLength = CGFloat(0)
    var majorTickLineStyle: CPTLineStyle
    var majorTickLocations: CPTNumberSet
    var preferredNumberOfMajorTicks = 0
    
    // MARK:  Minor Ticks
    var minorTicksPerInterval = 0
    var minorTickLength = CGFloat(0.0)
    var minorTickLineStyle: CPTLineStyle
    var minorTickLocations: CPTNumberSet
    
    // MARK:  Grid Lines
    var  majorGridLineStyle: CPTLineStyle
    var  minorGridLineStyle: CPTLineStyle
    var  gridLinesRange : CPTPlotRange?
    
    // MARK:  Background Bands
    //    var majorGridLineStyle : CPTFillArray
    var alternatingBandFills = [CPTFill]()

    var alternatingBandAnchor = 0.0
    var backgroundLimitBands = [CPTLimitBand]()
    
    // MARK:  Plot Space
    var  plotSpace : CPTPlotSpace?
    
    // MARK:  Layers
    var separateLayers = false
    var plotArea: CPTPlotArea?
    var minorGridLines : CPTGridLines?
    var majorGridLines: CPTGridLines?
    var axisSet: CPTAxisSet
    
    var axisLabels: Set<CPTAxisLabel>
    var minorTickAxisLabels : Set<Double>
    
    var labelExclusionRanges = [CPTPlot]()
    var labelShadow: CPTShadow?
    var minorTickLabelShadow: CPTShadow?
    
    var mutableBackgroundLimitBands = [CPTLimitBand]()
    
    override init( frame : CGRect  )
    {
        //        super.init(Frame: frame)
        //        plotSpace                   = nil;
        //        majorTickLocations          = [NSSet set];
        
        
        title                       = ""
        attributedTitle             = NSAttributedString(string: "")
        
        
        minorTickLocations.removeAll()
        preferredNumberOfMajorTicks = 0;
        minorTickLength             = CGFloat(3.0);
        majorTickLength             = CGFloat(5.0);
        labelOffset                 = CGFloat(2.0);
        minorTickLabelOffset        = CGFloat(2.0);
        labelRotation               = CGFloat(0.0);
        minorTickLabelRotation      = CGFloat(0.0);
        labelAlignment              = .center
        minorTickLabelAlignment     = .center
        
        titleOffset                 = CGFloat(30.0)
        axisLineStyle               = CPTLineStyle()
        majorTickLineStyle          = CPTLineStyle()
        minorTickLineStyle          = CPTLineStyle()
        tickLabelDirection          = .none
        minorTickLabelDirection     = .none
        majorGridLineStyle          = CPTLineStyle()
        minorGridLineStyle          = CPTLineStyle()
        axisLineCapMin              = CPTLineCap()
        axisLineCapMax              = CPTLineCap()
        labelingOrigin              = 0.0
        majorIntervalLength         = 1;
        minorTicksPerInterval       = 1
        coordinate                  = .x
        labelingPolicy              = .fixedInterval;
        labelTextStyle              = CPTTextStyle()
        
        var newFormatter = NumberFormatter()
        newFormatter.minimumIntegerDigits  = 1
        newFormatter.maximumFractionDigits = 1
        newFormatter.minimumFractionDigits = 1
        
        labelFormatter              = newFormatter;
        minorTickLabelTextStyle     = CPTTextStyle()
        minorTickLabelFormatter     = nil
        labelFormatterChanged       = true;
        minorLabelFormatterChanged  = false
        axisLabels.removeAll()
        minorTickAxisLabels.removeAll()
        tickDirection               = CPTSign.none
        axisTitle                  = nil
        titleTextStyle              = CPTTextStyle()
        titleRotation               = nil
        titleLocation               = 0
        needsRelabel                = true;
        labelExclusionRanges.removeAll()
        plotArea                    = nil;
        separateLayers              = false
        labelShadow                 = nil;
        minorTickLabelShadow        = nil;
        visibleRange                = nil;
        visibleAxisRange            = nil;
        gridLinesRange              = nil;
        alternatingBandFills.removeAll()
        alternatingBandAnchor       = 0
        backgroundLimitBands.removeAll()
        minorGridLines              = nil;
        majorGridLines              = nil;
        pointingDeviceDownLabel     = nil;
        pointingDeviceDownTickLabel = nil;
        inTitleUpdate               = false
        labelsUpdated               = false
        
        self.needsDisplayOnBoundsChange = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    //    init(layer :  CPTAxis )
    //    {
    //        super.init(layer: layer)
    //        let theLayer = CPTAxis( )
    //
    //        plotSpace                   = theLayer.plotSpace;
    //        majorTickLocations          = theLayer.majorTickLocations;
    //        minorTickLocations          = theLayer.minorTickLocations;
    //        preferredNumberOfMajorTicks = theLayer.preferredNumberOfMajorTicks;
    //        minorTickLength             = theLayer.minorTickLength;
    //        majorTickLength             = theLayer.majorTickLength;
    //        labelOffset                 = theLayer.labelOffset;
    //        minorTickLabelOffset        = theLayer.labelOffset;
    //        labelRotation               = theLayer.labelRotation;
    //        minorTickLabelRotation      = theLayer.labelRotation;
    //        labelAlignment              = theLayer.labelAlignment;
    //        minorTickLabelAlignment     = theLayer.labelAlignment;
    //        title                       = theLayer.title;
    //        attributedTitle             = theLayer.attributedTitle;
    //        titleOffset                 = theLayer.titleOffset;
    //        axisLineStyle               = theLayer.axisLineStyle;
    //        majorTickLineStyle          = theLayer.majorTickLineStyle;
    //        minorTickLineStyle          = theLayer.minorTickLineStyle;
    //        tickLabelDirection          = theLayer.tickLabelDirection;
    //        minorTickLabelDirection     = theLayer.minorTickLabelDirection;
    //        majorGridLineStyle          = theLayer.majorGridLineStyle;
    //        minorGridLineStyle          = theLayer.minorGridLineStyle;
    //        axisLineCapMin              = theLayer.axisLineCapMin;
    //        axisLineCapMax              = theLayer.axisLineCapMax;
    //        labelingOrigin              = theLayer.labelingOrigin;
    //        majorIntervalLength         = theLayer.majorIntervalLength;
    //        minorTicksPerInterval       = theLayer.minorTicksPerInterval;
    //        coordinate                  = theLayer.coordinate;
    //        labelingPolicy              = theLayer.labelingPolicy;
    //        labelFormatter              = theLayer.labelFormatter;
    //        minorTickLabelFormatter     = theLayer.minorTickLabelFormatter;
    //        axisLabels                  = theLayer.axisLabels;
    //        minorTickAxisLabels         = theLayer.minorTickAxisLabels;
    //        tickDirection               = theLayer.tickDirection;
    //        labelTextStyle              = theLayer.labelTextStyle;
    //        minorTickLabelTextStyle     = theLayer.minorTickLabelTextStyle;
    //        axisTitle                   = theLayer.axisTitle;
    //        titleTextStyle              = theLayer.titleTextStyle;
    //        titleRotation               = theLayer.titleRotation;
    //        titleDirection              = theLayer.titleDirection;
    //        titleLocation               = theLayer.titleLocation;
    //        needsRelabel                = theLayer.needsRelabel;
    //        labelExclusionRanges        = theLayer.labelExclusionRanges;
    //        plotArea                    = theLayer.plotArea;
    //        separateLayers              = theLayer.separateLayers;
    //        labelShadow                 = theLayer.labelShadow;
    //        minorTickLabelShadow        = theLayer.minorTickLabelShadow;
    //        visibleRange                = theLayer.visibleRange;
    //        visibleAxisRange            = theLayer.visibleAxisRange;
    //        gridLinesRange              = theLayer.gridLinesRange;
    //        alternatingBandFills        = theLayer.alternatingBandFills;
    //        alternatingBandAnchor       = theLayer.alternatingBandAnchor;
    //        mutableBackgroundLimitBands = theLayer.mutableBackgroundLimitBands;
    //        minorGridLines              = theLayer.minorGridLines;
    //        majorGridLines              = theLayer.majorGridLines;
    //        pointingDeviceDownLabel     = theLayer.pointingDeviceDownLabel;
    //        pointingDeviceDownTickLabel = theLayer.pointingDeviceDownTickLabel;
    //        inTitleUpdate               = theLayer.inTitleUpdate;
    //        labelsUpdated               = theLayer.labelsUpdated;
    //   }
    
    
    // MARK: - Animation
    func needsDisplayForKey(aKey:String )-> Bool
    {
        var keys        = Set<String>()
        
        keys.insert("titleOffset")
        keys.insert("titleRotation")
        keys.insert("labelOffset")
        keys.insert("minorTickLabelOffset")
        keys.insert("labelRotation")
        keys.insert("minorTickLabelRotation")
        
        if keys.contains(aKey ) {
            return true
        }
        else {
            return CPTLayer.needsDisplay(forKey: aKey)
        }
    }
    
    
    
    // MARK: -Ticks
    //
    //    /// @cond
    //
    //    /**
    //     *  @internal
    //     *  @brief Generate major and minor tick locations using the fixed interval labeling policy.
    //     *  @param newMajorLocations A new NSSet containing the major tick locations.
    //     *  @param newMinorLocations A new NSSet containing the minor tick locations.
    //     */
    func generateFixedIntervalMajorTickLocations(newMajorLocations: inout CGFloat, newMinorLocations: inout CGFloat)
    {
        var majorLocations = Set<CGFloat>()
        var minorLocations =  Set<CGFloat>()
        
        let zero          = 0
        var majorInterval = self.majorIntervalLength
        
        if (majorInterval > zero) {
            let range = self.plotSpace.plotRangeForCoordinate(self.coordinate)
            
            
            if ( range ) {
                CPTPlotRange *theVisibleRange = self.visibleRange;
                if theVisibleRange  {
                    [range intersectionPlotRange:theVisibleRange];
                }
                
                let rangeMin = range.minLimitDecimal;
                let rangeMax = range.maxLimitDecimal;
                
                NSDecimal minorInterval;
                NSUInteger minorTickCount = self.minorTicksPerInterval;
                if ( minorTickCount > 0 ) {
                    minorInterval = CPTDecimalDivide(majorInterval, CPTDecimalFromUnsignedInteger(minorTickCount + 1));
                }
                else {
                    minorInterval = zero;
                }
                
                // Set starting coord--should be the smallest value >= rangeMin that is a whole multiple of majorInterval away from the labelingOrigin
                let origin = self.labelingOrigin.decimalValue;
                let  coord  = CPTDecimalDivide(CPTDecimalSubtract(rangeMin, origin), majorInterval);
                NSDecimalRound(&coord, &coord, 0, NSRoundUp);
                coord = CPTDecimalAdd(CPTDecimalMultiply(coord, majorInterval), origin);
                
                // Set minor ticks between the starting point and rangeMin
                if ( minorTickCount > 0 ) {
                    NSDecimal minorCoord = CPTDecimalSubtract(coord, minorInterval);
                    
                    for ( NSUInteger minorTickIndex = 0; minorTickIndex < minorTickCount; minorTickIndex++ ) {
                        if ( CPTDecimalLessThan(minorCoord, rangeMin)) {
                            break;
                        }
                        [minorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:minorCoord]];
                        minorCoord = CPTDecimalSubtract(minorCoord, minorInterval);
                    }
                }
                
                // Set tick locations
                while ( CPTDecimalLessThanOrEqualTo(coord, rangeMax)) {
                    // Major tick
                    [majorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:coord]];
                    
                    // Minor ticks
                    if ( minorTickCount > 0 ) {
                        NSDecimal minorCoord = CPTDecimalAdd(coord, minorInterval);
                        
                        for (minorTickIndex in  0..<minorTickCount {
                            if ( CPTDecimalGreaterThan(minorCoord, rangeMax)) {
                                break;
                            }
                            [minorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:minorCoord]];
                            minorCoord = CPTDecimalAdd(minorCoord, minorInterval);
                        }
                    }
                    
                    coord = CPTDecimalAdd(coord, majorInterval);
                }
            }
        }
        
        newMajorLocations = majorLocations;
        newMinorLocations = minorLocations;
    }
    
    //    /**
    //     *  @internal
    //     *  @brief Generate major and minor tick locations using the automatic labeling policy.
    //     *  @param newMajorLocations A new NSSet containing the major tick locations.
    //     *  @param newMinorLocations A new NSSet containing the minor tick locations.
    //     */
    func autoGenerateMajorTickLocations(newMajorLocations :CPTNumberSet, newMinorLocations:CPTNumberSet)
     
    {
        var newMajorLocations = newMajorLocations
        var newMinorLocations = newMinorLocations
        
        // Create sets for locations
        var majorLocations = [NSMutableSet ]
        var minorLocations = [NSMutableSet ]
        
        // Get plot range
        var range    = self.plotSpace.plotRangeForCoordinate(coordinate)
        var theVisibleRange = self.visibleRange;
        
        if (theVisibleRange != nil)  {
            range.intersectionPlotRange(theVisibleRange)
        }
        
        // Validate scale type
        var valid             = true;
        let scaleType = self.plotSpace.scaleTypeForCoordinate(self.coordinate)
        
        switch ( scaleType ) {
        case .linear:
            // supported scale type
            break;
            
        case .log:
            // supported scale type--check range
            if ((range.minLimitDouble <= 0.0) || (range.maxLimitDouble <= 0.0)) {
                valid = false
            }
            break;
            
        case .logModulus:
            // supported scale type
            break;
            
        default:
            // unsupported scale type--bail out
            valid = false
            break;
        }
        
        if ( !valid ) {
            newMajorLocations = majorLocations;
            newMinorLocations = minorLocations;
            return;
        }
        
        // Cache some values
        let numTicks   = self.preferredNumberOfMajorTicks;
        let minorTicks = self.minorTicksPerInterval + 1;
        let length         = fabs(range.lengthDouble);
        
        // Filter troublesome values and return empty sets
        if ((length != 0.0) && !isinf(length)) {
            switch ( scaleType ) {
            case .linear:
                {
                    // Determine interval value
                    switch ( numTicks ) {
                    case 0:
                        numTicks = 5;
                        break;
                        
                    case 1:
                        numTicks = 2;
                        break;
                        
                    default:
                        // ok
                        break;
                    }
                    
                    let zero = CPTDecimalFromInteger(0);
                    let one  = CPTDecimalFromInteger(1);
                    
                    var majorInterval = 0
                    if ( numTicks == 2 ) {
                        majorInterval = CPTNiceLength(range.lengthDecimal);
                    }
                    else {
                        majorInterval = CPTDecimalDivide(range.lengthDecimal, CPTDecimalFromUnsignedInteger(numTicks - 1));
                        majorInterval = CPTNiceNum(majorInterval);
                    }
                    if ( CPTDecimalLessThan(majorInterval, zero)) {
                        majorInterval = CPTDecimalMultiply(majorInterval, CPTDecimalFromInteger(-1));
                    }
                    
                    NSDecimal minorInterval;
                    if ( minorTicks > 1 ) {
                        minorInterval = CPTDecimalDivide(majorInterval, CPTDecimalFromUnsignedInteger(minorTicks));
                    }
                    else {
                        minorInterval = zero;
                    }
                    
                    // Calculate actual range limits
                    NSDecimal minLimit = range.minLimitDecimal;
                    NSDecimal maxLimit = range.maxLimitDecimal;
                    
                    // Determine the initial and final major indexes for the actual visible range
                    NSDecimal initialIndex = CPTDecimalDivide(minLimit, majorInterval);
                    NSDecimalRound(&initialIndex, &initialIndex, 0, NSRoundDown);
                    
                    NSDecimal finalIndex = CPTDecimalDivide(maxLimit, majorInterval);
                    NSDecimalRound(&finalIndex, &finalIndex, 0, NSRoundUp);
                    
                    // Iterate through the indexes with visible ticks and build the locations sets
                    for ( NSDecimal i = initialIndex; CPTDecimalLessThanOrEqualTo(i, finalIndex); i = CPTDecimalAdd(i, one)) {
                        
                        NSDecimal pointLocation      = CPTDecimalMultiply(majorInterval, i);
                        let minorPointLocation = pointLocation;
                        
                        for  j in 1..<minorTicks {
                            minorPointLocation = CPTDecimalAdd(minorPointLocation, minorInterval);
                            
                            if ( CPTDecimalLessThan(minorPointLocation, minLimit)) {
                                continue;
                            }
                            if ( CPTDecimalGreaterThan(minorPointLocation, maxLimit)) {
                                continue;
                            }
                            [minorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:minorPointLocation]];
                        }
                        
                        if ( CPTDecimalLessThan(pointLocation, minLimit)) {
                            continue;
                        }
                        if ( CPTDecimalGreaterThan(pointLocation, maxLimit)) {
                            continue;
                        }
                        [majorLocations.addObject:[NSDecimalNumber decimalNumberWithDecimal:pointLocation]];
                    }
                }
                break;
                
            case CPTScaleType.log:
                {
                    double minLimit = range.minLimitDouble;
                    double maxLimit = range.maxLimitDouble;
                    
                    if ((minLimit > 0.0) && (maxLimit > 0.0)) {
                        // Determine interval value
                        length = log10(maxLimit / minLimit);
                        
                        double interval     = signbit(length) ? -1.0 : 1.0;
                        double intervalStep = pow(10.0, fabs(interval));
                        
                        // Determine minor interval
                        double minorInterval = intervalStep * 0.9 * pow(10.0, floor(log10(minLimit))) / minorTicks;
                        
                        // Determine the initial and final major indexes for the actual visible range
                        NSInteger initialIndex = (NSInteger)lrint(floor(log10(minLimit / fabs(interval)))); // can be negative
                        NSInteger finalIndex   = (NSInteger)lrint(ceil(log10(maxLimit / fabs(interval))));  // can be negative
                        
                        // Iterate through the indexes with visible ticks and build the locations sets
                        for ( NSInteger i = initialIndex; i <= finalIndex; i++ ) {
                            double pointLocation = pow(10.0, i * interval);
                            for ( NSUInteger j = 1; j < minorTicks; j++ ) {
                                double minorPointLocation = pointLocation + minorInterval * j;
                                if ( minorPointLocation < minLimit ) {
                                    continue;
                                }
                                if ( minorPointLocation > maxLimit ) {
                                    continue;
                                }
                                [minorLocations addObject:@(minorPointLocation)];
                            }
                            minorInterval *= intervalStep;
                            
                            if ( pointLocation < minLimit ) {
                                continue;
                            }
                            if ( pointLocation > maxLimit ) {
                                continue;
                            }
                            [majorLocations addObject:@(pointLocation)];
                        }
                    }
                }
                break;
                
            case CPTScaleType.logModulus:
                {
                    let minLimit = range.minLimitDouble;
                    let maxLimit = range.maxLimitDouble;
                    
                    // Determine interval value
                    double modMinLimit = CPTLogModulus(minLimit);
                    double modMaxLimit = CPTLogModulus(maxLimit);
                    
                    double multiplier = pow(10.0, floor(log10(length)));
                    multiplier = (multiplier < 1.0) ? multiplier : 1.0;
                    
                    double intervalStep = 10.0;
                    
                    // Determine the initial and final major indexes for the actual visible range
                    NSInteger initialIndex = (NSInteger)lrint(floor(modMinLimit / multiplier)); // can be negative
                    NSInteger finalIndex   = (NSInteger)lrint(ceil(modMaxLimit / multiplier));  // can be negative
                    
                    if ( initialIndex < 0 ) {
                        // Determine minor interval
                        double minorInterval = intervalStep * 0.9 * multiplier / minorTicks;
                        
                        for ( NSInteger i = MIN(0, finalIndex); i >= initialIndex; i-- ) {
                            double pointLocation;
                            double sign = -multiplier;
                            
                            if ( multiplier < 1.0 ) {
                                pointLocation = sign * pow(10.0, fabs((double)i) - 1.0);
                            }
                            else {
                                pointLocation = sign * pow(10.0, fabs((double)i));
                            }
                            
                            for ( NSUInteger j = 1; j < minorTicks; j++ ) {
                                double minorPointLocation = pointLocation + sign * minorInterval * j;
                                if ( minorPointLocation < minLimit ) {
                                    continue;
                                }
                                if ( minorPointLocation > maxLimit ) {
                                    continue;
                                }
                                [minorLocations addObject:@(minorPointLocation)];
                            }
                            minorInterval *= intervalStep;
                            
                            if ( i == 0 ) {
                                pointLocation = 0.0;
                            }
                            if ( pointLocation < minLimit ) {
                                continue;
                            }
                            if ( pointLocation > maxLimit ) {
                                continue;
                            }
                            [majorLocations addObject:@(pointLocation)];
                        }
                    }
                    
                    if ( finalIndex >= 0 ) {
                        // Determine minor interval
                        let minorInterval = intervalStep * 0.9 * multiplier / minorTicks;
                        
                        for ( NSInteger i = MAX(0, initialIndex); i <= finalIndex; i++ ) {
                            double pointLocation;
                            double sign = multiplier;
                            
                            if ( multiplier < 1.0 ) {
                                pointLocation = sign * pow(10.0, fabs((double)i) - 1.0);
                            }
                            else {
                                pointLocation = sign * pow(10.0, fabs((double)i));
                            }
                            
                            for   j in 1..<minorTicks {
                                var minorPointLocation = pointLocation + sign * minorInterval * j;
                                if ( minorPointLocation < minLimit ) {
                                    continue;
                                }
                                if ( minorPointLocation > maxLimit ) {
                                    continue;
                                }
                                [minorLocations addObject:@(minorPointLocation)];
                            }
                            minorInterval *= intervalStep
                            
                            if ( i == 0 ) {
                                pointLocation = 0.0;
                            }
                            if ( pointLocation < minLimit ) {
                                continue;
                            }
                            if ( pointLocation > maxLimit ) {
                                continue;
                            }
                            majorLocations.addObject(pointLocation)
                        }
                    }
                }
                break;
                
            default:
                break;
            }
        }
        
        //
        //        // Return tick locations sets
        //        *newMajorLocations = majorLocations;
        //        *newMinorLocations = minorLocations;
        //    }
        //
        //    /**
        //     *  @internal
        //     *  @brief Generate major and minor tick locations using the equal divisions labeling policy.
        //     *  @param newMajorLocations A new NSSet containing the major tick locations.
        //     *  @param newMinorLocations A new NSSet containing the minor tick locations.
        //     */
        func generateEqualMajorTickLocations(newMajorLocations: inout Set<CGFloat>,  newMinorLocations: inout Set<CGFloat>)
        {
        var majorLocations = Set<CGFloat>()
        var minorLocations = Set<CGFloat>()
        
        var range = self.plotSpace.plotRangeForCoordinate(self.coordinate)
        
        if ( range ) {
        var theVisibleRange = self.visibleRange;
            if (( theVisibleRange ) != nil) {
        range.intersectionPlotRange(theVisibleRange)
        }
        
        if ( range.lengthDouble != 0.0 ) {
        var zero     = CPTDecimalFromInteger(0);
            let rangeMin = range.minLimitDecimal;
        let rangeMax = range.maxLimitDecimal;
        
        NSUInteger majorTickCount = self.preferredNumberOfMajorTicks;
        
        if ( majorTickCount < 2 ) {
        majorTickCount = 2;
        }
        NSDecimal majorInterval = CPTDecimalDivide(range.lengthDecimal, CPTDecimalFromUnsignedInteger(majorTickCount - 1));
        if ( CPTDecimalLessThan(majorInterval, zero)) {
        majorInterval = CPTDecimalMultiply(majorInterval, CPTDecimalFromInteger(-1));
        }
        
        NSDecimal minorInterval;
        NSUInteger minorTickCount = self.minorTicksPerInterval;
        if ( minorTickCount > 0 ) {
        minorInterval = CPTDecimalDivide(majorInterval, CPTDecimalFromUnsignedInteger(minorTickCount + 1));
        }
        else {
        minorInterval = zero;
        }
        
        NSDecimal coord = rangeMin;
        
        // Set tick locations
        while ( CPTDecimalLessThanOrEqualTo(coord, rangeMax)) {
        // Major tick
        [majorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:coord]];
        
        // Minor ticks
        if ( minorTickCount > 0 ) {
        NSDecimal minorCoord = CPTDecimalAdd(coord, minorInterval);
        
        for ( NSUInteger minorTickIndex = 0; minorTickIndex < minorTickCount; minorTickIndex++ ) {
        if ( CPTDecimalGreaterThan(minorCoord, rangeMax)) {
        break;
        }
        [minorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:minorCoord]];
        minorCoord = CPTDecimalAdd(minorCoord, minorInterval);
        }
        }
        
        coord = CPTDecimalAdd(coord, majorInterval);
        }
        }
        }
        newMajorLocations = majorLocations
        newMinorLocations = minorLocations
        }
        
        //
        //    /**
        //     *  @internal
        //     *  @brief Determines a @quote{nice} number (a multiple of @num{2}, @num{5}, or @num{10}) near the given number.
        //     *  @param x The number to round.
        //     */
        //    NSDecimal CPTNiceNum(NSDecimal x)
        //    {
        //        NSDecimal zero = CPTDecimalFromInteger(0);
        //
        //        if ( CPTDecimalEquals(x, zero)) {
        //            return zero;
        //        }
        //
        //        NSDecimal minusOne = CPTDecimalFromInteger(-1);
        //
        //        var xIsNegative = CPTDecimalLessThan(x, zero);
        //
        //        if ( xIsNegative ) {
        //            x = CPTDecimalMultiply(x, minusOne);
        //        }
        //
        //        short exponent = (short)lrint(floor(log10(CPTDecimalDoubleValue(x))));
        //
        //        NSDecimal fractionPart;
        //
        //        NSDecimalMultiplyByPowerOf10(&fractionPart, &x, -exponent, NSRoundPlain);
        //
        //        NSDecimal roundedFraction;
        //
        //        if ( CPTDecimalLessThan(fractionPart, CPTDecimalFromDouble(1.5))) {
        //            roundedFraction = CPTDecimalFromInteger(1);
        //        }
        //        else if ( CPTDecimalLessThan(fractionPart, CPTDecimalFromInteger(3))) {
        //            roundedFraction = CPTDecimalFromInteger(2);
        //        }
        //        else if ( CPTDecimalLessThan(fractionPart, CPTDecimalFromInteger(7))) {
        //            roundedFraction = CPTDecimalFromInteger(5);
        //        }
        //        else {
        //            roundedFraction = CPTDecimalFromInteger(10);
        //        }
        //
        //        if ( xIsNegative ) {
        //            roundedFraction = CPTDecimalMultiply(roundedFraction, minusOne);
        //        }
        //
        //        NSDecimal roundedNumber;
        //
        //        NSDecimalMultiplyByPowerOf10(&roundedNumber, &roundedFraction, exponent, NSRoundPlain);
        //
        //        return roundedNumber;
        //    }
        //
        //    /**
        //     *  @internal
        //     *  @brief Determines a @quote{nice} range length (a multiple of @num{2}, @num{5}, or @num{10}) less than or equal to the given length.
        //     *  @param length The length to round.
        //     */
        //    NSDecimal CPTNiceLength(NSDecimal length)
        //    {
        //        NSDecimal zero = CPTDecimalFromInteger(0);
        //
        //        if ( CPTDecimalEquals(length, zero)) {
        //            return zero;
        //        }
        //
        //        NSDecimal minusOne = CPTDecimalFromInteger(-1);
        //
        //        var isNegative = CPTDecimalLessThan(length, zero);
        //
        //        if ( isNegative ) {
        //            length = CPTDecimalMultiply(length, minusOne);
        //        }
        //
        //        NSDecimal roundedNumber;
        //
        //        if ( CPTDecimalGreaterThan(length, CPTDecimalFromInteger(10))) {
        //            NSDecimalRound(&roundedNumber, &length, 0, NSRoundDown);
        //        }
        //        else {
        //            short exponent = (short)lrint(floor(log10(CPTDecimalDoubleValue(length)))) - 1;
        //            NSDecimalRound(&roundedNumber, &length, -exponent, NSRoundDown);
        //        }
        //
        //        if ( isNegative ) {
        //            roundedNumber = CPTDecimalMultiply(roundedNumber, minusOne);
        //        }
        //
        //        return roundedNumber;
        //    }
        //
        //    /**
        //     *  @internal
        //     *  @brief Removes any tick locations falling inside the label exclusion ranges from a set of tick locations.
        //     *  @param allLocations A set of tick locations.
        //     *  @return The filtered set of tick locations.
        //     */
        //    -(nullable CPTNumberSet *)filteredTickLocations:(nullable CPTNumberSet *)allLocations
        //    {
        //        CPTPlotRangeArray *exclusionRanges = self.labelExclusionRanges;
        //
        //        if ( exclusionRanges ) {
        //            CPTMutableNumberSet *filteredLocations = [allLocations mutableCopy];
        //            for ( CPTPlotRange *range in exclusionRanges ) {
        //                for ( NSNumber *location in allLocations ) {
        //                    if ( [range containsNumber:location] ) {
        //                        [filteredLocations removeObject:location];
        //                    }
        //                }
        //            }
        //            return filteredLocations;
        //        }
        //        else {
        //            return allLocations;
        //        }
        //    }
        //
        //    /// @endcond
        //
        //    /** @brief Removes any major ticks falling inside the label exclusion ranges from the set of tick locations.
        //     *  @param allLocations A set of major tick locations.
        //     *  @return The filtered set.
        //     **/
        //    -(nullable CPTNumberSet *)filteredMajorTickLocations:(nullable CPTNumberSet *)allLocations
        //    {
        //        return [self filteredTickLocations:allLocations];
        //    }
        //
        //    /** @brief Removes any minor ticks falling inside the label exclusion ranges from the set of tick locations.
        //     *  @param allLocations A set of minor tick locations.
        //     *  @return The filtered set.
        //     **/
        //    -(nullable CPTNumberSet *)filteredMinorTickLocations:(nullable CPTNumberSet *)allLocations
        //    {
        //        return [self filteredTickLocations:allLocations];
        //    }
        //
        //    #pragma mark -
        //    #pragma mark Labels
        //
        //    /// @cond
        //
        //    -(CGFloat)tickOffset
        //    {
        //        CGFloat offset = CGFloat(0.0);
        //
        //        switch ( self.tickDirection ) {
        //            case CPTSignNone:
        //                offset += self.majorTickLength * CGFloat(0.5);
        //                break;
        //
        //            case CPTSignPositive:
        //            case CPTSignNegative:
        //                offset += self.majorTickLength;
        //                break;
        //        }
        //
        //        return offset;
        //    }
        //
        //    /**
        //     *  @internal
        //     *  @brief Updates the set of axis labels using the given locations.
        //     *  Existing axis label objects and content layers are reused where possible.
        //     *  @param locations A set of NSDecimalNumber label locations.
        //     *  @param labeledRange A plot range used to filter the generated labels. If @nil, no filtering is done.
        //     *  @param useMajorAxisLabels If @true, label the major ticks, otherwise label the minor ticks.
        //     **/
        //   func updateAxisLabelsAtLocations:(nullable CPTNumberSet *)locations inRange:(nullable CPTPlotRange *)labeledRange useMajorAxisLabels:(var)useMajorAxisLabels
        //    {
        //        CPTAlignment theLabelAlignment;
        //        CPTSign theLabelDirection;
        //        CGFloat theLabelOffset;
        //        CGFloat theLabelRotation;
        //        CPTTextStyle *theLabelTextStyle;
        //        NSFormatter *theLabelFormatter;
        //        var theLabelFormatterChanged;
        //        CPTShadow *theShadow;
        //
        //        id<CPTAxisDelegate> theDelegate = (id<CPTAxisDelegate>)self.delegate;
        //
        //        if ( useMajorAxisLabels ) {
        //            if ( locations.count > 0 ) {
        //                if ( [theDelegate respondsToSelector:@selector(axis:shouldUpdateAxisLabelsAtLocations:)] ) {
        //                    CPTNumberSet *locationSet = locations;
        //                    var shouldContinue       = [theDelegate axis:self shouldUpdateAxisLabelsAtLocations:locationSet];
        //                    if ( !shouldContinue ) {
        //                        return;
        //                    }
        //                }
        //            }
        //            theLabelAlignment        = self.labelAlignment;
        //            theLabelDirection        = self.tickLabelDirection;
        //            theLabelOffset           = self.labelOffset;
        //            theLabelRotation         = self.labelRotation;
        //            theLabelTextStyle        = self.labelTextStyle;
        //            theLabelFormatter        = self.labelFormatter;
        //            theLabelFormatterChanged = self.labelFormatterChanged;
        //            theShadow                = self.labelShadow;
        //        }
        //        else {
        //            if ( locations.count > 0 ) {
        //                if ( [theDelegate respondsToSelector:@selector(axis:shouldUpdateMinorAxisLabelsAtLocations:)] ) {
        //                    CPTNumberSet *locationSet = locations;
        //                    var shouldContinue       = [theDelegate axis:self shouldUpdateMinorAxisLabelsAtLocations:locationSet];
        //                    if ( !shouldContinue ) {
        //                        return;
        //                    }
        //                }
        //            }
        //            theLabelAlignment        = self.minorTickLabelAlignment;
        //            theLabelDirection        = self.minorTickLabelDirection;
        //            theLabelOffset           = self.minorTickLabelOffset;
        //            theLabelRotation         = self.minorTickLabelRotation;
        //            theLabelTextStyle        = self.minorTickLabelTextStyle;
        //            theLabelFormatter        = self.minorTickLabelFormatter;
        //            theLabelFormatterChanged = self.minorLabelFormatterChanged;
        //            theShadow                = self.minorTickLabelShadow;
        //        }
        //
        //        if ((locations.count == 0) || !theLabelTextStyle || !theLabelFormatter ) {
        //            if ( useMajorAxisLabels ) {
        //                self.axisLabels = nil;
        //            }
        //            else {
        //                self.minorTickAxisLabels = nil;
        //            }
        //            return;
        //        }
        //
        //        CPTDictionary *textAttributes = theLabelTextStyle.attributes;
        //        var hasAttributedFormatter   = ([theLabelFormatter attributedStringForObjectValue:[NSDecimalNumber zero]
        //                                                                     withDefaultAttributes:textAttributes] != nil);
        //
        //        CPTPlotSpace *thePlotSpace = self.plotSpace;
        //        CPTCoordinate myCoordinate = self.coordinate;
        //        var hasCategories         = ([thePlotSpace scaleTypeForCoordinate:myCoordinate] == CPTScaleTypeCategory);
        //
        //        CPTSign direction = self.tickDirection;
        //
        //        if ( theLabelDirection == CPTSignNone ) {
        //            theLabelDirection = direction;
        //        }
        //
        //        if ((direction == CPTSignNone) || (theLabelDirection == direction)) {
        //            theLabelOffset += self.tickOffset;
        //        }
        //
        //        CPTPlotArea *thePlotArea = self.plotArea;
        //
        //        [thePlotArea setAxisSetLayersForType:CPTGraphLayerTypeAxisLabels];
        //
        //        CPTMutableAxisLabelSet *oldAxisLabels;
        //
        //        if ( useMajorAxisLabels ) {
        //            oldAxisLabels = [self.axisLabels mutableCopy];
        //        }
        //        else {
        //            oldAxisLabels = [self.minorTickAxisLabels mutableCopy];
        //        }
        //
        //        CPTMutableAxisLabelSet *newAxisLabels = [[NSMutableSet alloc] initWithCapacity:locations.count];
        //        CPTAxisLabel *blankLabel              = [[CPTAxisLabel alloc] initWithText:nil textStyle:nil];
        //        CPTAxisLabelGroup *axisLabelGroup     = thePlotArea.axisLabelGroup;
        //        CPTLayer *lastLayer                   = nil;
        //
        //        for ( NSDecimalNumber *tickLocation in locations ) {
        //            if ( labeledRange && ![labeledRange containsNumber:tickLocation] ) {
        //                continue;
        //            }
        //
        //            CPTAxisLabel *newAxisLabel;
        //            var needsNewContentLayer = false
        //
        //            // reuse axis labels where possible--will prevent flicker when updating layers
        //            blankLabel.tickLocation = tickLocation;
        //            CPTAxisLabel *oldAxisLabel = [oldAxisLabels member:blankLabel];
        //
        //            if ( oldAxisLabel ) {
        //                newAxisLabel = oldAxisLabel;
        //            }
        //            else {
        //                newAxisLabel              = [[CPTAxisLabel alloc] initWithText:nil textStyle:nil];
        //                newAxisLabel.tickLocation = tickLocation;
        //                needsNewContentLayer      = true;
        //            }
        //
        //            newAxisLabel.rotation  = theLabelRotation;
        //            newAxisLabel.offset    = theLabelOffset;
        //            newAxisLabel.alignment = theLabelAlignment;
        //
        //            if ( needsNewContentLayer || theLabelFormatterChanged ) {
        //                CPTTextLayer *newLabelLayer = nil;
        //                if ( hasCategories ) {
        //                    NSString *labelString = [thePlotSpace categoryForCoordinate:myCoordinate atIndex:tickLocation.unsignedIntegerValue];
        //                    if ( labelString ) {
        //                        newLabelLayer = [[CPTTextLayer alloc] initWithText:labelString style:theLabelTextStyle];
        //                    }
        //                }
        //                else if ( hasAttributedFormatter ) {
        //                    NSAttributedString *labelString = [theLabelFormatter attributedStringForObjectValue:tickLocation withDefaultAttributes:textAttributes];
        //                    newLabelLayer = [[CPTTextLayer alloc] initWithAttributedText:labelString];
        //                }
        //                else {
        //                    NSString *labelString = [theLabelFormatter stringForObjectValue:tickLocation];
        //                    newLabelLayer = [[CPTTextLayer alloc] initWithText:labelString style:theLabelTextStyle];
        //                }
        //                [oldAxisLabel.contentLayer removeFromSuperlayer];
        //                if ( newLabelLayer ) {
        //                    newAxisLabel.contentLayer = newLabelLayer;
        //
        //                    if ( lastLayer ) {
        //                        [axisLabelGroup insertSublayer:newLabelLayer below:lastLayer];
        //                    }
        //                    else {
        //                        [axisLabelGroup insertSublayer:newLabelLayer atIndex:[thePlotArea sublayerIndexForAxis:self layerType:CPTGraphLayerTypeAxisLabels]];
        //                    }
        //                }
        //            }
        //
        //            lastLayer        = newAxisLabel.contentLayer;
        //            lastLayer.shadow = theShadow;
        //
        //            [newAxisLabels addObject:newAxisLabel];
        //        }
        //
        //        // remove old labels that are not needed any more from the layer hierarchy
        //        [oldAxisLabels minusSet:newAxisLabels];
        //        for ( CPTAxisLabel *label in oldAxisLabels ) {
        //            [label.contentLayer removeFromSuperlayer];
        //        }
        //
        //        self.labelsUpdated = true;
        //        if ( useMajorAxisLabels ) {
        //            self.axisLabels            = newAxisLabels;
        //            self.labelFormatterChanged = false
        //        }
        //        else {
        //            self.minorTickAxisLabels        = newAxisLabels;
        //            self.minorLabelFormatterChanged = false
        //        }
        //        self.labelsUpdated = false
        //    }
        //
        //    /// @endcond
        //
        //    /**
        //     *  @brief Marks the receiver as needing to update the labels before the content is next drawn.
        //     **/
        
        func setNeedsRelabel(_ newNeedsRelabel: var) {
            if newNeedsRelabel != needsRelabel {
                needsRelabel = newNeedsRelabel
                if needsRelabel {
                    setNeedsDisplay()
                    if separateLayers {
                        var gridlines = majorGridLines
                        gridlines.setNeedsDisplay()
                        
                        gridlines = minorGridLines
                        gridlines.setNeedsDisplay()
                    } else {
                        let thePlotArea = plotArea
                        thePlotArea.majorGridLineGroup!.setNeedsDisplay()
                        thePlotArea.minorGridLineGroup!.setNeedsDisplay()
                    }
                }
            }
        }
        
        func setNeedsRelabel()
        {
            self.needsRelabel = true
        }
        //        //    /**
        //     *  @brief Updates the axis labels.
        //     **/
        func relabel()
        {
            if ( !self.needsRelabel ) {
                return;
            }
            if ( !self.plotSpace != nil) {
                return;
            }
            let theDelegate = self.delegate;
            
            if ( [theDelegate respondsToSelector:@selector(axisShouldRelabel:)] && ![theDelegate axisShouldRelabel:self] ) {
                self.needsRelabel = false
                return;
            }
            
            var newMajorLocations = 0
            var newMinorLocations = 0
            
            switch ( self.labelingPolicy ) {
            case CPTAxisLabelingPolicyNone:
            case CPTAxisLabelingPolicyLocationsProvided:
                // Locations are set by user
                break;
                
            case CPTAxisLabelingPolicyFixedInterval:
                [self generateFixedIntervalMajorTickLocations:&newMajorLocations minorTickLocations:&newMinorLocations];
                break;
                
            case CPTAxisLabelingPolicyAutomatic:
                [self autoGenerateMajorTickLocations:&newMajorLocations minorTickLocations:&newMinorLocations];
                break;
                
            case CPTAxisLabelingPolicyEqualDivisions:
                [self generateEqualMajorTickLocations:&newMajorLocations minorTickLocations:&newMinorLocations];
                break;
            }
            
            switch ( self.labelingPolicy ) {
            case CPTAxisLabelingPolicyNone:
            case CPTAxisLabelingPolicyLocationsProvided:
                // Locations are set by user--no filtering required
                break;
                
            default:
                // Filter and set tick locations
                self.majorTickLocations = [self filteredMajorTickLocations:newMajorLocations];
                self.minorTickLocations = [self filteredMinorTickLocations:newMinorLocations];
            }
            
            // Label ticks
            switch ( self.labelingPolicy ) {
            case .none:
                self.updateCustomTickLabels()
                break;
                
            case .provided:
                {
                    CPTMutablePlotRange *labeledRange = [[self.plotSpace plotRangeForCoordinate:self.coordinate] mutableCopy];
                    CPTPlotRange *theVisibleRange     = self.visibleRange;
                    if ( theVisibleRange ) {
                        [labeledRange intersectionPlotRange:theVisibleRange];
                    }
                    
                    [self updateAxisLabelsAtLocations:self.majorTickLocations
                    inRange:labeledRange
                    useMajorAxisLabels:true];
                    
                    [self updateAxisLabelsAtLocations:self.minorTickLocations
                    inRange:labeledRange
                    useMajorAxisLabels:false];
                }
                break;
                
            default:
                [self updateAxisLabelsAtLocations(self.majorTickLocations
                                                  inRange:nil
                                                  useMajorAxisLabels:true)
                
                [self updateAxisLabelsAtLocations:self.minorTickLocations
                    inRange:nil
                    useMajorAxisLabels:false];
                    break;
            }
            
            self.needsRelabel = false
            if ( self.alternatingBandFills.count > 0 ) {
                let thePlotArea = self.plotArea;
                thePlotArea.setNeedsDisplay()
            }
            
            if ( [theDelegate respondsToSelector:@selector(axisDidRelabel:)] ) {
                [theDelegate axisDidRelabel:self];
            }
        }
        
        //    /// @cond
        //
        //    /**
        //     *  @internal
        //     *  @brief Updates the position of all custom labels, hiding the ones that are outside the visible range.
        //     */
        //   func updateCustomTickLabels
        //    {
        //        CPTMutablePlotRange *range = [[self.plotSpace plotRangeForCoordinate:self.coordinate] mutableCopy];
        //
        //        if ( range ) {
        //            CPTPlotRange *theVisibleRange = self.visibleRange;
        //            if ( theVisibleRange ) {
        //                [range intersectionPlotRange:theVisibleRange];
        //            }
        //
        //            if ( range.lengthDouble != 0.0 ) {
        //                CPTCoordinate orthogonalCoordinate = CPTOrthogonalCoordinate(self.coordinate);
        //
        //                CPTSign direction = self.tickLabelDirection;
        //
        //                if ( direction == CPTSignNone ) {
        //                    direction = self.tickDirection;
        //                }
        //
        //                for ( CPTAxisLabel *label in self.axisLabels ) {
        //                    var visible = [range containsNumber:label.tickLocation];
        //                    label.contentLayer.hidden = !visible;
        //                    if ( visible ) {
        //                        CGPoint tickBasePoint = [self viewPointForCoordinateValue:label.tickLocation];
        //                        [label positionRelativeToViewPoint:tickBasePoint forCoordinate:orthogonalCoordinate inDirection:direction];
        //                    }
        //                }
        //
        //                for ( CPTAxisLabel *label in self.minorTickAxisLabels ) {
        //                    var visible = [range containsNumber:label.tickLocation];
        //                    label.contentLayer.hidden = !visible;
        //                    if ( visible ) {
        //                        CGPoint tickBasePoint = [self viewPointForCoordinateValue:label.tickLocation];
        //                        [label positionRelativeToViewPoint:tickBasePoint forCoordinate:orthogonalCoordinate inDirection:direction];
        //                    }
        //                }
        //            }
        //        }
        //    }
        //
        //   func updateMajorTickLabelOffsets
        //    {
        //        CPTSign direction      = self.tickDirection;
        //        CPTSign labelDirection = self.tickLabelDirection;
        //
        //        if ( labelDirection == CPTSignNone ) {
        //            labelDirection = direction;
        //        }
        //
        //        CGFloat majorOffset = self.labelOffset;
        //
        //        if ((direction == CPTSignNone) || (labelDirection == direction)) {
        //            majorOffset += self.tickOffset;
        //        }
        //
        //        for ( CPTAxisLabel *label in self.axisLabels ) {
        //            label.offset = majorOffset;
        //        }
        //    }
        //
        //   func updateMinorTickLabelOffsets
        //    {
        //        CPTSign direction      = self.tickDirection;
        //        CPTSign labelDirection = self.minorTickLabelDirection;
        //
        //        if ( labelDirection == CPTSignNone ) {
        //            labelDirection = direction;
        //        }
        //
        //        CGFloat minorOffset = self.minorTickLabelOffset;
        //
        //        if ((direction == CPTSignNone) || (labelDirection == direction)) {
        //            minorOffset += self.tickOffset;
        //        }
        //
        //        for ( CPTAxisLabel *label in self.minorTickAxisLabels ) {
        //            label.offset = minorOffset;
        //        }
        //    }
        //
        //    /// @endcond
        //
        //    /**
        //     *  @brief Update the major tick mark labels.
        //     **/
        //   func updateMajorTickLabels
        //    {
        //        CPTCoordinate orthogonalCoordinate = CPTOrthogonalCoordinate(self.coordinate);
        //
        //        CPTSign direction = self.tickLabelDirection;
        //
        //        if ( direction == CPTSignNone ) {
        //            direction = self.tickDirection;
        //        }
        //
        //        for ( CPTAxisLabel *label in self.axisLabels ) {
        //            CGPoint tickBasePoint = [self viewPointForCoordinateValue:label.tickLocation];
        //            [label positionRelativeToViewPoint:tickBasePoint forCoordinate:orthogonalCoordinate inDirection:direction];
        //        }
        //    }
        //
        //    /**
        //     *  @brief Update the minor tick mark labels.
        //     **/
        //   func updateMinorTickLabels
        //    {
        //        CPTCoordinate orthogonalCoordinate = CPTOrthogonalCoordinate(self.coordinate);
        //
        //        CPTSign direction = self.minorTickLabelDirection;
        //
        //        if ( direction == CPTSignNone ) {
        //            direction = self.tickDirection;
        //        }
        //
        //        for ( CPTAxisLabel *label in self.minorTickAxisLabels ) {
        //            CGPoint tickBasePoint = [self viewPointForCoordinateValue:label.tickLocation];
        //            [label positionRelativeToViewPoint:tickBasePoint forCoordinate:orthogonalCoordinate inDirection:direction];
        //        }
        //    }
        //
        //    #pragma mark -
        //    #pragma mark Titles
        //
        //    -(nonnull NSNumber *)defaultTitleLocation
        //    {
        //        return @(NAN);
        //    }
        //
        //    /**
        //     *  @brief Update the axis title position.
        //     **/
        func updateAxisTitle()
        {
            var direction = self.titleDirection;
            
            if direction == .none {
                direction = self.tickDirection;
            }
            
            self.axisTitle.positionRelativeToViewPoint( self, viewPointForCoordinateValue:self.titleLocation
                                                         forCoordinate:CPTOrthogonalCoordinate(self.coordinate)
                                                         inDirection:direction)
            }
    }
        //
        //    #pragma mark -
        //    #pragma mark Layout
        //
        //    /// @name Layout
        //    /// @{
        //
        //    /**
        //     *  @brief Updates the layout of all sublayers. The axes are relabeled if needed and all axis labels are repositioned.
        //     *
        //     *  This is where we do our custom replacement for the Mac-only layout manager and autoresizing mask.
        //     *  Subclasses should override this method to provide a different layout of their own sublayers.
        //     **/
        //   func layoutSublayers
        //    {
        //        if ( self.needsRelabel ) {
        //            [self relabel];
        //        }
        //        else {
        //            [self updateMajorTickLabels];
        //            [self updateMinorTickLabels];
        //        }
        //        [self updateAxisTitle];
        //    }
        //
        //    /// @}
        //
        //    #pragma mark -
        //    #pragma mark Background Bands
        //
        //    /** @brief Add a background limit band.
        //     *  @param limitBand The new limit band.
        //     **/
        //   func addBackgroundLimitBand:(nullable CPTLimitBand *)limitBand
        //    {
        //        if ( limitBand ) {
        //            if ( !self.mutableBackgroundLimitBands ) {
        //                self.mutableBackgroundLimitBands = [NSMutableArray array];
        //            }
        //
        //            CPTLimitBand *band = limitBand;
        //            [self.mutableBackgroundLimitBands addObject:band];
        //
        //            CPTPlotArea *thePlotArea = self.plotArea;
        //            [thePlotArea setNeedsDisplay];
        //        }
        //    }
        //
        //    /** @brief Remove a background limit band.
        //     *  @param limitBand The limit band to be removed.
        //     **/
        //   func removeBackgroundLimitBand:(nullable CPTLimitBand *)limitBand
        //    {
        //        if ( limitBand ) {
        //            CPTLimitBand *band = limitBand;
        //            [self.mutableBackgroundLimitBands removeObject:band];
        //
        //            CPTPlotArea *thePlotArea = self.plotArea;
        //            [thePlotArea setNeedsDisplay];
        //        }
        //    }
        //
        //    /** @brief Remove all background limit bands.
        //    **/
        //   func removeAllBackgroundLimitBands
        //    {
        //        [self.mutableBackgroundLimitBands removeAllObjects];
        //
        //        CPTPlotArea *thePlotArea = self.plotArea;
        //
        //        [thePlotArea setNeedsDisplay];
        //    }
        //
        //    #pragma mark -
        //    #pragma mark Responder Chain and User Interaction
        //
        //    /// @name User Interaction
        //    /// @{
        //
        //    /**
        //     *  @brief Informs the receiver that the user has
        //     *  @if MacOnly pressed the mouse button. @endif
        //     *  @if iOSOnly started touching the screen. @endif
        //     *
        //     *
        //     *  If this axis has a delegate that responds to either
        //     *  @link CPTAxisDelegate::axis:labelTouchDown: -axis:labelTouchDown: @endlink or
        //     *  @link CPTAxisDelegate::axis:labelTouchDown:withEvent: -axis:labelTouchDown:withEvent: @endlink
        //     *  methods, the axis labels are searched to find the one containing the @par{interactionPoint}.
        //     *  The delegate method will be called and this method returns @true if the @par{interactionPoint} is within a label.
        //     *
        //     *  If this axis has a delegate that responds to either
        //     *  @link CPTAxisDelegate::axis:minorTickTouchDown: -axis:minorTickTouchDown: @endlink or
        //     *  @link CPTAxisDelegate::axis:minorTickTouchDown:withEvent: -axis:minorTickTouchDown:withEvent: @endlink
        //     *  methods, the minor tick axis labels are searched to find the one containing the @par{interactionPoint}.
        //     *  The delegate method will be called and this method returns @true if the @par{interactionPoint} is within a label.
        //     *
        //     *  This method returns @NO if the @par{interactionPoint} is outside all of the labels.
        //     *
        //     *  @param event The OS event.
        //     *  @param interactionPoint The coordinates of the interaction.
        //     *  @return Whether the event was handled or not.
        //     **/
        //    -(BOOL)pointingDeviceDownEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
        //    {
        //        CPTGraph *theGraph = self.graph;
        //
        //        if ( !theGraph || self.hidden ) {
        //            return false
        //        }
        //
        //        id<CPTAxisDelegate> theDelegate = (id<CPTAxisDelegate>)self.delegate;
        //
        //        // Tick labels
        //        if ( [theDelegate respondsToSelector:@selector(axis:labelTouchDown:)] ||
        //             [theDelegate respondsToSelector:@selector(axis:labelTouchDown:withEvent:)] ||
        //             [theDelegate respondsToSelector:@selector(axis:labelWasSelected:)] ||
        //             [theDelegate respondsToSelector:@selector(axis:labelWasSelected:withEvent:)] ) {
        //            for ( CPTAxisLabel *label in self.axisLabels ) {
        //                CPTLayer *contentLayer = label.contentLayer;
        //                if ( contentLayer && !contentLayer.hidden ) {
        //                    CGPoint labelPoint = [theGraph convertPoint:interactionPoint toLayer:contentLayer];
        //
        //                    if ( CGRectContainsPoint(contentLayer.bounds, labelPoint)) {
        //                        self.pointingDeviceDownLabel = label;
        //                        var handled = false
        //
        //                        if ( [theDelegate respondsToSelector:@selector(axis:labelTouchDown:)] ) {
        //                            handled = true;
        //                            [theDelegate axis:self labelTouchDown:label];
        //                        }
        //
        //                        if ( [theDelegate respondsToSelector:@selector(axis:labelTouchDown:withEvent:)] ) {
        //                            handled = true;
        //                            [theDelegate axis:self labelTouchDown:label withEvent:event];
        //                        }
        //
        //                        if ( handled ) {
        //                            return true;
        //                        }
        //                    }
        //                }
        //            }
        //        }
        //
        //        // Minor tick labels
        //        if ( [theDelegate respondsToSelector:@selector(axis:minorTickTouchDown:)] ||
        //             [theDelegate respondsToSelector:@selector(axis:minorTickTouchDown:withEvent:)] ||
        //             [theDelegate respondsToSelector:@selector(axis:minorTickLabelWasSelected:)] ||
        //             [theDelegate respondsToSelector:@selector(axis:minorTickLabelWasSelected:withEvent:)] ) {
        //            for ( CPTAxisLabel *label in self.minorTickAxisLabels ) {
        //                CPTLayer *contentLayer = label.contentLayer;
        //                if ( contentLayer && !contentLayer.hidden ) {
        //                    CGPoint labelPoint = [theGraph convertPoint:interactionPoint toLayer:contentLayer];
        //
        //                    if ( CGRectContainsPoint(contentLayer.bounds, labelPoint)) {
        //                        self.pointingDeviceDownTickLabel = label;
        //                        var handled = false
        //
        //                        if ( [theDelegate respondsToSelector:@selector(axis:minorTickTouchDown:)] ) {
        //                            handled = true;
        //                            [theDelegate axis:self minorTickTouchDown:label];
        //                        }
        //
        //                        if ( [theDelegate respondsToSelector:@selector(axis:minorTickTouchDown:withEvent:)] ) {
        //                            handled = true;
        //                            [theDelegate axis:self minorTickTouchDown:label withEvent:event];
        //                        }
        //
        //                        if ( handled ) {
        //                            return true;
        //                        }
        //                    }
        //                }
        //            }
        //        }
        //
        //        return [super pointingDeviceDownEvent:event atPoint:interactionPoint];
        //    }
        //
        //    /**
        //     *  @brief Informs the receiver that the user has
        //     *  @if MacOnly released the mouse button. @endif
        //     *  @if iOSOnly ended touching the screen. @endif
        //     *
        //     *
        //     *  If this axis has a delegate that responds to
        //     *  @link CPTAxisDelegate::axis:labelTouchUp: -axis:labelTouchUp: @endlink,
        //     *  @link CPTAxisDelegate::axis:labelTouchUp:withEvent: -axis:labelTouchUp:withEvent: @endlink
        //     *  @link CPTAxisDelegate::axis:labelWasSelected: -axis:labelWasSelected: @endlink, and/or
        //     *  @link CPTAxisDelegate::axis:labelWasSelected:withEvent: -axis:labelWasSelected:withEvent: @endlink
        //     *  methods, the axis labels are searched to find the one containing the @par{interactionPoint}.
        //     *  The delegate method will be called and this method returns @true if the @par{interactionPoint} is within a label.
        //     *
        //     *  If this axis has a delegate that responds to
        //     *  @link CPTAxisDelegate::axis:minorTickTouchUp: -axis:minorTickTouchUp: @endlink,
        //     *  @link CPTAxisDelegate::axis:minorTickTouchUp:withEvent: -axis:minorTickTouchUp:withEvent: @endlink
        //     *  @link CPTAxisDelegate::axis:minorTickLabelWasSelected: -axis:minorTickLabelWasSelected: @endlink, and/or
        //     *  @link CPTAxisDelegate::axis:minorTickLabelWasSelected:withEvent: -axis:minorTickLabelWasSelected:withEvent: @endlink
        //     *  methods, the minor tick axis labels are searched to find the one containing the @par{interactionPoint}.
        //     *  The delegate method will be called and this method returns @true if the @par{interactionPoint} is within a label.
        //     *
        //     *  This method returns @NO if the @par{interactionPoint} is outside all of the labels.
        //     *
        //     *  @param event The OS event.
        //     *  @param interactionPoint The coordinates of the interaction.
        //     *  @return Whether the event was handled or not.
        //     **/
        //    -(BOOL)pointingDeviceUpEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
        //    {
        //        CPTAxisLabel *selectedDownLabel     = self.pointingDeviceDownLabel;
        //        CPTAxisLabel *selectedDownTickLabel = self.pointingDeviceDownTickLabel;
        //
        //        self.pointingDeviceDownLabel     = nil;
        //        self.pointingDeviceDownTickLabel = nil;
        //
        //        CPTGraph *theGraph = self.graph;
        //
        //        if ( !theGraph || self.hidden ) {
        //            return false
        //        }
        //
        //        id<CPTAxisDelegate> theDelegate = (id<CPTAxisDelegate>)self.delegate;
        //
        //        // Tick labels
        //        if ( [theDelegate respondsToSelector:@selector(axis:labelTouchUp:)] ||
        //             [theDelegate respondsToSelector:@selector(axis:labelTouchUp:withEvent:)] ||
        //             [theDelegate respondsToSelector:@selector(axis:labelWasSelected:)] ||
        //             [theDelegate respondsToSelector:@selector(axis:labelWasSelected:withEvent:)] ) {
        //            for ( CPTAxisLabel *label in self.axisLabels ) {
        //                CPTLayer *contentLayer = label.contentLayer;
        //                if ( contentLayer && !contentLayer.hidden ) {
        //                    CGPoint labelPoint = [theGraph convertPoint:interactionPoint toLayer:contentLayer];
        //
        //                    if ( CGRectContainsPoint(contentLayer.bounds, labelPoint)) {
        //                        var handled = false
        //
        //                        if ( [theDelegate respondsToSelector:@selector(axis:labelTouchUp:)] ) {
        //                            handled = true;
        //                            [theDelegate axis:self labelTouchUp:label];
        //                        }
        //
        //                        if ( [theDelegate respondsToSelector:@selector(axis:labelTouchUp:withEvent:)] ) {
        //                            handled = true;
        //                            [theDelegate axis:self labelTouchUp:label withEvent:event];
        //                        }
        //
        //                        if ( label == selectedDownLabel ) {
        //                            if ( [theDelegate respondsToSelector:@selector(axis:labelWasSelected:)] ) {
        //                                handled = true;
        //                                [theDelegate axis:self labelWasSelected:label];
        //                            }
        //
        //                            if ( [theDelegate respondsToSelector:@selector(axis:labelWasSelected:withEvent:)] ) {
        //                                handled = true;
        //                                [theDelegate axis:self labelWasSelected:label withEvent:event];
        //                            }
        //                        }
        //
        //                        if ( handled ) {
        //                            return true;
        //                        }
        //                    }
        //                }
        //            }
        //        }
        //
        //        // Minor tick labels
        //        if ( [theDelegate respondsToSelector:@selector(axis:minorTickTouchUp:)] ||
        //             [theDelegate respondsToSelector:@selector(axis:minorTickTouchUp:withEvent:)] ||
        //             [theDelegate respondsToSelector:@selector(axis:minorTickLabelWasSelected:)] ||
        //             [theDelegate respondsToSelector:@selector(axis:minorTickLabelWasSelected:withEvent:)] ) {
        //            for ( CPTAxisLabel *label in self.minorTickAxisLabels ) {
        //                CPTLayer *contentLayer = label.contentLayer;
        //                if ( contentLayer && !contentLayer.hidden ) {
        //                    CGPoint labelPoint = [theGraph convertPoint:interactionPoint toLayer:contentLayer];
        //
        //                    if ( CGRectContainsPoint(contentLayer.bounds, labelPoint)) {
        //                        var handled = false
        //
        //                        if ( [theDelegate respondsToSelector:@selector(axis:minorTickTouchUp:)] ) {
        //                            handled = true;
        //                            [theDelegate axis:self minorTickTouchUp:label];
        //                        }
        //
        //                        if ( [theDelegate respondsToSelector:@selector(axis:minorTickTouchUp:withEvent:)] ) {
        //                            handled = true;
        //                            [theDelegate axis:self minorTickTouchUp:label withEvent:event];
        //                        }
        //
        //                        if ( label == selectedDownTickLabel ) {
        //                            if ( [theDelegate respondsToSelector:@selector(axis:minorTickLabelWasSelected:)] ) {
        //                                handled = true;
        //                                [theDelegate axis:self minorTickLabelWasSelected:label];
        //                            }
        //
        //                            if ( [theDelegate respondsToSelector:@selector(axis:minorTickLabelWasSelected:withEvent:)] ) {
        //                                handled = true;
        //                                [theDelegate axis:self minorTickLabelWasSelected:label withEvent:event];
        //                            }
        //                        }
        //
        //                        if ( handled ) {
        //                            return true;
        //                        }
        //                    }
        //                }
        //            }
        //        }
        //
        //        return [super pointingDeviceUpEvent:event atPoint:interactionPoint];
        //    }
        //
        //    /// @}
        //
        //    #pragma mark -
        //    #pragma mark Accessors
        //
        //    /// @cond
        //
        //   func setAxisLabels:(nullable CPTAxisLabelSet *)newLabels
        //    {
        //        if ( newLabels != axisLabels ) {
        //            if ( self.labelsUpdated ) {
        //                axisLabels = newLabels;
        //            }
        //            else {
        //                for ( CPTAxisLabel *label in axisLabels ) {
        //                    [label.contentLayer removeFromSuperlayer];
        //                }
        //
        //                axisLabels = newLabels;
        //
        //                CPTPlotArea *thePlotArea = self.plotArea;
        //                [thePlotArea updateAxisSetLayersForType:CPTGraphLayerTypeAxisLabels];
        //
        //                if ( axisLabels ) {
        //                    CPTAxisLabelGroup *axisLabelGroup = thePlotArea.axisLabelGroup;
        //                    CALayer *lastLayer                = nil;
        //
        //                    for ( CPTAxisLabel *label in axisLabels ) {
        //                        CPTLayer *contentLayer = label.contentLayer;
        //                        if ( contentLayer ) {
        //                            if ( lastLayer ) {
        //                                [axisLabelGroup insertSublayer:contentLayer below:lastLayer];
        //                            }
        //                            else {
        //                                [axisLabelGroup insertSublayer:contentLayer atIndex:[thePlotArea sublayerIndexForAxis:self layerType:CPTGraphLayerTypeAxisLabels]];
        //                            }
        //
        //                            lastLayer = contentLayer;
        //                        }
        //                    }
        //                }
        //            }
        //
        //            if ( self.labelingPolicy == CPTAxisLabelingPolicyNone ) {
        //                [self updateCustomTickLabels];
        //            }
        //            else {
        //                [self updateMajorTickLabels];
        //            }
        //        }
        //    }
        //
        //   func setMinorTickAxisLabels:(nullable CPTAxisLabelSet *)newLabels
        //    {
        //        if ( newLabels != minorTickAxisLabels ) {
        //            if ( self.labelsUpdated ) {
        //                minorTickAxisLabels = newLabels;
        //            }
        //            else {
        //                for ( CPTAxisLabel *label in minorTickAxisLabels ) {
        //                    [label.contentLayer removeFromSuperlayer];
        //                }
        //
        //                minorTickAxisLabels = newLabels;
        //
        //                CPTPlotArea *thePlotArea = self.plotArea;
        //                [thePlotArea updateAxisSetLayersForType:CPTGraphLayerTypeAxisLabels];
        //
        //                if ( minorTickAxisLabels ) {
        //                    CPTAxisLabelGroup *axisLabelGroup = thePlotArea.axisLabelGroup;
        //                    CALayer *lastLayer                = nil;
        //
        //                    for ( CPTAxisLabel *label in minorTickAxisLabels ) {
        //                        CPTLayer *contentLayer = label.contentLayer;
        //                        if ( contentLayer ) {
        //                            if ( lastLayer ) {
        //                                [axisLabelGroup insertSublayer:contentLayer below:lastLayer];
        //                            }
        //                            else {
        //                                [axisLabelGroup insertSublayer:contentLayer atIndex:[thePlotArea sublayerIndexForAxis:self layerType:CPTGraphLayerTypeAxisLabels]];
        //                            }
        //
        //                            lastLayer = contentLayer;
        //                        }
        //                    }
        //                }
        //            }
        //
        //            if ( self.labelingPolicy == CPTAxisLabelingPolicyNone ) {
        //                [self updateCustomTickLabels];
        //            }
        //            else {
        //                [self updateMinorTickLabels];
        //            }
        //        }
        //    }
        //
        //   func setLabelTextStyle:(nullable CPTTextStyle *)newStyle
        //    {
        //        if ( labelTextStyle != newStyle ) {
        //            labelTextStyle = [newStyle copy];
        //
        //            Class textLayerClass = [CPTTextLayer class];
        //            for ( CPTAxisLabel *axisLabel in self.axisLabels ) {
        //                CPTLayer *contentLayer = axisLabel.contentLayer;
        //                if ( [contentLayer isKindOfClass:textLayerClass] ) {
        //                    ((CPTTextLayer *)contentLayer).textStyle = labelTextStyle;
        //                }
        //            }
        //
        //            [self updateMajorTickLabels];
        //        }
        //    }
        //
        //   func setMinorTickLabelTextStyle:(nullable CPTTextStyle *)newStyle
        //    {
        //        if ( minorTickLabelTextStyle != newStyle ) {
        //            minorTickLabelTextStyle = [newStyle copy];
        //
        //            Class textLayerClass = [CPTTextLayer class];
        //            for ( CPTAxisLabel *axisLabel in self.minorTickAxisLabels ) {
        //                CPTLayer *contentLayer = axisLabel.contentLayer;
        //                if ( [contentLayer isKindOfClass:textLayerClass] ) {
        //                    ((CPTTextLayer *)contentLayer).textStyle = minorTickLabelTextStyle;
        //                }
        //            }
        //
        //            [self updateMinorTickLabels];
        //        }
        //    }
        //
        //   func setAxisTitle:(nullable CPTAxisTitle *)newTitle
        //    {
        //        if ( newTitle != axisTitle ) {
        //            [axisTitle.contentLayer removeFromSuperlayer];
        //            axisTitle = newTitle;
        //
        //            CPTPlotArea *thePlotArea = self.plotArea;
        //            [thePlotArea updateAxisSetLayersForType:CPTGraphLayerTypeAxisTitles];
        //
        //            if ( axisTitle ) {
        //                axisTitle.offset = self.titleOffset;
        //                CPTLayer *contentLayer = axisTitle.contentLayer;
        //                if ( contentLayer ) {
        //                    [thePlotArea.axisTitleGroup insertSublayer:contentLayer atIndex:[thePlotArea sublayerIndexForAxis:self layerType:CPTGraphLayerTypeAxisTitles]];
        //                    [self updateAxisTitle];
        //                }
        //            }
        //        }
        //    }
        //
        //    -(nullable CPTAxisTitle *)axisTitle
        //    {
        //        if ( !axisTitle ) {
        //            CPTAxisTitle *newTitle = nil;
        //
        //            if ( self.attributedTitle ) {
        //                CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithAttributedText:self.attributedTitle];
        //                newTitle = [[CPTAxisTitle alloc] initWithContentLayer:textLayer];
        //            }
        //            else if ( self.title ) {
        //                newTitle = [[CPTAxisTitle alloc] initWithText:self.title textStyle:self.titleTextStyle];
        //            }
        //
        //            if ( newTitle ) {
        //                newTitle.rotation = self.titleRotation;
        //                self.axisTitle    = newTitle;
        //            }
        //        }
        //        return axisTitle;
        //    }
        //
        //   func setTitleTextStyle:(nullable CPTTextStyle *)newStyle
        //    {
        //        if ( newStyle != titleTextStyle ) {
        //            titleTextStyle = [newStyle copy];
        //
        //            if ( !self.inTitleUpdate ) {
        //                self.inTitleUpdate   = true;
        //                self.attributedTitle = nil;
        //                self.inTitleUpdate   = false
        //
        //                CPTLayer *contentLayer = self.axisTitle.contentLayer;
        //                if ( [contentLayer isKindOfClass:[CPTTextLayer class]] ) {
        //                    ((CPTTextLayer *)contentLayer).textStyle = titleTextStyle;
        //                    [self updateAxisTitle];
        //                }
        //            }
        //        }
        //    }
        //
        //   func setTitleOffset:(CGFloat)newOffset
        //    {
        //        if ( newOffset != titleOffset ) {
        //            titleOffset = newOffset;
        //
        //            self.axisTitle.offset = titleOffset;
        //            [self updateAxisTitle];
        //        }
        //    }
        //
        //   func setTitleRotation:(CGFloat)newRotation
        //    {
        //        if ( newRotation != titleRotation ) {
        //            titleRotation = newRotation;
        //
        //            self.axisTitle.rotation = titleRotation;
        //            [self updateAxisTitle];
        //        }
        //    }
        //
        //   func setTitleDirection:(CPTSign)newDirection
        //    {
        //        if ( newDirection != titleDirection ) {
        //            titleDirection = newDirection;
        //
        //            [self updateAxisTitle];
        //        }
        //    }
        //
        //   func setTitle:(nullable NSString *)newTitle
        //    {
        //        if ( newTitle != title ) {
        //            title = [newTitle copy];
        //
        //            if ( !self.inTitleUpdate ) {
        //                self.inTitleUpdate   = true;
        //                self.attributedTitle = nil;
        //                self.inTitleUpdate   = false
        //
        //                if ( title ) {
        //                    CPTLayer *contentLayer = self.axisTitle.contentLayer;
        //                    if ( [contentLayer isKindOfClass:[CPTTextLayer class]] ) {
        //                        ((CPTTextLayer *)contentLayer).text = title;
        //                        [self updateAxisTitle];
        //                    }
        //                }
        //                else {
        //                    self.axisTitle = nil;
        //                }
        //            }
        //        }
        //    }
        //
        //   func setAttributedTitle:(nullable NSAttributedString *)newTitle
        //    {
        //        if ( newTitle != attributedTitle ) {
        //            attributedTitle = [newTitle copy];
        //
        //            if ( !self.inTitleUpdate ) {
        //                self.inTitleUpdate = true;
        //
        //                if ( attributedTitle ) {
        //                    self.titleTextStyle = [CPTTextStyle textStyleWithAttributes:[attributedTitle attributesAtIndex:0
        //                                                                                                    effectiveRange:NULL]];
        //                    self.title = attributedTitle.string;
        //
        //                    CPTLayer *contentLayer = self.axisTitle.contentLayer;
        //                    if ( [contentLayer isKindOfClass:[CPTTextLayer class]] ) {
        //                        ((CPTTextLayer *)contentLayer).attributedText = attributedTitle;
        //                        [self updateAxisTitle];
        //                    }
        //                }
        //                else {
        //                    self.titleTextStyle = nil;
        //                    self.title          = nil;
        //
        //                    self.axisTitle = nil;
        //                }
        //
        //                self.inTitleUpdate = false
        //            }
        //        }
        //    }
        //
        //   func setTitleLocation:(nullable NSNumber *)newLocation
        //    {
        //        var needsUpdate = true;
        //
        //        if ( newLocation ) {
        //            NSNumber *location = newLocation;
        //            needsUpdate = ![titleLocation isEqualToNumber:location];
        //        }
        //
        //        if ( needsUpdate ) {
        //            titleLocation = newLocation;
        //            [self updateAxisTitle];
        //        }
        //    }
        //
        //    -(nullable NSNumber *)titleLocation
        //    {
        //        if ( isnan(titleLocation.doubleValue)) {
        //            return self.defaultTitleLocation;
        //        }
        //        else {
        //            return titleLocation;
        //        }
        //    }
        //
        //   func setLabelExclusionRanges:(nullable CPTPlotRangeArray *)ranges
        //    {
        //        if ( ranges != labelExclusionRanges ) {
        //            labelExclusionRanges = ranges;
        //            self.needsRelabel    = true;
        //        }
        //    }
        //
        
        
        
        //   func setMajorTickLocations:(nullable CPTNumberSet *)newLocations
        //    {
        //        if ( newLocations != majorTickLocations ) {
        //            majorTickLocations = newLocations;
        //            if ( self.separateLayers ) {
        //                CPTGridLines *gridlines = self.majorGridLines;
        //                [gridlines setNeedsDisplay];
        //            }
        //            else {
        //                CPTPlotArea *thePlotArea = self.plotArea;
        //                [thePlotArea.majorGridLineGroup setNeedsDisplay];
        //            }
        //
        //            self.needsRelabel = true;
        //        }
        //    }
        //
        //   func setMinorTickLocations:(nullable CPTNumberSet *)newLocations
        //    {
        //        if ( newLocations != minorTickLocations ) {
        //            minorTickLocations = newLocations;
        //            if ( self.separateLayers ) {
        //                CPTGridLines *gridlines = self.minorGridLines;
        //                [gridlines setNeedsDisplay];
        //            }
        //            else {
        //                CPTPlotArea *thePlotArea = self.plotArea;
        //                [thePlotArea.minorGridLineGroup setNeedsDisplay];
        //            }
        //
        //            self.needsRelabel = true;
        //        }
        //    }
        //
        //   func setMajorTickLength:(CGFloat)newLength
        //    {
        //        if ( newLength != majorTickLength ) {
        //            majorTickLength = newLength;
        //
        //            [self updateMajorTickLabelOffsets];
        //            [self updateMinorTickLabelOffsets];
        //
        //            [self setNeedsDisplay];
        //            [self updateMajorTickLabels];
        //            [self updateMinorTickLabels];
        //        }
        //    }
        //
        //   func setMinorTickLength:(CGFloat)newLength
        //    {
        //        if ( newLength != minorTickLength ) {
        //            minorTickLength = newLength;
        //            [self setNeedsDisplay];
        //        }
        //    }
        //
        //   func setLabelOffset:(CGFloat)newOffset
        //    {
        //        if ( newOffset != labelOffset ) {
        //            labelOffset = newOffset;
        //
        //            [self updateMajorTickLabelOffsets];
        //            [self updateMajorTickLabels];
        //        }
        //    }
        //
        //   func setMinorTickLabelOffset:(CGFloat)newOffset
        //    {
        //        if ( newOffset != minorTickLabelOffset ) {
        //            minorTickLabelOffset = newOffset;
        //
        //            [self updateMinorTickLabelOffsets];
        //            [self updateMinorTickLabels];
        //        }
        //    }
        //
        //   func setLabelRotation:(CGFloat)newRotation
        //    {
        //        if ( newRotation != labelRotation ) {
        //            labelRotation = newRotation;
        //            for ( CPTAxisLabel *label in self.axisLabels ) {
        //                label.rotation = labelRotation;
        //            }
        //            [self updateMajorTickLabels];
        //        }
        //    }
        //
        //   func setMinorTickLabelRotation:(CGFloat)newRotation
        //    {
        //        if ( newRotation != minorTickLabelRotation ) {
        //            minorTickLabelRotation = newRotation;
        //            for ( CPTAxisLabel *label in self.minorTickAxisLabels ) {
        //                label.rotation = minorTickLabelRotation;
        //            }
        //            [self updateMinorTickLabels];
        //        }
        //    }
        //
        //   func setLabelAlignment:(CPTAlignment)newAlignment
        //    {
        //        if ( newAlignment != labelAlignment ) {
        //            labelAlignment = newAlignment;
        //            [self updateMajorTickLabels];
        //        }
        //    }
        //
        //   func setMinorTickLabelAlignment:(CPTAlignment)newAlignment
        //    {
        //        if ( newAlignment != minorTickLabelAlignment ) {
        //            minorTickLabelAlignment = newAlignment;
        //            [self updateMinorTickLabels];
        //        }
        //    }
        //
        //   func setLabelShadow:(nullable CPTShadow *)newLabelShadow
        //    {
        //        if ( newLabelShadow != labelShadow ) {
        //            labelShadow = newLabelShadow;
        //            for ( CPTAxisLabel *label in self.axisLabels ) {
        //                label.contentLayer.shadow = labelShadow;
        //            }
        //            [self updateMajorTickLabels];
        //        }
        //    }
        //
        //   func setMinorTickLabelShadow:(nullable CPTShadow *)newLabelShadow
        //    {
        //        if ( newLabelShadow != minorTickLabelShadow ) {
        //            minorTickLabelShadow = newLabelShadow;
        //            for ( CPTAxisLabel *label in self.minorTickAxisLabels ) {
        //                label.contentLayer.shadow = minorTickLabelShadow;
        //            }
        //            [self updateMinorTickLabels];
        //        }
        //    }
        //
        //   func setPlotSpace:(nullable CPTPlotSpace *)newSpace
        //    {
        //        if ( newSpace != plotSpace ) {
        //            plotSpace         = newSpace;
        //            self.needsRelabel = true;
        //        }
        //    }
        //
        //   func setCoordinate:(CPTCoordinate)newCoordinate
        //    {
        //        if ( newCoordinate != coordinate ) {
        //            coordinate        = newCoordinate;
        //            self.needsRelabel = true;
        //        }
        //    }
        //
        //   func setAxisLineStyle:(nullable CPTLineStyle *)newLineStyle
        //    {
        //        if ( newLineStyle != axisLineStyle ) {
        //            axisLineStyle = [newLineStyle copy];
        //            [self setNeedsDisplay];
        //        }
        //    }
        //
        //   func setMajorTickLineStyle:(nullable CPTLineStyle *)newLineStyle
        //    {
        //        if ( newLineStyle != majorTickLineStyle ) {
        //            majorTickLineStyle = [newLineStyle copy];
        //            [self setNeedsDisplay];
        //        }
        //    }
        //
        //   func setMinorTickLineStyle:(nullable CPTLineStyle *)newLineStyle
        //    {
        //        if ( newLineStyle != minorTickLineStyle ) {
        //            minorTickLineStyle = [newLineStyle copy];
        //            [self setNeedsDisplay];
        //        }
        //    }
        //
        func setMajorGridLineStyle(newLineStyle: CPTLineStyle )
        {
            if ( newLineStyle != majorGridLineStyle ) {
                majorGridLineStyle = newLineStyle
                
                let thePlotArea = self.plotArea;
                thePlotArea = updateAxisSetLayersForType( .ajorGridLines)
                
                if ( self.separateLayers ) {
                    if majorGridLineStyle {
                        var gridLines = self.majorGridLines;
                        
                        if gridLines {
                            gridLines.setNeedsDisplay()
                        }
                        else {
                            gridLines           = CPTGridLines()
                            self.majorGridLines = gridLines;
                        }
                    }
                    else {
                        self.majorGridLines = nil
                    }
                }
                else {
                    thePlotArea.majorGridLineGroup!.setNeedsDisplay()
                }
            }
        }
        //
        //   func setMinorGridLineStyle:(nullable CPTLineStyle *)newLineStyle
        //    {
        //        if ( newLineStyle != minorGridLineStyle ) {
        //            minorGridLineStyle = [newLineStyle copy];
        //
        //            CPTPlotArea *thePlotArea = self.plotArea;
        //            [thePlotArea updateAxisSetLayersForType:CPTGraphLayerTypeMinorGridLines];
        //
        //            if ( self.separateLayers ) {
        //                if ( minorGridLineStyle ) {
        //                    CPTGridLines *gridLines = self.minorGridLines;
        //
        //                    if ( gridLines ) {
        //                        [gridLines setNeedsDisplay];
        //                    }
        //                    else {
        //                        gridLines           = [[CPTGridLines alloc] init];
        //                        self.minorGridLines = gridLines;
        //                    }
        //                }
        //                else {
        //                    self.minorGridLines = nil;
        //                }
        //            }
        //            else {
        //                [thePlotArea.minorGridLineGroup setNeedsDisplay];
        //            }
        //        }
        //    }
        //
        //   func setAxisLineCapMin:(nullable CPTLineCap *)newAxisLineCapMin
        //    {
        //        if ( newAxisLineCapMin != axisLineCapMin ) {
        //            axisLineCapMin = [newAxisLineCapMin copy];
        //            [self setNeedsDisplay];
        //        }
        //    }
        //
        //   func setAxisLineCapMax:(nullable CPTLineCap *)newAxisLineCapMax
        //    {
        //        if ( newAxisLineCapMax != axisLineCapMax ) {
        //            axisLineCapMax = [newAxisLineCapMax copy];
        //            [self setNeedsDisplay];
        //        }
        //    }
        //
        //   func setLabelingOrigin:(nonnull NSNumber *)newLabelingOrigin
        //    {
        //        var needsUpdate = true;
        //
        //        if ( newLabelingOrigin ) {
        //            needsUpdate = ![labelingOrigin isEqualToNumber:newLabelingOrigin];
        //        }
        //
        //        if ( needsUpdate ) {
        //            labelingOrigin = newLabelingOrigin;
        //
        //            self.needsRelabel = true;
        //        }
        //    }
        //
        //   func setMajorIntervalLength:(nullable NSNumber *)newIntervalLength
        //    {
        //        var needsUpdate = true;
        //
        //        if ( newIntervalLength ) {
        //            NSNumber *interval = newIntervalLength;
        //            needsUpdate = ![majorIntervalLength isEqualToNumber:interval];
        //        }
        //
        //        if ( needsUpdate ) {
        //            majorIntervalLength = newIntervalLength;
        //
        //            self.needsRelabel = true;
        //        }
        //    }
        //
        //   func setMinorTicksPerInterval:(NSUInteger)newMinorTicksPerInterval
        //    {
        //        if ( newMinorTicksPerInterval != minorTicksPerInterval ) {
        //            minorTicksPerInterval = newMinorTicksPerInterval;
        //
        //            self.needsRelabel = true;
        //        }
        //    }
        //
        //   func setLabelingPolicy:(CPTAxisLabelingPolicy)newPolicy
        //    {
        //        if ( newPolicy != labelingPolicy ) {
        //            labelingPolicy    = newPolicy;
        //            self.needsRelabel = true;
        //        }
        //    }
        //
        //   func setPreferredNumberOfMajorTicks:(NSUInteger)newPreferredNumberOfMajorTicks
        //    {
        //        if ( newPreferredNumberOfMajorTicks != preferredNumberOfMajorTicks ) {
        //            preferredNumberOfMajorTicks = newPreferredNumberOfMajorTicks;
        //            if ( self.labelingPolicy == CPTAxisLabelingPolicyAutomatic ) {
        //                self.needsRelabel = true;
        //            }
        //        }
        //    }
        //
        //   func setLabelFormatter:(nullable NSFormatter *)newTickLabelFormatter
        //    {
        //        if ( newTickLabelFormatter != labelFormatter ) {
        //            labelFormatter = newTickLabelFormatter;
        //
        //            self.labelFormatterChanged = true;
        //            self.needsRelabel          = true;
        //        }
        //    }
        //
        //   func setMinorTickLabelFormatter:(nullable NSFormatter *)newMinorTickLabelFormatter
        //    {
        //        if ( newMinorTickLabelFormatter != minorTickLabelFormatter ) {
        //            minorTickLabelFormatter = newMinorTickLabelFormatter;
        //
        //            self.minorLabelFormatterChanged = true;
        //            self.needsRelabel               = true;
        //        }
        //    }
        //
        //   func setTickDirection:(CPTSign)newDirection
        //    {
        //        if ( newDirection != tickDirection ) {
        //            tickDirection = newDirection;
        //
        //            [self updateMajorTickLabelOffsets];
        //            [self updateMinorTickLabelOffsets];
        //
        //            [self setNeedsDisplay];
        //            [self updateMajorTickLabels];
        //            [self updateMinorTickLabels];
        //        }
        //    }
        //
        //   func setTickLabelDirection:(CPTSign)newDirection
        //    {
        //        if ( newDirection != tickLabelDirection ) {
        //            tickLabelDirection = newDirection;
        //
        //            [self updateMajorTickLabelOffsets];
        //            [self updateMajorTickLabels];
        //        }
        //    }
        //
        //   func setMinorTickLabelDirection:(CPTSign)newDirection
        //    {
        //        if ( newDirection != minorTickLabelDirection ) {
        //            minorTickLabelDirection = newDirection;
        //
        //            [self updateMinorTickLabelOffsets];
        //            [self updateMinorTickLabels];
        //        }
        //    }
        //
        //   func setGridLinesRange:(nullable CPTPlotRange *)newRange
        //    {
        //        if ( gridLinesRange != newRange ) {
        //            gridLinesRange = [newRange copy];
        //            if ( self.separateLayers ) {
        //                CPTGridLines *gridlines = self.majorGridLines;
        //                [gridlines setNeedsDisplay];
        //
        //                gridlines = self.minorGridLines;
        //                [gridlines setNeedsDisplay];
        //            }
        //            else {
        //                CPTPlotArea *thePlotArea = self.plotArea;
        //                [thePlotArea.majorGridLineGroup setNeedsDisplay];
        //                [thePlotArea.minorGridLineGroup setNeedsDisplay];
        //            }
        //        }
        //    }
        //
        //   func setPlotArea:(nullable CPTPlotArea *)newPlotArea
        //    {
        //        if ( newPlotArea != plotArea ) {
        //            plotArea = newPlotArea;
        //
        //            CPTGridLines *theMinorGridLines = self.minorGridLines;
        //            CPTGridLines *theMajorGridLines = self.majorGridLines;
        //
        //            if ( newPlotArea ) {
        //                [newPlotArea updateAxisSetLayersForType:CPTGraphLayerTypeMinorGridLines];
        //                if ( theMinorGridLines ) {
        //                    [theMinorGridLines removeFromSuperlayer];
        //                    [newPlotArea.minorGridLineGroup insertSublayer:theMinorGridLines atIndex:[newPlotArea sublayerIndexForAxis:self layerType:CPTGraphLayerTypeMinorGridLines]];
        //                }
        //
        //                [newPlotArea updateAxisSetLayersForType:CPTGraphLayerTypeMajorGridLines];
        //                if ( theMajorGridLines ) {
        //                    [theMajorGridLines removeFromSuperlayer];
        //                    [newPlotArea.majorGridLineGroup insertSublayer:theMajorGridLines atIndex:[newPlotArea sublayerIndexForAxis:self layerType:CPTGraphLayerTypeMajorGridLines]];
        //                }
        //
        //                [newPlotArea updateAxisSetLayersForType:CPTGraphLayerTypeAxisLabels];
        //                if ( self.axisLabels.count > 0 ) {
        //                    CPTAxisLabelGroup *axisLabelGroup = newPlotArea.axisLabelGroup;
        //                    CALayer *lastLayer                = nil;
        //
        //                    for ( CPTAxisLabel *label in self.axisLabels ) {
        //                        CPTLayer *contentLayer = label.contentLayer;
        //                        if ( contentLayer ) {
        //                            [contentLayer removeFromSuperlayer];
        //
        //                            if ( lastLayer ) {
        //                                [axisLabelGroup insertSublayer:contentLayer below:lastLayer];
        //                            }
        //                            else {
        //                                [axisLabelGroup insertSublayer:contentLayer atIndex:[newPlotArea sublayerIndexForAxis:self layerType:CPTGraphLayerTypeAxisLabels]];
        //                            }
        //
        //                            lastLayer = contentLayer;
        //                        }
        //                    }
        //                }
        //
        //                if ( self.minorTickAxisLabels.count > 0 ) {
        //                    CPTAxisLabelGroup *axisLabelGroup = newPlotArea.axisLabelGroup;
        //                    CALayer *lastLayer                = nil;
        //
        //                    for ( CPTAxisLabel *label in self.minorTickAxisLabels ) {
        //                        CPTLayer *contentLayer = label.contentLayer;
        //                        if ( contentLayer ) {
        //                            [contentLayer removeFromSuperlayer];
        //
        //                            if ( lastLayer ) {
        //                                [axisLabelGroup insertSublayer:contentLayer below:lastLayer];
        //                            }
        //                            else {
        //                                [axisLabelGroup insertSublayer:contentLayer atIndex:[newPlotArea sublayerIndexForAxis:self layerType:CPTGraphLayerTypeAxisLabels]];
        //                            }
        //
        //                            lastLayer = contentLayer;
        //                        }
        //                    }
        //                }
        //
        //                [newPlotArea updateAxisSetLayersForType:CPTGraphLayerTypeAxisTitles];
        //                CPTLayer *content = self.axisTitle.contentLayer;
        //                if ( content ) {
        //                    [content removeFromSuperlayer];
        //                    [newPlotArea.axisTitleGroup insertSublayer:content atIndex:[newPlotArea sublayerIndexForAxis:self layerType:CPTGraphLayerTypeAxisTitles]];
        //                }
        //            }
        //            else {
        //                [theMinorGridLines removeFromSuperlayer];
        //                [theMajorGridLines removeFromSuperlayer];
        //
        //                for ( CPTAxisLabel *label in self.axisLabels ) {
        //                    [label.contentLayer removeFromSuperlayer];
        //                }
        //                for ( CPTAxisLabel *label in self.minorTickAxisLabels ) {
        //                    [label.contentLayer removeFromSuperlayer];
        //                }
        //                [self.axisTitle.contentLayer removeFromSuperlayer];
        //            }
        //        }
        //    }
        //
        //   func setVisibleRange:(nullable CPTPlotRange *)newRange
        //    {
        //        if ( newRange != visibleRange ) {
        //            visibleRange      = [newRange copy];
        //            self.needsRelabel = true;
        //        }
        //    }
        //
        //   func setVisibleAxisRange:(nullable CPTPlotRange *)newRange
        //    {
        //        if ( newRange != visibleAxisRange ) {
        //            visibleAxisRange  = [newRange copy];
        //            self.needsRelabel = true;
        //        }
        //    }
        //
        //   func setSeparateLayers:(BOOL)newSeparateLayers
        //    {
        //        if ( newSeparateLayers != separateLayers ) {
        //            separateLayers = newSeparateLayers;
        //            if ( separateLayers ) {
        //                if ( self.minorGridLineStyle ) {
        //                    CPTGridLines *gridLines = [[CPTGridLines alloc] init];
        //                    self.minorGridLines = gridLines;
        //                }
        //                if ( self.majorGridLineStyle ) {
        //                    CPTGridLines *gridLines = [[CPTGridLines alloc] init];
        //                    self.majorGridLines = gridLines;
        //                }
        //            }
        //            else {
        //                CPTPlotArea *thePlotArea = self.plotArea;
        //                self.minorGridLines = nil;
        //                if ( self.minorGridLineStyle ) {
        //                    [thePlotArea.minorGridLineGroup setNeedsDisplay];
        //                }
        //                self.majorGridLines = nil;
        //                if ( self.majorGridLineStyle ) {
        //                    [thePlotArea.majorGridLineGroup setNeedsDisplay];
        //                }
        //            }
        //        }
        //    }
        //
        //   func setMinorGridLines:(nullable CPTGridLines *)newGridLines
        //    {
        //        CPTGridLines *oldGridLines = minorGridLines;
        //
        //        if ( newGridLines != oldGridLines ) {
        //            [oldGridLines removeFromSuperlayer];
        //            minorGridLines = newGridLines;
        //
        //            if ( newGridLines ) {
        //                CPTGridLines *gridLines = newGridLines;
        //
        //                gridLines.major = false
        //                gridLines.axis  = self;
        //
        //                CPTPlotArea *thePlotArea = self.plotArea;
        //                [thePlotArea.minorGridLineGroup insertSublayer:gridLines atIndex:[thePlotArea sublayerIndexForAxis:self layerType:CPTGraphLayerTypeMinorGridLines]];
        //            }
        //        }
        //    }
        //
        //   func setMajorGridLines:(nullable CPTGridLines *)newGridLines
        //    {
        //        CPTGridLines *oldGridLines = majorGridLines;
        //
        //        if ( newGridLines != oldGridLines ) {
        //            [oldGridLines removeFromSuperlayer];
        //            majorGridLines = newGridLines;
        //
        //            if ( newGridLines ) {
        //                CPTGridLines *gridLines = newGridLines;
        //
        //                gridLines.major = true;
        //                gridLines.axis  = self;
        //
        //                CPTPlotArea *thePlotArea = self.plotArea;
        //                [thePlotArea.majorGridLineGroup insertSublayer:gridLines atIndex:[thePlotArea sublayerIndexForAxis:self layerType:CPTGraphLayerTypeMajorGridLines]];
        //            }
        //        }
        //    }
        //
        //   func setAlternatingBandFills:(nullable CPTFillArray *)newFills
        //    {
        //        if ( newFills != alternatingBandFills ) {
        //            Class nullClass = [NSNull class];
        //            Class fillClass = [CPTFill class];
        //
        //            var convertFills = false
        //            for ( id obj in newFills ) {
        //                if ( [obj isKindOfClass:nullClass] || [obj isKindOfClass:fillClass] ) {
        //                    continue;
        //                }
        //                else {
        //                    convertFills = true;
        //                    break;
        //                }
        //            }
        //
        //            if ( convertFills ) {
        //                Class colorClass    = [CPTColor class];
        //                Class gradientClass = [CPTGradient class];
        //                Class imageClass    = [CPTImage class];
        //
        //                CPTMutableFillArray *fillArray = [newFills mutableCopy];
        //                NSUInteger i                   = 0;
        //                CPTFill *newFill               = nil;
        //
        //                for ( id obj in newFills ) {
        //                    if ( [obj isKindOfClass:nullClass] || [obj isKindOfClass:fillClass] ) {
        //                        i++;
        //                        continue;
        //                    }
        //                    else if ( [obj isKindOfClass:colorClass] ) {
        //                        newFill = [[CPTFill alloc] initWithColor:obj];
        //                    }
        //                    else if ( [obj isKindOfClass:gradientClass] ) {
        //                        newFill = [[CPTFill alloc] initWithGradient:obj];
        //                    }
        //                    else if ( [obj isKindOfClass:imageClass] ) {
        //                        newFill = [[CPTFill alloc] initWithImage:obj];
        //                    }
        //                    else {
        //                        [NSException raise:CPTException format:@"Alternating band fills must be one or more of the following: CPTFill, CPTColor, CPTGradient, CPTImage, or [NSNull null]."];
        //                    }
        //
        //                    fillArray[i] = newFill;
        //
        //                    i++;
        //                }
        //
        //                alternatingBandFills = fillArray;
        //            }
        //            else {
        //                alternatingBandFills = [newFills copy];
        //            }
        //
        //            CPTPlotArea *thePlotArea = self.plotArea;
        //            [thePlotArea setNeedsDisplay];
        //        }
        //    }
        //
        //   func setAlternatingBandAnchor:(nullable NSNumber *)newBandAnchor
        //    {
        //        if ( newBandAnchor != alternatingBandAnchor ) {
        //            alternatingBandAnchor = newBandAnchor;
        //
        //            CPTPlotArea *thePlotArea = self.plotArea;
        //            [thePlotArea setNeedsDisplay];
        //        }
        //    }
        //
        //    -(nullable CPTLimitBandArray *)backgroundLimitBands
        //    {
        //        return [self.mutableBackgroundLimitBands copy];
        //    }
        //
        //    -(nullable CPTAxisSet *)axisSet
        //    {
        //        CPTPlotArea *thePlotArea = self.plotArea;
        //
        //        return thePlotArea.axisSet;
        //    }
        //
        func setHidde(newHidden: Bool)
        {
            if ( newHidden != self.isHidden ) {
                super.isHidden = newHidden;
                self.setNeedsRelabel()
            }
        }
        
        // MARK: AbstractMethods
        //
        //    /** @brief Converts a position on the axis to drawing coordinates.
        //     *  @param coordinateValue The axis value in data coordinate space.
        //     *  @return The drawing coordinates of the point.
        //     **/
        func viewPointForCoordinateValue(coordinateValue:  NSNumber )-> CGPoint
        {
            return CGPoint()
        }
        //
        //    /** @brief Draws grid lines into the provided graphics context.
        //     *  @param context The graphics context to draw into.
        //     *  @param major Draw the major grid lines If @true, minor grid lines otherwise.
        //     **/
        func drawGridLinesInContext(context: CGContext, isMajor:Bool)
        {
            // do nothing--subclasses must override to do their drawing
        }
        
        /** @brief Draws alternating background bands into the provided graphics context.
         *  @param context The graphics context to draw into.
         **/
        func drawBackgroundBandsInContext(context: CGContext )
        {
            // do nothing--subclasses must override to do their drawing
        }
        
        /** @brief Draws background limit ranges into the provided graphics context.
         *  @param context The graphics context to draw into.
         **/
        func drawBackgroundLimitsInContext(context: CGContext)
        {
            // do nothing--subclasses must override to do their drawing
        }
    }
}
