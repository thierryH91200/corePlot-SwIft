//
//  CPTGraph.swift
//  corePlot
//
//  Created by thierryH24 on 09/11/2020.
//

import AppKit


protocol CPTAxisDelegate : CPTLayerDelegate {
    
    func axisShouldRelabel(axis: CPTAxis ) -> Bool
    func axisDidRelabel(axis: CPTAxis )
    
    func axis(axis:  CPTAxis, shouldUpdateAxisLabelsAtLocations locations: CPTNumberSet ) -> Bool
    func axis(axis:  CPTAxis, shouldUpdateMinorAxisLabelsAtLocations locations: CPTNumberSet ) -> Bool
    
    func axis(axis:  CPTAxis, labelWasSelected label: CPTAxisLabel )
    func axis(axis:  CPTAxis, labelWasSelected label: CPTAxisLabel, withEvent event: CPTNativeEvent )
    
    func axis(axis:  CPTAxis, minorTickLabelWasSelected label: CPTAxisLabel )
    func axis(axis:  CPTAxis, minorTickLabelWasSelected label: CPTAxisLabel, withEvent event: CPTNativeEvent )
    
    func axis(axis:  CPTAxis, labelTouchDown label: CPTAxisLabel )
    func axis(axis:  CPTAxis, labelTouchDown label: CPTAxisLabel, withEvent event: CPTNativeEvent )
    
    func axis(axis:  CPTAxis, labelTouchUp label: CPTAxisLabel );
    func axis(axis:  CPTAxis, labelTouchUp label: CPTAxisLabel, withEvent event: CPTNativeEvent)
    
    func axis(axis:  CPTAxis, minorTickTouchDown label: CPTAxisLabel)
    func axis(axis:  CPTAxis, minorTickTouchDown label: CPTAxisLabel, withEvent event: CPTNativeEvent )
    
    func axis(axis:  CPTAxis, minorTickTouchUp label: CPTAxisLabel );
    func axis(axis:  CPTAxis, minorTickTouchUp label: CPTAxisLabel, withEvent event: CPTNativeEvent )
    
}

public class CPTAxis : CPTLayer {
    
    enum CPTAxisLabelingPolicy: Int  {
        case none              ///< No labels provided; user sets labels and tick locations.
        case provided ///< User sets tick locations; axis makes labels.
        case fixedInterval    ///< Fixed interval labeling policy.
        case automatic        ///< Automatic labeling policy.
        case divisions     ///< Divide the plot range into equal parts.
    }
    typealias CPTAxisLabelSet = Set<CPTAxisLabel>
    
    var _axisTitle: CPTAxisTitle?
    var axisTitle : CPTAxisTitle? {
        get {
            if (_axisTitle == nil) {
                var newTitle: CPTAxisTitle? = nil
                
                let textLayer = CPTTextLayer(attributedText: attributedTitle)
                newTitle = CPTAxisTitle(layer: textLayer)
                if title != "" {
                    newTitle = CPTAxisTitle( newText: self.title, newStyle: self.titleTextStyle)
                }
                
                if let newTitle = newTitle {
                    newTitle.rotation = titleRotation!
                    _axisTitle = newTitle
                }
            }
            return _axisTitle
        }
        set {
            if newValue != _axisTitle {
                _axisTitle?.contentLayer.removeFromSuperlayer()
                _axisTitle = newValue
                
                let thePlotArea = plotArea
                thePlotArea?.updateAxisSetLayersForType(layerType: CPTGraphLayerType.axisTitles)
                
                if (_axisTitle != nil) {
                    _axisTitle?.offset = titleOffset
                    let contentLayer = _axisTitle?.contentLayer
                    if let contentLayer = contentLayer {
                        let idx = thePlotArea?.sublayerIndexForAxis(axis: self, layerType: CPTGraphLayerType.axisTitles)
                        thePlotArea?.axisTitleGroup?.insertSublayer(contentLayer, at: UInt32(idx!))
                        updateAxisTitle()
                    }
                }
            }
        }
    }
    
    // MARK: Title
    var titleTextStyle = CPTTextStyle()
//    var titleOffset =  CGFloat(0)
    var title = "title"
    var attributedTitle =  NSAttributedString(string: "")
    var titleRotation :  CGFloat?
    var titleDirection : CPTSign = .none
    var titleLocation = 0
    var defaultTitleLocation = 0
    
