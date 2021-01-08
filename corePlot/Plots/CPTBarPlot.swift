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
    
    func attributedLegendTitleForBarPlot(plot: CPTBarPlot, index:Int )-> NSAttributedString
}

// MARK:  Bar plot delegate
@objc protocol CPTBarPlotDelegate: CPTPlotDelegate {
    
    @objc optional func barPlot( plot: CPTBarPlot, barWasSelectedAtRecordIndex idx: Int)
    @objc optional func barPlot( plot: CPTBarPlot, barWasSelectedAtRecordIndex idx: Int, withEvent event: CPTNativeEvent)
    @objc optional func barPlot( plot: CPTBarPlot, barTouchDownAtRecordIndex   idx: Int)
    @objc optional func barPlot( plot: CPTBarPlot, barTouchDownAtRecordIndex   idx: Int, withEvent event: CPTNativeEvent)
    @objc optional func barPlot( plot: CPTBarPlot, barTouchUpAtRecordIndex     idx: Int)
    @objc optional func barPlot( plot: CPTBarPlot, barTouchUpAtRecordIndex     idx: Int, withEvent event: CPTNativeEvent )
}

enum  CPTBarPlotField : Int {
    case location ///< Bar location on independent coordinate axis.
    case tip      ///< Bar tip value.
    case base     ///< Bar base (used only if @link CPTBarPlot::barBasesVary barBasesVary @endlink is YES).
}


public class CPTBarPlot: CPTPlot {
    
    weak var barDataSource : CPTBarPlotDataSource?
    
//    var barFills = [CPTFill]()
//    var barLineStyles  = [CPTLineStyle]()
//    var barWidths  = [CPTLineStyle]()
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
    
    func tubularBarPlot(with color: NSUIColor, horizontalBars horizontal: Bool) -> CPTBarPlot {
        
        let barPlot = CPTBarPlot()
        let barLineStyle = CPTLineStyle()
        
        barLineStyle.lineWidth = CGFloat(1.0)
        barLineStyle.lineColor = NSUIColor.black
        
        barPlot.lineStyle = barLineStyle
        barPlot.barsAreHorizontal = horizontal
        barPlot.barWidth = CGFloat( 0.8)
        barPlot.barCornerRadius = CGFloat(2.0)
        
        let fillGradient = CPTGradient.shared.gradient(beginColor: color, endColor: NSUIColor.black)
        fillGradient.angle = CGFloat(horizontal ? -90.0 : 0.0)
        
        barPlot.fill = CPTFill.shared.fill(gradient: fillGradient)
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
    
    override func reloadPlotDataInIndexRange(indexRange: NSRange)
    {
        super.reloadPlotDataInIndexRange(indexRange: indexRange)
        
        if  self.loadNumbersForAllFieldsFromDataSourceInRecordIndexRange(indexRange: indexRange)  == false {
            
            weak var theDataSource = self.dataSource as? CPTBarPlotDataSource
            
            // Bar lengths
            if ( theDataSource ) != nil {
                let newBarLengths = self.numbersFromDataSourceForField(fieldEnum: .barTip., recordIndexRange:indexRange)
                self.cacheNumbers(newBarLengths, forField:.barTip, atRecordIndex:indexRange.location)
                
                
                if  self.barBasesVary  {
                    let newBarBases = self.numbersFromDataSourceForField( fieldEnum: .barBase, recordIndexRange:indexRange)
                    self.cacheNumbers(newBarBases, forField:.barBase, atRecordIndex:indexRange.location)
                }
                else {
                    self.barBases = nil;
                }
            }
            else {
                self.barTips.removeAll()
                self.barBases.removeAll()
            }
            
            // Locations of bars
            if self.plotRange {
                // Spread bars evenly over the plot range
                var locationData = nil;
                if ( self.doublePrecisionCache ) {
                    locationData = [[CPTMutableNumericData alloc] initWithData:[NSData data]
                                    dataType:CPTDataType(CGFloatingPointDataType, sizeof(double), CFByteOrderGetCurrent())
                                    shape:nil];
                    
                    locationData.shape = @[@(indexRange.length)];
                    
                    let doublePrecisionDelta = CGFloat(1.0)
                    if ( indexRange.length > 1 ) {
                        doublePrecisionDelta = self.plotRange.lengthDouble / (double)(indexRange.length - 1);
                    }
                    
                    let locationDouble = self.plotRange.locationDouble;
                    let dataBytes     = locationData.mutableBytes;
                    let dataEnd       = dataBytes + indexRange.length;
                    while ( dataBytes < dataEnd ) {
                        dataBytes++    = locationDouble;
                        locationDouble += doublePrecisionDelta;
                    }
                }
                else {
                    locationData = [[CPTMutableNumericData alloc] initWithData:[NSData data]
                                    dataType:CPTDataType(CPTDecimalDataType, sizeof(NSDecimal), CFByteOrderGetCurrent())
                                    shape:nil];
                    locationData.shape = @[@(indexRange.length)];
                    
                    var delta = CGFloat(1);
                    if ( indexRange.length > 1 ) {
                        delta = self.plotRange.lengthDecimal / CGFloat((indexRange.length - 1));
                    }
                    
                    var locationDecimal = self.plotRange.locationDecimal;
                    let dataBytes      = locationData.mutableBytes;
                    let dataEnd        = dataBytes + indexRange.length;
                    while ( dataBytes < dataEnd ) {
                        dataBytes++    = locationDecimal;
                        locationDecimal = locationDecimal + delta;
                    }
                }
                self cacheNumbers(locationData, forField:CPTBarPlotFieldBarLocation, atRecordIndex:indexRange.location)
            }
            else if (( theDataSource ) != nil) {
                // Get locations from the datasource
                let newBarLocations = self numbersFromDataSourceForField:CPTBarPlotFieldBarLocation, recordIndexRange:indexRange)
                [self cacheNumbers:newBarLocations forField:CPTBarPlotFieldBarLocation atRecordIndex:indexRange.location];
            }
            else {
                // Make evenly spaced locations starting at zero
                let locationData = nil;
                if self.doublePrecisionCache() {
                    locationData = [[CPTMutableNumericData alloc] initWithData:[NSData data]
                                    dataType:CPTDataType(CGFloatingPointDataType, sizeof(double), CFByteOrderGetCurrent())
                                    shape:nil];
                    locationData.shape = @[@(indexRange.length)];
                    
                    var locationDouble = 0.0;
                    var dataBytes     = locationData;
                    var dataEnd       = dataBytes + indexRange.length;
                    while ( dataBytes < dataEnd ) {
                        dataBytes++    = locationDouble;
                        locationDouble += 1.0;
                    }
                }
                else {
                    locationData = [[CPTMutableNumericData alloc] initWithData:[NSData data]
                                    dataType:CPTDataType(CPTDecimalDataType, sizeof(NSDecimal), CFByteOrderGetCurrent())
                                    shape:nil];
                    locationData.shape = @[@(indexRange.length)];
                    
                    let locationDecimal = CGFloat(0);
                    let dataBytes      = locationData.mutableBytes;
                    let dataEnd        = dataBytes + indexRange.length;
                    var one             = CGFloat(1);
                    while ( dataBytes < dataEnd ) {
                        dataBytes++    = locationDecimal
                        locationDecimal = locationDecimal + one
                    }
                }
                self.cacheNumbers(locationData, forField:CPTBarPlotFieldBarLocation, atRecordIndex:indexRange.location)
            }
        }
    }
    
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
        
