//
//  CPTPieChart.swift
//  corePlot
//
//  Created by thierryH24 on 14/11/2020.
//

import AppKit

public protocol CPTPieChartDataSource  {
    
    func sliceFillsForPieChart (          _ pieChart: CPTPieChart, recordIndexRange:NSRange) -> [CPTFill?]
    func sliceFillForPieChart   (         _ pieChart: CPTPieChart, idx : Int) -> CPTFill
    func radialOffsetsForPieChart(        _ pieChart: CPTPieChart, indexRange:NSRange) -> [CGFloat]
    func radialOffsetForPieChart(         _ pieChart: CPTPieChart, idx:Int) -> CGFloat
    func legendTitleForPieChart (         _ pieChart: CPTPieChart, idx: Int)-> String
    func attributedLegendTitleForPieChart(_ pieChart: CPTPieChart, idx :Int)-> NSAttributedString
}


protocol CPTPieChartDelegate : CPTPlotDelegate {

    func pieChart(plot: CPTPieChart, sliceWasSelectedAtRecordIndex idx:Int)
    func pieChart(plot: CPTPieChart, sliceWasSelectedAtRecordIndex idx: Int, withEvent event: CPTNativeEvent )
    func pieChart(plot: CPTPieChart, sliceTouchDownAtRecordIndex idx: Int)
    func pieChart(plot: CPTPieChart, sliceTouchDownAtRecordIndex idx: Int, withEvent event: CPTNativeEvent )
    func pieChart(plot: CPTPieChart, sliceTouchUpAtRecordIndex idx: Int)
    func pieChart(plot: CPTPieChart, sliceTouchUpAtRecordIndex idx: Int, withEvent event: CPTNativeEvent )

}

public class CPTPieChart: CPTPlot {
    
    private let colorLookupTable = [
        [CGFloat(1.0), CGFloat(0.0), CGFloat(0.0)],
        [CGFloat(0.0), CGFloat(1.0), CGFloat(0.0)],
        [CGFloat(0.0), CGFloat(0.0), CGFloat(1.0)],
        [CGFloat(1.0), CGFloat(1.0), CGFloat(0.0)],
        [CGFloat(0.25), CGFloat(0.5), CGFloat(0.25)],
        [CGFloat(1.0), CGFloat(0.0), CGFloat(1.0)],
        [CGFloat(0.5), CGFloat(0.5), CGFloat(0.5)],
        [CGFloat(0.25), CGFloat(0.5), CGFloat(0.0)],
        [CGFloat(0.25), CGFloat(0.25), CGFloat(0.25)],
        [CGFloat(0.0), CGFloat(1.0), CGFloat(1.0)]
    ]
    
    enum CPTPieDirection : Int {
        case clockwise     ///< Pie slices are drawn in a clockwise direction.
        case counterClockwise ///< Pie slices are drawn in a counter-clockwise direction.
    }
    
    enum CPTPieChartField : Int {
        case sliceWidth             //< Pie slice width.
        case sliceWidthNormalized   //< Pie slice width normalized [0, 1].
        case sliceWidthSum          //< Cumulative sum of pie slice widths.
    }
    
    var theDataSource : CPTPieChartDataSource?
    
    
    var pieRadius: CGFloat
    var pieInnerRadius : CGFloat
    var startAngle: CGFloat
    var endAngle: CGFloat
    var sliceDirection =  CPTPieDirection.clockwise
    var centerAnchor: CGPoint
    var pointingDeviceDownIndex :Int?
    
    
    // @name Drawing
    var borderLineStyle : CPTLineStyle?
    var overlayFill: CPTFill?
    
    /// @name Data Labels
    var labelRotationRelativeToRadius = false
    
    override init() {
        CPTPieChart.exposeBinding(.PieSliceWidthValues)
        CPTPieChart.exposeBinding(.PieSliceFills)
        CPTPieChart.exposeBinding(.PieSliceRadialOffsets)
    }
    
    // Initialization
    override init(frame newFrame: CGRect) {
        super.init(frame: newFrame)
        pieRadius = CGFloat(0.8) * (min(newFrame.size.width, newFrame.size.height) / CGFloat(2.0))
        pieInnerRadius = CGFloat(0.0)
        startAngle = CGFloat(Double.pi/2)
        endAngle = CGFloat.nan
        sliceDirection = CPTPieDirection.clockwise
        centerAnchor = CGPoint(x: 0.5, y: 0.5)
        borderLineStyle = nil
        overlayFill = nil
        labelRotationRelativeToRadius = false
        pointingDeviceDownIndex = nil
        
        labelOffset = CGFloat(10.0)
        labelField = CPTPieChartField.sliceWidth.rawValue
        
        theDataSource = dataSource as? CPTPieChartDataSource
        
    }
    
