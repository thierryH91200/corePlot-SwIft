//
//  CPTAxis  Accessors.swift
//  corePlot
//
//  Created by thierryH24 on 16/11/2020.
//

import AppKit

extension CPTAxis {
    
    // MARK: - Accessors
    func setAxisLabels(newLabels : CPTAxisLabelSet )
    {
        if ( newLabels != axisLabels ) {
            if self.labelsUpdated == true {
                axisLabels = newLabels
            }
            else {
                
                let arrayLabels = Array(axisLabels)
                for  label in arrayLabels  {
                    label.contentLayer.removeFromSuperlayer()
                }
                
                axisLabels = newLabels;
                let thePlotArea = self.plotArea
                thePlotArea?.updateAxisSetLayersForType( layerType: .axisLabels)
                
                if ( axisLabels.isEmpty != false ) {
                    
                    let axisLabelGroup = thePlotArea?.axisLabelGroup
                    let lastLayer      : CALayer?
                    
                    for label in axisLabels  {
                        let contentLayer = label.contentLayer
                        if (( lastLayer ) != nil) {
                            axisLabelGroup?.insertSublayer(contentLayer, below:lastLayer)
                        }
                        else {
                            
                            let index = thePlotArea!.sublayerIndexForAxis(axis: self, layerType:.axisLabels)
                            axisLabelGroup?.insertSublayer(contentLayer, at: UInt32(index) )
                        }
                        lastLayer = contentLayer;
                    }
                }
            }
            if ( self.labelingPolicy == .none ) {
                self.updateCustomTickLabels()
            }
            else {
                self.updateMajorTickLabels()
            }
        }
    }
    
    func setMinorTickAxisLabels(newLabels: CPTAxisLabelSet )
    {
        if newLabels != minorTickAxisLabels {
            if ( self.labelsUpdated == true ) {
                minorTickAxisLabels = newLabels;
            }
            else {
                for label in minorTickAxisLabels {
                    label.contentLayer.removeFromSuperlayer()
                }
                
                minorTickAxisLabels = newLabels;
                
                let thePlotArea = self.plotArea;
                thePlotArea?.updateAxisSetLayersForType( layerType: .axisLabels)
                
                if ( minorTickAxisLabels.isEmpty == false ) {
                    let axisLabelGroup = thePlotArea?.axisLabelGroup
                    let lastLayer   : CALayer?
                    
                    for  label in minorTickAxisLabels  {
                        let contentLayer = label.contentLayer
                        if ( lastLayer  != nil) {
                            axisLabelGroup?.insertSublayer(contentLayer, below:lastLayer)
                        }
                        else {
                            
                            let index = thePlotArea?.sublayerIndexForAxis(axis: self, layerType:.axisLabels)
                            axisLabelGroup!.insertSublayer(contentLayer, at:UInt32(index!))
                        }
                        
                        lastLayer = contentLayer;
                    }
                }
            }
            
            if ( self.labelingPolicy == .none ) {
                self.updateCustomTickLabels()
            }
            else {
                self.updateMinorTickLabels()
            }
        }
    }
    
    func setLabelTextStyle(newStyle: CPTTextStyle )
    {
        if ( labelTextStyle != newStyle ) {
            labelTextStyle = newStyle
            
            for axisLabel in self.axisLabels {
                let contentLayer = (axisLabel.contentLayer) as! CPTTextLayer
//                if contentLayer is CPTTextLayer {
                    contentLayer.textStyle = labelTextStyle
//                }
            }
            self.updateMajorTickLabels()
        }
    }
    
    func setMinorTickLabelTextStyle(newStyle: CPTTextStyle)
        {
            if ( minorTickLabelTextStyle != newStyle ) {
                minorTickLabelTextStyle = newStyle
    
//                Class textLayerClass = [CPTTextLayer class];
                for   axisLabel in self.minorTickAxisLabels {
                    let contentLayer = axisLabel.contentLayer as! CPTTextLayer
//                    if ( [contentLayer isKindOfClass:textLayerClass] ) {
                        contentLayer.textStyle = minorTickLabelTextStyle;
//                    }
                }
    
                self.updateMinorTickLabels()
            }
        }

    
    //    -(void)setTitleTextStyle:(nullable CPTTextStyle *)newStyle
    //    {
    //        if ( newStyle != titleTextStyle ) {
    //            titleTextStyle = [newStyle copy];
    //
    //            if ( !self.inTitleUpdate ) {
    //                self.inTitleUpdate   = YES;
    //                self.attributedTitle = nil;
    //                self.inTitleUpdate   = NO;
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
    func setTitleOffset(newOffset: CGFloat)
    {
        if ( newOffset != titleOffset ) {
            titleOffset = newOffset;
            
            self.axisTitle?.offset = titleOffset;
            self.updateAxisTitle()
        }
    }
    