    // MARK: -
    var axisLineStyle : CPTLineStyle?
    
    // MARK: Axis.m
    var needsRelabel = false
    var pointingDeviceDownLabel: CPTAxisLabel?
    var pointingDeviceDownTickLabel:CPTAxisLabel?
    var labelFormatterChanged = false
    var minorLabelFormatterChanged = false
    //    var  mutableBackgroundLimitBands: CPTMutableLimitBandArray
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
        var minorTickAxisLabels : CPTAxisLabelSet
    //    var needsRelabel = false
    //    var labelExclusionRanges = [CPTPlotRange]()
    //    var labelShadow: CPTShadow
    //    var minorTickLabelShadow: CPTShadow
    
    // MARK:  Major Ticks
    var majorIntervalLength = CGFloat(0)
    var majorTickLength = CGFloat(0)
    var majorTickLineStyle: CPTLineStyle
    var majorTickLocations: CPTNumberSet
    var preferredNumberOfMajorTicks = 0
    
    // MARK:  Minor Ticks
    var minorTicksPerInterval = CGFloat(0.0)
    var minorTickLength = CGFloat(0.0)
    var minorTickLineStyle: CPTLineStyle
    var minorTickLocations: CPTNumberSet
    
    // MARK:  Grid Lines
    var  majorGridLineStyle: CPTLineStyle?
    var  minorGridLineStyle: CPTLineStyle?
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
//    var minorTickAxisLabels : Set<Double>
    
    var labelExclusionRanges = [CPTPlot]()
    var labelShadow: CPTShadow?
    var minorTickLabelShadow: CPTShadow?
    
    var mutableBackgroundLimitBands = [CPTLimitBand]()
    
