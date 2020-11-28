//
//  CPTBarPlot.swift
//  corePlot
//
//  Created by thierryH24 on 11/11/2020.
//

import AppKit



class CPTBarPlot: CPTPlot {
    
    enum  CPTBarPlotField  :Int {
       case location ///< Bar location on independent coordinate axis.
        case barTip      ///< Bar tip value.
        case barBase      ///< Bar base (used only if @link CPTBarPlot::barBasesVary barBasesVary @endlink is YES).
    };

    
//    typedef NSString *CPTBarPlotBinding cpt_swift_struct;
    
    let CPTBarPlotBindingBarLocations  = "barLocations"  ///< Bar locations.
    let CPTBarPlotBindingBarTips       = "barTips"       ///< Bar tips.
    let CPTBarPlotBindingBarBases      = "barBases"      ///< Bar bases.
    let CPTBarPlotBindingBarFills      = "barFills"      ///< Bar fills.
    let CPTBarPlotBindingBarLineStyles = "barLineStyles" ///< Bar line styles.
    let CPTBarPlotBindingBarWidths     = "barWidths"     ///< Bar widths.

   var  barLocations = [CGFloat]()
   var barTips  = [CGFloat]()
   var barBases  = [CGFloat]()
   var barFills = [CPTFill]()
   var barLineStyles  = [CPTLineStyle]()
   var barWidths  = [CPTLineStyle]()
   var pointingDeviceDownIndex = 0


    
    
    // MARK: Appearance
    var barWidthsAreInViewCoordinates = true
    var barWidth = CGFloat(0.0)
    var barOffset : CGFloat
    var barCornerRadius : CGFloat
    var barBaseCornerRadius : CGFloat
    var barsAreHorizontal : Bool
    var baseValue : CGFloat
    var barBasesVary : Bool
    var plotRange : CPTPlotRange

    // MARK: Drawing
    var  lineStyle : CPTLineStyle
    var  fill : CPTFill
//
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

     func tubularBarPlot(with color: NSUIColor, horizontalBars horizontal: Bool) -> Self {

        let barPlot = CPTBarPlot()
        let barLineStyle = CPTMutableLineStyle()

        barLineStyle.lineWidth = CGFloat(1.0)
        barLineStyle.lineColor = CPTColor.black()

        barPlot?.lineStyle = barLineStyle
        barPlot.barsAreHorizontal = horizontal
        barPlot.barWidth = CGFloat( 0.8)
        barPlot.barCornerRadius = CGFloat(2.0)

        let fillGradient = CPTGradient(beginningColor: color, endingColor: NSUIColor.black)

        fillGradient.angle = CGFloat(horizontal ? -90.0 : 0.0)
        barPlot?.fill = CPTFill(gradient: fillGradient)

        barPlot.barWidthsAreInViewCoordinates = false

        return barPlot
    }

    override init() {
            CPTBarPlot.exposeBinding(NSBindingName(rawValue: CPTBarPlotBindingBarLocations))
            CPTBarPlot.exposeBinding(NSBindingName(rawValue: CPTBarPlotBindingBarTips))
            CPTBarPlot.exposeBinding(NSBindingName(rawValue: CPTBarPlotBindingBarBases))
            CPTBarPlot.exposeBinding(NSBindingName(rawValue: CPTBarPlotBindingBarFills))
            CPTBarPlot.exposeBinding(NSBindingName(rawValue: CPTBarPlotBindingBarLineStyles))
            CPTBarPlot.exposeBinding(NSBindingName(rawValue: CPTBarPlotBindingBarWidths))
        
    }
    
    override func reloadData(indexRange: NSRange)
    {
        super.reloadData(indexRange: indexRange)

        // Bar fills
        self.reloadBarFills(indexRange)

        // Bar line styles
        self.reloadBarLineStyles(indexRange)

        // Bar widths
        self.reloadBarWidths(indexRange)

        // Legend
        let theDataSource = self.dataSource;

        if theDataSource.respondsToSelector(#selector(legendTitleForBarPlot(recordIndex:) )) {
            NotificationCenter.default.send( .CPTLegendNeedsLayindexRange: outForPlotNotification)
        }
    }

