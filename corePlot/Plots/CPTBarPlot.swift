//
//  CPTBarPlot.swift
//  corePlot
//
//  Created by thierryH24 on 11/11/2020.
//

import AppKit


// MARK: bar plot data source.
@objc public protocol CPTBarPlotDataSource:   CPTPlotDataSource  {
    
    func barFillsForBarPlot     (plot: CPTBarPlot, indexRange:NSRange)-> [CPTFill]
    func barFillForBarPlot      (plot: CPTBarPlot, index:Int) -> [CPTFill]
    
    func barLineStyleForBarPlot (plot: CPTBarPlot, index:Int)-> CPTLineStyle
    func barLineStylesForBarPlot(plot: CPTBarPlot, indexRange:NSRange)-> [CPTLineStyle]
    
    func barWidthsForBarPlot    (plot: CPTBarPlot, indexRange :NSRange)-> [CGFloat]
    func barWidthForBarPlot     (plot: CPTBarPlot, index: Int)-> CGFloat
    
    func legendTitleForBarPlot  (plot: CPTBarPlot, index:Int) -> String
    
    func attributedLegendTitleForBarPlot(plot: CPTBarPlot, idx:Int )-> NSAttributedString
}


// MARK:  Bar plot delegate
protocol CPTBarPlotDelegate: CPTPlotDelegate {
    
    func barPlot( plot: CPTBarPlot, barWasSelectedAtRecordIndex idx: Int)
    func barPlot( plot: CPTBarPlot, barWasSelectedAtRecordIndex idx: Int, withEvent event: CPTNativeEvent)
    func barPlot( plot: CPTBarPlot, barTouchDownAtRecordIndex   idx: Int)
    func barPlot( plot: CPTBarPlot, barTouchDownAtRecordIndex   idx: Int, withEvent event: CPTNativeEvent)
    func barPlot( plot: CPTBarPlot, barTouchUpAtRecordIndex     idx: Int)
    func barPlot( plot: CPTBarPlot, barTouchUpAtRecordIndex     idx: Int, withEvent event: CPTNativeEvent )
}

enum  CPTBarPlotField  :Int {
    case location ///< Bar location on independent coordinate axis.
    case tip      ///< Bar tip value.
    case base      ///< Bar base (used only if @link CPTBarPlot::barBasesVary barBasesVary @endlink is YES).
}


public class CPTBarPlot: CPTPlot {
    
    
    weak public var barDataSource : CPTBarPlotDataSource?

    var barLocations = [CGFloat]()
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //    class func tubularBarPlot(with color: NSUIColor, horizontalBars horizontal: Bool) -> Self {
    //        let barPlot = self.init()
    //        let barLineStyle = CPTLineStyle()
    //
    //        barLineStyle.lineWidth = CGFloat(1.0)
    //        barLineStyle.lineColor = CPTColor.black
    //
    //        barPlot?.lineStyle = barLineStyle
    //        barPlot?.barsAreHorizontal = horizontal
    //        barPlot?.barWidth = NSUIColor( 0.8)
    //        barPlot?.barCornerRadius = CGFloat(2.0)
    //
    //        let fillGradient = CPTGradient(beginningColor: color, endingColor: CPTColor.black())
    //
    //        fillGradient.angle = CPTFloat(horizontal ? -90.0 : 0.0)
    //        barPlot?.fill = CPTFill(gradient: fillGradient)
    //
    //        barPlot?.barWidthsAreInViewCoordinates = false
    //
    //        return barPlot
    //    }
    
    func tubularBarPlot(with color: NSUIColor, horizontalBars horizontal: Bool) -> CPTBarPlot {
        
        let barPlot = CPTBarPlot()
        let barLineStyle = CPTLineStyle()
        
        barLineStyle.lineWidth = CGFloat(1.0)
        barLineStyle.lineColor = NSUIColor.black
        
        barPlot.lineStyle = barLineStyle
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
        CPTBarPlot.exposeBinding(.BarLocations)
        CPTBarPlot.exposeBinding(.BarTips)
        CPTBarPlot.exposeBinding(.BarBases)
        CPTBarPlot.exposeBinding(.BarFills)
        CPTBarPlot.exposeBinding(.BarLineStyles)
        CPTBarPlot.exposeBinding(.BarWidths)
    }
    