    override init( frame : CGRect  )
    {
        super.init(frame: frame)
        plotSpace                   = nil;
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
        
        let newFormatter = NumberFormatter()
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
//        axisTitle                  = CPTAxisTitle()
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
    
    override init(layer :  Any )
    {
        super.init(layer: layer)
        
        let theLayer = CPTAxis( layer: layer)
        
        plotSpace                   = theLayer.plotSpace;
        majorTickLocations          = theLayer.majorTickLocations;
        minorTickLocations          = theLayer.minorTickLocations;
        preferredNumberOfMajorTicks = theLayer.preferredNumberOfMajorTicks;
        minorTickLength             = theLayer.minorTickLength;
        majorTickLength             = theLayer.majorTickLength;
        labelOffset                 = theLayer.labelOffset;
        minorTickLabelOffset        = theLayer.labelOffset;
        labelRotation               = theLayer.labelRotation;
        minorTickLabelRotation      = theLayer.labelRotation;
        labelAlignment              = theLayer.labelAlignment;
        minorTickLabelAlignment     = theLayer.labelAlignment;
        title                       = theLayer.title;
        attributedTitle             = theLayer.attributedTitle;
        titleOffset                 = theLayer.titleOffset;
        axisLineStyle               = theLayer.axisLineStyle;
        majorTickLineStyle          = theLayer.majorTickLineStyle;
        minorTickLineStyle          = theLayer.minorTickLineStyle;
        tickLabelDirection          = theLayer.tickLabelDirection;
        minorTickLabelDirection     = theLayer.minorTickLabelDirection;
        majorGridLineStyle          = theLayer.majorGridLineStyle;
        minorGridLineStyle          = theLayer.minorGridLineStyle;
        axisLineCapMin              = theLayer.axisLineCapMin;
        axisLineCapMax              = theLayer.axisLineCapMax;
        labelingOrigin              = theLayer.labelingOrigin;
        majorIntervalLength         = theLayer.majorIntervalLength;
        minorTicksPerInterval       = theLayer.minorTicksPerInterval;
        coordinate                  = theLayer.coordinate;
        labelingPolicy              = theLayer.labelingPolicy;
        labelFormatter              = theLayer.labelFormatter;
        minorTickLabelFormatter     = theLayer.minorTickLabelFormatter;
        axisLabels                  = theLayer.axisLabels;
        minorTickAxisLabels         = theLayer.minorTickAxisLabels;
        tickDirection               = theLayer.tickDirection;
        labelTextStyle              = theLayer.labelTextStyle;
        minorTickLabelTextStyle     = theLayer.minorTickLabelTextStyle;
        axisTitle                   = theLayer.axisTitle;
        titleTextStyle              = theLayer.titleTextStyle;
        titleRotation               = theLayer.titleRotation;
        titleDirection              = theLayer.titleDirection;
        titleLocation               = theLayer.titleLocation;
        needsRelabel                = theLayer.needsRelabel;
        labelExclusionRanges        = theLayer.labelExclusionRanges;
        plotArea                    = theLayer.plotArea;
        separateLayers              = theLayer.separateLayers;
        labelShadow                 = theLayer.labelShadow;
        minorTickLabelShadow        = theLayer.minorTickLabelShadow;
        visibleRange                = theLayer.visibleRange;
        visibleAxisRange            = theLayer.visibleAxisRange;
        gridLinesRange              = theLayer.gridLinesRange;
        alternatingBandFills        = theLayer.alternatingBandFills;
        alternatingBandAnchor       = theLayer.alternatingBandAnchor;
        mutableBackgroundLimitBands = theLayer.mutableBackgroundLimitBands;
        minorGridLines              = theLayer.minorGridLines;
        majorGridLines              = theLayer.majorGridLines;
        pointingDeviceDownLabel     = theLayer.pointingDeviceDownLabel;
        pointingDeviceDownTickLabel = theLayer.pointingDeviceDownTickLabel;
        inTitleUpdate               = theLayer.inTitleUpdate;
        labelsUpdated               = theLayer.labelsUpdated;
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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

    // MARK: - Ticks
    func generateFixedInterval(newMajorLocations: inout Set<CGFloat>, newMinorLocations: inout Set<CGFloat>)
    {
        var majorLocations = Set<CGFloat>()
        var minorLocations = Set<CGFloat>()
        
        let zero          = CGFloat(0.0)
        var majorInterval = self.majorIntervalLength
        
        if majorInterval > zero {
            let range = self.plotSpace?.plotRangeForCoordinate(coordinate: self.coordinate) as! CPTMutablePlotRange
            
            
//            if (( range ) != nil) {
                let theVisibleRange = self.visibleRange
                if (theVisibleRange != nil)  {
                    range.intersectionPlotRange(other: theVisibleRange)
                }
                
                let rangeMin = CGFloat(range.minLimitDecimal)
                let rangeMax = CGFloat(range.maxLimitDecimal)
                
                var minorInterval = CGFloat(0.0)
                let minorTickCount = self.minorTicksPerInterval;
                if ( minorTickCount > 0 ) {
                    minorInterval = majorInterval / (minorTickCount + 1)
                }
                else {
                    minorInterval = zero;
                }
                
                // Set starting coord--should be the smallest value >= rangeMin that is a whole multiple of majorInterval away from the labelingOrigin
                let origin = CGFloat(truncating: self.labelingOrigin)
                var  coord  = ( rangeMin - origin) / majorInterval
                NSDecimalRound(&coord, &coord, 0, NSRoundUp);
                coord = (coord * majorInterval) + origin
                
                // Set minor ticks between the starting point and rangeMin
                if ( minorTickCount > 0 ) {
                    var minorCoord = coord - minorInterval
                    
                    for  minorTickIndex in 0..<Int(minorTickCount)  {
                        if minorCoord < rangeMin {
                            break
                        }
                        minorLocations.insert(minorCoord)
                            minorCoord = minorCoord - minorInterval
                        }
                }
                
                // Set tick locations
                while ( coord < rangeMax) {
                    // Major tick
                    majorLocations.insert(coord)
                    
                    // Minor ticks
                    if ( minorTickCount > 0 ) {
                        var minorCoord = coord + minorInterval
                        
                        for minorTickIndex in  0..<Int(minorTickCount) {
                            if minorCoord > rangeMax {
                                break
                            }
                            minorLocations.insert(minorCoord)
                            minorCoord = (minorCoord + minorInterval)
                        }
                    }
                    coord = coord + majorInterval
                }
//            }
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
    
    //    /**
    //     *  @internal
    //     *  @brief Generate major and minor tick locations using the equal divisions labeling policy.
    //     *  @param newMajorLocations A new NSSet containing the major tick locations.
    //     *  @param newMinorLocations A new NSSet containing the minor tick locations.
    //     */
 
    //
    //    /**
    //     *  @internal
    //     *  @brief Determines a @quote{nice} number (a multiple of @num{2}, @num{5}, or @num{10}) near the given number.
    //     *  @param x The number to round.
    //     */
    //
    //    /**
    //     *  @internal
    //     *  @brief Removes any tick locations falling inside the label exclusion ranges from a set of tick locations.
    //     *  @param allLocations A set of tick locations.
    //     *  @return The filtered set of tick locations.
    //     */
    func filteredTickLocations(allLocations: CPTNumberSet )-> CPTNumberSet
    {
        let exclusionRanges = self.labelExclusionRanges;
        
        if ( exclusionRanges.isEmpty == false ) {
            let filteredLocations = allLocations 
            for range in exclusionRanges  {
                for location in allLocations {
                    if range.containsNumber(location) {
                        filteredLocations.removeObject(location)
                    }
                }
            }
            return filteredLocations;
        }
        else {
            return allLocations;
        }
    }
    
    
    //    /** @brief Removes any major ticks falling inside the label exclusion ranges from the set of tick locations.
    //     *  @param allLocations A set of major tick locations.
    //     *  @return The filtered set.
    //     **/
    func filteredMajorTickLocations(allLocations: CPTNumberSet )-> CPTNumberSet
    {
        return self.filteredTickLocations(allLocations: allLocations)
    }
    //
    //    /** @brief Removes any minor ticks falling inside the label exclusion ranges from the set of tick locations.
    //     *  @param allLocations A set of minor tick locations.
    //     *  @return The filtered set.
    //     **/
    func filteredMinorTickLocations(allLocations: CPTNumberSet )-> CPTNumberSet
    {
        return self.filteredTickLocations(allLocations: allLocations)
    }
    //
    // MARK: - Labels
    var _tickOffset = CGFloat(0)
    var tickOffset : CGFloat {
        get   {
            var offset = CGFloat(0.0);
            
            switch ( self.tickDirection ) {
            case .none:
                offset += self.majorTickLength * CGFloat(0.5);
                break;
                
            case .positive:
                fallthrough
                
            case .negative:
                offset += self.majorTickLength;
                break;
            }
            
            return offset;
        }
        set {}
    }

        /**
         *  @internal
         *  @brief Updates the set of axis labels using the given locations.
         *  Existing axis label objects and content layers are reused where possible.
         *  @param locations A set of NSDecimalNumber label locations.
         *  @param labeledRange A plot range used to filter the generated labels. If @nil, no filtering is done.
         *  @param useMajorAxisLabels If @true, label the major ticks, otherwise label the minor ticks.
         **/
    func updateAxisLabelsAtLocations(locations: CPTNumberSet, inRange labeledRange : CPTPlotRange, useMajorAxisLabels:Bool)
    {
        var theLabelAlignment = CPTAlignment.left
        let theLabelDirection : CPTSign
        var theLabelOffset = CGFloat(0);
        var theLabelRotation = CGFloat(0);
        let theLabelTextStyle : CPTTextStyle;
        let theLabelFormatter : Formatter
        var theLabelFormatterChanged = false
        let theShadow : CPTShadow
        
        let theDelegate = self.delegate as! CPTAxisDelegate
        
        if ( useMajorAxisLabels == true ) {
            if ( locations.count > 0 ) {
                let locationSet = locations;
                var shouldContinue = theDelegate.axis(axis: self, shouldUpdateAxisLabelsAtLocations: locationSet)
            }
            theLabelAlignment        = self.labelAlignment;
            theLabelDirection        = self.tickLabelDirection;
            theLabelOffset           = self.labelOffset;
            theLabelRotation         = self.labelRotation;
            theLabelTextStyle        = self.labelTextStyle;
            theLabelFormatter        = self.labelFormatter!;
            theLabelFormatterChanged = self.labelFormatterChanged;
            theShadow                = self.labelShadow!;
        }
        else {
            if ( locations.count > 0 ) {
                var locationSet = locations;
                var shouldContinue   = theDelegate.axis(axis: self, shouldUpdateMinorAxisLabelsAtLocations:locationSet)
                if ( shouldContinue  == false) { return }
            }
            theLabelAlignment        = self.minorTickLabelAlignment;
            theLabelDirection        = self.minorTickLabelDirection;
            theLabelOffset           = self.minorTickLabelOffset;
            theLabelRotation         = self.minorTickLabelRotation;
            theLabelTextStyle        = self.minorTickLabelTextStyle;
            theLabelFormatter        = self.minorTickLabelFormatter!;
            theLabelFormatterChanged = self.minorLabelFormatterChanged;
            theShadow                = self.minorTickLabelShadow!;
        }
        
        if ((locations.count == 0) || !theLabelTextStyle || !theLabelFormatter ) {
            if ( useMajorAxisLabels ) {
                self.axisLabels.removeAll()
            }
            else {
                self.minorTickAxisLabels.removeAll()
            }
            return
        }
        
        CPTDictionary textAttributes = theLabelTextStyle.attributes;
        var hasAttributedFormatter   = ([theLabelFormatter attributedStringForObjectValue:[NSDecimalNumber zero]
                                         withDefaultAttributes:textAttributes] != nil);
        
        let thePlotSpace = self.plotSpace;
        let myCoordinate = self.coordinate;
        var hasCategories = thePlotSpace?.scaleTypeForCoordinate(coordinate: myCoordinate) == CPTScaleType.category
        
        let direction = self.tickDirection;
        
        if ( theLabelDirection == CPTSign.none ) {
            theLabelDirection = direction
        }
        
        if ((direction == CPTSign.none) || (theLabelDirection == direction)) {
            theLabelOffset += self.tickOffset;
        }
        
        let thePlotArea = self.plotArea;
        
        thePlotArea?.setAxisSetLayersForType(layerType: CPTGraphLayerType.axisLabels)
        
        var oldAxisLabels = Set<CPTAxisLabel>()
        if ( useMajorAxisLabels == true ) {
            oldAxisLabels.insert( self.axisLabels )
        }
        else {
            oldAxisLabels.insert( self.minorTickAxisLabels )
        }
        
        var newAxisLabels = Set<CPTAxisLabel>()
        let blankLabel         = CPTAxisLabel(newText: nil, newStyle:nil);
        let axisLabelGroup     = thePlotArea!.axisLabelGroup;
        var lastLayer          : CPTLayer?
        
        for tickLocation in locations  {
            if ( labeledRange && labeledRange.containsNumber(number: tickLocation) == false ) {
                continue;
            }
            
            let newAxisLabel : CPTAxisLabel
            var needsNewContentLayer = false
            
            // reuse axis labels where possible--will prevent flicker when updating layers
            blankLabel.tickLocation = tickLocation;
            var oldAxisLabel = [oldAxisLabels member:blankLabel];
            
            if ( oldAxisLabel ) {
                newAxisLabel = oldAxisLabel;
            }
            else {
                newAxisLabel              = CPTAxisLabel(newText: nil, newStyle:nil)
                newAxisLabel.tickLocation = tickLocation;
                needsNewContentLayer      = true;
            }
            
            newAxisLabel.rotation  = theLabelRotation;
            newAxisLabel.offset    = theLabelOffset;
            newAxisLabel.alignment = theLabelAlignment;
            
            if ( needsNewContentLayer || theLabelFormatterChanged ) {
                var newLabelLayer : CPTTextLayer?
                if ( hasCategories ) {
                    let labelString = [thePlotSpace categoryForCoordinate:myCoordinate atIndex:tickLocation.unsignedIntegerValue];
                    if ( labelString ) {
                        newLabelLayer = CPTTextLayer(labelString, style:theLabelTextStyle)
                    }
                }
                else if ( hasAttributedFormatter == true) {
                    let labelString = [theLabelFormatter attributedStringForObjectValue:tickLocation withDefaultAttributes:textAttributes];
                    newLabelLayer = CPTTextLayer(attributedText: labelString)
                }
                else {
                    var labelString = [theLabelFormatter stringForObjectValue:tickLocation];
                    newLabelLayer = CPTTextLayer(labelString, style:theLabelTextStyle)
                }
                [oldAxisLabel.contentLayer removeFromSuperlayer];
                if (( newLabelLayer ) != nil) {
                    newAxisLabel.contentLayer = newLabelLayer!;
                    
                    if (( lastLayer ) != nil) {
                        axisLabelGroup?.insertSublayer(newLabelLayer!, below:lastLayer)
                    }
                    else {
                        axisLabelGroup?.insertSublayer(newLabelLayer!, at: UInt32((thePlotArea?.sublayerIndexForAxis(axis: self, layerType:CPTGraphLayerType.axisLabels))!))
                    }
                }
            }
            
            lastLayer        = newAxisLabel.contentLayer;
            lastLayer.shadow = theShadow;
            
            newAxisLabels.addObject(newAxisLabel)
        }
        
        // remove old labels that are not needed any more from the layer hierarchy
        [oldAxisLabels minusSet:newAxisLabels];
        for label in oldAxisLabels {
            label.contentLayer.removeFromSuperlayer()
        }
        
        self.labelsUpdated = true;
        if ( useMajorAxisLabels ) {
            self.axisLabels            = newAxisLabels;
            self.labelFormatterChanged = false
        }
        else {
            self.minorTickAxisLabels        = newAxisLabels;
            self.minorLabelFormatterChanged = false
        }
        self.labelsUpdated = false
    }

    //    /**
    //     *  @brief Marks the receiver as needing to update the labels before the content is next drawn.
    //     **/
    
    func setNeedsRelabel(_ newNeedsRelabel: Bool) {
        if newNeedsRelabel != needsRelabel {
            needsRelabel = newNeedsRelabel
            if needsRelabel {
                setNeedsDisplay()
                if separateLayers {
                    var gridlines = majorGridLines
                    gridlines?.setNeedsDisplay()
                    
                    gridlines = minorGridLines
                    gridlines?.setNeedsDisplay()
                } else {
                    let thePlotArea = plotArea
                    thePlotArea?.majorGridLineGroup!.setNeedsDisplay()
                    thePlotArea?.minorGridLineGroup!.setNeedsDisplay()
                }
            }
        }
    }
    
    func setNeedsRelabel()
    {
        self.needsRelabel = true
    }
    
    //    Updates the axis labels.
    func relabel()
    {
        guard self.needsRelabel == true else { return }
        guard self.plotSpace != nil else  { return }
        
        let theDelegate = self.delegate as! CPTAxisDelegate
        
        if theDelegate.axisShouldRelabel(axis: self ) == true {
            self.needsRelabel = false
            return;
        }
        
        var newMajorLocations = Set<CGFloat>()
        var newMinorLocations = Set<CGFloat>()
        
        switch ( self.labelingPolicy ) {
        case .none:
            fallthrough
        case .provided:
            // Locations are set by user
            break;
            
        case .fixedInterval:
            self.generateFixedInterval(newMajorLocations:&newMajorLocations, newMinorLocations:&newMinorLocations)
            
        case .automatic:
            self.autoGenerateMajorTickLocations(newMajorLocations: &newMajorLocations, minorTickLocations:&newMinorLocations)
            break;
            
        case .divisions:
            self.generateEqualMajorTickLocations(&newMajorLocations, minorTickLocations:&newMinorLocations)
            break;
        }
        
        switch ( self.labelingPolicy ) {
        case .none:
            fallthrough
        case .provided:
            // Locations are set by user--no filtering required
            break;
            
        default:
            // Filter and set tick locations
            self.majorTickLocations = self.filteredMajorTickLocations(newMajorLocations)
            self.minorTickLocations = self.filteredMinorTickLocations(newMinorLocations)
        }
        
        // Label ticks
        switch ( self.labelingPolicy ) {
        case .none:
            self.updateCustomTickLabels()
            break;
            
        case .provided:
            let labeledRange = self.plotSpace?.plotRangeForCoordinate(coordinate: self.coordinate) as! CPTMutablePlotRange
                let theVisibleRange     = self.visibleRange;
            if ( theVisibleRange != nil ) {
                labeledRange.intersectionPlotRange(other: theVisibleRange)
            }
                
            self.updateAxisLabelsAtLocations(self.majorTickLocations,
                inRange:labeledRange,
                useMajorAxisLabel:true)
                
            self.updateAxisLabelsAtLocations(self.minorTickLocations,
                inRange:labeledRange,
                useMajorAxisLabels:false)
                        
        default:
            self.updateAxisLabelsAtLocations(self.majorTickLocations,
                                              inRange:nil,
                                              useMajorAxisLabels:true)
            
            self.updateAxisLabelsAtLocations(self.minorTickLocations,
                inRange:nil,
                useMajorAxisLabels:false)
        }
        
        self.needsRelabel = false
        if ( self.alternatingBandFills.count > 0 ) {
            let thePlotArea = self.plotArea
            thePlotArea?.setNeedsDisplay()
        }
        
        theDelegate.axisDidRelabel(axis: self)
    }
    
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
    
        /**
         *  @brief Update the minor tick mark labels.
         **/
    
    
    // MARK: - Titles

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
        
        let coordValue = self.viewPointForCoordinateValue(coordinateValue: CGFloat(self.titleLocation))
        let ortho = CPTUtilities.shared.CPTOrthogonalCoordinate(coordinate)
            
        self.axisTitle()!.positionRelativeToViewPoint( point: coordValue,
                                                    coordinate: ortho,
                                                    direction:direction)
    }

// MARK: - Layout
    public override func layoutSublayers()
    {
        if self.needsRelabel == true {
            self.relabel()
        }
        else {
            self.updateMajorTickLabels();
            self.updateMinorTickLabels()
        }
        self.updateAxisTitle()
    }
    
    // MARK: -  Background Bands
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
    func removeBackgroundLimitBand(limitBand: CPTLimitBand? )
    {
        if (( limitBand ) != nil) {
            let band = limitBand;
            self.mutableBackgroundLimitBands.removeObject(band!)
            
            let thePlotArea = self.plotArea;
            thePlotArea?.setNeedsDisplay()
        }
    }

    /** @brief Remove all background limit bands.
    **/
    func removeAllBackgroundLimitBands()
    {
        self.mutableBackgroundLimitBands.removeAll()
        let thePlotArea = self.plotArea;
        thePlotArea?.setNeedsDisplay()
    }
    
    // MARK: -  Responder Chain and User Interaction
    override func pointingDeviceDownEvent(event: CPTNativeEvent, atPoint interactionPoint:CGPoint)-> Bool
    {
        guard self.isHidden == false else { return false }
        
        let theGraph = self.graph;
        guard theGraph != nil else { return false }
        
        weak var theDelegate = self.delegate as? CPTAxisDelegate
        
        // Tick labels
        
        for label in self.axisLabels {
            let contentLayer = label.contentLayer;
            if contentLayer.isHidden == false {
                let labelPoint = theGraph?.convert(interactionPoint, to:contentLayer)
                
                if contentLayer.bounds.contains( labelPoint!) == true {
                    self.pointingDeviceDownLabel = label;
                    var handled = false
                    
                    if ((theDelegate?.axis(axis:labelTouchDown:)) != nil) {
                        handled = true;
                        theDelegate?.axis(axis: self, labelTouchDown:label)
                    }
                    
                    if ((theDelegate?.axis(axis:labelTouchDown:withEvent:)) != nil) {
                        handled = true;
                        theDelegate?.axis(axis:self, labelTouchDown:label, withEvent:event)
                    }
                    guard handled == false else { return true }
                }
            }
        }
        
        // Minor tick labels
        for label in self.minorTickAxisLabels {
            let contentLayer = label.contentLayer;
            if ( !contentLayer.isHidden ) {
                
                let labelPoint = theGraph?.convert(interactionPoint, to:contentLayer)
                
                if contentLayer.bounds.contains(labelPoint!) == true {
                    self.pointingDeviceDownTickLabel = label;
                    var handled = false
                    
                    if ((theDelegate?.axis(axis: minorTickTouchDown:)) != nil) {
                        handled = true;
                        theDelegate?.axis(axis:self, minorTickTouchDown:label)
                    }
                    
                    if ((theDelegate?.axis(axis:minorTickTouchDown:withEvent:)) != nil) {
                        handled = true;
                        theDelegate?.axis(axis: self, minorTickTouchDown:label, withEvent:event)
                    }
                    guard handled == false else { return true }
                }
            }
        }
        return super.pointingDeviceDownEvent(event: event, atPoint:interactionPoint)
    }

    
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
    override func pointingDeviceUpEvent(event: CPTNativeEvent, atPoint interactionPoint:CGPoint )-> Bool
    {
        let selectedDownLabel     = self.pointingDeviceDownLabel;
        let selectedDownTickLabel = self.pointingDeviceDownTickLabel;
        
        self.pointingDeviceDownLabel     = nil;
        self.pointingDeviceDownTickLabel = nil;
        
        let theGraph = self.graph;
        
        guard self.isHidden == false else { return false }
//        guard self.plots.count != 0 else { return false }
        
        weak var theDelegate = self.delegate as? CPTAxisDelegate
        
        
        // Tick labels
        for label in self.axisLabels {
            let contentLayer = label.contentLayer;
            if ( !contentLayer.isHidden ) {
                let labelPoint = theGraph?.convert(interactionPoint, to:contentLayer)
                
                if ( contentLayer.bounds.contains(labelPoint!)) {
                    var handled = false
                    
                    if ((theDelegate?.axis(axis: labelTouchUp:)) != nil) {
                        handled = true
                        theDelegate?.axis(axis:self, labelTouchUp:label)
                        
                    }
                    
                    if ((theDelegate?.axis( axis: labelTouchUp: withEvent:)) != nil) {
                        handled = true
                        theDelegate?.axis(axis:self, labelTouchUp:label, withEvent:event)
                    }
                    
                    if ( label == selectedDownLabel ) {
                        if (theDelegate?.axis(axis: labelWasSelected:) != nil) {
                            handled = true;
                            theDelegate?.axis(axis:self, labelWasSelected:label)
                        }
                        
                        if ((theDelegate?.axis(axis: labelWasSelected: withEvent:)) != nil) {
                            handled = true
                            theDelegate?.axis(axis:self, labelWasSelected:label, withEvent:event)
                        }
                    }
                    
                    if ( handled ) {
                        return true;
                    }
                }
            }
            
        }
        
        // Minor tick labels
        for label in self.minorTickAxisLabels {
            let contentLayer = label.contentLayer;
            if (  !contentLayer.isHidden ) {
                let labelPoint = theGraph!.convert(interactionPoint, to:contentLayer)
                
                if ( contentLayer.bounds.contains(labelPoint)) {
                    var handled = false
                    
                    if ((theDelegate?.axis(axis: minorTickTouchUp:)) != nil) {
                        handled = true;
                        theDelegate?.axis(axis:self, minorTickTouchUp:label)
                    }
                    
                    if ((theDelegate?.axis(axis: minorTickTouchUp: withEvent:)) != nil) {
                        handled = true;
                        theDelegate?.axis(axis:self, minorTickTouchUp:label, withEvent:event)
                    }
                    
                    if label == selectedDownTickLabel  {
                        if ((theDelegate?.axis(axis: minorTickLabelWasSelected:)) != nil) {
                            handled = true;
                            theDelegate?.axis(axis:self, minorTickLabelWasSelected:label)
                        }
                        
                        if ((theDelegate?.axis(axis: minorTickLabelWasSelected: withEvent:)) != nil) {
                            handled = true;
                            theDelegate?.axis(axis:self, minorTickLabelWasSelected:label, withEvent:event)
                        }
                    }
                    
                    if ( handled ) {
                        return true;
                    }
                }
            }
        }
        return super.pointingDeviceUpEvent(event:event, atPoint:interactionPoint)
    }

    // MARK: - Accessors
    
    
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
    var _titleOffset =  CGFloat(0)
    var titleOffset :  CGFloat {
        get { return _titleOffset}
        set {
            if ( newValue != _titleOffset ) {
                _titleOffset = newValue;
                
                self.axisTitle?.offset = _titleOffset;
                self.updateAxisTitle()
            }
        }
    }

    func setTitleRotation(newRotation: CGFloat)
        {
            if ( newRotation != titleRotation ) {
                titleRotation = newRotation;
    
                self.axisTitle?.rotation = titleRotation!;
                self.updateAxisTitle()
            }
        }
    
    func setTitleDirection(newDirection: CPTSign)
        {
            if ( newDirection != titleDirection ) {
                titleDirection = newDirection;
    
                self.updateAxisTitle()
            }
        }
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
            thePlotArea?.updateAxisSetLayersForType( layerType: .majorGridLines)
            
            if ( self.separateLayers ) {
                if (majorGridLineStyle != nil) {
                    var gridLines = self.majorGridLines;
                    
                    if (gridLines != nil) {
                        gridLines?.setNeedsDisplay()
                    }
                    else {
                        gridLines           = CPTGridLines(frame: CGRect())
                        self.majorGridLines = gridLines;
                    }
                }
                else {
                    self.majorGridLines = nil
                }
            }
            else {
                thePlotArea?.majorGridLineGroup!.setNeedsDisplay()
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
    func viewPointForCoordinateValue(coordinateValue:  CGFloat )-> CGPoint
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