    //    -(void)setTitleRotation:(CGFloat)newRotation
    //    {
    //        if ( newRotation != titleRotation ) {
    //            titleRotation = newRotation;
    //
    //            self.axisTitle.rotation = titleRotation;
    //            [self updateAxisTitle];
    //        }
    //    }
    //
    //    -(void)setTitleDirection:(CPTSign)newDirection
    //    {
    //        if ( newDirection != titleDirection ) {
    //            titleDirection = newDirection;
    //
    //            [self updateAxisTitle];
    //        }
    //    }
    //
    //    -(void)setTitle:(nullable NSString *)newTitle
    //    {
    //        if ( newTitle != title ) {
    //            title = [newTitle copy];
    //
    //            if ( !self.inTitleUpdate ) {
    //                self.inTitleUpdate   = YES;
    //                self.attributedTitle = nil;
    //                self.inTitleUpdate   = NO;
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
    //    -(void)setAttributedTitle:(nullable NSAttributedString *)newTitle
    //    {
    //        if ( newTitle != attributedTitle ) {
    //            attributedTitle = [newTitle copy];
    //
    //            if ( !self.inTitleUpdate ) {
    //                self.inTitleUpdate = YES;
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
    //                self.inTitleUpdate = NO;
    //            }
    //        }
    //    }
    //

    //    -(void)setNeedsRelabel:(BOOL)newNeedsRelabel
    //    {
    //        if ( newNeedsRelabel != needsRelabel ) {
    //            needsRelabel = newNeedsRelabel;
    //            if ( needsRelabel ) {
    //                [self setNeedsDisplay];
    //                if ( self.separateLayers ) {
    //                    CPTGridLines *gridlines = self.majorGridLines;
    //                    [gridlines setNeedsDisplay];
    //
    //                    gridlines = self.minorGridLines;
    //                    [gridlines setNeedsDisplay];
    //                }
    //                else {
    //                    CPTPlotArea *thePlotArea = self.plotArea;
    //                    [thePlotArea.majorGridLineGroup setNeedsDisplay];
    //                    [thePlotArea.minorGridLineGroup setNeedsDisplay];
    //                }
    //            }
    //        }
    //    }
    //
    //    -(void)setMajorTickLocations:(nullable CPTNumberSet *)newLocations
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
    //            self.needsRelabel = YES;
    //        }
    //    }
    //
    //    -(void)setMinorTickLocations:(nullable CPTNumberSet *)newLocations
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
    //            self.needsRelabel = YES;
    //        }
    //    }
    
    func setMajorTickLength(_ newLength: CGFloat) {
        if newLength != majorTickLength {
            majorTickLength = newLength
            
            updateMajorTickLabelOffsets()
            updateMinorTickLabelOffsets()
            
            setNeedsDisplay()
            updateMajorTickLabels()
            updateMinorTickLabels()
        }
    }
    
    func setMinorTickLength(_ newLength: CGFloat) {
        if newLength != minorTickLength {
            minorTickLength = newLength
            setNeedsDisplay()
        }
    }

    func setLabelOffset(newOffset: CGFloat)
    {
        if ( newOffset != labelOffset ) {
            labelOffset = newOffset;
            
            self.updateMajorTickLabelOffsets()
            self.updateMajorTickLabels();
        }
    }
    