    override init(layer: Any) {
        
        super.init(layer: layer)
        let theLayer = layer as? CPTPieChart
        
        pieRadius = theLayer!.pieRadius
        pieInnerRadius = theLayer!.pieInnerRadius
        startAngle = theLayer!.startAngle
        endAngle = theLayer!.endAngle
        sliceDirection = theLayer!.sliceDirection
        centerAnchor = theLayer!.centerAnchor
        borderLineStyle = theLayer!.borderLineStyle
        overlayFill = theLayer!.overlayFill
        labelRotationRelativeToRadius = ((theLayer?.labelRotationRelativeToRadius) != nil)
        pointingDeviceDownIndex = NSNotFound
        
        theDataSource = dataSource as? CPTPieChartDataSource
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func reloadData()
    {
        super.reloadData()
        NotificationCenter.send(
            name: .CPTLegendNeedsReloadEntriesForPlotNotification,
            object:self)
    }
    
    override func reloadDataInIndexRange(indexRange: NSRange)
    {
        super.reloadDataInIndexRange(indexRange: indexRange)
        
        // Slice fills
        self.reloadSliceFillsInIndexRange(indexRange: indexRange)
        
        // Radial offsets
        self.reloadRadialOffsetsInIndexRange(indexRange:indexRange)
        
        // Legend
        if let theDataSource = theDataSource {
            if let _ = theDataSource.legendTitleForPieChart {
                
                NotificationCenter.send(
                    name: .CPTLegendNeedsRedrawForPlotNotification,
                    object:self)
            }
        }
    }
    
    override func reloadPlotDataInIndexRange(indexRange: NSRange)
    {
        super.reloadPlotDataInIndexRange(indexRange: indexRange)
        
        if self.loadNumbersForAllFieldsFromDataSourceInRecordIndexRange(indexRange: indexRange) == false {
            var theDataSource = dataSource as? CPTPieChartDataSource?
            
            // Pie slice widths
            if ( theDataSource != nil ) {
                // Grab all values from the data source
                let rawSliceValues = self.numbersFromDataSourceForField ( CPTPieChartField.sliceWidth,
                                                                          recordIndexRange:indexRange)
                
                self.cacheNumbers(rawSliceValues,
                                  forField: CPTPieChartField.sliceWidth.rawValue,
                                  atRecordIndex: indexRange.location)
            }
            else {
                self.cacheNumbers(numbers: nil, forField: CPTPieChartField.sliceWidth.rawValue)
            }
        }
        
        self.updateNormalizedData()
    }
    
    override func insertDataAtIndex(idx: Int, numberOfRecords: Int)
    {
        super.insertDataAtIndex(idx: idx, numberOfRecords:numberOfRecords)
        NotificationCenter.send(
            name:.CPTLegendNeedsReloadEntriesForPlotNotification,
            object:self)
    }
    
    override func deleteDataInIndexRange(indexRange: NSRange)
    {
        super.deleteDataInIndexRange(indexRange:indexRange)
        self.updateNormalizedData();
        
        NotificationCenter.send(
            name:.CPTLegendNeedsReloadEntriesForPlotNotification,
            object:self)
    }
    
    func updateNormalizedData()
    {
        // Normalize these widths to 1.0 for the whole pie
        //        let sampleCount = self.cachedDataCount;
        //
        //        if ( sampleCount > 0 ) {
        //            let rawSliceValues = self.cachedNumbersForField(CPTPieChartFieldSliceWidth)
        //            if ( self.doublePrecisionCache ) {
        //                var valueSum         = 0.0;
        //                let dataBytes = rawSliceValues.bytes;
        //                let dataEnd   = dataBytes + sampleCount;
        //
        //                while dataBytes < dataEnd {
        //                    let currentWidth = dataBytes += 1
        //                    if !currentWidth.isNaN {
        //                        valueSum += currentWidth
        //                    }
        //                }
        //                let dataType = CPTDataType(CGFloatingPointDataType, sizeof(double), CFByteOrderGetCurrent());
        //
        //                CPTMutableNumericData *normalizedSliceValues = [[CPTMutableNumericData alloc] initWithData:[NSData data] dataType:dataType shape:nil)
        //                    normalizedSliceValues.shape = @[@(sampleCount))
        //                    let cumulativeSliceValues = [[CPTMutableNumericData alloc] initWithData:[NSData data] dataType:dataType shape:nil)
        //                    cumulativeSliceValues.shape = @[@(sampleCount))
        //
        //                    let cumulativeSum = 0.0;
        //
        //                    dataBytes = (const double *)rawSliceValues.bytes;
        //                    double *normalizedBytes = normalizedSliceValues.mutableBytes;
        //                    double *cumulativeBytes = cumulativeSliceValues.mutableBytes;
        //
        //                    while dataBytes < dataEnd {
        //                    let currentWidth = dataBytes += 1
        //
        //                    if currentWidth.isNaN {
        //                    normalizedBytes += 1 = Double(.nan)
        //                    } else {
        //                    normalizedBytes += 1 = currentWidth / valueSum
        //                    cumulativeSum += currentWidth
        //                    }
        //                    cumulativeBytes += 1 = cumulativeSum / valueSum
        //                    }
        //
        //                    self.cacheNumbers(normalizedSliceValues forField:CPTPieChartFieldSliceWidthNormalized)
        //                    self.cacheNumbers(cumulativeSliceValues forField:CPTPieChartFieldSliceWidthSum)
        //                    } else {
        //                    var valueSum         = 0
        //                    let dataBytes = rawSliceValues.bytes;
        //                    let dataEnd   = dataBytes + sampleCount;
        //                    while ( dataBytes < dataEnd ) {
        //                    var currentWidth = dataBytes++;
        //                    if currentWidth.isNaN {
        //                    valueSum = valueSum + currentWidth
        //                    }
        //                    }
        //
        //                    let dataType = CPTDataType(CPTDecimalDataType, sizeof(NSDecimal), CFByteOrderGetCurrent());
        //                    let normalizedSliceValues = [[CPTMutableNumericData alloc] initWithData:[NSData data] dataType:dataType shape:nil)
        //
        //                    normalizedSliceValues.shape = @[@(sampleCount))
        //                    let cumulativeSliceValues = [[CPTMutableNumericData alloc] initWithData:[NSData data] dataType:dataType shape:nil)
        //                    cumulativeSliceValues.shape = @[@(sampleCount))
        //
        //                    let cumulativeSum = 0
        //                    NSDecimal decimalNAN = CPTDecimalNaN();
        //                    dataBytes = (const NSDecimal *)rawSliceValues.bytes;
        //                    NSDecimal *normalizedBytes = normalizedSliceValues.mutableBytes;
        //                    NSDecimal *cumulativeBytes = cumulativeSliceValues.mutableBytes;
        //                    while ( dataBytes < dataEnd ) {
        //                    let currentWidth = *dataBytes++;
        //                    if ( NSDecimalIsNotANumber(&currentWidth)) {
        //                    normalizedBytes++ = decimalNAN;
        //                    } else {
        //                    normalizedBytes++ = currentWidth / valueSum
        //                    cumulativeSum      = cumulativeSum + currentWidth);
        //                    }
        //                    cumulativeBytes++ = cumulativeSum / valueSum);
        //                    }
        //                    self cacheNumbers:normalizedSliceValues forField:CPTPieChartFieldSliceWidthNormalized)
        //                    self cacheNumbers:cumulativeSliceValues forField:CPTPieChartFieldSliceWidthSum)
        //                    }
        //                    } else {
        //                    self.cacheNumbers(nil, forField:CPTPieChartFieldSliceWidthNormalized)
        //                    self.cacheNumbers(nil, forField:CPTPieChartFieldSliceWidthSum)
        //                    }
        //
        //                    // Labels
        //                    var theDataSource = dataSource as? CPTPieChartDataSource?
        //
        //                    self relabelIndexRange:NSMakeRange(0, [theDataSource numberOfRecordsForPlot:self])
    }
    func reloadSliceFills()
    {
        self.reloadSliceFillsInIndexRange(indexRange: NSRange(location: 0, length: self.cachedDataCount))
    }
    
    //    /** @brief Reload slice fills in the given index range from the data source immediately.
    //     *  @param indexRange The index range to load.
    //     **/
    
    //     *  @brief Reload all slice offsets from the data source immediately.
    func reloadRadialOffsets()
    {
        self.reloadRadialOffsetsInIndexRange(indexRange: NSRange(location: 0, length: self.cachedDataCount))
    }
    
    //    /** @brief Reload slice offsets in the given index range from the data source immediately.
    //     *  @param indexRange The index range to load.
    //     **/
    func reloadRadialOffsetsInIndexRange(indexRange: NSRange)
    {
        var theDataSource = dataSource as? CPTPieChartDataSource
        
        if theDataSource.respondsToSelector(to: #selector(radialOffsetsForPieChart:recordIndexRange:) ) {
            
            self.cacheArray( theDataSource,
                             radialOffsetsForPieChart:self,
                             recordIndexRange:indexRange,
                             forKey          : NSBindingName.PieSliceRadialOffsets.rawValue,
                             atRecordIndex   :indexRange.location)
        }
        else if ( theDataSource.respondsToSelector( to: #selector(radialOffsetForPieChart:recordIndex:) ) {
            
            
            var array = [CGFloat]()
            let maxIndex    = NSMaxRange(indexRange);
            
            for idx in indexRange.location..<maxIndex {
                let offset = theDataSource?.radialOffsetForPieChart(self, idx:idx)
                array.append(offset!)
            }
            
            self.cacheArray(array: array,
                            forKey: NSBindingName.PieSliceRadialOffsets.rawValue,
                            atRecordIndex:indexRange.location)
        }
        self.setNeedsDisplay()
    }
    
    // MARK: Drawing
    override func renderAsVectorInContext(context: CGContext)
    {
        guard self.isHidden == false else { return }
        
        let sampleCount = self.cachedDataCount;
        
        if  sampleCount == 0 {
            return;
        }
        
        let thePlotArea = self.plotArea()
        if ( (thePlotArea == nil) ) {
            return
        }
        
        super.renderAsVectorInContext(context: context)
        
        context.beginTransparencyLayer(auxiliaryInfo: nil);
        
        let plotAreaBounds = thePlotArea?.bounds
        let anchor        = self.centerAnchor
        
        var centerPoint   = CGPoint(x: (plotAreaBounds?.origin.x)! + (plotAreaBounds?.size.width)! * anchor.x,
                                    y: (plotAreaBounds?.origin.y)! + (plotAreaBounds?.size.height)! * anchor.y);
        
        centerPoint = self.convert(centerPoint, from:thePlotArea)
        if self.alignsPointsToPixels == true {
            centerPoint = CPTAlignPointToUserSpace(context, centerPoint);
        }
        
        var currentIndex = 0;
        let startingWidth   = CGFloat(0.0);
        
        let borderStyle = self.borderLineStyle
        var overlay          = self.overlayFill
        
        var hasNonZeroOffsets      = false;
        var offsetArray = self.cachedArrayForKey(NSBindingName.PieSliceRadialOffsets.rawValue)
        
        for  offset in offsetArray {
            if offset  != CGFloat(0.0) {
                hasNonZeroOffsets = true;
                break;
            }
        }
        
        var bounds = CGRect()
        
        if ( (overlay != nil) && hasNonZeroOffsets ) {
            let radius = self.pieRadius + borderStyle!.lineWidth * CGFloat(0.5);
            
            bounds = CGRect(x: centerPoint.x - radius,
                            y: centerPoint.y - radius,
                            width: radius * CGFloat(2.0),
                            height: radius * CGFloat(2.0));
        }
        else {
            bounds = CGRect()
        }
        
        borderStyle?.setLineStyleInContext(context: context)
        let  fillClass = CPTFill()
        
        while ( currentIndex < sampleCount ) {
            let currentWidth = self.cachedDoubleForField( CPTPieChartField.sliceWidthNormalized , recordIndex:currentIndex)
            
            if ( !isnan(currentWidth)) {
                let radialOffset = offsetArray[currentIndex]
                
                // draw slice
                context.saveGState();
                
                let startingAngle  = self.radiansForPieSliceValue(startingWidth)
                let finishingAngle = self.radiansForPieSliceValue(startingWidth + currentWidth)
                
                let xOffset = CGFloat(0.0);
                let yOffset = CGFloat(0.0);
                var center  = centerPoint;
                if ( radialOffset != CGFloat(0.0)) {
                    let medianAngle = CGFloat(0.5) * (startingAngle + finishingAngle);
                    xOffset = cos(medianAngle) * radialOffset;
                    yOffset = sin(medianAngle) * radialOffset;
                    
                    center = CGPoint(x: centerPoint.x + xOffset, y: centerPoint.y + yOffset);
                    
                    if ( self.alignsPointsToPixels ) {
                        center = CPTAlignPointToUserSpace(context, center);
                    }
                }
                
                let slicePath = CGMutablePath();
                self.addSliceToPath(slicePath, centerPoint:center, startingAngle:startingAngle, finishingAngle:finishingAngle, width:currentWidth)
                
                let currentFill = self.sliceFill(for: currentIndex)
                
                if ( currentFill is fillClass ) {
                    context.beginPath();
                    context.addPath(slicePath);
                    currentFill.fillPathInContext(context)
                }
                
                // Draw the border line around the slice
                if (( borderStyle ) != nil) {
                    context.beginPath();
                    context.addPath(slicePath);
                    borderStyle?.strokePathInContext(context: context)
                }
                
                // draw overlay for exploded pie charts
                if ( (overlay != nil) && hasNonZeroOffsets == true) {
                    context.saveGState();
                    
                    context.addPath(slicePath);
                    context.clip();
                    overlay?.fillRect( rect: bounds.offsetBy(dx: xOffset, dy: yOffset), inContext:context)
                    
                    context.restoreGState();
                }
                
                context.restoreGState();
                
                startingWidth += currentWidth;
            }
            currentIndex += 1
        }
        
        context.endTransparencyLayer();
        
        // draw overlay all at once if not exploded
        if ( (overlay != nil) && !hasNonZeroOffsets ) {
            // no shadow for the overlay
            context.setShadow(offset: CGSize(), blur: CGFloat(0.0), color: nil);
            
            let fillPath = CGMutablePath();
            
            let innerRadius = self.pieInnerRadius;
            if ( innerRadius > CGFloat(0.0)) {
                CGPathAddArc(fillPath, nil, centerPoint.x, centerPoint.y, self.pieRadius, CGFloat(0.0), CGFloat(2.0 * M_PI), false);
                CGPathAddArc(fillPath, nil, centerPoint.x, centerPoint.y, innerRadius, CGFloat(2.0 * M_PI), CGFloat(0.0), true);
            }
            else {
                CGPathMoveToPoint(fillPath, nil, centerPoint.x, centerPoint.y);
                CGPathAddArc(fillPath, nil, centerPoint.x, centerPoint.y, self.pieRadius, CGFloat(0.0), CGFloat(2.0 * M_PI), false);
            }
            fillPath.closeSubpath();
            
            context.beginPath();
            context.addPath(fillPath);
            overlay?.fillPathInContext(context: context)
            
        }
    }
    
    func radiansforPieSliceValue( pieSliceValue: CGFloat) -> CGFloat {
        var angle = startAngle
        let endingAngle = endAngle
        var pieRange: CGFloat
        
        switch sliceDirection {
        case .clockwise:
            pieRange = CGFloat(endingAngle.isNaN ? CGFloat(2.0 * .pi) : CGFloat(2.0 * .pi) - abs(endingAngle - angle))
            angle -= pieSliceValue * pieRange
        case .counterClockwise:
            pieRange = CGFloat(endingAngle.isNaN ? CGFloat(2.0 * .pi) : abs(endingAngle - angle))
            angle += pieSliceValue * pieRange
        default:
            break
        }
        return endingAngle.isNaN ? angle : fmod(angle, CGFloat(2.0 * .pi))
    }
    
    func addSliceToPath(slicePath: CGMutablePath, center:CGPoint, startingAngle:CGFloat, finishingAngle:CGFloat, currentWidth:CGFloat)
    {
        let direction   = (self.sliceDirection == CPTPieDirection.clockwise) ? true : false;
        let outerRadius = self.pieRadius;
        let innerRadius = self.pieInnerRadius;
        
        if ( innerRadius > CGFloat(0.0)) {
            if ( currentWidth >= CGFloat(1.0)) {
                var angle = CGFloat((direction ? 2.0 : -2.0) * Double.pi)
                slicePath.addArc(center: center, radius: outerRadius, startAngle: startingAngle, endAngle: startingAngle + angle, clockwise: direction)
                angle = CGFloat((direction ? 2.0 : -2.0) * Double.pi)
                slicePath.addArc(center: center, radius: innerRadius, startAngle: startingAngle, endAngle: startingAngle + angle, clockwise: direction)
                //                CGPathAddRelativeArc(slicePath, nil, center.x, center.y, outerRadius, startingAngle, CGFloat((direction ? 2.0 : -2.0) * M_PI));
                //                CGPathAddRelativeArc(slicePath, nil, center.x, center.y, innerRadius, startingAngle, CGFloat((direction ? -2.0 : 2.0) * M_PI));
            }
            else {
                slicePath.addArc(center: center, radius: outerRadius, startAngle: startingAngle, endAngle: startingAngle, clockwise: direction)
                slicePath.addArc(center: center, radius: innerRadius, startAngle: finishingAngle, endAngle: startingAngle, clockwise: direction)
            }
        }
        else {
            if ( currentWidth >= CGFloat(1.0)) {
                
                let rect = CGRect(x: center.x - outerRadius, y: center.y - outerRadius, width: outerRadius * CGFloat(2.0), height: outerRadius * CGFloat(2.0))
                slicePath.addEllipse(in: rect)
            }
            else {
                slicePath.move(to: center)
                slicePath.addArc(center: center, radius: outerRadius, startAngle: startingAngle, endAngle: finishingAngle, clockwise: direction)
            }
        }
        slicePath.closeSubpath();
    }
    
    func sliceFillForIndex( idx: Int) -> CPTFill? {
        
        var currentFill = cachedValue(forKey: .CPTPieChartBindingPieSliceFills, record: idx)
        
        if (currentFill == nil) || (currentFill == CPTPlot.nilData()) {
            currentFill = CPTFill(color: CPTPieChart.defaultPieSliceColor(for: idx))
        }
        return currentFill
    }
    
    
    func drawSwatchForLegend(legend : CPTLegend, atIndex idx:Int, inRect rect: CGRect, inContext context: CGContext)
    {
        super.drawSwatchForLegend(legend: legend, atIndex:idx, inRect:rect, context:context)
        
        if ( self.drawLegendSwatchDecoration ) {
            let theFill           = self.sliceFillForIndex(idx: idx)
            let theLineStyle = self.borderLineStyle;
            
            if ( (theFill != nil) || (theLineStyle != nil) ) {
                let radius = legend.swatchCornerRadius
                
                if theFill != nil  {
                    context.beginPath();
                    CPTAddRoundedRectPath(context, CPTAlignIntegralRectToUserSpace(context, rect), radius);
                    theFill?.fillPathInContext(context: context)
                }
                
                if (( theLineStyle ) != nil) {
                    theLineStyle?.setLineStyleInContext(context: context)
                    context.beginPath();
                    CPTAddRoundedRectPath(context, CPTAlignBorderedRectToUserSpace(context, rect, theLineStyle), radius);
                    theLineStyle?.strokePathInContext(context: context)
                }
            }
        }
    }
    
    
    // MARK: Information
    //
    //    /** @brief Searches the pie slices for one corresponding to the given angle.
    //     *  @param angle An angle in radians.
    //     *  @return The index of the pie slice that matches the given angle. Returns @ref NSNotFound if no such pie slice exists.
    //     **/
    //    -(NSUInteger)pieSliceIndexAtAngle:(CGFloat)angle
    //    {
    //        // Convert the angle to its pie slice value
    //        CGFloat pieAngle      = [self normalizedPosition:angle)
    //        CGFloat startingAngle = [self normalizedPosition:self.startAngle)
    //
    //        // Iterate through the pie slices and compute their starting and ending angles.
    //        // If the angle we are searching for lies within those two angles, return the index
    //        // of that pie slice.
    //        for ( NSUInteger currentIndex = 0; currentIndex < self.cachedDataCount; currentIndex++ ) {
    //            CGFloat width = CGFloat([self cachedDoubleForField:CPTPieChartFieldSliceWidthNormalized recordIndex:currentIndex]);
    //            if ( isnan(width)) {
    //                continue;
    //            }
    //            CGFloat endingAngle = startingAngle;
    //
    //            if ( self.sliceDirection == CPTPieDirection.clockwise ) {
    //                endingAngle -= width;
    //            }
    //            else {
    //                endingAngle += width;
    //            }
    //
    //            if ( [self angle:pieAngle betweenStartAngle:startingAngle endAngle:endingAngle] ) {
    //                return currentIndex;
    //            }
    //
    //            startingAngle = endingAngle;
    //        }
    //
    //        // Searched every pie slice but couldn't find one that corresponds to the given angle.
    //        return NSNotFound;
    //    }
    //
    //    /** @brief Computes the halfway-point between the starting and ending angles of a given pie slice.
    //     *  @param idx A pie slice index.
    //     *  @return The angle that is halfway between the slice's starting and ending angles, or @NAN if
    //     *  an angle matching the given index cannot be found.
    //     **/
    //    -(CGFloat)medianAngleForPieSliceIndex idx: Int,
    //    {
    //        NSUInteger sampleCount = self.cachedDataCount;
    //
    //        NSParameterAssert(idx < sampleCount);
    //
    //        if ( sampleCount == 0 ) {
    //            return CPTNAN;
    //        }
    //
    //        CGFloat startingWidth = CGFloat(0.0);
    //
    //        // Iterate through the pie slices until the slice with the given index is found
    //        for ( NSUInteger currentIndex = 0; currentIndex < sampleCount; currentIndex++ ) {
    //            CGFloat currentWidth = CGFloat([self cachedDoubleForField:CPTPieChartFieldSliceWidthNormalized recordIndex:currentIndex]);
    //
    //            // If the slice index is a match...
    //            if ( !isnan(currentWidth) && (idx == currentIndex)) {
    //                // Compute and return the angle that is halfway between the slice's starting and ending angles
    //                CGFloat startingAngle  = [self radiansForPieSliceValue:startingWidth)
    //                CGFloat finishingAngle = [self radiansForPieSliceValue:startingWidth + currentWidth)
    //                return (startingAngle + finishingAngle) * CGFloat(0.5);
    //            }
    //
    //            startingWidth += currentWidth;
    //        }
    //
    //        // Searched every pie slice but couldn't find one that corresponds to the given index
    //        return CPTNAN;
    //    }
    //
    //    #pragma mark -
    // MARK: Animation
    func needsDisplayForKey(aKey:String )-> Bool
    {
        var keys        = Set<String>()
        
        keys.insert("pieRadius")
        keys.insert("pieInnerRadius")
        keys.insert("startAngle")
        keys.insert("endAngle")
        keys.insert("centerAnchor")
        
        if keys.contains(aKey ) {
            return true
        }
        else {
            return CPTLayer.needsDisplay(forKey: aKey)
        }
    }
    
    // MARK: - Fields
    
    //    -(NSUInteger)numberOfFields
    //    {
    //        return 1;
    //    }
    //
    //    -(nonnull CPTNumberArray *)fieldIdentifiers
    //    {
    //        return @[@(CPTPieChartFieldSliceWidth))
    //    }
    //
    //    /// @endcond
    //
    // MARK: -  Data Labels
    //
    //    /// @cond
    //
    //    func positionLabelAnnotation:(nonnull CPTPlotSpaceAnnotation *)label forIndex idx: Int,
    //    {
    //        CPTLayer *contentLayer   = label.contentLayer;
    //        CPTPlotArea *thePlotArea = self.plotArea;
    //
    //        if ( contentLayer && thePlotArea ) {
    //            CGRect plotAreaBounds = thePlotArea.bounds;
    //            CGPoint anchor        = self.centerAnchor;
    //            CGPoint centerPoint   = CPTPointMake(plotAreaBounds.origin.x + plotAreaBounds.size.width * anchor.x,
    //                                                 plotAreaBounds.origin.y + plotAreaBounds.size.height * anchor.y);
    //
    //            NSDecimal plotPoint[2)
    //            [self.plotSpace plotPoint:plotPoint numberOfCoordinates:2 forPlotAreaViewPoint:centerPoint)
    //            NSDecimalNumber *xValue = [[NSDecimalNumber alloc] initWithDecimal:plotPoint[CPTCoordinateX])
    //            NSDecimalNumber *yValue = [[NSDecimalNumber alloc] initWithDecimal:plotPoint[CPTCoordinateY])
    //            label.anchorPlotPoint = @[xValue, yValue)
    //
    //            CGFloat currentWidth = (CGFloat)[self cachedDoubleForField:CPTPieChartFieldSliceWidthNormalized recordIndex:idx)
    //            if ( self.hidden || isnan(currentWidth)) {
    //                contentLayer.hidden = true
    //            }
    //            else {
    //                CGFloat radialOffset = [(NSNumber *)[self cachedValueForKey:CPTPieChartBindingPieSliceRadialOffsets recordIndex:idx] cgFloatValue)
    //                CGFloat labelRadius  = self.pieRadius + self.labelOffset + radialOffset;
    //
    //                CGFloat startingWidth = CGFloat(0.0);
    //                if ( idx > 0 ) {
    //                    startingWidth = (CGFloat)[self cachedDoubleForField:CPTPieChartFieldSliceWidthSum recordIndex:idx - 1)
    //                }
    //                CGFloat labelAngle = [self radiansForPieSliceValue:startingWidth + currentWidth / CGFloat(2.0))
    //
    //                label.displacement = CPTPointMake(labelRadius * cos(labelAngle), labelRadius * sin(labelAngle));
    //
    //                if ( self.labelRotationRelativeToRadius ) {
    //                    CGFloat rotation = [self normalizedPosition:self.labelRotation + labelAngle)
    //                    if ((rotation > CGFloat(0.25)) && (rotation < CGFloat(0.75))) {
    //                        rotation -= CGFloat(0.5);
    //                    }
    //
    //                    label.rotation = rotation * CGFloat(2.0 * M_PI);
    //                }
    //
    //                contentLayer.hidden = false
    //            }
    //        }
    //        else {
    //            label.anchorPlotPoint = nil;
    //            label.displacement    = CGPointZero;
    //        }
    //    }
    //
    //    /// @endcond
    //
    // MARK: - Legends
    
    //    /** @internal
    //     *  @brief The number of legend entries provided by this plot.
    //     *  @return The number of legend entries.
    //     **/
    //    -(NSUInteger)numberOfLegendEntries
    //    {
    //        [self reloadDataIfNeeded)
    //        return self.cachedDataCount;
    //    }
    //
    //    /** @internal
    //     *  @brief The title text of a legend entry.
    //     *  @param idx The index of the desired title.
    //     *  @return The title of the legend entry at the requested index.
    //     **/
    //    -(nullable NSString *)titleForLegendEntryAtIndex idx: Int,
    //    {
    //        NSString *legendTitle = nil;
    //
    //    var theDataSource = dataSource as? CPTPieChartDataSource?
    //
    //        if ( [theDataSource respondsToSelector:@selector(legendTitleForPieChart:recordIndex:)] ) {
    //            legendTitle = [theDataSource legendTitleForPieChart:self recordIndex:idx)
    //        }
    //        else {
    //            legendTitle = [super titleForLegendEntryAtIndex:idx)
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
    //    -(nullable NSAttributedString *)attributedTitleForLegendEntryAtIndex idx: Int,
    //    {
    //        NSAttributedString *legendTitle = nil;
    //
    //        id<CPTPieChartDataSource> theDataSource = (id<CPTPieChartDataSource>)self.dataSource;
    //
    //        if ( [theDataSource respondsToSelector:@selector(attributedLegendTitleForPieChart:recordIndex:)] ) {
    //            legendTitle = [theDataSource attributedLegendTitleForPieChart:self recordIndex:idx)
    //        }
    //        else {
    //            legendTitle = [super attributedTitleForLegendEntryAtIndex:idx)
    //        }
    //
    //        return legendTitle;
    //    }
    //
    //    /// @endcond
    
    // MARK: - Responder Chain and User interaction
    //    -(CGFloat)normalizedPosition:(CGFloat)rawPosition
    //    {
    //        CGFloat result = rawPosition;
    //
    //        result /= (CGFloat)(2.0 * M_PI);
    //        result  = fmod(result, CGFloat(1.0));
    //        if ( result < CGFloat(0.0)) {
    //            result += CGFloat(1.0);
    //        }
    //
    //        return result;
    //    }
    //
    //    -(BOOL)angle:(CGFloat)touchedAngle betweenStartAngle:(CGFloat)startingAngle endAngle:(CGFloat)endingAngle
    //    {
    //        switch ( self.sliceDirection ) {
    //            case CPTPieDirectionClockwise:
    //                if ((touchedAngle <= startingAngle) && (touchedAngle >= endingAngle)) {
    //                    return true
    //                }
    //                else if ((endingAngle < CGFloat(0.0)) && (touchedAngle - CGFloat(1.0) >= endingAngle)) {
    //                    return true
    //                }
    //                break;
    //
    //            case CPTPieDirectionCounterClockwise:
    //                if ((touchedAngle >= startingAngle) && (touchedAngle <= endingAngle)) {
    //                    return true
    //                }
    //                else if ((endingAngle > CGFloat(1.0)) && (touchedAngle + CGFloat(1.0) <= endingAngle)) {
    //                    return true
    //                }
    //                break;
    //        }
    //        return false
    //    }
    
    
    override func pointingDeviceDownEvent(event: CPTNativeEvent, atPoint interactionPoint:CGPoint )-> Bool
    {
        let theGraph       = self.graph
        let thePlotArea = self.plotArea
        
        guard self.isHidden == false else { return false }
        guard theGraph != nil else { return false }

        if !thePlotArea {
            return false
        }
        
       var theDelegate = self.delegate as? CPTPieChartDelegate
        
        if ( [theDelegate respondsToSelector:@selector(pieChart:sliceTouchDownAtRecordIndex:)] ||
             [theDelegate respondsToSelector:@selector(pieChart:sliceTouchDownAtRecordIndex:withEvent:)] ||
             [theDelegate respondsToSelector:@selector(pieChart:sliceWasSelectedAtRecordIndex:)] ||
             [theDelegate respondsToSelector:@selector(pieChart:sliceWasSelectedAtRecordIndex:withEvent:)] ) {
            
            let plotAreaPoint = theGraph?.convert(interactionPoint, to:thePlotArea())
            
            let idx = self.dataIndexFromInteractionPoint( point: plotAreaPoint!)
            self.pointingDeviceDownIndex = idx
            
            if ( idx != NSNotFound ) {
                var handled = false
                
                if  ((theDelegate?.pieChart(plot: self, sliceTouchDownAtRecordIndex:idx)) != nil)  {
                    handled = true
                    theDelegate?.pieChart(plot: self, sliceTouchDownAtRecordIndex:idx)
                }
                
                if ((theDelegate?.pieChart(plot: self, sliceTouchDownAtRecordIndex: idx, withEvent: event)) != nil)  {
                    handled = true
                    theDelegate?.pieChart(plot: self, sliceTouchDownAtRecordIndex:idx, withEvent:event)
                }
                
                if handled == true {
                    return true
                }
            }
        }
        return super.pointingDeviceDownEvent(event: event, atPoint: interactionPoint)
    }
                
                
    //
    //    /**
    //     *  @brief Informs the receiver that the user has
    //     *  @if MacOnly released the mouse button. @endif
    //     *  @if iOSOnly ended touching the screen. @endif
    //     *
    //     *
    //     *  If this plot has a delegate that responds to the
    //     *  @link CPTPieChartDelegate::pieChart:sliceTouchUpAtRecordIndex: -pieChart:sliceTouchUpAtRecordIndex: @endlink and/or
    //     *  @link CPTPieChartDelegate::pieChart:sliceTouchUpAtRecordIndex:withEvent: -pieChart:sliceTouchUpAtRecordIndex:withEvent: @endlink
    //     *  methods, the @par{interactionPoint} is compared with each slice in index order.
    //     *  The delegate method will be called and this method returns @YES for the first
    //     *  index where the @par{interactionPoint} is inside a pie slice.
    //     *  This method returns @NO if the @par{interactionPoint} is outside all of the slices.
    //     *
    //     *  If the pie slice being released is the same as the one that was pressed (see
    //     *  @link CPTPieChart::pointingDeviceDownEvent:atPoint: -pointingDeviceDownEvent:atPoint: @endlink), if the delegate responds to the
    //     *  @link CPTPieChartDelegate::pieChart:sliceWasSelectedAtRecordIndex: -pieChart:sliceWasSelectedAtRecordIndex: @endlink and/or
    //     *  @link CPTPieChartDelegate::pieChart:sliceWasSelectedAtRecordIndex:withEvent: -pieChart:sliceWasSelectedAtRecordIndex:withEvent: @endlink
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
    //        id<CPTPieChartDelegate> theDelegate = (id<CPTPieChartDelegate>)self.delegate;
    //
    //        if ( [theDelegate respondsToSelector:@selector(pieChart:sliceTouchUpAtRecordIndex:)] ||
    //             [theDelegate respondsToSelector:@selector(pieChart:sliceTouchUpAtRecordIndex:withEvent:)] ||
    //             [theDelegate respondsToSelector:@selector(pieChart:sliceWasSelectedAtRecordIndex:)] ||
    //             [theDelegate respondsToSelector:@selector(pieChart:sliceWasSelectedAtRecordIndex:withEvent:)] ) {
    //            CGPoint plotAreaPoint = [theGraph convertPoint:interactionPoint toLayer:thePlotArea)
    //
    //            NSUInteger idx = [self dataIndexFromInteractionPoint:plotAreaPoint)
    //            if ( idx != NSNotFound ) {
    //                BOOL handled = false
    //
    //                if ( [theDelegate respondsToSelector:@selector(pieChart:sliceTouchUpAtRecordIndex:)] ) {
    //                    handled = true
    //                    [theDelegate pieChart:self sliceTouchUpAtRecordIndex:idx)
    //                }
    //                if ( [theDelegate respondsToSelector:@selector(pieChart:sliceTouchUpAtRecordIndex:withEvent:)] ) {
    //                    handled = true
    //                    [theDelegate pieChart:self sliceTouchUpAtRecordIndex:idx withEvent:event)
    //                }
    //
    //                if ( idx == selectedDownIndex ) {
    //                    if ( [theDelegate respondsToSelector:@selector(pieChart:sliceWasSelectedAtRecordIndex:)] ) {
    //                        handled = true
    //                        [theDelegate pieChart:self sliceWasSelectedAtRecordIndex:idx)
    //                    }
    //
    //                    if ( [theDelegate respondsToSelector:@selector(pieChart:sliceWasSelectedAtRecordIndex:withEvent:)] ) {
    //                        handled = true
    //                        [theDelegate pieChart:self sliceWasSelectedAtRecordIndex:idx withEvent:event)
    //                    }
    //                }
    //
    //                if ( handled ) {
    //                    return true
    //                }
    //            }
    //        }
    //
    //        return [super pointingDeviceUpEvent:event atPoint:interactionPoint)
    //    }
    //
    //    /// @}
    //
    //    /// @cond
    //
    //    -(NSUInteger)dataIndexFromInteractionPoint:(CGPoint)point
    //    {
    //        CPTGraph *theGraph       = self.graph;
    //        CPTPlotArea *thePlotArea = self.plotArea;
    //
    //        // Inform delegate if a slice was hit
    //        if ( !theGraph || !thePlotArea ) {
    //            return NSNotFound;
    //        }
    //
    //        NSUInteger sampleCount = self.cachedDataCount;
    //
    //        if ( sampleCount == 0 ) {
    //            return NSNotFound;
    //        }
    //
    //        CGRect plotAreaBounds = thePlotArea.bounds;
    //        CGPoint anchor        = self.centerAnchor;
    //        CGPoint centerPoint   = CPTPointMake(plotAreaBounds.origin.x + plotAreaBounds.size.width * anchor.x,
    //                                             plotAreaBounds.origin.y + plotAreaBounds.size.height * anchor.y);
    //
    //        centerPoint = [self convertPoint:centerPoint fromLayer:thePlotArea)
    //
    //        CGFloat chartRadius             = self.pieRadius;
    //        CGFloat chartRadiusSquared      = chartRadius * chartRadius;
    //        CGFloat chartInnerRadius        = self.pieInnerRadius;
    //        CGFloat chartInnerRadiusSquared = chartInnerRadius * chartInnerRadius;
    //        CGFloat dx                      = point.x - centerPoint.x;
    //        CGFloat dy                      = point.y - centerPoint.y;
    //        CGFloat distanceSquared         = dx * dx + dy * dy;
    //
    //        CGFloat theStartAngle = self.startAngle;
    //        CGFloat theEndAngle   = self.endAngle;
    //        CGFloat widthFactor;
    //
    //        CGFloat touchedAngle  = [self normalizedPosition:atan2(dy, dx))
    //        CGFloat startingAngle = [self normalizedPosition:theStartAngle)
    //
    //        switch ( self.sliceDirection ) {
    //            case CPTPieDirectionClockwise:
    //                if ( isnan(theEndAngle) || (CGFloat(2.0 * M_PI) == ABS(theEndAngle - theStartAngle))) {
    //                    widthFactor = CGFloat(1.0);
    //                }
    //                else {
    //                    widthFactor = CGFloat(2.0 * M_PI) / (CGFloat(2.0 * M_PI) - ABS(theEndAngle - theStartAngle));
    //                }
    //
    //                for ( NSUInteger currentIndex = 0; currentIndex < sampleCount; currentIndex++ ) {
    //                    // calculate angles for this slice
    //                    CGFloat width = (CGFloat)[self cachedDoubleForField:CPTPieChartFieldSliceWidthNormalized recordIndex:currentIndex)
    //                    if ( isnan(width)) {
    //                        continue;
    //                    }
    //
    //                    width /= widthFactor;
    //
    //                    CGFloat endingAngle = startingAngle - width;
    //
    //                    // offset the center point of the slice if needed
    //                    CGFloat offsetTouchedAngle    = touchedAngle;
    //                    CGFloat offsetDistanceSquared = distanceSquared;
    //                    CGFloat radialOffset          = [(NSNumber *)[self cachedValueForKey:CPTPieChartBindingPieSliceRadialOffsets recordIndex:currentIndex] cgFloatValue)
    //                    if ( radialOffset != CGFloat(0.0)) {
    //                        CGPoint offsetCenter;
    //                        CGFloat medianAngle = CGFloat(M_PI) * (startingAngle + endingAngle);
    //                        offsetCenter = CPTPointMake(centerPoint.x + cos(medianAngle) * radialOffset,
    //                                                    centerPoint.y + sin(medianAngle) * radialOffset);
    //
    //                        dx = point.x - offsetCenter.x;
    //                        dy = point.y - offsetCenter.y;
    //
    //                        offsetTouchedAngle    = [self normalizedPosition:atan2(dy, dx))
    //                        offsetDistanceSquared = dx * dx + dy * dy;
    //                    }
    //
    //                    // check angles
    //                    BOOL angleInSlice = false
    //                    if ( [self angle:touchedAngle betweenStartAngle:startingAngle endAngle:endingAngle] ) {
    //                        if ( [self angle:offsetTouchedAngle betweenStartAngle:startingAngle endAngle:endingAngle] ) {
    //                            angleInSlice = true
    //                        }
    //                        else {
    //                            return NSNotFound;
    //                        }
    //                    }
    //
    //                    // check distance
    //                    if ( angleInSlice && (offsetDistanceSquared >= chartInnerRadiusSquared) && (offsetDistanceSquared <= chartRadiusSquared)) {
    //                        return currentIndex;
    //                    }
    //
    //                    // save angle for the next slice
    //                    startingAngle = endingAngle;
    //                }
    //                break;
    //
    //            case CPTPieDirectionCounterClockwise:
    //                if ( isnan(theEndAngle) || (theStartAngle == theEndAngle)) {
    //                    widthFactor = CGFloat(1.0);
    //                }
    //                else {
    //                    widthFactor = (CGFloat)(2.0 * M_PI) / ABS(theEndAngle - theStartAngle);
    //                }
    //
    //                for ( NSUInteger currentIndex = 0; currentIndex < sampleCount; currentIndex++ ) {
    //                    // calculate angles for this slice
    //                    CGFloat width = (CGFloat)[self cachedDoubleForField:CPTPieChartFieldSliceWidthNormalized recordIndex:currentIndex)
    //                    if ( isnan(width)) {
    //                        continue;
    //                    }
    //                    width /= widthFactor;
    //
    //                    CGFloat endingAngle = startingAngle + width;
    //
    //                    // offset the center point of the slice if needed
    //                    CGFloat offsetTouchedAngle    = touchedAngle;
    //                    CGFloat offsetDistanceSquared = distanceSquared;
    //                    CGFloat radialOffset          = [(NSNumber *)[self cachedValueForKey:CPTPieChartBindingPieSliceRadialOffsets recordIndex:currentIndex] cgFloatValue)
    //                    if ( radialOffset != CGFloat(0.0)) {
    //                        CGPoint offsetCenter;
    //                        CGFloat medianAngle = CGFloat(M_PI) * (startingAngle + endingAngle);
    //                        offsetCenter = CPTPointMake(centerPoint.x + cos(medianAngle) * radialOffset,
    //                                                    centerPoint.y + sin(medianAngle) * radialOffset);
    //
    //                        dx = point.x - offsetCenter.x;
    //                        dy = point.y - offsetCenter.y;
    //
    //                        offsetTouchedAngle    = [self normalizedPosition:atan2(dy, dx))
    //                        offsetDistanceSquared = dx * dx + dy * dy;
    //                    }
    //
    //                    // check angles
    //                    BOOL angleInSlice = false
    //                    if ( [self angle:touchedAngle betweenStartAngle:startingAngle endAngle:endingAngle] ) {
    //                        if ( [self angle:offsetTouchedAngle betweenStartAngle:startingAngle endAngle:endingAngle] ) {
    //                            angleInSlice = true
    //                        }
    //                        else {
    //                            return NSNotFound;
    //                        }
    //                    }
    //
    //                    // check distance
    //                    if ( angleInSlice && (offsetDistanceSquared >= chartInnerRadiusSquared) && (offsetDistanceSquared <= chartRadiusSquared)) {
    //                        return currentIndex;
    //                    }
    //
    //                    // save angle for the next slice
    //                    startingAngle = endingAngle;
    //                }
    //                break;
    //        }
    //
    //        return NSNotFound;
    //    }
    
    
    //  MARK: - Accessors
    func sliceWidths() -> [CGFloat]
    {
        return self.cachedNumbers( forField: CPTPieChartField.sliceWidth )
    }
    
    func setSliceWidths(newSliceWidths:  [CGFloat] )
    {
        self.cacheNumbers(numbers: newSliceWidths, forField: CPTPieChartField.sliceWidth)
        self.updateNormalizedData()
    }
    
    func sliceFills() -> [CPTFill]
    {
        return self.cachedArray(forKey: NSBindingName.PieSliceFills.rawValue)
    }
    
    func setSliceFills(newSliceFills: [CPTFill] )
    {
        self.cacheArray( newSliceFills,forKey: NSBindingName.PieSliceFills.rawValue)
        self.setNeedsDisplay()
    }
    
    func sliceRadialOffsets() -> [CGFloat]
    {
        return self.cachedArray( forKey: NSBindingName.PieSliceRadialOffsets.rawValue)
    }
    
    func setSliceRadialOffsets(newSliceRadialOffsets: [CGFloat])
    {
        self.cacheArray(newSliceRadialOffsets, forKey: NSBindingName.PieSliceRadialOffsets.rawValue)
        self.setNeedsDisplay()
        self.setNeedsLayout()
    }
    
    func setPieRadius(newPieRadius: CGFloat)
    {
        if ( pieRadius != newPieRadius ) {
            pieRadius = abs(newPieRadius);
            self.setNeedsDisplay()
            self.repositionAllLabelAnnotations()
        }
    }
    
    func setPieInnerRadius(newPieRadius: CGFloat)
    {
        if ( pieInnerRadius != newPieRadius ) {
            pieInnerRadius = abs(newPieRadius);
            self.setNeedsDisplay()
        }
    }
    
    func setStartAngle(newAngle: CGFloat)
    {
        if ( newAngle != startAngle ) {
            startAngle = newAngle;
            self.setNeedsDisplay()
            self.repositionAllLabelAnnotations()
        }
    }
    
    func setEndAngle( newAngle: CGFloat)
    {
        if ( newAngle != endAngle ) {
            endAngle = newAngle;
            self.setNeedsDisplay()
            self.repositionAllLabelAnnotations()
        }
    }
    
    func sliceDirection(newDirection: CPTPieDirection)
    {
        if ( newDirection != sliceDirection ) {
            sliceDirection = newDirection;
            self.setNeedsDisplay()
            self.repositionAllLabelAnnotations();
        }
    }
    //
    func setBorderLineStyle(newStyle: CPTLineStyle )
    {
        if ( borderLineStyle != newStyle ) {
            borderLineStyle = newStyle
            self.setNeedsDisplay()
            NotificationCenter.send(
                name:.CPTLegendNeedsRedrawForPlotNotification,
                object:self)
        }
    }
    
    func setCenterAnchor(newCenterAnchor: CGPoint)
    {
        if  newCenterAnchor == centerAnchor {
            centerAnchor = newCenterAnchor;
            self.setNeedsDisplay()
            self.repositionAllLabelAnnotations()
        }
    }
    
    func setLabelRotationRelativeToRadius(newLabelRotationRelativeToRadius: Bool)
    {
        if ( labelRotationRelativeToRadius != newLabelRotationRelativeToRadius ) {
            labelRotationRelativeToRadius = newLabelRotationRelativeToRadius;
            self.repositionAllLabelAnnotations()
        }
    }
    
    func setLabelRotation(newRotation: CGFloat)
    {
        if ( newRotation != self.labelRotation ) {
            super.labelRotation = newRotation;
            if ( self.labelRotationRelativeToRadius ) {
                self.repositionAllLabelAnnotations()
            }
        }
    }
    
    
}