    //    func legendTitleForBarPlot(barPlot: CPTBarPlot, recordIndex idx:Int) -> String
    
    
    // https://ask.xiaolee.net/questions/1044854
    override func reloadData(indexRange: NSRange)
    {
        super.reloadData(indexRange: indexRange)
        
        // Bar fills
        self.reloadBarFills(indexRange: indexRange)
        
        // Bar line styles
        self.reloadBarLineStyles(indexRange: indexRange)
        
        // Bar widths
        self.reloadBarWidths(indexRange: indexRange)
        
        // Legend
        let theDataSource = self.barDataSource //as? CPTBarPlotDataSource
        
        if let legendTitleForBarPlot = theDataSource?.legendTitleForBarPlot {
            _ = legendTitleForBarPlot(self, indexRange.length)
            NotificationCenter.send(
                name: .CPTLegendNeedsRedrawForPlotNotification,
                object : self)
        }
    }
    
//    func reloadPlotData(indexRange: NSRange)
//    {
//        super.reloadPlotData(indexRange: indexRange)
//
//        if  self.loadNumbersForAllFieldsFromDataSourceInRecordIndexRange(indexRange)  == false {
//
//            let  theDataSource = self.dataSource as! CPTBarPlotDataSource
//
//            // Bar lengths
//            if ( theDataSource ) != nil {
//                let newBarLengths = self.numbersFromDataSourceForField(.barTip, recordIndexRange:indexRange)
//                [self.cacheNumbers:newBarLengths forField:.barTip atRecordIndex:indexRange.location];
//
//
//                if  self.barBasesVary  {
//                    let newBarBases = self.numbersFromDataSourceForField( .barBase, recordIndexRange:indexRange)
//                    self.cacheNumbers(newBarBases, forField:.barBase, atRecordIndex:indexRange.location)
//                }
//                else {
//                    self.barBases = nil;
//                }
//            }
//            else {
//                self.barTips.removeAll()
//                self.barBases.removeAll()
//            }
//
//            // Locations of bars
//            if self.plotRange {
//                // Spread bars evenly over the plot range
//                CPTMutableNumericData *locationData = nil;
//                if ( self.doublePrecisionCache ) {
//                    locationData = [[CPTMutableNumericData alloc] initWithData:[NSData data]
//                                    dataType:CPTDataType(CPTFloatingPointDataType, sizeof(double), CFByteOrderGetCurrent())
//                                    shape:nil];
//                    locationData.shape = @[@(indexRange.length)];
//
//                    let doublePrecisionDelta = 1.0;
//                    if ( indexRange.length > 1 ) {
//                        doublePrecisionDelta = self.plotRange.lengthDouble / (double)(indexRange.length - 1);
//                    }
//
//                    let locationDouble = self.plotRange.locationDouble;
//                    let dataBytes     = locationData.mutableBytes;
//                    let dataEnd       = dataBytes + indexRange.length;
//                    while ( dataBytes < dataEnd ) {
//                        *dataBytes++    = locationDouble;
//                        locationDouble += doublePrecisionDelta;
//                    }
//                }
//                else {
//                    locationData = [[CPTMutableNumericData alloc] initWithData:[NSData data]
//                                    dataType:CPTDataType(CPTDecimalDataType, sizeof(NSDecimal), CFByteOrderGetCurrent())
//                                    shape:nil];
//                    locationData.shape = @[@(indexRange.length)];
//
//                    NSDecimal delta = CPTDecimalFromInteger(1);
//                    if ( indexRange.length > 1 ) {
//                        delta = CPTDecimalDivide(self.plotRange.lengthDecimal, CPTDecimalFromUnsignedInteger(indexRange.length - 1));
//                    }
//
//                    let locationDecimal = self.plotRange.locationDecimal;
//                    NSDecimal *dataBytes      = (NSDecimal *)locationData.mutableBytes;
//                    NSDecimal *dataEnd        = dataBytes + indexRange.length;
//                    while ( dataBytes < dataEnd ) {
//                        *dataBytes++    = locationDecimal;
//                        locationDecimal = CPTDecimalAdd(locationDecimal, delta);
//                    }
//                }
//                self cacheNumbers:locationData forField:CPTBarPlotFieldBarLocation atRecordIndex:indexRange.location];
//            }
//            else if ( theDataSource ) {
//                // Get locations from the datasource
//                id newBarLocations = [self numbersFromDataSourceForField:CPTBarPlotFieldBarLocation recordIndexRange:indexRange];
//                [self cacheNumbers:newBarLocations forField:CPTBarPlotFieldBarLocation atRecordIndex:indexRange.location];
//            }
//            else {
//                // Make evenly spaced locations starting at zero
//                let locationData = nil;
//                if ( self.doublePrecisionCache ) {
//                    locationData = [[CPTMutableNumericData alloc] initWithData:[NSData data]
//                                    dataType:CPTDataType(CPTFloatingPointDataType, sizeof(double), CFByteOrderGetCurrent())
//                                    shape:nil];
//                    locationData.shape = @[@(indexRange.length)];
//
//                    double locationDouble = 0.0;
//                    double *dataBytes     = (double *)locationData.mutableBytes;
//                    double *dataEnd       = dataBytes + indexRange.length;
//                    while ( dataBytes < dataEnd ) {
//                        *dataBytes++    = locationDouble;
//                        locationDouble += 1.0;
//                    }
//                }
//                else {
//                    locationData = [[CPTMutableNumericData alloc] initWithData:[NSData data]
//                                    dataType:CPTDataType(CPTDecimalDataType, sizeof(NSDecimal), CFByteOrderGetCurrent())
//                                    shape:nil];
//                    locationData.shape = @[@(indexRange.length)];
//
//                    NSDecimal locationDecimal = CPTDecimalFromInteger(0);
//                    NSDecimal *dataBytes      = (NSDecimal *)locationData.mutableBytes;
//                    NSDecimal *dataEnd        = dataBytes + indexRange.length;
//                    NSDecimal one             = CPTDecimalFromInteger(1);
//                    while ( dataBytes < dataEnd ) {
//                        *dataBytes++    = locationDecimal;
//                        locationDecimal = CPTDecimalAdd(locationDecimal, one);
//                    }
//                }
//                [self cacheNumbers:locationData forField:CPTBarPlotFieldBarLocation atRecordIndex:indexRange.location];
//            }
//        }
//    }
    