    //    -(void)setMinorTickLabelOffset:(CGFloat)newOffset
    //    {
    //        if ( newOffset != minorTickLabelOffset ) {
    //            minorTickLabelOffset = newOffset;
    //
    //            [self updateMinorTickLabelOffsets];
    //            [self updateMinorTickLabels];
    //        }
    //    }
    //
    //    -(void)setLabelRotation:(CGFloat)newRotation
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
    //    -(void)setMinorTickLabelRotation:(CGFloat)newRotation
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
    //    -(void)setLabelAlignment:(CPTAlignment)newAlignment
    //    {
    //        if ( newAlignment != labelAlignment ) {
    //            labelAlignment = newAlignment;
    //            [self updateMajorTickLabels];
    //        }
    //    }
    //
    //    -(void)setMinorTickLabelAlignment:(CPTAlignment)newAlignment
    //    {
    //        if ( newAlignment != minorTickLabelAlignment ) {
    //            minorTickLabelAlignment = newAlignment;
    //            [self updateMinorTickLabels];
    //        }
    //    }
    //
    //    -(void)setLabelShadow:(nullable CPTShadow *)newLabelShadow
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
    //    -(void)setMinorTickLabelShadow:(nullable CPTShadow *)newLabelShadow
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
    //    -(void)setPlotSpace:(nullable CPTPlotSpace *)newSpace
    //    {
    //        if ( newSpace != plotSpace ) {
    //            plotSpace         = newSpace;
    //            self.needsRelabel = YES;
    //        }
    //    }
    //
    //    -(void)setCoordinate:(CPTCoordinate)newCoordinate
    //    {
    //        if ( newCoordinate != coordinate ) {
    //            coordinate        = newCoordinate;
    //            self.needsRelabel = YES;
    //        }
    //    }
    //
    //    -(void)setAxisLineStyle:(nullable CPTLineStyle *)newLineStyle
    //    {
    //        if ( newLineStyle != axisLineStyle ) {
    //            axisLineStyle = [newLineStyle copy];
    //            [self setNeedsDisplay];
    //        }
    //    }
    //
    //    -(void)setMajorTickLineStyle:(nullable CPTLineStyle *)newLineStyle
    //    {
    //        if ( newLineStyle != majorTickLineStyle ) {
    //            majorTickLineStyle = [newLineStyle copy];
    //            [self setNeedsDisplay];
    //        }
    //    }
    //
    //    -(void)setMinorTickLineStyle:(nullable CPTLineStyle *)newLineStyle
    //    {
    //        if ( newLineStyle != minorTickLineStyle ) {
    //            minorTickLineStyle = [newLineStyle copy];
    //            [self setNeedsDisplay];
    //        }
    //    }
    //
    //    -(void)setMajorGridLineStyle:(nullable CPTLineStyle *)newLineStyle
    //    {
    //        if ( newLineStyle != majorGridLineStyle ) {
    //            majorGridLineStyle = [newLineStyle copy];
    //
    //            CPTPlotArea *thePlotArea = self.plotArea;
    //            [thePlotArea updateAxisSetLayersForType:CPTGraphLayerTypeMajorGridLines];
    //
    //            if ( self.separateLayers ) {
    //                if ( majorGridLineStyle ) {
    //                    CPTGridLines *gridLines = self.majorGridLines;
    //
    //                    if ( gridLines ) {
    //                        [gridLines setNeedsDisplay];
    //                    }
    //                    else {
    //                        gridLines           = [[CPTGridLines alloc] init];
    //                        self.majorGridLines = gridLines;
    //                    }
    //                }
    //                else {
    //                    self.majorGridLines = nil;
    //                }
    //            }
    //            else {
    //                [thePlotArea.majorGridLineGroup setNeedsDisplay];
    //            }
    //        }
    //    }
    //
    //    -(void)setMinorGridLineStyle:(nullable CPTLineStyle *)newLineStyle
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
    //    -(void)setAxisLineCapMin:(nullable CPTLineCap *)newAxisLineCapMin
    //    {
    //        if ( newAxisLineCapMin != axisLineCapMin ) {
    //            axisLineCapMin = [newAxisLineCapMin copy];
    //            [self setNeedsDisplay];
    //        }
    //    }
    //
    //    -(void)setAxisLineCapMax:(nullable CPTLineCap *)newAxisLineCapMax
    //    {
    //        if ( newAxisLineCapMax != axisLineCapMax ) {
    //            axisLineCapMax = [newAxisLineCapMax copy];
    //            [self setNeedsDisplay];
    //        }
    //    }
    //
    //    -(void)setLabelingOrigin:(nonnull NSNumber *)newLabelingOrigin
    //    {
    //        BOOL needsUpdate = YES;
    //
    //        if ( newLabelingOrigin ) {
    //            needsUpdate = ![labelingOrigin isEqualToNumber:newLabelingOrigin];
    //        }
    //
    //        if ( needsUpdate ) {
    //            labelingOrigin = newLabelingOrigin;
    //
    //            self.needsRelabel = YES;
    //        }
    //    }
    //
    //    -(void)setMajorIntervalLength:(nullable NSNumber *)newIntervalLength
    //    {
    //        BOOL needsUpdate = YES;
    //
    //        if ( newIntervalLength ) {
    //            NSNumber *interval = newIntervalLength;
    //            needsUpdate = ![majorIntervalLength isEqualToNumber:interval];
    //        }
    //
    //        if ( needsUpdate ) {
    //            majorIntervalLength = newIntervalLength;
    //
    //            self.needsRelabel = YES;
    //        }
    //    }
    //
    //    -(void)setMinorTicksPerInterval:(NSUInteger)newMinorTicksPerInterval
    //    {
    //        if ( newMinorTicksPerInterval != minorTicksPerInterval ) {
    //            minorTicksPerInterval = newMinorTicksPerInterval;
    //
    //            self.needsRelabel = YES;
    //        }
    //    }
    //
    //    -(void)setLabelingPolicy:(CPTAxisLabelingPolicy)newPolicy
    //    {
    //        if ( newPolicy != labelingPolicy ) {
    //            labelingPolicy    = newPolicy;
    //            self.needsRelabel = YES;
    //        }
    //    }
    //
    //    -(void)setPreferredNumberOfMajorTicks:(NSUInteger)newPreferredNumberOfMajorTicks
    //    {
    //        if ( newPreferredNumberOfMajorTicks != preferredNumberOfMajorTicks ) {
    //            preferredNumberOfMajorTicks = newPreferredNumberOfMajorTicks;
    //            if ( self.labelingPolicy == CPTAxisLabelingPolicyAutomatic ) {
    //                self.needsRelabel = YES;
    //            }
    //        }
    //    }
    //
    //    -(void)setLabelFormatter:(nullable NSFormatter *)newTickLabelFormatter
    //    {
    //        if ( newTickLabelFormatter != labelFormatter ) {
    //            labelFormatter = newTickLabelFormatter;
    //
    //            self.labelFormatterChanged = YES;
    //            self.needsRelabel          = YES;
    //        }
    //    }
    //
    //    -(void)setMinorTickLabelFormatter:(nullable NSFormatter *)newMinorTickLabelFormatter
    //    {
    //        if ( newMinorTickLabelFormatter != minorTickLabelFormatter ) {
    //            minorTickLabelFormatter = newMinorTickLabelFormatter;
    //
    //            self.minorLabelFormatterChanged = YES;
    //            self.needsRelabel               = YES;
    //        }
    //    }
    //
    func setTickDirection(_ newDirection: CPTSign) {
        if newDirection != tickDirection {
            tickDirection = newDirection
            
            updateMajorTickLabelOffsets()
            updateMinorTickLabelOffsets()
            
            setNeedsDisplay()
            updateMajorTickLabels()
            updateMinorTickLabels()
        }
    }
    