    func reloadPlotData(indexRange: NSRange)
    {
    super.reloadPlotData(indexRange)

    if  self.loadNumbersForAllFieldsFromDataSourceInRecordIndexRange(indexRange)  == false {
            let  theDataSource = self.dataSource

            // Bar lengths
        if ( theDataSource ) != nil {
                let newBarLengths = self.numbersFromDataSourceForField(.barTip, recordIndexRange:indexRange)
                [self.cacheNumbers:newBarLengths forField:.barTip atRecordIndex:indexRange.location];
                    
                    
                if  self.barBasesVary  {
                    let newBarBases = self.numbersFromDataSourceForField( .barBase recordIndexRange:indexRange)
                    [self.cacheNumbers(newBarBases, forField:.barBase, atRecordIndex:indexRange.location)
                }
                else {
                    self.barBases = nil;
                }
            }
            else {
                self.barTips  = nil
                self.barBases = nil
            }

            // Locations of bars
            if self.plotRange {
                // Spread bars evenly over the plot range
                CPTMutableNumericData *locationData = nil;
                if ( self.doublePrecisionCache ) {
                    locationData = [[CPTMutableNumericData alloc] initWithData:[NSData data]
                                                                      dataType:CPTDataType(CPTFloatingPointDataType, sizeof(double), CFByteOrderGetCurrent())
                                                                         shape:nil];
                    locationData.shape = @[@(indexRange.length)];

                    let doublePrecisionDelta = 1.0;
                    if ( indexRange.length > 1 ) {
                        doublePrecisionDelta = self.plotRange.lengthDouble / (double)(indexRange.length - 1);
                    }

                    let locationDouble = self.plotRange.locationDouble;
                    let dataBytes     = locationData.mutableBytes;
                    let dataEnd       = dataBytes + indexRange.length;
                    while ( dataBytes < dataEnd ) {
                        *dataBytes++    = locationDouble;
                        locationDouble += doublePrecisionDelta;
                    }
                }
                else {
                    locationData = [[CPTMutableNumericData alloc] initWithData:[NSData data]
                                                                      dataType:CPTDataType(CPTDecimalDataType, sizeof(NSDecimal), CFByteOrderGetCurrent())
                                                                         shape:nil];
                    locationData.shape = @[@(indexRange.length)];

                    NSDecimal delta = CPTDecimalFromInteger(1);
                    if ( indexRange.length > 1 ) {
                        delta = CPTDecimalDivide(self.plotRange.lengthDecimal, CPTDecimalFromUnsignedInteger(indexRange.length - 1));
                    }

                    let locationDecimal = self.plotRange.locationDecimal;
                    NSDecimal *dataBytes      = (NSDecimal *)locationData.mutableBytes;
                    NSDecimal *dataEnd        = dataBytes + indexRange.length;
                    while ( dataBytes < dataEnd ) {
                        *dataBytes++    = locationDecimal;
                        locationDecimal = CPTDecimalAdd(locationDecimal, delta);
                    }
                }
                self cacheNumbers:locationData forField:CPTBarPlotFieldBarLocation atRecordIndex:indexRange.location];
            }
            else if ( theDataSource ) {
                // Get locations from the datasource
                id newBarLocations = [self numbersFromDataSourceForField:CPTBarPlotFieldBarLocation recordIndexRange:indexRange];
                [self cacheNumbers:newBarLocations forField:CPTBarPlotFieldBarLocation atRecordIndex:indexRange.location];
            }
            else {
                // Make evenly spaced locations starting at zero
                CPTMutableNumericData *locationData = nil;
                if ( self.doublePrecisionCache ) {
                    locationData = [[CPTMutableNumericData alloc] initWithData:[NSData data]
                                                                      dataType:CPTDataType(CPTFloatingPointDataType, sizeof(double), CFByteOrderGetCurrent())
                                                                         shape:nil];
                    locationData.shape = @[@(indexRange.length)];

                    double locationDouble = 0.0;
                    double *dataBytes     = (double *)locationData.mutableBytes;
                    double *dataEnd       = dataBytes + indexRange.length;
                    while ( dataBytes < dataEnd ) {
                        *dataBytes++    = locationDouble;
                        locationDouble += 1.0;
                    }
                }
                else {
                    locationData = [[CPTMutableNumericData alloc] initWithData:[NSData data]
                                                                      dataType:CPTDataType(CPTDecimalDataType, sizeof(NSDecimal), CFByteOrderGetCurrent())
                                                                         shape:nil];
                    locationData.shape = @[@(indexRange.length)];

                    NSDecimal locationDecimal = CPTDecimalFromInteger(0);
                    NSDecimal *dataBytes      = (NSDecimal *)locationData.mutableBytes;
                    NSDecimal *dataEnd        = dataBytes + indexRange.length;
                    NSDecimal one             = CPTDecimalFromInteger(1);
                    while ( dataBytes < dataEnd ) {
                        *dataBytes++    = locationDecimal;
                        locationDecimal = CPTDecimalAdd(locationDecimal, one);
                    }
                }
                [self cacheNumbers:locationData forField:CPTBarPlotFieldBarLocation atRecordIndex:indexRange.location];
            }
        }
    }

//    /// @endcond
//
//    /**
//     *  @brief Reload all bar fills from the data source immediately.
//     **/
//    -(void)reloadBarFills
//    {
//        [self reloadBarFillsInIndexRange:NSMakeRange(0, self.cachedDataCount)];
//    }
//
//    /** @brief Reload bar fills in the given index range from the data source immediately.
//     *  @param indexRange The index range to load.
//     **/
//    -(void)reloadBarFillsInIndexRange:(NSRange)indexRange
//    {
//        id<CPTBarPlotDataSource> theDataSource = (id<CPTBarPlotDataSource>)self.dataSource;
//
//        BOOL needsLegendUpdate = NO;
//
//        if ( [theDataSource respondsToSelector:@selector(barFillsForBarPlot:recordIndexRange:)] ) {
//            needsLegendUpdate = YES;
//
//            [self cacheArray:[theDataSource barFillsForBarPlot:self recordIndexRange:indexRange]
//                      forKey:CPTBarPlotBindingBarFills
//               atRecordIndex:indexRange.location];
//        }
//        else if ( [theDataSource respondsToSelector:@selector(barFillForBarPlot:recordIndex:)] ) {
//            needsLegendUpdate = YES;
//
//            id nilObject               = [CPTPlot nilData];
//            CPTMutableFillArray *array = [[NSMutableArray alloc] initWithCapacity:indexRange.length];
//            NSUInteger maxIndex        = NSMaxRange(indexRange);
//
//            for ( NSUInteger idx = indexRange.location; idx < maxIndex; idx++ ) {
//                CPTFill *dataSourceFill = [theDataSource barFillForBarPlot:self recordIndex:idx];
//                if ( dataSourceFill ) {
//                    [array addObject:dataSourceFill];
//                }
//                else {
//                    [array addObject:nilObject];
//                }
//            }
//
//            [self cacheArray:array
//                      forKey:CPTBarPlotBindingBarFills
//               atRecordIndex:indexRange.location];
//        }
//
//        // Legend
//        if ( needsLegendUpdate ) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
//        }
//
//        [self setNeedsDisplay];
//    }
//
//    /**
//     *  @brief Reload all bar line styles from the data source immediately.
//     **/
//    -(void)reloadBarLineStyles
//    {
//        [self reloadBarLineStylesInIndexRange:NSMakeRange(0, self.cachedDataCount)];
//    }
//
//    /** @brief Reload bar line styles in the given index range from the data source immediately.
//     *  @param indexRange The index range to load.
//     **/
//    -(void)reloadBarLineStylesInIndexRange:(NSRange)indexRange
//    {
//        id<CPTBarPlotDataSource> theDataSource = (id<CPTBarPlotDataSource>)self.dataSource;
//
//        BOOL needsLegendUpdate = NO;
//
//        if ( [theDataSource respondsToSelector:@selector(barLineStylesForBarPlot:recordIndexRange:)] ) {
//            needsLegendUpdate = YES;
//
//            [self cacheArray:[theDataSource barLineStylesForBarPlot:self recordIndexRange:indexRange]
//                      forKey:CPTBarPlotBindingBarLineStyles
//               atRecordIndex:indexRange.location];
//        }
//        else if ( [theDataSource respondsToSelector:@selector(barLineStyleForBarPlot:recordIndex:)] ) {
//            needsLegendUpdate = YES;
//
//            id nilObject                    = [CPTPlot nilData];
//            CPTMutableLineStyleArray *array = [[NSMutableArray alloc] initWithCapacity:indexRange.length];
//            NSUInteger maxIndex             = NSMaxRange(indexRange);
//
//            for ( NSUInteger idx = indexRange.location; idx < maxIndex; idx++ ) {
//                CPTLineStyle *dataSourceLineStyle = [theDataSource barLineStyleForBarPlot:self recordIndex:idx];
//                if ( dataSourceLineStyle ) {
//                    [array addObject:dataSourceLineStyle];
//                }
//                else {
//                    [array addObject:nilObject];
//                }
//            }
//
//            [self cacheArray:array
//                      forKey:CPTBarPlotBindingBarLineStyles
//               atRecordIndex:indexRange.location];
//        }
//
//        // Legend
//        if ( needsLegendUpdate ) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
//        }
//
//        [self setNeedsDisplay];
//    }
//
//    /**
//     *  @brief Reload all bar widths from the data source immediately.
//     **/
//    -(void)reloadBarWidths
//    {
//        [self reloadBarWidthsInIndexRange:NSMakeRange(0, self.cachedDataCount)];
//    }
//
//    /** @brief Reload bar widths in the given index range from the data source immediately.
//     *  @param indexRange The index range to load.
//     **/
//    -(void)reloadBarWidthsInIndexRange:(NSRange)indexRange
//    {
//        id<CPTBarPlotDataSource> theDataSource = (id<CPTBarPlotDataSource>)self.dataSource;
//
//        if ( [theDataSource respondsToSelector:@selector(barWidthsForBarPlot:recordIndexRange:)] ) {
//            [self cacheArray:[theDataSource barWidthsForBarPlot:self recordIndexRange:indexRange]
//                      forKey:CPTBarPlotBindingBarWidths
//               atRecordIndex:indexRange.location];
//        }
//        else if ( [theDataSource respondsToSelector:@selector(barWidthForBarPlot:recordIndex:)] ) {
//            id nilObject                 = [CPTPlot nilData];
//            CPTMutableNumberArray *array = [[NSMutableArray alloc] initWithCapacity:indexRange.length];
//            NSUInteger maxIndex          = NSMaxRange(indexRange);
//
//            for ( NSUInteger idx = indexRange.location; idx < maxIndex; idx++ ) {
//                NSNumber *width = [theDataSource barWidthForBarPlot:self recordIndex:idx];
//                if ( width ) {
//                    [array addObject:width];
//                }
//                else {
//                    [array addObject:nilObject];
//                }
//            }
//
//            [self cacheArray:array
//                      forKey:CPTBarPlotBindingBarWidths
//               atRecordIndex:indexRange.location];
//        }
//
//        [self setNeedsDisplay];
//    }
//
//    #pragma mark -
//    #pragma mark Length Conversions for Independent Coordinate (e.g., widths, offsets)
//
//    /// @cond
//
//    -(CGFloat)lengthInView:(NSDecimal)decimalLength
//    {
//        CGFloat length;
//
//        if ( self.barWidthsAreInViewCoordinates ) {
//            length = CPTDecimalCGFloatValue(decimalLength);
//        }
//        else {
//            CPTCoordinate coordinate     = (self.barsAreHorizontal ? CPTCoordinateY : CPTCoordinateX);
//            CPTXYPlotSpace *thePlotSpace = (CPTXYPlotSpace *)self.plotSpace;
//            NSDecimal xLocation          = thePlotSpace.xRange.locationDecimal;
//            NSDecimal yLocation          = thePlotSpace.yRange.locationDecimal;
//
//            NSDecimal originPlotPoint[2];
//            NSDecimal displacedPlotPoint[2];
//
//            switch ( coordinate ) {
//                case CPTCoordinateX:
//                    originPlotPoint[CPTCoordinateX]    = xLocation;
//                    originPlotPoint[CPTCoordinateY]    = yLocation;
//                    displacedPlotPoint[CPTCoordinateX] = CPTDecimalAdd(xLocation, decimalLength);
//                    displacedPlotPoint[CPTCoordinateY] = yLocation;
//                    break;
//
//                case CPTCoordinateY:
//                    originPlotPoint[CPTCoordinateX]    = xLocation;
//                    originPlotPoint[CPTCoordinateY]    = yLocation;
//                    displacedPlotPoint[CPTCoordinateX] = xLocation;
//                    displacedPlotPoint[CPTCoordinateY] = CPTDecimalAdd(yLocation, decimalLength);
//                    break;
//
//                default:
//                    break;
//            }
//
//            CGPoint originPoint    = [thePlotSpace plotAreaViewPointForPlotPoint:originPlotPoint numberOfCoordinates:2];
//            CGPoint displacedPoint = [thePlotSpace plotAreaViewPointForPlotPoint:displacedPlotPoint numberOfCoordinates:2];
//
//            switch ( coordinate ) {
//                case CPTCoordinateX:
//                    length = displacedPoint.x - originPoint.x;
//                    break;
//
//                case CPTCoordinateY:
//                    length = displacedPoint.y - originPoint.y;
//                    break;
//
//                default:
//                    length = CPTFloat(0.0);
//                    break;
//            }
//        }
//        return length;
//    }
//
//    -(double)doubleLengthInPlotCoordinates:(NSDecimal)decimalLength
//    {
//        double length;
//
//        if ( self.barWidthsAreInViewCoordinates ) {
//            CGFloat floatLength = CPTDecimalCGFloatValue(decimalLength);
//            CGPoint originViewPoint = CGPointZero;
//            CGPoint displacedViewPoint = CPTPointMake(floatLength, floatLength);
//            double originPlotPoint[2], displacedPlotPoint[2];
//            CPTPlotSpace *thePlotSpace = self.plotSpace;
//            [thePlotSpace doublePrecisionPlotPoint:originPlotPoint numberOfCoordinates:2 forPlotAreaViewPoint:originViewPoint];
//            [thePlotSpace doublePrecisionPlotPoint:displacedPlotPoint numberOfCoordinates:2 forPlotAreaViewPoint:displacedViewPoint];
//            if ( self.barsAreHorizontal ) {
//                length = displacedPlotPoint[CPTCoordinateY] - originPlotPoint[CPTCoordinateY];
//            }
//            else {
//                length = displacedPlotPoint[CPTCoordinateX] - originPlotPoint[CPTCoordinateX];
//            }
//        }
//        else {
//            length = CPTDecimalDoubleValue(decimalLength);
//        }
//        return length;
//    }
//
//    -(NSDecimal)lengthInPlotCoordinates:(NSDecimal)decimalLength
//    {
//        NSDecimal length;
//
//        if ( self.barWidthsAreInViewCoordinates ) {
//            CGFloat floatLength = CPTDecimalCGFloatValue(decimalLength);
//            CGPoint originViewPoint = CGPointZero;
//            CGPoint displacedViewPoint = CPTPointMake(floatLength, floatLength);
//            NSDecimal originPlotPoint[2], displacedPlotPoint[2];
//            CPTPlotSpace *thePlotSpace = self.plotSpace;
//            [thePlotSpace plotPoint:originPlotPoint numberOfCoordinates:2 forPlotAreaViewPoint:originViewPoint];
//            [thePlotSpace plotPoint:displacedPlotPoint numberOfCoordinates:2 forPlotAreaViewPoint:displacedViewPoint];
//            if ( self.barsAreHorizontal ) {
//                length = CPTDecimalSubtract(displacedPlotPoint[CPTCoordinateY], originPlotPoint[CPTCoordinateY]);
//            }
//            else {
//                length = CPTDecimalSubtract(displacedPlotPoint[CPTCoordinateX], originPlotPoint[CPTCoordinateX]);
//            }
//        }
//        else {
//            length = decimalLength;
//        }
//        return length;
//    }
//
//    /// @endcond
//
//    #pragma mark -
//    #pragma mark Data Ranges
//
//    /// @cond
//
//    -(nullable CPTPlotRange *)plotRangeForCoordinate:(CPTCoordinate)coord
//    {
//        CPTPlotRange *range = [super plotRangeForCoordinate:coord];
//
//        if ( !self.barBasesVary ) {
//            switch ( coord ) {
//                case CPTCoordinateX:
//                    if ( self.barsAreHorizontal ) {
//                        NSDecimal base = self.baseValue.decimalValue;
//                        if ( ![range contains:base] ) {
//                            CPTMutablePlotRange *newRange = [range mutableCopy];
//                            [newRange unionPlotRange:[CPTPlotRange plotRangeWithLocationDecimal:base lengthDecimal:CPTDecimalFromInteger(0)]];
//                            range = newRange;
//                        }
//                    }
//                    break;
//
//                case CPTCoordinateY:
//                    if ( !self.barsAreHorizontal ) {
//                        NSDecimal base = self.baseValue.decimalValue;
//                        if ( ![range contains:base] ) {
//                            CPTMutablePlotRange *newRange = [range mutableCopy];
//                            [newRange unionPlotRange:[CPTPlotRange plotRangeWithLocationDecimal:base lengthDecimal:CPTDecimalFromInteger(0)]];
//                            range = newRange;
//                        }
//                    }
//                    break;
//
//                default:
//                    break;
//            }
//        }
//        return range;
//    }
//
//    -(nullable CPTPlotRange *)plotRangeEnclosingField:(NSUInteger)fieldEnum
//    {
//        CPTPlotRange *range = nil;
//
//        switch ( fieldEnum ) {
//            case CPTBarPlotFieldBarLocation:
//                range = [self plotRangeEnclosingBars];
//                break;
//
//            case CPTBarPlotFieldBarTip:
//            case CPTBarPlotFieldBarBase:
//                range = [self plotRangeForField:fieldEnum];
//                break;
//
//            default:
//                break;
//        }
//
//        return range;
//    }
//
//    /// @endcond
//
//    /** @brief Computes a plot range that completely encloses all of the bars.
//     *
//     *  For a horizontal bar plot, this range starts at the left edge of the first bar and continues to the right edge
//     *  of the last bar. Similarly, this range starts at the bottom edge of the first bar and continues to the top edge
//     *  of the last bar for vertical bar plots. The length will have the same sign as the corresponding plot range from the plot space.
//     *
//     *  @return A plot range that completely encloses all of the bars.
//     **/
//    -(nullable CPTPlotRange *)plotRangeEnclosingBars
//    {
//        BOOL horizontalBars = self.barsAreHorizontal;
//        CPTMutablePlotRange *range;
//
//        if ( horizontalBars ) {
//            range = [[self plotRangeForCoordinate:CPTCoordinateY] mutableCopy];
//        }
//        else {
//            range = [[self plotRangeForCoordinate:CPTCoordinateX] mutableCopy];
//        }
//
//        NSDecimal barOffsetLength = [self lengthInPlotCoordinates:self.barOffset.decimalValue];
//        NSDecimal barWidthLength  = [self lengthInPlotCoordinates:self.barWidth.decimalValue];
//        NSDecimal halfBarWidth    = CPTDecimalDivide(barWidthLength, CPTDecimalFromInteger(2));
//
//        NSDecimal rangeLocation = range.locationDecimal;
//        NSDecimal rangeLength   = range.lengthDecimal;
//
//        if ( CPTDecimalGreaterThanOrEqualTo(rangeLength, CPTDecimalFromInteger(0))) {
//            rangeLocation = CPTDecimalSubtract(rangeLocation, halfBarWidth);
//
//            range.locationDecimal = CPTDecimalAdd(rangeLocation, barOffsetLength);
//            range.lengthDecimal   = CPTDecimalAdd(rangeLength, barWidthLength);
//        }
//        else {
//            rangeLocation = CPTDecimalAdd(rangeLocation, halfBarWidth);
//
//            range.locationDecimal = CPTDecimalSubtract(rangeLocation, barOffsetLength);
//            range.lengthDecimal   = CPTDecimalSubtract(rangeLength, barWidthLength);
//        }
//
//        return range;
//    }
//
//    #pragma mark -
//    #pragma mark Drawing
//
//    /// @cond
//
//    -(void)renderAsVectorInContext:(nonnull CGContextRef)context
//    {
//        if ( self.hidden ) {
//            return;
//        }
//
//        CPTMutableNumericData *cachedLocations = [self cachedNumbersForField:CPTBarPlotFieldBarLocation];
//        CPTMutableNumericData *cachedLengths   = [self cachedNumbersForField:CPTBarPlotFieldBarTip];
//
//        if ((cachedLocations == nil) || (cachedLengths == nil)) {
//            return;
//        }
//
//        BOOL basesVary                     = self.barBasesVary;
//        CPTMutableNumericData *cachedBases = [self cachedNumbersForField:CPTBarPlotFieldBarBase];
//
//        if ( basesVary && (cachedBases == nil)) {
//            return;
//        }
//
//        NSUInteger barCount = self.cachedDataCount;
//
//        if ( barCount == 0 ) {
//            return;
//        }
//
//        if ( cachedLocations.numberOfSamples != cachedLengths.numberOfSamples ) {
//            [NSException raise:CPTException format:@"Number of bar locations and lengths do not match"];
//        }
//
//        if ( basesVary && (cachedLengths.numberOfSamples != cachedBases.numberOfSamples)) {
//            [NSException raise:CPTException format:@"Number of bar lengths and bases do not match"];
//        }
//
//        [super renderAsVectorInContext:context];
//
//        CGContextBeginTransparencyLayer(context, NULL);
//
//        for ( NSUInteger ii = 0; ii < barCount; ii++ ) {
//            // Draw
//            [self drawBarInContext:context recordIndex:ii];
//        }
//
//        CGContextEndTransparencyLayer(context);
//    }
//
//    -(BOOL)barAtRecordIndex:(NSUInteger)idx basePoint:(nonnull CGPoint *)basePoint tipPoint:(nonnull CGPoint *)tipPoint
//    {
//        BOOL horizontalBars            = self.barsAreHorizontal;
//        CPTCoordinate independentCoord = (horizontalBars ? CPTCoordinateY : CPTCoordinateX);
//        CPTCoordinate dependentCoord   = (horizontalBars ? CPTCoordinateX : CPTCoordinateY);
//
//        CPTPlotSpace *thePlotSpace = self.plotSpace;
//
//        if ( self.doublePrecisionCache ) {
//            double plotPoint[2];
//            plotPoint[independentCoord] = [self cachedDoubleForField:CPTBarPlotFieldBarLocation recordIndex:idx];
//            if ( isnan(plotPoint[independentCoord])) {
//                return NO;
//            }
//
//            // Tip point
//            plotPoint[dependentCoord] = [self cachedDoubleForField:CPTBarPlotFieldBarTip recordIndex:idx];
//            if ( isnan(plotPoint[dependentCoord])) {
//                return NO;
//            }
//            *tipPoint = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];
//
//            // Base point
//            if ( !self.barBasesVary ) {
//                plotPoint[dependentCoord] = self.baseValue.doubleValue;
//            }
//            else {
//                plotPoint[dependentCoord] = [self cachedDoubleForField:CPTBarPlotFieldBarBase recordIndex:idx];
//            }
//            if ( isnan(plotPoint[dependentCoord])) {
//                return NO;
//            }
//            *basePoint = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];
//        }
//        else {
//            NSDecimal plotPoint[2];
//            plotPoint[independentCoord] = [self cachedDecimalForField:CPTBarPlotFieldBarLocation recordIndex:idx];
//            if ( NSDecimalIsNotANumber(&plotPoint[independentCoord])) {
//                return NO;
//            }
//
//            // Tip point
//            plotPoint[dependentCoord] = [self cachedDecimalForField:CPTBarPlotFieldBarTip recordIndex:idx];
//            if ( NSDecimalIsNotANumber(&plotPoint[dependentCoord])) {
//                return NO;
//            }
//            *tipPoint = [thePlotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2];
//
//            // Base point
//            if ( !self.barBasesVary ) {
//                plotPoint[dependentCoord] = self.baseValue.decimalValue;
//            }
//            else {
//                plotPoint[dependentCoord] = [self cachedDecimalForField:CPTBarPlotFieldBarBase recordIndex:idx];
//            }
//            if ( NSDecimalIsNotANumber(&plotPoint[dependentCoord])) {
//                return NO;
//            }
//            *basePoint = [thePlotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2];
//        }
//
//        // Determine bar width and offset.
//        CGFloat barOffsetLength = [self lengthInView:self.barOffset.decimalValue];
//
//        // Offset
//        if ( horizontalBars ) {
//            basePoint->y += barOffsetLength;
//            tipPoint->y  += barOffsetLength;
//        }
//        else {
//            basePoint->x += barOffsetLength;
//            tipPoint->x  += barOffsetLength;
//        }
//
//        return YES;
//    }
//
//    -(nullable CGMutablePathRef)newBarPathWithContext:(nullable CGContextRef)context recordIndex:(NSUInteger)recordIndex
//    {
//        // Get base and tip points
//        CGPoint basePoint, tipPoint;
//        BOOL barExists = [self barAtRecordIndex:recordIndex basePoint:&basePoint tipPoint:&tipPoint];
//
//        if ( !barExists ) {
//            return NULL;
//        }
//
//        NSNumber *width = [self barWidthForIndex:recordIndex];
//
//        CGMutablePathRef path = [self newBarPathWithContext:context
//                                                  basePoint:basePoint
//                                                   tipPoint:tipPoint
//                                                      width:width];
//
//        return path;
//    }
//
//    -(nonnull CGMutablePathRef)newBarPathWithContext:(nullable CGContextRef)context basePoint:(CGPoint)basePoint tipPoint:(CGPoint)tipPoint width:(NSNumber *)width
//    {
//        // This function is used to create a path which is used for both
//        // drawing a bar and for doing hit-testing on a click/touch event
//        BOOL horizontalBars = self.barsAreHorizontal;
//
//        CGFloat barWidthLength = [self lengthInView:width.decimalValue];
//        CGFloat halfBarWidth   = CPTFloat(0.5) * barWidthLength;
//
//        CGRect barRect;
//
//        if ( horizontalBars ) {
//            barRect = CPTRectMake(basePoint.x, basePoint.y - halfBarWidth, tipPoint.x - basePoint.x, barWidthLength);
//        }
//        else {
//            barRect = CPTRectMake(basePoint.x - halfBarWidth, basePoint.y, barWidthLength, tipPoint.y - basePoint.y);
//        }
//
//        int widthNegative  = signbit(barRect.size.width);
//        int heightNegative = signbit(barRect.size.height);
//
//        // Align to device pixels if there is a line border.
//        // Otherwise, align to view space, so fills are sharp at edges.
//        // Note: may not have a context if doing hit testing.
//        if ( self.alignsPointsToPixels && context ) {
//            // Round bar dimensions so adjacent bars always align to the right pixel position
//            const CGFloat roundingPrecision = CPTFloat(1.0e6);
//
//            barRect.origin.x    = round(barRect.origin.x * roundingPrecision) / roundingPrecision;
//            barRect.origin.y    = round(barRect.origin.y * roundingPrecision) / roundingPrecision;
//            barRect.size.width  = round(barRect.size.width * roundingPrecision) / roundingPrecision;
//            barRect.size.height = round(barRect.size.height * roundingPrecision) / roundingPrecision;
//
//            CGContextRef theContext = context;
//
//            if ( self.lineStyle.lineWidth > CPTFloat(0.0)) {
//                barRect = CPTAlignRectToUserSpace(theContext, barRect);
//            }
//            else {
//                barRect = CPTAlignIntegralRectToUserSpace(theContext, barRect);
//            }
//        }
//
//        CGFloat radius     = MIN(MIN(self.barCornerRadius, ABS(barRect.size.width) * CPTFloat(0.5)), ABS(barRect.size.height) * CPTFloat(0.5));
//        CGFloat baseRadius = MIN(MIN(self.barBaseCornerRadius, ABS(barRect.size.width) * CPTFloat(0.5)), ABS(barRect.size.height) * CPTFloat(0.5));
//
//        if ( widthNegative && (barRect.size.width > CPTFloat(0.0))) {
//            barRect.origin.x  += barRect.size.width;
//            barRect.size.width = -barRect.size.width;
//        }
//        if ( heightNegative && (barRect.size.height > CPTFloat(0.0))) {
//            barRect.origin.y   += barRect.size.height;
//            barRect.size.height = -barRect.size.height;
//        }
//
//        CGMutablePathRef path = CGPathCreateMutable();
//
//        if ( radius == CPTFloat(0.0)) {
//            if ( baseRadius == CPTFloat(0.0)) {
//                // square corners
//                CGPathAddRect(path, NULL, barRect);
//            }
//            else {
//                CGFloat tipX = barRect.origin.x + barRect.size.width;
//                CGFloat tipY = barRect.origin.y + barRect.size.height;
//
//                // rounded at base end only
//                if ( horizontalBars ) {
//                    CGPathMoveToPoint(path, NULL, tipX, tipY);
//                    CGPathAddArcToPoint(path, NULL, barRect.origin.x, tipY, barRect.origin.x, CGRectGetMidY(barRect), baseRadius);
//                    CGPathAddArcToPoint(path, NULL, barRect.origin.x, barRect.origin.y, tipX, barRect.origin.y, baseRadius);
//                    CGPathAddLineToPoint(path, NULL, tipX, barRect.origin.y);
//                }
//                else {
//                    CGPathMoveToPoint(path, NULL, barRect.origin.x, tipY);
//                    CGPathAddArcToPoint(path, NULL, barRect.origin.x, barRect.origin.y, CGRectGetMidX(barRect), barRect.origin.y, baseRadius);
//                    CGPathAddArcToPoint(path, NULL, tipX, barRect.origin.y, tipX, tipY, baseRadius);
//                    CGPathAddLineToPoint(path, NULL, tipX, tipY);
//                }
//                CGPathCloseSubpath(path);
//            }
//        }
//        else {
//            CGFloat tipX = barRect.origin.x + barRect.size.width;
//            CGFloat tipY = barRect.origin.y + barRect.size.height;
//
//            if ( baseRadius == CPTFloat(0.0)) {
//                // rounded at tip end only
//                CGPathMoveToPoint(path, NULL, barRect.origin.x, barRect.origin.y);
//                if ( horizontalBars ) {
//                    CGPathAddArcToPoint(path, NULL, tipX, barRect.origin.y, tipX, CGRectGetMidY(barRect), radius);
//                    CGPathAddArcToPoint(path, NULL, tipX, tipY, barRect.origin.x, tipY, radius);
//                    CGPathAddLineToPoint(path, NULL, barRect.origin.x, tipY);
//                }
//                else {
//                    CGPathAddArcToPoint(path, NULL, barRect.origin.x, tipY, CGRectGetMidX(barRect), tipY, radius);
//                    CGPathAddArcToPoint(path, NULL, tipX, tipY, tipX, barRect.origin.y, radius);
//                    CGPathAddLineToPoint(path, NULL, tipX, barRect.origin.y);
//                }
//                CGPathCloseSubpath(path);
//            }
//            else {
//                // rounded at both ends
//                if ( horizontalBars ) {
//                    CGPathMoveToPoint(path, NULL, barRect.origin.x, CGRectGetMidY(barRect));
//                    CGPathAddArcToPoint(path, NULL, barRect.origin.x, tipY, CGRectGetMidX(barRect), tipY, baseRadius);
//                    CGPathAddArcToPoint(path, NULL, tipX, tipY, tipX, CGRectGetMidY(barRect), radius);
//                    CGPathAddArcToPoint(path, NULL, tipX, barRect.origin.y, CGRectGetMidX(barRect), barRect.origin.y, radius);
//                    CGPathAddArcToPoint(path, NULL, barRect.origin.x, barRect.origin.y, barRect.origin.x, CGRectGetMidY(barRect), baseRadius);
//                }
//                else {
//                    CGPathMoveToPoint(path, NULL, barRect.origin.x, CGRectGetMidY(barRect));
//                    CGPathAddArcToPoint(path, NULL, barRect.origin.x, tipY, CGRectGetMidX(barRect), tipY, radius);
//                    CGPathAddArcToPoint(path, NULL, tipX, tipY, tipX, CGRectGetMidY(barRect), radius);
//                    CGPathAddArcToPoint(path, NULL, tipX, barRect.origin.y, CGRectGetMidX(barRect), barRect.origin.y, baseRadius);
//                    CGPathAddArcToPoint(path, NULL, barRect.origin.x, barRect.origin.y, barRect.origin.x, CGRectGetMidY(barRect), baseRadius);
//                }
//                CGPathCloseSubpath(path);
//            }
//        }
//
//        return path;
//    }
//
//    -(BOOL)barIsVisibleWithBasePoint:(CGPoint)basePoint width:(NSNumber *)width
//    {
//        BOOL horizontalBars    = self.barsAreHorizontal;
//        CGFloat barWidthLength = [self lengthInView:width.decimalValue];
//        CGFloat halfBarWidth   = CPTFloat(0.5) * barWidthLength;
//
//        CPTPlotArea *thePlotArea = self.plotArea;
//
//        CGFloat lowerBound = (horizontalBars ? CGRectGetMinY(thePlotArea.bounds) : CGRectGetMinX(thePlotArea.bounds));
//        CGFloat upperBound = (horizontalBars ? CGRectGetMaxY(thePlotArea.bounds) : CGRectGetMaxX(thePlotArea.bounds));
//        CGFloat base       = (horizontalBars ? basePoint.y : basePoint.x);
//
//        return (base + halfBarWidth >= lowerBound) && (base - halfBarWidth <= upperBound);
//    }
//
//    -(nullable CPTFill *)barFillForIndex:(NSUInteger)idx
//    {
//        CPTFill *theBarFill = [self cachedValueForKey:CPTBarPlotBindingBarFills recordIndex:idx];
//
//        if ((theBarFill == nil) || (theBarFill == [CPTPlot nilData])) {
//            theBarFill = self.fill;
//        }
//
//        return theBarFill;
//    }
//
//    -(nullable CPTLineStyle *)barLineStyleForIndex:(NSUInteger)idx
//    {
//        CPTLineStyle *theBarLineStyle = [self cachedValueForKey:CPTBarPlotBindingBarLineStyles recordIndex:idx];
//
//        if ((theBarLineStyle == nil) || (theBarLineStyle == [CPTPlot nilData])) {
//            theBarLineStyle = self.lineStyle;
//        }
//
//        return theBarLineStyle;
//    }
//
//    -(nonnull NSNumber *)barWidthForIndex:(NSUInteger)idx
//    {
//        NSNumber *theBarWidth = [self cachedValueForKey:CPTBarPlotBindingBarWidths recordIndex:idx];
//
//        if ((theBarWidth == nil) || (theBarWidth == [CPTPlot nilData])) {
//            theBarWidth = self.barWidth;
//        }
//
//        return theBarWidth;
//    }
//
//    -(void)drawBarInContext:(nonnull CGContextRef)context recordIndex:(NSUInteger)idx
//    {
//        // Get base and tip points
//        CGPoint basePoint, tipPoint;
//        BOOL barExists = [self barAtRecordIndex:idx basePoint:&basePoint tipPoint:&tipPoint];
//
//        if ( !barExists ) {
//            return;
//        }
//
//        NSNumber *width = [self barWidthForIndex:idx];
//
//        // Return if bar is off screen
//        if ( ![self barIsVisibleWithBasePoint:basePoint width:width] ) {
//            return;
//        }
//
//        CGMutablePathRef path = [self newBarPathWithContext:context
//                                                  basePoint:basePoint
//                                                   tipPoint:tipPoint
//                                                      width:width];
//
//        if ( path ) {
//            CGContextSaveGState(context);
//
//            CPTFill *theBarFill = [self barFillForIndex:idx];
//            if ( [theBarFill isKindOfClass:[CPTFill class]] ) {
//                CGContextBeginPath(context);
//                CGContextAddPath(context, path);
//                [theBarFill fillPathInContext:context];
//            }
//
//            CPTLineStyle *theLineStyle = [self barLineStyleForIndex:idx];
//            if ( [theLineStyle isKindOfClass:[CPTLineStyle class]] ) {
//                CGContextBeginPath(context);
//                CGContextAddPath(context, path);
//                [theLineStyle setLineStyleInContext:context];
//                [theLineStyle strokePathInContext:context];
//            }
//
//            CGContextRestoreGState(context);
//
//            CGPathRelease(path);
//        }
//    }
//
//    -(void)drawSwatchForLegend:(nonnull CPTLegend *)legend atIndex:(NSUInteger)idx inRect:(CGRect)rect inContext:(nonnull CGContextRef)context
//    {
//        [super drawSwatchForLegend:legend atIndex:idx inRect:rect inContext:context];
//
//        if ( self.drawLegendSwatchDecoration ) {
//            CPTFill *theFill           = [self barFillForIndex:idx];
//            CPTLineStyle *theLineStyle = [self barLineStyleForIndex:idx];
//
//            if ( theFill || theLineStyle ) {
//                CGFloat radius = MAX(self.barCornerRadius, self.barBaseCornerRadius);
//
//                if ( [theFill isKindOfClass:[CPTFill class]] ) {
//                    CGContextBeginPath(context);
//                    CPTAddRoundedRectPath(context, CPTAlignIntegralRectToUserSpace(context, rect), radius);
//                    [theFill fillPathInContext:context];
//                }
//
//                if ( [theLineStyle isKindOfClass:[CPTLineStyle class]] ) {
//                    [theLineStyle setLineStyleInContext:context];
//                    CGContextBeginPath(context);
//                    CPTAddRoundedRectPath(context, CPTAlignBorderedRectToUserSpace(context, rect, theLineStyle), radius);
//                    [theLineStyle strokePathInContext:context];
//                }
//            }
//        }
//    }
//
//    /// @endcond
//
//    #pragma mark -
//    #pragma mark Animation
//
//    /// @cond
//
//    +(BOOL)needsDisplayForKey:(nonnull NSString *)aKey
//    {
//        static NSSet<NSString *> *keys   = nil;
//        static dispatch_once_t onceToken = 0;
//
//        dispatch_once(&onceToken, ^{
//            keys = [NSSet setWithArray:@[@"barCornerRadius",
//                                         @"barBaseCornerRadius",
//                                         @"barOffset",
//                                         @"barWidth",
//                                         @"baseValue"]];
//        });
//
//        if ( [keys containsObject:aKey] ) {
//            return YES;
//        }
//        else {
//            return [super needsDisplayForKey:aKey];
//        }
//    }
//
//    /// @endcond
//
//    #pragma mark -
//    #pragma mark Data Labels
//
//    /// @cond
//
//    -(void)positionLabelAnnotation:(nonnull CPTPlotSpaceAnnotation *)label forIndex:(NSUInteger)idx
//    {
//        NSDecimal theBaseDecimalValue;
//
//        if ( !self.barBasesVary ) {
//            theBaseDecimalValue = self.baseValue.decimalValue;
//        }
//        else {
//            theBaseDecimalValue = [self cachedDecimalForField:CPTBarPlotFieldBarBase recordIndex:idx];
//        }
//
//        NSNumber *location = [self cachedNumberForField:CPTBarPlotFieldBarLocation recordIndex:idx];
//        NSNumber *length   = [self cachedNumberForField:CPTBarPlotFieldBarTip recordIndex:idx];
//
//        BOOL positiveDirection    = CPTDecimalGreaterThanOrEqualTo(length.decimalValue, theBaseDecimalValue);
//        BOOL horizontalBars       = self.barsAreHorizontal;
//        CPTCoordinate coordinate  = (horizontalBars ? CPTCoordinateX : CPTCoordinateY);
//        CPTPlotRange *lengthRange = [self.plotSpace plotRangeForCoordinate:coordinate];
//
//        if ( CPTDecimalLessThan(lengthRange.lengthDecimal, CPTDecimalFromInteger(0))) {
//            positiveDirection = !positiveDirection;
//        }
//
//        NSNumber *offsetLocation;
//
//        if ( self.doublePrecisionCache ) {
//            offsetLocation = @(location.doubleValue + [self doubleLengthInPlotCoordinates:self.barOffset.decimalValue]);
//        }
//        else {
//            NSDecimal decimalLocation = location.decimalValue;
//            NSDecimal offset          = [self lengthInPlotCoordinates:self.barOffset.decimalValue];
//            offsetLocation = [NSDecimalNumber decimalNumberWithDecimal:CPTDecimalAdd(decimalLocation, offset)];
//        }
//
//        // Offset
//        if ( horizontalBars ) {
//            label.anchorPlotPoint = @[length, offsetLocation];
//
//            if ( positiveDirection ) {
//                label.displacement = CPTPointMake(self.labelOffset, 0.0);
//            }
//            else {
//                label.displacement = CPTPointMake(-self.labelOffset, 0.0);
//            }
//        }
//        else {
//            label.anchorPlotPoint = @[offsetLocation, length];
//
//            if ( positiveDirection ) {
//                label.displacement = CPTPointMake(0.0, self.labelOffset);
//            }
//            else {
//                label.displacement = CPTPointMake(0.0, -self.labelOffset);
//            }
//        }
//
//        label.contentLayer.hidden = self.hidden || isnan([location doubleValue]) || isnan([length doubleValue]);
//    }
//
//    /// @endcond
//
//    #pragma mark -
//    #pragma mark Legends
//
//    /// @cond
//
//    /** @internal
//     *  @brief The number of legend entries provided by this plot.
//     *  @return The number of legend entries.
//     **/
//    -(NSUInteger)numberOfLegendEntries
//    {
//        NSUInteger entryCount = 1;
//
//        id<CPTBarPlotDataSource> theDataSource = (id<CPTBarPlotDataSource>)self.dataSource;
//
//        if ( [theDataSource respondsToSelector:@selector(legendTitleForBarPlot:recordIndex:)] ||
//             [theDataSource respondsToSelector:@selector(barFillForBarPlot:recordIndex:)] ) {
//            [self reloadDataIfNeeded];
//            entryCount = self.cachedDataCount;
//        }
//
//        return entryCount;
//    }
//
//    /** @internal
//     *  @brief The title text of a legend entry.
//     *  @param idx The index of the desired title.
//     *  @return The title of the legend entry at the requested index.
//     **/
//    -(nullable NSString *)titleForLegendEntryAtIndex:(NSUInteger)idx
//    {
//        NSString *legendTitle = nil;
//
//        id<CPTBarPlotDataSource> theDataSource = (id<CPTBarPlotDataSource>)self.dataSource;
//
//        if ( [theDataSource respondsToSelector:@selector(legendTitleForBarPlot:recordIndex:)] ) {
//            legendTitle = [theDataSource legendTitleForBarPlot:self recordIndex:idx];
//        }
//        else {
//            legendTitle = [super titleForLegendEntryAtIndex:idx];
//        }
//
//        return legendTitle;
//    }
//
//    /** @internal
//     *  @brief The styled title text of a legend entry.
//     *  @param idx The index of the desired title.
//     *  @return The styled title of the legend entry at the requested index.
//     **/
//    -(nullable NSAttributedString *)attributedTitleForLegendEntryAtIndex:(NSUInteger)idx
//    {
//        NSAttributedString *legendTitle = nil;
//
//        id<CPTBarPlotDataSource> theDataSource = (id<CPTBarPlotDataSource>)self.dataSource;
//
//        if ( [theDataSource respondsToSelector:@selector(attributedLegendTitleForBarPlot:recordIndex:)] ) {
//            legendTitle = [theDataSource attributedLegendTitleForBarPlot:self recordIndex:idx];
//        }
//        else {
//            legendTitle = [super attributedTitleForLegendEntryAtIndex:idx];
//        }
//
//        return legendTitle;
//    }
//
//    /// @endcond
//
//    #pragma mark -
//    #pragma mark Responder Chain and User interaction
//
//    /// @cond
//
//    -(NSUInteger)dataIndexFromInteractionPoint:(CGPoint)point
//    {
//        NSUInteger idx      = NSNotFound;
//        NSUInteger barCount = self.cachedDataCount;
//        NSUInteger ii       = 0;
//
//        while ((ii < barCount) && (idx == NSNotFound)) {
//            CGMutablePathRef path = [self newBarPathWithContext:NULL recordIndex:ii];
//
//            if ( CGPathContainsPoint(path, NULL, point, false)) {
//                idx = ii;
//            }
//
//            CGPathRelease(path);
//
//            ii++;
//        }
//
//        return idx;
//    }
//
//    /// @endcond
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
//     *  If this plot has a delegate that responds to the
//     *  @link CPTBarPlotDelegate::barPlot:barTouchDownAtRecordIndex: -barPlot:barTouchDownAtRecordIndex: @endlink or
//     *  @link CPTBarPlotDelegate::barPlot:barTouchDownAtRecordIndex:withEvent: -barPlot:barTouchDownAtRecordIndex:withEvent: @endlink
//     *  methods, the @par{interactionPoint} is compared with each bar in index order.
//     *  The delegate method will be called and this method returns @YES for the first
//     *  index where the @par{interactionPoint} is inside a bar.
//     *  This method returns @NO if the @par{interactionPoint} is outside all of the bars.
//     *
//     *  @param event The OS event.
//     *  @param interactionPoint The coordinates of the interaction.
//     *  @return Whether the event was handled or not.
//     **/
//    -(BOOL)pointingDeviceDownEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
//    {
//        CPTGraph *theGraph       = self.graph;
//        CPTPlotArea *thePlotArea = self.plotArea;
//
//        if ( !theGraph || !thePlotArea || self.hidden ) {
//            return NO;
//        }
//
//        id<CPTBarPlotDelegate> theDelegate = (id<CPTBarPlotDelegate>)self.delegate;
//
//        if ( [theDelegate respondsToSelector:@selector(barPlot:barTouchDownAtRecordIndex:)] ||
//             [theDelegate respondsToSelector:@selector(barPlot:barTouchDownAtRecordIndex:withEvent:)] ||
//             [theDelegate respondsToSelector:@selector(barPlot:barWasSelectedAtRecordIndex:)] ||
//             [theDelegate respondsToSelector:@selector(barPlot:barWasSelectedAtRecordIndex:withEvent:)] ) {
//            // Inform delegate if a point was hit
//            CGPoint plotAreaPoint = [theGraph convertPoint:interactionPoint toLayer:thePlotArea];
//            NSUInteger idx        = [self dataIndexFromInteractionPoint:plotAreaPoint];
//            self.pointingDeviceDownIndex = idx;
//
//            if ( idx != NSNotFound ) {
//                BOOL handled = NO;
//
//                if ( [theDelegate respondsToSelector:@selector(barPlot:barTouchDownAtRecordIndex:)] ) {
//                    handled = YES;
//                    [theDelegate barPlot:self barTouchDownAtRecordIndex:idx];
//                }
//
//                if ( [theDelegate respondsToSelector:@selector(barPlot:barTouchDownAtRecordIndex:withEvent:)] ) {
//                    handled = YES;
//                    [theDelegate barPlot:self barTouchDownAtRecordIndex:idx withEvent:event];
//                }
//
//                if ( handled ) {
//                    return YES;
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
//     *  If this plot has a delegate that responds to the
//     *  @link CPTBarPlotDelegate::barPlot:barTouchUpAtRecordIndex: -barPlot:barTouchUpAtRecordIndex: @endlink or
//     *  @link CPTBarPlotDelegate::barPlot:barTouchUpAtRecordIndex:withEvent: -barPlot:barTouchUpAtRecordIndex:withEvent: @endlink
//     *  methods, the @par{interactionPoint} is compared with each bar in index order.
//     *  The delegate method will be called and this method returns @YES for the first
//     *  index where the @par{interactionPoint} is inside a bar.
//     *  This method returns @NO if the @par{interactionPoint} is outside all of the bars.
//     *
//     *  If the bar being released is the same as the one that was pressed (see
//     *  @link CPTBarPlot::pointingDeviceDownEvent:atPoint: -pointingDeviceDownEvent:atPoint: @endlink), if the delegate responds to the
//     *  @link CPTBarPlotDelegate::barPlot:barWasSelectedAtRecordIndex: -barPlot:barWasSelectedAtRecordIndex: @endlink and/or
//     *  @link CPTBarPlotDelegate::barPlot:barWasSelectedAtRecordIndex:withEvent: -barPlot:barWasSelectedAtRecordIndex:withEvent: @endlink
//     *  methods, these will be called.
//     *
//     *  @param event The OS event.
//     *  @param interactionPoint The coordinates of the interaction.
//     *  @return Whether the event was handled or not.
//     **/
//    -(BOOL)pointingDeviceUpEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
//    {
//        NSUInteger selectedDownIndex = self.pointingDeviceDownIndex;
//
//        self.pointingDeviceDownIndex = NSNotFound;
//
//        CPTGraph *theGraph       = self.graph;
//        CPTPlotArea *thePlotArea = self.plotArea;
//
//        if ( !theGraph || !thePlotArea || self.hidden ) {
//            return NO;
//        }
//
//        id<CPTBarPlotDelegate> theDelegate = (id<CPTBarPlotDelegate>)self.delegate;
//
//        if ( [theDelegate respondsToSelector:@selector(barPlot:barTouchUpAtRecordIndex:)] ||
//             [theDelegate respondsToSelector:@selector(barPlot:barTouchUpAtRecordIndex:withEvent:)] ||
//             [theDelegate respondsToSelector:@selector(barPlot:barWasSelectedAtRecordIndex:)] ||
//             [theDelegate respondsToSelector:@selector(barPlot:barWasSelectedAtRecordIndex:withEvent:)] ) {
//            // Inform delegate if a point was hit
//            CGPoint plotAreaPoint = [theGraph convertPoint:interactionPoint toLayer:thePlotArea];
//            NSUInteger idx        = [self dataIndexFromInteractionPoint:plotAreaPoint];
//
//            if ( idx != NSNotFound ) {
//                BOOL handled = NO;
//
//                if ( [theDelegate respondsToSelector:@selector(barPlot:barTouchUpAtRecordIndex:)] ) {
//                    handled = YES;
//                    [theDelegate barPlot:self barTouchUpAtRecordIndex:idx];
//                }
//
//                if ( [theDelegate respondsToSelector:@selector(barPlot:barTouchUpAtRecordIndex:withEvent:)] ) {
//                    handled = YES;
//                    [theDelegate barPlot:self barTouchUpAtRecordIndex:idx withEvent:event];
//                }
//
//                if ( idx == selectedDownIndex ) {
//                    if ( [theDelegate respondsToSelector:@selector(barPlot:barWasSelectedAtRecordIndex:)] ) {
//                        handled = YES;
//                        [theDelegate barPlot:self barWasSelectedAtRecordIndex:idx];
//                    }
//
//                    if ( [theDelegate respondsToSelector:@selector(barPlot:barWasSelectedAtRecordIndex:withEvent:)] ) {
//                        handled = YES;
//                        [theDelegate barPlot:self barWasSelectedAtRecordIndex:idx withEvent:event];
//                    }
//                }
//
//                if ( handled ) {
//                    return YES;
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
//    -(nullable CPTNumberArray *)barTips
//    {
//        return [[self cachedNumbersForField:CPTBarPlotFieldBarTip] sampleArray];
//    }
//
//    -(void)setBarTips:(nullable CPTNumberArray *)newTips
//    {
//        [self cacheNumbers:newTips forField:CPTBarPlotFieldBarTip];
//    }
//
//    -(nullable CPTNumberArray *)barBases
//    {
//        return [[self cachedNumbersForField:CPTBarPlotFieldBarBase] sampleArray];
//    }
//
//    -(void)setBarBases:(nullable CPTNumberArray *)newBases
//    {
//        [self cacheNumbers:newBases forField:CPTBarPlotFieldBarBase];
//    }
//
//    -(nullable CPTNumberArray *)barLocations
//    {
//        return [[self cachedNumbersForField:CPTBarPlotFieldBarLocation] sampleArray];
//    }
//
//    -(void)setBarLocations:(nullable CPTNumberArray *)newLocations
//    {
//        [self cacheNumbers:newLocations forField:CPTBarPlotFieldBarLocation];
//    }
//
//    -(nullable CPTFillArray *)barFills
//    {
//        return [self cachedArrayForKey:CPTBarPlotBindingBarFills];
//    }
//
//    -(void)setBarFills:(nullable CPTFillArray *)newBarFills
//    {
//        [self cacheArray:newBarFills forKey:CPTBarPlotBindingBarFills];
//        [self setNeedsDisplay];
//    }
//
//    -(nullable CPTLineStyleArray *)barLineStyles
//    {
//        return [self cachedArrayForKey:CPTBarPlotBindingBarLineStyles];
//    }
//
//    -(void)setBarLineStyles:(nullable CPTLineStyleArray *)newBarLineStyles
//    {
//        [self cacheArray:newBarLineStyles forKey:CPTBarPlotBindingBarLineStyles];
//        [self setNeedsDisplay];
//    }
//
    func setLineStyle(newLineStyle: CPTLineStyle )
    {
        if ( lineStyle != newLineStyle ) {
            lineStyle = newLineStyle
            self.setNeedsDisplay()
    NotificationCenter.default.post( name:.CPTLegendNeedsRedrawForPlotNotification, object:self)
        }
    }
//
//    -(void)setFill:(nullable CPTFill *)newFill
//    {
//        if ( fill != newFill ) {
//            fill = [newFill copy];
//            [self setNeedsDisplay];
    NotificationCenter.default.post( name:.CPTLegendNeedsRedrawForPlotNotification, object:self)
//        }
//    }
//
//    -(void)setBarWidth:(nonnull NSNumber *)newBarWidth
//    {
//        if ( ![barWidth isEqualToNumber:newBarWidth] ) {
//            barWidth = newBarWidth;
//            [self setNeedsDisplay];
//        }
//    }
//
//    -(void)setBarOffset:(nonnull NSNumber *)newBarOffset
//    {
//        if ( ![barOffset isEqualToNumber:newBarOffset] ) {
//            barOffset = newBarOffset;
//            [self setNeedsDisplay];
//            [self repositionAllLabelAnnotations];
//        }
//    }
//
    func setBarCornerRadius(newCornerRadius : CGFloat)
    {
        if ( barCornerRadius != newCornerRadius ) {
            barCornerRadius = abs(newCornerRadius);
            self.setNeedsDisplay()
            NotificationCenter.default.post( name:.CPTLegendNeedsRedrawForPlotNotification, object:self)
        }
    }
//
//    -(void)setBarBaseCornerRadius:(CGFloat)newCornerRadius
//    {
//        if ( barBaseCornerRadius != newCornerRadius ) {
//            barBaseCornerRadius = ABS(newCornerRadius);
//            [self setNeedsDisplay];
//            [[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
//        }
//    }
//
//    -(void)setBaseValue:(nonnull NSNumber *)newBaseValue
//    {
//        if ( ![baseValue isEqualToNumber:newBaseValue] ) {
//            baseValue = newBaseValue;
//            [self setNeedsDisplay];
//            [self setNeedsLayout];
//        }
//    }
//
//    -(void)setBarBasesVary:(BOOL)newBasesVary
//    {
//        if ( newBasesVary != barBasesVary ) {
//            barBasesVary = newBasesVary;
//            [self setDataNeedsReloading];
//            [self setNeedsDisplay];
//            [self setNeedsLayout];
//        }
//    }
//
//    -(void)setBarsAreHorizontal:(BOOL)newBarsAreHorizontal
//    {
//        if ( barsAreHorizontal != newBarsAreHorizontal ) {
//            barsAreHorizontal = newBarsAreHorizontal;
//            [self setNeedsDisplay];
//            [self setNeedsLayout];
//        }
//    }
//
//    /// @endcond
//
//    #pragma mark -
//    #pragma mark Fields
//
//    /// @cond
//
//    -(NSUInteger)numberOfFields
//    {
//        return 3;
//    }
//
//    -(nonnull CPTNumberArray *)fieldIdentifiers
//    {
//        return @[@(CPTBarPlotFieldBarLocation),
//                 @(CPTBarPlotFieldBarTip),
//                 @(CPTBarPlotFieldBarBase)];
//    }
//
//    -(nonnull CPTNumberArray *)fieldIdentifiersForCoordinate:(CPTCoordinate)coord
//    {
//        CPTNumberArray *result = nil;
//
//        switch ( coord ) {
//            case CPTCoordinateX:
//                if ( self.barsAreHorizontal ) {
//                    if ( self.barBasesVary ) {
//                        result = @[@(CPTBarPlotFieldBarTip), @(CPTBarPlotFieldBarBase)];
//                    }
//                    else {
//                        result = @[@(CPTBarPlotFieldBarTip)];
//                    }
//                }
//                else {
//                    result = @[@(CPTBarPlotFieldBarLocation)];
//                }
//                break;
//
//            case CPTCoordinateY:
//                if ( self.barsAreHorizontal ) {
//                    result = @[@(CPTBarPlotFieldBarLocation)];
//                }
//                else {
//                    if ( self.barBasesVary ) {
//                        result = @[@(CPTBarPlotFieldBarTip), @(CPTBarPlotFieldBarBase)];
//                    }
//                    else {
//                        result = @[@(CPTBarPlotFieldBarTip)];
//                    }
//                }
//                break;
//
//            default:
//                [NSException raise:CPTException format:@"Invalid coordinate passed to fieldIdentifiersForCoordinate:"];
//                break;
//        }
//        return result;
//    }
//
//    -(CPTCoordinate)coordinateForFieldIdentifier:(NSUInteger)field
//    {
//        CPTCoordinate coordinate = CPTCoordinateNone;
//
//        switch ( field ) {
//            case CPTBarPlotFieldBarLocation:
//                coordinate = (self.barsAreHorizontal ? CPTCoordinateY : CPTCoordinateX);
//                break;
//
//            case CPTBarPlotFieldBarTip:
//            case CPTBarPlotFieldBarBase:
//                coordinate = (self.barsAreHorizontal ? CPTCoordinateX : CPTCoordinateY);
//                break;
//
//            default:
//                break;
//        }
//
//        return coordinate;
//    }
//
//    /// @endcond
//
//    @end

}