    func reloadBarFills()
    {
        reloadBarFills(indexRange: NSMakeRange(0, self.cachedDataCount))
    }
    
    //    /** @brief Reload bar fills in the given index range from the data source immediately.
    //     *  @param indexRange The index range to load.
    //     **/
    func reloadBarFills(indexRange: NSRange)
    {
        let theDataSource = self.dataSource as? CPTBarPlotDataSource
        
        var needsLegendUpdate = false
        
        if let barFillsForBarPlot = theDataSource?.barFillsForBarPlot {
            needsLegendUpdate = true
            
            self.cacheArray(array: (theDataSource?.barFillsForBarPlot(barPlot: self, recordIndexRange:indexRange))!,
                            forKey: NSBindingName.BarFills.rawValue,
                            atRecordIndex:indexRange.location)
        }
        else
        if let barFillsForBarPlot = theDataSource?.barFillsForBarPlot {
            needsLegendUpdate = true
            
            let nilObject               : CPTFill?
            var array = [CPTFill]()
            let maxIndex        = NSMaxRange(indexRange)
            let location = indexRange.location
            
            for  idx in location..<maxIndex {
                let dataSourceFill = theDataSource?.barFillForBarPlot(barPlot: self, recordIndex:idx)
                if dataSourceFill  != nil {
                    array.append( dataSourceFill!)
                }
                else {
                    array.append(nilObject!)
                }
            }
            
            self.cacheArray(array: array,
                            forKey: NSBindingName.BarFills.rawValue,
                            atRecordIndex:indexRange.location)
        }
        
        // Legend
        if needsLegendUpdate == true {
            NotificationCenter.send (
                name: .CPTLegendNeedsRedrawForPlotNotification,
                object:self)
            self.setNeedsDisplay()
        }
    }
    
    //     *  @brief Reload all bar line styles from the data source immediately.
    func reloadBarLineStyles()
    {
        self.reloadBarLineStyles(indexRange:NSMakeRange(0, self.cachedDataCount))
    }
    
    /** @brief Reload bar line styles in the given index range from the data source immediately.
     *  @param indexRange The index range to load.
     **/
    func reloadBarLineStyles(indexRange: NSRange)
    {
        let theDataSource = self.dataSource as? CPTBarPlotDataSource
        
        var needsLegendUpdate = false
        if let barLineStylesForBarPlot = theDataSource?.barLineStylesForBarPlot {
            
            needsLegendUpdate = true
            let array = theDataSource?.barLineStylesForBarPlot!(
                            plot: self,
                            indexRange:indexRange)
            self.cacheArray(array: array! ,
                                forKey: NSBindingName.BarLineStyles.rawValue,
                                atRecordIndex: indexRange.location)
        }
        else if let barLineStylesForBarPlot = theDataSource?.barLineStylesForBarPlot {
            
            needsLegendUpdate = true
            let  nilObject : CPTLineStyle?
            var array = [CPTLineStyle?]()
            let maxIndex  = NSMaxRange(indexRange)
            
            for  idx in indexRange.location..<maxIndex {
                let dataSourceLineStyle = theDataSource?.barLineStyleForBarPlot!(plot: self, index: idx)
                if (( dataSourceLineStyle ) != nil) {
                    array.append(dataSourceLineStyle!)
                }
                else {
                    array.append(nilObject)
                }
            }
            self.cacheArray(array: array as [Any],
                            forKey: NSBindingName.BarLineStyles.rawValue,
                            atRecordIndex:indexRange.location)
        }
        
        // Legend
        if needsLegendUpdate == true {
            NotificationCenter.send(
                name: .CPTLegendNeedsRedrawForPlotNotification ,
                object:self)
        }
        self.setNeedsDisplay()
    }
    
        //**
        //*  @brief Reload all bar widths from the data source immediately.
    func reloadBarWidths()
    {
        self.reloadBarWidths(indexRange: NSMakeRange(0, self.cachedDataCount))
    }
    