    func setTickLabelDirection(_ newDirection: CPTSign) {
        if newDirection != tickLabelDirection {
            tickLabelDirection = newDirection
            
            updateMajorTickLabelOffsets()
            updateMajorTickLabels()
        }
    }

    func setMinorTickLabelDirection(newDirection: CPTSign)
    {
        if ( newDirection != minorTickLabelDirection ) {
            minorTickLabelDirection = newDirection;
            
            self.updateMinorTickLabelOffsets()
            self.updateMinorTickLabels()
        }
    }
    
    func setGridLinesRange(_ newValue: CPTPlotRange?) {
        if gridLinesRange != newValue {
            gridLinesRange = newValue
            if separateLayers {
                var gridlines = majorGridLines
                gridlines?.setNeedsDisplay()
                
                gridlines = minorGridLines
                gridlines?.setNeedsDisplay()
            } else {
                let thePlotArea = plotArea
                thePlotArea?.majorGridLineGroup?.setNeedsDisplay()
                thePlotArea?.minorGridLineGroup?.setNeedsDisplay()
            }
        }
    }
    
    //
    //    -(void)setPlotArea:(nullable CPTPlotArea *)newPlotArea
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
    func setVisibleRange(_ newRange: CPTPlotRange) {
        if newRange != visibleRange {
            visibleRange = newRange
            needsRelabel = true
        }
    }
    func setVisibleAxisRange(_ newRange: CPTPlotRange) {
        if newRange != visibleAxisRange {
            visibleAxisRange = newRange
            needsRelabel = true
        }
    }
    