        if (theDataSource?.barFillsForBarPlot) != nil {
            needsLegendUpdate = true
            
            self.cacheArray(array: (theDataSource?.barFillsForBarPlot(plot: self, indexRange:indexRange))!,
                            forKey: NSBindingName.BarFills.rawValue,
                            atRecordIndex:indexRange.location)
        }
        else
        if (theDataSource?.barFillsForBarPlot) != nil {
            needsLegendUpdate = true
            
            let nilObject               : CPTFill?
            var array = [CPTFill]()
            let maxIndex        = NSMaxRange(indexRange)
            let location = indexRange.location
            
            for  idx in location..<maxIndex {
                let dataSourceFill = theDataSource?.barFillForBarPlot(plot: self, index:idx)
                if dataSourceFill  != nil {
                    array.append( contentsOf: dataSourceFill!)
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
        if (theDataSource?.barLineStylesForBarPlot) != nil {
            
            needsLegendUpdate = true
            let array = theDataSource?.barLineStylesForBarPlot(
                plot: self,
                indexRange:indexRange)
            self.cacheArray(array: array! ,
                            forKey: NSBindingName.BarLineStyles.rawValue,
                            atRecordIndex: indexRange.location)
        }
        else if (theDataSource?.barLineStylesForBarPlot) != nil {
            
            needsLegendUpdate = true
            let  nilObject : CPTLineStyle?
            var array = [CPTLineStyle?]()
            let maxIndex  = NSMaxRange(indexRange)
            
            for  idx in indexRange.location..<maxIndex {
                let dataSourceLineStyle = theDataSource?.barLineStyleForBarPlot(plot: self, index: idx)
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
            
            var originPlotPoint    = [ CGFloat](repeating: 0, count: 2)
            var displacedPlotPoint = [ CGFloat](repeating: 0, count: 2)
            
            switch ( coord ) {
            case .x:
                originPlotPoint[CPTCoordinate.x.rawValue]    = xLocation
                originPlotPoint[CPTCoordinate.y.rawValue]    = yLocation
                displacedPlotPoint[CPTCoordinate.x.rawValue] = xLocation + decimalLength
                displacedPlotPoint[CPTCoordinate.y.rawValue] = yLocation;
                
            case .y:
                originPlotPoint[CPTCoordinate.x.rawValue]    = xLocation
                originPlotPoint[CPTCoordinate.y.rawValue]    = yLocation
                displacedPlotPoint[CPTCoordinate.x.rawValue] = xLocation;
                displacedPlotPoint[CPTCoordinate.y.rawValue] = yLocation + decimalLength
                
            default:
                break;
            }
            
            let originPoint    = thePlotSpace.plotAreaViewPointForPlotPoint(plotPoint: originPlotPoint   , numberOfCoordinates:2)
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
        
        var lengthDouble = Double(0)
        
        if barWidthsAreInViewCoordinates == true {
            let floatLength = CGFloat(length)
            let originViewPoint = CGPoint.zero
            let displacedViewPoint = CGPoint(x: floatLength, y: floatLength)
            
            var originPlotPoint    = [ CGFloat](repeating: 0, count: 2)
            var displacedPlotPoint = [ CGFloat](repeating: 0, count: 2)
            
            let thePlotSpace = plotSpace
            thePlotSpace?.doublePrecisionPlotPoint(originPlotPoint  , numberOfCoordinates: 2, forPlotAreaViewPoint: originViewPoint)
            thePlotSpace?.doublePrecisionPlotPoint(displacedPlotPoint, numberOfCoordinates: 2, forPlotAreaViewPoint: displacedViewPoint)
            
            if barsAreHorizontal == true {
                lengthDouble = Double(displacedPlotPoint[CPTCoordinate.y.rawValue] - originPlotPoint[CPTCoordinate.y.rawValue])
            } else {
                lengthDouble = Double(displacedPlotPoint[CPTCoordinate.x.rawValue] - originPlotPoint[CPTCoordinate.x.rawValue])
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
        
        if self.barWidthsAreInViewCoordinates == true  {
            
            let floatLength = decimalLength
            
            let originView = CGPoint()
            let displacedView = CGPoint(x: floatLength, y: floatLength)
            
            let originPlot = [CGFloat]()
            let displacedPlot  = [CGFloat]()
            
            let thePlotSpace = self.plotSpace;
            thePlotSpace?.plotPoint(plotPoint: originPlot,    numberOfCoordinates: 2, forPlotAreaViewPoint:originView)
            thePlotSpace?.plotPoint(plotPoint: displacedPlot, numberOfCoordinates: 2, forPlotAreaViewPoint:displacedView)
            
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
                        newRange.unionPlotRange(plotRangeWithLocationDecimal(base, lengthDecimal:(0)))
                        range = newRange;
                    }
                }
                
            case CPTCoordinate.y:
                if ( !self.barsAreHorizontal == true ) {
                    let base = self.baseValue
                    if ( range?.contains(base) == false ) {
                        var newRange = range
                        newRange.unionPlotRange( plotRangeWithLocationDecimal(base ,lengthDecimal:0))
                        range = newRange
                    }
                }
                
            default:
                break
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
    
    /** @brief Computes a plot range that completely encloses all of the bars.
     *
     *  For a horizontal bar plot, this range starts at the left edge of the first bar and continues to the right edge
     *  of the last bar. Similarly, this range starts at the bottom edge of the first bar and continues to the top edge
     *  of the last bar for vertical bar plots. The length will have the same sign as the corresponding plot range from the plot space.
     *
     *  @return A plot range that completely encloses all of the bars.
     **/
    func plotRangeEnclosingBars() -> CPTPlotRange
    {
        let horizontalBars = self.barsAreHorizontal;
        var range = CPTPlotRange(location: 0, length: 0)
        
        if horizontalBars == true {
            range = self.plotRangeForCoordinate(coord: CPTCoordinate.y)!
        }
        else {
            range = self.plotRangeForCoordinate(coord: CPTCoordinate.x)!
        }
        
        let barOffsetLength = self.lengthInPlotCoordinates(decimalLength: self.barOffset)
        let barWidthLength  = self.lengthInPlotCoordinates(decimalLength: self.barWidth)
        let halfBarWidth    = barWidthLength / CGFloat(2)
        
        var rangeLocation = range.location
        let rangeLength   = range.length
        
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
        
        var cachedLocations = self.cachedNumbersForField(fieldEnum: CPTBarPlotField.location.rawValue)
        var cachedLengths   = self.cachedNumbersForField(fieldEnum: CPTBarPlotField.tip.rawValue)
        
        if ((cachedLocations == nil) || (cachedLengths == nil)) {
            return
        }
        
        var basesVary   = self.barBasesVary;
        var cachedBases = self.cachedNumbersForField(fieldEnum: CPTBarPlotField.base.rawValue)
        
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
        
        if self.doublePrecisionCache( ) == true {
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
            basePoint = thePlotSpace!.plotAreaViewPointForDoublePrecisionPlotPoint(plotPoint, numberOfCoordinates:2)
        }
        else {
            var plotPoint = [CGFloat]()
            plotPoint[independentCoord.rawValue] = self.cachedDecimalForField(fieldEnum: CPTBarPlotField.location.rawValue, recordIndex:idx)
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
    
    func newBarPathWithContext( context: CGContext?, record recordIndex: Int) -> CGMutablePath? {
        
        // Get base and tip points
        var basePoint: CGPoint
        var tipPoint: CGPoint
        
        let barExists = barAtRecordIndex (idx: recordIndex, basePoint: &basePoint, tipPoint: &tipPoint)
        guard barExists == true else  { return nil }
        
        let width = barWidthForIndex(idx: recordIndex)
        
        let path = newBarPathWithContext(
            context: context,
            basePoint: basePoint,
            tip: tipPoint,
            width: width)
        
        return path
    }
    
    func newBarPathWithContext( context: CGContext?, basePoint: CGPoint, tip tipPoint: CGPoint, width: CGFloat?) -> CGMutablePath {
        
        // drawing a bar and for doing hit-testing on a click/touch event
        let horizontalBars = barsAreHorizontal
        
        let barWidthLength = lengthInView( decimalLength: width!)
        let halfBarWidth = CGFloat(0.5) * barWidthLength
        
        var barRect: CGRect
        
        if horizontalBars == true {
            barRect = CGRect(x: basePoint.x, y: basePoint.y - halfBarWidth, width: tipPoint.x - basePoint.x, height: barWidthLength)
        } else {
            barRect = CGRect(x: basePoint.x - halfBarWidth, y: basePoint.y, width: barWidthLength, height: tipPoint.y - basePoint.y)
        }
        
        
        let widthNegative  = barRect.size.width.signbit()
        let heightNegative = barRect.size.height.signbit()
        
        // Align to device pixels if there is a line border.
        // Otherwise, align to view space, so fills are sharp at edges.
        // Note: may not have a context if doing hit testing.
        if ( self.alignsPointsToPixels /*&& (context != nil)*/ ) {
            // Round bar dimensions so adjacent bars always align to the right pixel position
            
            let roundingPrecision = CGFloat(1.0e6);
            
            barRect.origin.x    = round(barRect.origin.x * roundingPrecision) / roundingPrecision
            barRect.origin.y    = round(barRect.origin.y * roundingPrecision) / roundingPrecision
            barRect.size.width  = round(barRect.size.width * roundingPrecision) / roundingPrecision
            barRect.size.height = round(barRect.size.height * roundingPrecision) / roundingPrecision
            
            let theContext = context;
            
            if ( self.lineStyle.lineWidth > CGFloat(0.0)) {
                barRect = CPTUtilities.shared.CPTAlignRectToUserSpace(context: theContext!, rect: barRect)
            }
            else {
                barRect = CPTUtilities.shared.CPTAlignIntegralRectToUserSpace(context: theContext!, rect: barRect)
            }
        }
        
        let radius = CGFloat(min(min(barCornerRadius, abs(barRect.size.width) * CGFloat(0.5)), abs(barRect.size.height) * CGFloat(0.5)))
        let baseRadius = CGFloat(min(min(barBaseCornerRadius, abs(barRect.size.width) * CGFloat(0.5)), abs(barRect.size.height) * CGFloat(0.5)))
        
        if ( widthNegative && (barRect.size.width > CGFloat(0.0))) {
            barRect.origin.x  += barRect.size.width;
            barRect.size.width = -barRect.size.width;
        }
        if ( heightNegative && (barRect.size.height > CGFloat(0.0))) {
            barRect.origin.y   += barRect.size.height;
            barRect.size.height = -barRect.size.height;
        }
        
        let path = CGMutablePath()
        
        if ( radius == CGFloat(0.0)) {
            if ( baseRadius == CGFloat(0.0)) {
                // square corners
                path.addRect( barRect)
            }
            else {
                let tipX = barRect.origin.x + barRect.size.width;
                let tipY = barRect.origin.y + barRect.size.height;
                
                // rounded at base end only
                if ( horizontalBars == true ) {
                    path.move(to: CGPoint( x: tipX, y: tipY))
                    
                    let point1 = CGPoint(x: barRect.origin.x, y: tipY)
                    let point2 = CGPoint(x: barRect.origin.x, y: barRect.midY)
                    path.addArc(tangent1End: point1, tangent2End: point2, radius: baseRadius)
                    
                    let point3 = CGPoint(x: barRect.origin.x, y: barRect.origin.y)
                    let point4 = CGPoint(x: tipX, y: barRect.origin.y)
                    path.addArc(tangent1End: point3, tangent2End: point4, radius: baseRadius, transform:  .identity)
                    
                    path.addLine(to: CGPoint( x: tipX, y: barRect.origin.y))
                }
                else {
                    path.move(to: CGPoint(x: barRect.origin.x, y: tipY), transform: .identity)
                    path.addArc(tangent1End: CGPoint(x: barRect.origin.x, y: barRect.origin.y), tangent2End: CGPoint(x: barRect.midX, y: barRect.origin.y), radius: baseRadius, transform: .identity)
                    path.addArc(tangent1End: CGPoint(x: tipX, y: barRect.origin.y), tangent2End: CGPoint(x: tipX, y: tipY), radius: baseRadius, transform: .identity)
                    path.addLine(to: CGPoint(x: tipX, y: tipY), transform: .identity)
                }
                path.closeSubpath();
            }
        }
        else {
            let tipX = barRect.origin.x + barRect.size.width;
            let tipY = barRect.origin.y + barRect.size.height;
            
            if ( baseRadius == CGFloat(0.0)) {
                // rounded at tip end only
                path.move(to: CGPoint( x: barRect.origin.x, y: barRect.origin.y ))
                
                if ( horizontalBars == true) {
                    
                    path.addArc(tangent1End: CGPoint(x: tipX, y: barRect.origin.y), tangent2End: CGPoint(x: tipX, y: barRect.midY), radius: radius, transform: .identity)
                    path.addArc(tangent1End: CGPoint(x: tipX, y: tipY), tangent2End: CGPoint(x: barRect.origin.x, y: tipY), radius: radius, transform: .identity)
                    path.addLine(to: CGPoint(x: barRect.origin.x, y: tipY), transform: .identity)
                }
                else {
                    
                    
                    path.addArc(tangent1End: CGPoint(x: barRect.origin.x, y: tipY), tangent2End: CGPoint(x: barRect.midX, y: tipY), radius: radius, transform: .identity)
                    path.addArc(tangent1End: CGPoint(x: tipX, y: tipY), tangent2End: CGPoint(x: tipX, y: barRect.origin.y), radius: radius, transform: .identity)
                    path.addLine(to: CGPoint(x: tipX, y: barRect.origin.y), transform: .identity)
                    
                }
                path.closeSubpath();
            }
            else {
                // rounded at both ends
                if ( horizontalBars ) {
                    path.move(to: CGPoint(x: barRect.origin.x, y: barRect.midY), transform: .identity)
                    path.addArc(tangent1End: CGPoint(x: barRect.origin.x, y: tipY), tangent2End: CGPoint(x: barRect.midX, y: tipY), radius: baseRadius, transform: .identity)
                    path.addArc(tangent1End: CGPoint(x: tipX, y: tipY), tangent2End: CGPoint(x: tipX, y: barRect.midY), radius: radius, transform: .identity)
                    path.addArc(tangent1End: CGPoint(x: tipX, y: barRect.origin.y), tangent2End: CGPoint(x: barRect.midX, y: barRect.origin.y), radius: radius, transform: .identity)
                    path.addArc(tangent1End: CGPoint(x: barRect.origin.x, y: barRect.origin.y), tangent2End: CGPoint(x: barRect.origin.x, y: barRect.midY), radius: baseRadius, transform: .identity)
                }
                else {
                    path.move(to: CGPoint(x: barRect.origin.x, y: barRect.midY), transform: .identity)
                    path.addArc(tangent1End: CGPoint(x: barRect.origin.x, y: tipY), tangent2End: CGPoint(x: barRect.midX, y: tipY), radius: radius, transform: .identity)
                    path.addArc(tangent1End: CGPoint(x: tipX, y: tipY), tangent2End: CGPoint(x: tipX, y: barRect.midY), radius: radius, transform: .identity)
                    path.addArc(tangent1End: CGPoint(x: tipX, y: barRect.origin.y), tangent2End: CGPoint(x: barRect.midX, y: barRect.origin.y), radius: baseRadius, transform: .identity)
                    path.addArc(tangent1End: CGPoint(x: barRect.origin.x, y: barRect.origin.y), tangent2End: CGPoint(x: barRect.origin.x, y: barRect.midY), radius: baseRadius, transform: .identity)
                }
                path.closeSubpath();
            }
        }
        return path;
    }
    
    func barIsVisibleWithBasePoint(basePoint: CGPoint, width: CGFloat)-> Bool
    {
        let horizontalBars    = self.barsAreHorizontal
        let barWidthLength = self.lengthInView(decimalLength: width)
        let halfBarWidth   = CGFloat(0.5) * barWidthLength
        
        let thePlotArea = self.plotArea;
        
        let lowerBound = horizontalBars ? thePlotArea!.bounds.minY : thePlotArea?.bounds.minX
        let upperBound = horizontalBars ? thePlotArea!.bounds.maxY : thePlotArea!.bounds.maxX
        let base       = (horizontalBars ? basePoint.y : basePoint.x);
        
        return (base + halfBarWidth >= lowerBound!) && (base - halfBarWidth <= upperBound);
    }
    
    func barFillForIndex(idx: Int)-> CPTFill?
    {
        var theBarFill = self.cachedValueForKey(key: NSBindingName.BarFills.rawValue, recordIndex: idx) as? CPTFill
        
        if theBarFill == nil /*|| (theBarFill == CPTPlot.nilData()*/ {
            theBarFill = self.fill
        }
        return theBarFill
    }
    
    
    func barLineStyleForIndex(idx: Int) -> CPTLineStyle
    {
        var theBarLineStyle = self.cachedValueForKey( key: NSBindingName.BarLineStyles.rawValue, recordIndex:idx) as? CPTLineStyle
        
        if theBarLineStyle == nil /*|| theBarLineStyle == CPTPlot.nilData()*/ {
            theBarLineStyle = self.lineStyle;
        }
        
        return theBarLineStyle!;
    }
    
    func barWidthForIndex(idx: Int)-> CGFloat
    {
        var theBarWidth = self.cachedValueForKey(key: NSBindingName.BarWidths.rawValue, recordIndex:idx) as? CGFloat
        
        if theBarWidth == nil /*|| theBarWidth == CPTPlot.nilData()*/ {
            theBarWidth = self.barWidth;
        }
        return theBarWidth!
    }
    
    func drawBarInContext(context: CGContext, recordIndex idx: Int)
    {
        // Get base and tip points
        var basePoint = CGPoint()
        var tipPoint  = CGPoint()
        
        let barExists    = self.barAtRecordIndex(idx: idx, basePoint:&basePoint, tipPoint:&tipPoint)
        guard barExists == true else { return }
        
        let width = self.barWidthForIndex(idx: idx)
        
        // Return if bar is off screen
        if self.barIsVisibleWithBasePoint(basePoint: basePoint, width:width ) == false {
            return
        }
        
        let path = self.newBarPathWithContext(context  : context,
                                              basePoint: basePoint,
                                              tip      : tipPoint,
                                              width    : width)
        
        //        if ( path ) {
        context.saveGState();
        
        let theBarFill = self.barFillForIndex(idx: idx)
        //            if ( theBarFill is CPTFill ) {
        context.beginPath()
        context.addPath( path )
        theBarFill?.fillPathInContext(context: context)
        //            }
        
        let theLineStyle = self.barLineStyleForIndex(idx: idx)
        //            if ( theLineStyle is CPTLineStyle ) {
        context.beginPath()
        context.addPath( path )
        theLineStyle.setLineStyleInContext(context: context)
        theLineStyle.strokePathInContext(context: context)
        //            }
        
        context.restoreGState();
        //        }
    }
    
    func drawSwatchForLegend(legend: CPTLegend, atIndex:Int, inRect rect:CGRect, inContext context: CGContext)
    {
        super.drawSwatchForLegend(legend: legend, atIndex  :atIndex, inRect: rect, context: context)
        
        if ( self.drawLegendSwatchDecoration ) {
            let theFill      = self.barFillForIndex( idx: atIndex)
            let theLineStyle = self.barLineStyleForIndex(idx: atIndex)
            
//            if ( theFill || theLineStyle ) {
                let radius = max(self.barCornerRadius, self.barBaseCornerRadius);
                
                //                if ( [theFill isKindOfClass:[CPTFill class]] ) {
                context.beginPath();
                let rect =  CPTUtilities.shared.CPTAlignIntegralRectToUserSpace(context: context, rect: rect)
                CPTPathExtensions.shared.CPTAddRoundedRectPath(context: context, rect: rect, cornerRadius: radius)
                theFill!.fillPathInContext(context: context)
                //                }
                
                //                if ( theLineStyle is CPTLineStyle ) {
                theLineStyle.setLineStyleInContext(context: context)
                context.beginPath();
                let rect1 = CPTUtilities.shared.CPTAlignBorderedRectToUserSpace(context: context, rect: rect, borderLineStyle: theLineStyle)
                CPTPathExtensions.shared.CPTAddRoundedRectPath(context: context, rect: rect1, cornerRadius: radius);
                theLineStyle.strokePathInContext(context: context)
                //                }
//            }
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
    
    // MARK: - Data Labels
    override func positionLabelAnnotation(label: CPTPlotSpaceAnnotation, forIndex idx: Int)
    {
    }
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
    
    
    
    // MARK: -  Legends
    //
    //    /** @internal
    //     *  @brief The number of legend entries provided by this plot.
    //     *  @return The number of legend entries.
    //     **/
    override func numberOfLegendEntries() -> Int
    {
        var entryCount = 1;
        
        weak var  theDataSource = self.dataSource as? CPTBarPlotDataSource
        
        if (theDataSource?.legendTitleForBarPlot(_: index:))! ||
            ((theDataSource?.barFillForBarPlot(_:index:)) != nil) {
            self.reloadDataIfNeeded()
            entryCount = self.cachedDataCount;
        }
        return entryCount;
    }
    
    /** @internal
     *  @brief The title text of a legend entry.
     *  @param idx The index of the desired title.
     *  @return The title of the legend entry at the requested index.
     **/
    override func titleForLegendEntryAtIndex(idx: Int) ->String
    {
        var legendTitle = ""
        
        weak var theDataSource = self.dataSource as? CPTBarPlotDataSource
        
        if ((theDataSource?.legendTitleForBarPlot(_: index:)) != nil) {
            legendTitle = (theDataSource?.legendTitleForBarPlot(plot: self, index:idx))!
        }
        else {
            legendTitle = super.titleForLegendEntryAtIndex(idx: idx)
        }
        return legendTitle
    }
    
    /** @internal
     *  @brief The styled title text of a legend entry.
     *  @param idx The index of the desired title.
     *  @return The styled title of the legend entry at the requested index.
     **/
    override func attributedTitleForLegendEntryAtIndex( idx: Int)-> NSAttributedString
    {
        var legendTitle : NSAttributedString
        
        weak var theDataSource = dataSource as? CPTBarPlotDataSource
        
        if ((theDataSource?.attributedLegendTitleForBarPlot(_: recordIndex:)) != nil) {
            legendTitle = (theDataSource?.attributedLegendTitleForBarPlot( plot: self, index:idx))!
        }
        else {
            legendTitle = super.attributedTitleForLegendEntryAtIndex(idx: idx)
        }
        
        return legendTitle;
    }
    
    // MARK: - Responder Chain and User interaction
    override func dataIndexFromInteractionPoint( point:CGPoint)->Int
    {
        var idx      = NSNotFound;
        let barCount = self.cachedDataCount
        var ii       = 0;
        
        while (ii < barCount && idx == NSNotFound) {
            let path = self.newBarPathWithContext(context: nil, record:ii)
            
            if path?.contains(point) == false {
                idx = ii;
            }
            ii += 1
        }
        return idx;
    }
    
    override func pointingDeviceDownEvent(event: CPTNativeEvent, atPoint interactionPoint:CGPoint)-> Bool
    {
        let theGraph    = self.graph
        let thePlotArea = self.plotArea
        
        guard self.isHidden == false else { return false }
        guard theGraph != nil else { return false }
        guard thePlotArea != nil else { return false }
        
        weak var theDelegate = self.delegate as? CPTBarPlotDelegate
        
        // Inform delegate if a point was hit
        let plotAreaPoint = theGraph?.convert(interactionPoint, to:thePlotArea)
        let idx  = self.dataIndexFromInteractionPoint(point: plotAreaPoint!)
        self.pointingDeviceDownIndex = idx
        
        if ( idx != NSNotFound ) {
            var handled = false
            
            if let _ = theDelegate?.barPlot(plot:barTouchDownAtRecordIndex:) {
                theDelegate?.barPlot?(plot:self, barTouchUpAtRecordIndex: idx)
                handled = true
            }
            
            if let _ = theDelegate?.barPlot(plot:barTouchDownAtRecordIndex:withEvent:){
                theDelegate?.barPlot?(plot: self, barTouchUpAtRecordIndex: idx, withEvent: event)
                handled = true
            }
            
            if handled == true {
                return true
            }
        }
        return super.pointingDeviceDownEvent(event: event, atPoint:interactionPoint)
    }
    
    override func pointingDeviceUpEvent(event: CPTNativeEvent, atPoint interactionPoint:CGPoint)-> Bool
    {
        let selectedDownIndex = self.pointingDeviceDownIndex
        self.pointingDeviceDownIndex = NSNotFound
        
        let theGraph    = self.graph
        let thePlotArea = self.plotArea
        
        guard self.isHidden == false else { return false }
        guard theGraph != nil else { return false }
        guard thePlotArea != nil else { return false }
        
        weak var theDelegate = self.delegate as? CPTBarPlotDelegate
        
        // Inform delegate if a point was hit
        let plotAreaPoint = theGraph?.convert(interactionPoint, to: thePlotArea)
        let idx = self.dataIndexFromInteractionPoint(point: plotAreaPoint!)
        if idx != NSNotFound {
            
            var handled = false
            
            if let _ = theDelegate?.barPlot(plot:barTouchUpAtRecordIndex:) {
                theDelegate?.barPlot?(plot:self, barTouchUpAtRecordIndex: idx)
                handled = true
            }
            
            if let _ = theDelegate?.barPlot(plot:barTouchUpAtRecordIndex:withEvent:){
                theDelegate?.barPlot?(plot: self, barTouchUpAtRecordIndex: idx, withEvent: event)
                handled = true
            }
            
            if ( idx == selectedDownIndex ) {
                if let _ = theDelegate?.barPlot(plot:barWasSelectedAtRecordIndex:) {
                    theDelegate?.barPlot?(plot: self,  barWasSelectedAtRecordIndex:idx)
                    handled = true
                }
                
                if let _ = theDelegate?.barPlot(plot:barWasSelectedAtRecordIndex:withEvent:) {
                    theDelegate?.barPlot?(plot: self, barWasSelectedAtRecordIndex:idx, withEvent: event)
                    handled = true
                }
            }
            
            if ( handled == true) {
                return true
            }
        }
        return super.pointingDeviceUpEvent(event: event, atPoint:interactionPoint)
    }
    
    
    // MARK: - Accessors
    var barTips : CPTNumberArray {
        get { self.cachedNumbersForField( fieldEnum: CPTBarPlotField.tip.rawValue) }
        set { self.cachedNumbers ( newValue , fieldEnum: CPTBarPlotField.tip.rawValue)}
    }
    var barBases : CPTNumberArray {
        get { self.cachedNumbersForField( fieldEnum: CPTBarPlotField.base.rawValue) }
        set { self.cachedNumbers ( newValue , fieldEnum: CPTBarPlotField.base.rawValue)}
    }
    var barLocations : CPTNumberArray {
        get { self.cachedNumbersForField( fieldEnum: CPTBarPlotField.location.rawValue) }
        set { self.cachedNumbers ( newValue , fieldEnum: CPTBarPlotField.location.rawValue)}
    }
    var barFills : CPTNumberArray {
        get { self.cachedNumbersForField( fieldEnum: CPTBarPlotField) }
        set { self.cachedNumbers ( newValue , fieldEnum: CPTBarPlotField.location.rawValue)}
    }

    
    

    
//        -(nullable CPTFillArray *)barFills
//        {
//            return [self cachedArrayForKey:CPTBarPlotBindingBarFills];
//        }
//
//        func setBarFills:(nullable CPTFillArray *)newBarFills
//        {
//            [self cacheArray:newBarFills forKey:CPTBarPlotBindingBarFills];
//            [self setNeedsDisplay];
//        }
    
        -(nullable CPTLineStyleArray *)barLineStyles
        {
            return [self cachedArrayForKey:CPTBarPlotBindingBarLineStyles];
        }
    
    func setBarLineStyles(newBarLineStyles: [CPTLineStyle] )
    {
        self.cacheArray( newBarLineStyles, forKey:NSBindingName.BarLineStyles.rawValue)
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


    // MARK: - Fields
    
        /// @cond
    
    func numberOfFields() -> Int {
        return 3
    }
    func fieldIdentifiers() -> [CGFloat] {
        return [
            CPTBarPlotFieldBarLocation,
            CPTBarPlotFieldBarTip,
            CPTBarPlotFieldBarBase
        ]
    }
    
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
    override func coordinateForFieldIdentifier(field: Int) -> CPTCoordinate
        {
        let coordinate = CPTCoordinate.none;
    
            switch ( field ) {
            case CPTBarPlotFieldBar.location.rawValue:
                coordinate = (self.barsAreHorizontal ? CPTCoordinate.y : CPTCoordinate.x);
                    break;
    
            case CPTBarPlotFieldBar.tip.rawValue:
            case CPTBarPlotFieldBar.base.rawValue:
                coordinate = (self.barsAreHorizontal ? CPTCoordinate.x : CPTCoordinate.y);
                    break;
    
                default:
                    break;
            }
    
            return coordinate;
        }
    
}