        /** @brief Reload bar widths in the given index range from the data source immediately.
         *  @param indexRange The index range to load.
         **/
    func reloadBarWidths(indexRange: NSRange)
    {
        let theBarDataSource = self.dataSource as? CPTBarPlotDataSource
        
        let array = theBarDataSource?.barWidthsForBarPlot(plot : self ,indexRange: indexRange)
        self.cacheArray(array: array!,
                        forKey: NSBindingName.BarWidths.rawValue,
                        atRecordIndex:indexRange.location)
        
        if ((theBarDataSource?.barWidthsForBarPlot(plot: self, indexRange: indexRange)) != nil) {
            let nilObject : CGFloat?
            var array = [CGFloat]()
            
            let maxIndex = NSMaxRange(indexRange);
            
            for index in indexRange.location..<maxIndex {
                let width = theBarDataSource?.barWidthForBarPlot(plot: self, index:index)
                if width != 0  {
                    array.append(width!)
                }
                else {
                    array.append(nilObject!)
                }
            }
            
            self.cacheArray(array: array,
                            forKey: NSBindingName.BarWidths.rawValue,
                            atRecordIndex:indexRange.location)
        }
        self.setNeedsDisplay()
    }
    
    // MARK:Length Conversions for Independent Coordinate (e.g., widths, offsets)
    func lengthInView(decimalLength: CGFloat)-> CGFloat
    {
        var length = CGFloat(0)
        
        if ( self.barWidthsAreInViewCoordinates ) {
            length = CGFloat(decimalLength)
        }
        else {
            let coord              = self.barsAreHorizontal == true ? CPTCoordinate.y : CPTCoordinate.x
            let thePlotSpace       = self.plotSpace as! CPTXYPlotSpace
            let xLocation          = thePlotSpace.xRange.locationDecimal;
            let yLocation          = thePlotSpace.yRange.locationDecimal;
            
            var originPlotPoint = [CPTCoordinate: CGFloat]()
            var displacedPlotPoint = [CPTCoordinate: CGFloat]()
            
            switch ( coord ) {
            case .x:
                originPlotPoint[.x]    = xLocation
                originPlotPoint[.y]    = yLocation;
                displacedPlotPoint[.x] = xLocation + decimalLength
                displacedPlotPoint[.y] = yLocation;
                
            case .y:
                originPlotPoint[.x]    = xLocation
                originPlotPoint[.y]    = yLocation
                displacedPlotPoint[.x] = xLocation;
                displacedPlotPoint[.y] = yLocation + decimalLength
                
            default:
                break;
            }
            
            let originPoint    = thePlotSpace.plotAreaViewPointForPlotPoint(plotPoint: originPlotPoint, numberOfCoordinates:2)
            let displacedPoint = thePlotSpace.plotAreaViewPointForPlotPoint(plotPoint: displacedPlotPoint, numberOfCoordinates:2)
            
            switch ( coord ) {
            case .x:
                length = displacedPoint.x - originPoint.x;
                
            case .y:
                length = displacedPoint.y - originPoint.y;
                
            default:
                length = CGFloat(0.0);
            }
        }
        return length;
    }
    
    func LengthinPlotCoordinates( length: CGFloat) -> Double {
        var lengthDouble: Double
        
        if barWidthsAreInViewCoordinates {
            let floatLength = CGFloat(length)
            let originViewPoint = CGPoint.zero
            let displacedViewPoint = CGPoint(x: floatLength, y: floatLength)
            let originPlotPoint = [Double]()
            let displacedPlotPoint = [Double]()
            let thePlotSpace = plotSpace
            thePlotSpace?.doublePrecisionPlotPoint(originPlotPoint, numberOfCoordinates: 2, forPlotAreaViewPoint: originViewPoint)
            thePlotSpace?.doublePrecisionPlotPoint(displacedPlotPoint, numberOfCoordinates: 2, forPlotAreaViewPoint: displacedViewPoint)
            if barsAreHorizontal {
                lengthDouble = displacedPlotPoint[CPTCoordinate.y.rawValue] - originPlotPoint[CPTCoordinate.y.rawValue]
            } else {
                lengthDouble = displacedPlotPoint[CPTCoordinate.x.rawValue] - originPlotPoint[CPTCoordinate.x.rawValue]
            }
        } else {
            lengthDouble = Double(length)
        }
        return lengthDouble
    }
    
    
    