    func setSeparateLayers(newSeparateLayers: Bool)
    {
        if ( newSeparateLayers != separateLayers ) {
            separateLayers = newSeparateLayers;
            if separateLayers == true  {
                if (( self.minorGridLineStyle ) != nil) {
                    let gridLines = CPTGridLines()
                    self.minorGridLines = gridLines;
                }
                if (( self.majorGridLineStyle ) != nil) {
                    let gridLines = CPTGridLines()
                    self.majorGridLines = gridLines;
                }
            }
            else {
                let thePlotArea = self.plotArea;
                self.minorGridLines = nil;
                if (( self.minorGridLineStyle ) != nil) {
                    thePlotArea?.minorGridLineGroup?.setNeedsDisplay()
                }
                self.majorGridLines = nil;
                if (self.majorGridLineStyle != nil)  {
                    thePlotArea?.majorGridLineGroup?.setNeedsDisplay()
                }
            }
        }
    }
    
    func setMinorGridLines(_ newGridLines: CPTGridLines) {
        let oldGridLines = minorGridLines
        
        if newGridLines != oldGridLines {
            oldGridLines?.removeFromSuperlayer()
            minorGridLines = newGridLines
            
            if newGridLines == newGridLines {
                let gridLines = newGridLines
                
                gridLines.major = false
                gridLines.axis = self
                
                let thePlotArea = plotArea
                let index = (thePlotArea?.sublayerIndexForAxis(axis: self, layerType: .minorGridLines))!
                thePlotArea?.minorGridLineGroup!.insertSublayer(gridLines, at: UInt32(index))
            }
        }
    }
    
    
    func setMajorGridLines(newGridLines: CPTGridLines )
        {
            let oldGridLines = majorGridLines;
    
            if ( newGridLines != oldGridLines ) {
                oldGridLines?.removeFromSuperlayer()
                majorGridLines = newGridLines;
    
                let gridLines = newGridLines;
    
                gridLines.major = true
                gridLines.axis  = self;
                
                let thePlotArea = self.plotArea;
                let index = thePlotArea?.sublayerIndexForAxis(axis: self, layerType:CPTGraphLayerType.majorGridLines)
                thePlotArea?.majorGridLineGroup?.insertSublayer(gridLines, at:UInt32(index!))
            }
        }
    
    //    -(void)setAlternatingBandFills:(nullable CPTFillArray *)newFills
    //    {
    //        if ( newFills != alternatingBandFills ) {
    //            Class nullClass = [NSNull class];
    //            Class fillClass = [CPTFill class];
    //
    //            BOOL convertFills = NO;
    //            for ( id obj in newFills ) {
    //                if ( [obj isKindOfClass:nullClass] || [obj isKindOfClass:fillClass] ) {
    //                    continue;
    //                }
    //                else {
    //                    convertFills = YES;
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
    //    -(void)setAlternatingBandAnchor:(nullable NSNumber *)newBandAnchor
    //    {
    //        if ( newBandAnchor != alternatingBandAnchor ) {
    //            alternatingBandAnchor = newBandAnchor;
    //
    //            CPTPlotArea *thePlotArea = self.plotArea;
    //            [thePlotArea setNeedsDisplay];
    //        }
    //    }
    //    
    
    public override var isHidden: Bool {
        get {
            return super.isHidden
        }
        set {
            if ( newValue != self.isHidden ) {
                super.isHidden = newValue;
                if ( newValue == true ) {
                    self.setNeedsRelabel()
                }
            }
            
        }
    }
    
    func updateCustomTickLabels()
    {
        //        let range = NSRange(location: 0,length: 0)
        //self.plotSpace.plotRangeForCoordinate(self.coordinate)
        let range = self.plotSpace?.plotRangeForCoordinate(coordinate: self.coordinate) as? CPTMutablePlotRange
        
        if (( range ) != nil) {
            let theVisibleRange = self.visibleRange;
            if (( theVisibleRange ) != nil) {
                range?.intersectionPlotRange(other: theVisibleRange!)
            }
            
            if ( range?.lengthDouble != 0.0 ) {
                let orthogonalCoordinate = CPTUtilities.shared.CPTOrthogonalCoordinate(self.coordinate)
                
                var direction = self.tickLabelDirection;
                
                if ( direction == CPTSign.none ) {
                    direction = self.tickDirection;
                }
                
                for label in self.axisLabels {
                    let isVisible = range?.containsNumber(number: label.tickLocation)
                    label.contentLayer.isHidden = !isVisible!;
                    if ( isVisible == true) {
                        let tickBasePoint = self.viewPointForCoordinateValue(coordinateValue: label.tickLocation)
                        label.positionRelativeToViewPoint(point: tickBasePoint, coordinate:orthogonalCoordinate, direction:direction)
                    }
                }
                
                for label in self.minorTickAxisLabels {
                    let isVisible = range?.containsNumber(number: label.tickLocation)
                    label.contentLayer.isHidden = !isVisible!
                    if ( isVisible == true) {
                        let tickBasePoint = self.viewPointForCoordinateValue(coordinateValue: label.tickLocation)
                        label.positionRelativeToViewPoint(point: tickBasePoint, coordinate:orthogonalCoordinate, direction:direction)
                    }
                }
            }
        }
    }
    
    func updateMajorTickLabelOffsets()
    {
        let direction      = self.tickDirection;
        var labelDirection = self.tickLabelDirection
        
        if ( labelDirection == CPTSign.none ) {
            labelDirection = direction
        }
        
        var majorOffset = self.labelOffset;
        
        if ((direction == CPTSign.none) || (labelDirection == direction)) {
            majorOffset += self.tickOffset
        }
        
        for label in self.axisLabels  {
            label.offset = majorOffset
        }
    }
    
    func updateMinorTickLabelOffsets()
    {
        let direction      = self.tickDirection;
        var labelDirection = self.minorTickLabelDirection;
        
        if ( labelDirection == .none ) {
            labelDirection = direction;
        }
        
        var minorOffset = self.minorTickLabelOffset;
        
        if ((direction == .none) || (labelDirection == direction)) {
            minorOffset += self.tickOffset;
        }
        
        for label in self.minorTickAxisLabels {
            label.offset = minorOffset
        }
    }
    
    /**
     * @brief Update the major tick mark labels.
     **/
    func updateMajorTickLabels()
    {
        let orthogonalCoordinate = CPTUtilities.shared.CPTOrthogonalCoordinate(self.coordinate);
        
        var direction = self.tickLabelDirection;
        
        if ( direction == .none ) {
            direction = self.tickDirection;
        }
        
        for label in self.axisLabels {
            let tickBasePoint = self.viewPointForCoordinateValue(coordinateValue: label.tickLocation)
            label.positionRelativeToViewPoint(point: tickBasePoint, coordinate:orthogonalCoordinate, direction:direction)
        }
    }
    
    /**
     *  @brief Update the minor tick mark labels.
     **/
    func updateMinorTickLabels() {
        
        let orthogonalCoordinate = CPTUtilities.shared.CPTOrthogonalCoordinate(coordinate)
        var direction = minorTickLabelDirection
        
        if direction == CPTSign.none {
            direction = tickDirection
        }
        
        for label in minorTickAxisLabels {
            let tickBasePoint = self.viewPointForCoordinateValue( coordinateValue: label.tickLocation)
            label.positionRelativeToViewPoint( point: tickBasePoint, coordinate: orthogonalCoordinate, direction: direction)
        }
    }
}