    /** @brief Converts a point given in plot area drawing coordinates to the data coordinate space.
     *  @param plotPoint A c-style array of data point coordinates (as NSDecimal structs).
     *  @param count The number of coordinate values in the @par{plotPoint} array.
     *  @param point The drawing coordinates of the data point.
     **/
    func lengthInPlotCoordinates(decimalLength: CGFloat)-> CGFloat
    {
        var length = CGFloat(0)
        
        if ( self.barWidthsAreInViewCoordinates ) {
            let floatLength = decimalLength
            
            let originView = CGPoint()
            let displacedView = CGPoint(x: floatLength, y: floatLength)
            
            var originPlot = [CGFloat]()
            var displacedPlot  = [CGFloat]()
            
            let thePlotSpace = self.plotSpace;
            thePlotSpace?.plotPoint(plotPoint: originPlot, numberOfCoordinates:2, forPlotAreaViewPoint:originView)
            thePlotSpace?.plotPoint(plotPoint: displacedPlot, numberOfCoordinates:2, forPlotAreaViewPoint:displacedView)
            
            if ( self.barsAreHorizontal == true ) {
                length = displacedPlot[CPTCoordinate.y.rawValue] - originPlot[CPTCoordinate.y.rawValue]
            }
            else {
                length = displacedPlot[CPTCoordinate.x.rawValue] - originPlot[CPTCoordinate.x.rawValue]
            }
        }
        else {
            length = decimalLength;
        }
        return length;
    }
    
    
    
    
    // MARK: -  Data Ranges
    override func plotRangeForCoordinate(coord: CPTCoordinate)->CPTPlotRange?
    {
        var range = super.plotRangeForCoordinate(coord: coord);
        
        if ( !self.barBasesVary ) {
            switch ( coord ) {
            case CPTCoordinate.x:
                if ( self.barsAreHorizontal == true ) {
                    let base = self.baseValue
                    if range?.contains(base ) == false {
                        var newRange = range
                        newRange.unionPlotRange(plotRangeWithLocationDecimal(base, lengthDecimal:(0))
                                                range = newRange;
                    }
                }
                break;
                
            case CPTCoordinate.y:
                if ( !self.barsAreHorizontal == true ) {
                    let base = self.baseValue
                    if ( range?.contains(base) == false ) {
                        var newRange = range
                        newRange.unionPlotRange( plotRangeWithLocationDecimal(base ,lengthDecimal:0))
                        range = newRange;
                    }
                }
                break;
                
            default:
                break;
            }
        }
        return range!;
    }
    
    func plotRangeEnclosingField(fieldEnum: CPTBarPlotField) -> CPTPlotRange
    {
        var range : CPTPlotRange?
        switch ( fieldEnum ) {
        case .location:
            range = self.plotRangeEnclosingBars()
            
        case .tip:
            fallthrough
        case .base:
            range = self.plotRangeForField(fieldEnum: fieldEnum.rawValue)
            
        default:
            break;
        }
        return range!;
    }

    //    /** @brief Computes a plot range that completely encloses all of the bars.
    //     *
    //     *  For a horizontal bar plot, this range starts at the left edge of the first bar and continues to the right edge
    //     *  of the last bar. Similarly, this range starts at the bottom edge of the first bar and continues to the top edge
    //     *  of the last bar for vertical bar plots. The length will have the same sign as the corresponding plot range from the plot space.
    //     *
    //     *  @return A plot range that completely encloses all of the bars.
    //     **/
        func plotRangeEnclosingBars() -> CPTPlotRange
        {
            var horizontalBars = self.barsAreHorizontal;
            var range = CPTPlotRange(location: 0, length: 0)
    
            if ( horizontalBars ) {
                range = self.plotRangeForCoordinate(coord: CPTCoordinate.y)!
            }
            else {
                range = self.plotRangeForCoordinate(coord: CPTCoordinate.x)!
            }
    
            var barOffsetLength = self.lengthInPlotCoordinates(decimalLength: self.barOffset)
            var barWidthLength  = self.lengthInPlotCoordinates(decimalLength: self.barWidth)
            var halfBarWidth    = barWidthLength / CGFloat(2)
    
            var rangeLocation = range.location
            var rangeLength   = range.length
    
            if rangeLength > CGFloat(0) {
                rangeLocation = rangeLocation - halfBarWidth
    
                range.locationDecimal = rangeLocation + barOffsetLength
                range.lengthDecimal   = rangeLength + barWidthLength
            }
            else {
                rangeLocation = rangeLocation + halfBarWidth
    
                range.locationDecimal = rangeLocation - barOffsetLength
                range.lengthDecimal   = rangeLength - barWidthLength
            }
    
            return range;
        }
    
    // MARK: - Drawing
    
    override func renderAsVectorInContext(context: CGContext)
    {
        if ( self.isHidden ) {
            return;
        }
        
        var cachedLocations = self.cachedNumbersForField(CPTBarPlotField.location.rawValue)
        var cachedLengths   = self.cachedNumbersForField(CPTBarPlotField.tip.rawValue)
        
        if ((cachedLocations == nil) || (cachedLengths == nil)) {
            return
        }
        
        var basesVary   = self.barBasesVary;
        var cachedBases = self.cachedNumbersForField(CPTBarPlotField.base.rawValue)
        
        if ( basesVary && (cachedBases == nil)) {
            return;
        }
        
        var barCount = self.cachedDataCount;
        guard barCount != 0 else { return }
        
        if ( cachedLocations.numberOfSamples != cachedLengths.numberOfSamples ) {
            print("[NSException raise:CPTException format:Number of bar locations and lengths do not match")
        }
        
        if ( basesVary && (cachedLengths.numberOfSamples != cachedBases.numberOfSamples)) {
            print("NSException raise:CPTException format:@ Number of bar lengths and bases do not match")
        }
        
        super.renderAsVectorInContext(context: context)
        
        context.beginTransparencyLayer(auxiliaryInfo: nil);
        for ii in 0..<barCount {
            self.drawBarInContext(context: context, recordIndex:ii)
        }
        context.endTransparencyLayer();
    }
    
    func barAtRecordIndex(idx: Int, basePoint: inout CGPoint, tipPoint: inout CGPoint)-> Bool
     
    {
        var basePoint = basePoint
        var tipPoint = tipPoint
        var horizontalBars            = self.barsAreHorizontal;
        let independentCoord = horizontalBars ? CPTCoordinate.y : CPTCoordinate.x
        let dependentCoord   = horizontalBars ? CPTCoordinate.x : CPTCoordinate.y
        
        let thePlotSpace = self.plotSpace;
        
        if ( self.doublePrecisionCache ) {
            var plotPoint = [CGFloat]()
            
            plotPoint[independentCoord.rawValue] = self.cachedDoubleForField(CPTBarPlotField.location, recordIndex:idx)
            if plotPoint[independentCoord.rawValue].isNaN {
                return false
            }
            
            // Tip point
            plotPoint[dependentCoord.rawValue] = self.cachedDoubleForField(CPTBarPlotField.tip, recordIndex:idx)
            if plotPoint[dependentCoord.rawValue].isNaN {
                return false
            }
            tipPoint = thePlotSpace.plotAreaViewPointForDoublePrecisionPlotPoint(plotPoint, numberOfCoordinates:2)
            
            // Base point
            if ( !self.barBasesVary ) {
                plotPoint[dependentCoord.rawValue] = self.baseValue
            }
            else {
                plotPoint[dependentCoord.rawValue] = self.cachedDoubleForField(CPTBarPlotField.base, recordIndex:idx)
            }
            if plotPoint[dependentCoord.rawValue].isNaN {
                return false
            }
            basePoint = thePlotSpace.plotAreaViewPointForDoublePrecisionPlotPoint(plotPoint, numberOfCoordinates:2)
        }
        else {
            var plotPoint = [CGFloat]()
            plotPoint[independentCoord.rawValue] = self.cachedDecimalForField(CPTBarPlotField.location, recordIndex:idx)
            if plotPoint[independentCoord.rawValue].isNaN {
                return false
            }
            
            // Tip point
            plotPoint[dependentCoord.rawValue] = self.cachedDecimalForField(fieldEnum: CPTBarPlotField.tip.rawValue, recordIndex:idx)
            if plotPoint[dependentCoord.rawValue].isNaN {
                return false
            }
            tipPoint = (thePlotSpace?.plotAreaViewPointForPlotPoint(plotPoint: plotPoint, numberOfCoordinates:2))!
            
            // Base point
            if ( !self.barBasesVary ) {
                plotPoint[dependentCoord.rawValue] = self.baseValue
            }
            else {
                plotPoint[dependentCoord.rawValue] = self.cachedDecimalForField(fieldEnum: CPTBarPlotField.base.rawValue, recordIndex:idx)
            }
            if plotPoint[dependentCoord.rawValue].isNaN {
                return false
            }
            basePoint = (thePlotSpace?.plotAreaViewPointForPlotPoint(plotPoint: plotPoint, numberOfCoordinates:2))!
//            basePoint -= 1
        }
        
        // Determine bar width and offset.
        var barOffsetLength = self.lengthInView(decimalLength: self.barOffset)
        
        // Offset
        if ( horizontalBars ) {
            basePoint.y += barOffsetLength
            tipPoint.y  += barOffsetLength
        }
        else {
            basePoint.x += barOffsetLength
            tipPoint.x  += barOffsetLength
        }
        
        return true
    }
    
    func newBarPath(with context: CGContext?, record recordIndex: Int) -> CGMutablePath? {
    // Get base and tip points
        var basePoint: CGPoint
        var tipPoint: CGPoint
        
        let barExists = barAtRecordIndex (idx: recordIndex, basePoint: &basePoint, tipPoint: &tipPoint)
        guard barExists == true else  { return nil }
        
        let width = barWidthForIndex(for: recordIndex)
        
        let path = newBarPath(
            with: context,
            basePoint: basePoint,
            tip: tipPoint,
            width: width)
        
        return path
}
    
    
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
    
    func barFillForIndex(idx: Int)-> CPTFill
    {
        var theBarFill = self.cachedValueForKey(key: NSBindingName.BarFills.rawValue, recordIndex: idx)
        
        if theBarFill == nil || (theBarFill == [CPTPlot nilData] {
            theBarFill = self.fill
            }
            
            return theBarFill;
    }
    
    
    func barLineStyleForIndex(idx: Int) -> CPTLineStyle
    {
        var theBarLineStyle = self.cachedValueForKey( key: NSBindingName.BarLineStyles.rawValue, recordIndex:idx)
        
        if ((theBarLineStyle == nil) || (theBarLineStyle == [CPTPlot nilData])) {
            theBarLineStyle = self.lineStyle;
        }
        
        return theBarLineStyle;
    }
    
    func barWidthForIndex(idx: Int)-> CGFloat
    {
        let theBarWidth = self.cachedValueForKey(key: NSBindingName.BarWidths.rawValue, recordIndex:idx)
        
        if ((theBarWidth == nil) || (theBarWidth == [CPTPlot nilData])) {
            theBarWidth = self.barWidth;
        }
        
        return theBarWidth;
    }
    
    func drawBarInContext(context: CGContext, recordIndex idx: Int)
    {
        // Get base and tip points
        var basePoint = CGPoint()
        var tipPoint = CGPoint()
        
        let barExists = self.barAtRecordIndex(idx: idx, basePoint:&basePoint, tipPoint:&tipPoint)
        guard barExists == true else { return }
        
        let width = self.barWidthForIndex(idx: idx)
        
        // Return if bar is off screen
        if self.barIsVisibleWithBasePoint(basePoint, width:width ) == false {
            return
        }
        
        let path = self.newBarPathWithContext(context,
                                              basePoint:basePoint,
                                              tipPoint:tipPoint,
                                              width:width)
        
        if ( path ) {
            context.saveGState();
            
            let theBarFill = self.barFillForIndex(idx: idx)
//            if ( theBarFill is CPTFill ) {
                context.beginPath()
                CGContextAddPath(context, path);
                theBarFill.fillPathInContext(context: context)
//            }
            
            let theLineStyle = self.barLineStyleForIndex(idx: idx)
//            if ( theLineStyle is CPTLineStyle ) {
                context.beginPath();
                CGContextAddPath(context, path);
                theLineStyle.setLineStyleInContext(context: context)
                theLineStyle.strokePathInContext(context: context)
//            }
            
            context.restoreGState();
            
        }
    }
    
    func drawSwatchForLegend(legend: CPTLegend, atIndex:Int, inRect rect:CGRect, inContext context: CGContext)
    {
        super.drawSwatchForLegend(legend: legend, atIndex  :atIndex, inRect: rect, context: context)
        
        if ( self.drawLegendSwatchDecoration ) {
            let theFill    = self.barFillForIndex( idx: atIndex)
            let theLineStyle = self.barLineStyleForIndex(idx: atIndex)
            
            if ( theFill || theLineStyle ) {
                let radius = max(self.barCornerRadius, self.barBaseCornerRadius);
                
//                if ( [theFill isKindOfClass:[CPTFill class]] ) {
                    context.beginPath();
                    CPTAddRoundedRectPath(context, CPTAlignIntegralRectToUserSpace(context, rect), radius);
                    theFill.fillPathInContext(context: context)
//                }
                
                //                if ( theLineStyle is CPTLineStyle ) {
                theLineStyle.setLineStyleInContext(context: context)
                context.beginPath();
                CPTAddRoundedRectPath(context, CPTAlignBorderedRectToUserSpace(context, rect, theLineStyle), radius);
                theLineStyle.strokePathInContext(context: context)
                //                }
            }
        }
    }
    
        /// @endcond
    
    // MARK: - Animation
    
    override func needsDisplayForKey(forKey aKey: String) -> Bool
    {
        var keys        = Set<String>()
        
        keys .insert("barCornerRadius")
        keys .insert("barBaseCornerRadius")
        keys .insert("barOffset")
        keys .insert("barWidth")
        keys .insert("baseValue")
        
        if keys.contains(aKey ) {
            return true
        }
        else {
            return CPTPlot.needsDisplay(forKey: aKey)
        }
    }

    //    #pragma mark -
    // MARK: Data Labels
    //
    //    /// @cond
    //
    //    func positionLabelAnnotation:(nonnull CPTPlotSpaceAnnotation *)label forIndex:(NSUInteger)idx
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
    //            return false
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
    //                BOOL handled = false
    //
    //                if ( [theDelegate respondsToSelector:@selector(barPlot:barTouchDownAtRecordIndex:)] ) {
    //                    handled = true
    //                    [theDelegate barPlot:self barTouchDownAtRecordIndex:idx];
    //                }
    //
    //                if ( [theDelegate respondsToSelector:@selector(barPlot:barTouchDownAtRecordIndex:withEvent:)] ) {
    //                    handled = true
    //                    [theDelegate barPlot:self barTouchDownAtRecordIndex:idx withEvent:event];
    //                }
    //
    //                if ( handled ) {
    //                    return true
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
    //            return false
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
    //                BOOL handled = false
    //
    //                if ( [theDelegate respondsToSelector:@selector(barPlot:barTouchUpAtRecordIndex:)] ) {
    //                    handled = true
    //                    [theDelegate barPlot:self barTouchUpAtRecordIndex:idx];
    //                }
    //
    //                if ( [theDelegate respondsToSelector:@selector(barPlot:barTouchUpAtRecordIndex:withEvent:)] ) {
    //                    handled = true
    //                    [theDelegate barPlot:self barTouchUpAtRecordIndex:idx withEvent:event];
    //                }
    //
    //                if ( idx == selectedDownIndex ) {
    //                    if ( [theDelegate respondsToSelector:@selector(barPlot:barWasSelectedAtRecordIndex:)] ) {
    //                        handled = true
    //                        [theDelegate barPlot:self barWasSelectedAtRecordIndex:idx];
    //                    }
    //
    //                    if ( [theDelegate respondsToSelector:@selector(barPlot:barWasSelectedAtRecordIndex:withEvent:)] ) {
    //                        handled = true
    //                        [theDelegate barPlot:self barWasSelectedAtRecordIndex:idx withEvent:event];
    //                    }
    //                }
    //
    //                if ( handled ) {
    //                    return true
    //                }
    //            }
    //        }
    //
    //        return [super pointingDeviceUpEvent:event atPoint:interactionPoint];
    //    }
    //

    // MARK: - Accessors
    //
    //    /// @cond
    //
    //    -(nullable CPTNumberArray *)barTips
    //    {
    //        return [[self cachedNumbersForField:CPTBarPlotFieldBarTip] sampleArray];
    //    }
    //
    //    func setBarTips:(nullable CPTNumberArray *)newTips
    //    {
    //        [self cacheNumbers:newTips forField:CPTBarPlotFieldBarTip];
    //    }
    //
    //    -(nullable CPTNumberArray *)barBases
    //    {
    //        return [[self cachedNumbersForField:CPTBarPlotFieldBarBase] sampleArray];
    //    }
    //
    //    func setBarBases:(nullable CPTNumberArray *)newBases
    //    {
    //        [self cacheNumbers:newBases forField:CPTBarPlotFieldBarBase];
    //    }
    //
    //    -(nullable CPTNumberArray *)barLocations
    //    {
    //        return [[self cachedNumbersForField:CPTBarPlotFieldBarLocation] sampleArray];
    //    }
    //
    //    func setBarLocations:(nullable CPTNumberArray *)newLocations
    //    {
    //        [self cacheNumbers:newLocations forField:CPTBarPlotFieldBarLocation];
    //    }
    //
    //    -(nullable CPTFillArray *)barFills
    //    {
    //        return [self cachedArrayForKey:CPTBarPlotBindingBarFills];
    //    }
    //
    //    func setBarFills:(nullable CPTFillArray *)newBarFills
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
    func setBarLineStyles(newBarLineStyles: [CPTLineStyle] )
        {
    self.cacheArray( newBarLineStyles, forKey:NSBindingName.CPTBarPlotBindingBarLineStyles.rawValue)
        self.setNeedsDisplay()
        }
    
    func setLineStyle(newLineStyle: CPTLineStyle )
    {
        if ( lineStyle != newLineStyle ) {
            lineStyle = newLineStyle
            self.setNeedsDisplay()
            NotificationCenter.send(
                name:.CPTLegendNeedsRedrawForPlotNotification,
                object:self)
        }
    }
    
    func setFill(newFill: CPTFill )
    {
        if ( fill != newFill ) {
            fill = newFill;
            self.setNeedsDisplay()
            NotificationCenter.send(
                name:.CPTLegendNeedsRedrawForPlotNotification,
                object:self)
        }
    }
    
    func setBarWidth(newBarWidth: CGFloat)
    {
        if barWidth != newBarWidth {
            barWidth = newBarWidth
            self.setNeedsDisplay()
        }
    }
    
    func setBarOffset(newBarOffset: CGFloat)
    {
        if  barOffset != newBarOffset {
            barOffset = newBarOffset
            self.setNeedsDisplay()
            self.repositionAllLabelAnnotations()
        }
    }
    
    func setBarCornerRadius(newCornerRadius : CGFloat)
    {
        if ( barCornerRadius != newCornerRadius ) {
            barCornerRadius = abs(newCornerRadius);
            self.setNeedsDisplay()
            NotificationCenter.send(
                name:.CPTLegendNeedsRedrawForPlotNotification,
                object:self)
        }
    }
    
    func setBarBaseCornerRadius(newCornerRadius: CGFloat)
    {
        if ( barBaseCornerRadius != newCornerRadius ) {
            barBaseCornerRadius = abs(newCornerRadius)
            self.setNeedsDisplay()
            NotificationCenter.send(
                name: .CPTLegendNeedsRedrawForPlotNotification,
                object:self)
        }
    }
    
    func setBaseValue(newBaseValue : CGFloat )
    {
        if ( baseValue != newBaseValue ) {
            baseValue = newBaseValue;
            self.setNeedsDisplay()
            self.setNeedsLayout()
        }
    }
    
    //    func setBarBasesVary:(BOOL)newBasesVary
    //    {
    //        if ( newBasesVary != barBasesVary ) {
    //            barBasesVary = newBasesVary;
    //            [self setDataNeedsReloading];
    //            [self setNeedsDisplay];
    //            [self setNeedsLayout];
    //        }
    //    }
    //
    //    func setBarsAreHorizontal:(BOOL)newBarsAreHorizontal
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

