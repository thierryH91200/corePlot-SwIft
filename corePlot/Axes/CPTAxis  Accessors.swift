//
//  CPTAxis  Accessors.swift
//  corePlot
//
//  Created by thierryH24 on 16/11/2020.
//

import AVFoundation





extension CPTAxis {

    
    // MARK: Accessors
    func setAxisLabels(newLabels : CPTAxisLabelSet )
    {
        if ( newLabels != axisLabels ) {
            if ( self.labelsUpdated ) {
                axisLabels = newLabels;
            }
            else {
                for ( label as! CPTAxisLabel) in axisLabels  {
//                for ( label in axisLabels ) {
                    label.contentLayer.removeFromSuperlayer()
                }

                axisLabels = newLabels;

                let thePlotArea = self.plotArea;
                thePlotArea?.updateAxisSetLayersForType( layerType: .axisLabels)

                if ( axisLabels ) {
                    let axisLabelGroup = thePlotArea?.axisLabelGroup;
                    let lastLayer      = nil;

                    for label in axisLabels  {
                        let contentLayer = label.contentLayer;
                        if ( contentLayer ) {
                            if ( lastLayer ) {
                                axisLabelGroup.insertSublayer(contentLayer, below:lastLayer)
                            }
                            else {
                                axisLabelGroup.insertSublayer(contentLayer, atIndex:(thePlotArea.sublayerIndexForAxis(self, layerType:.axisLabels))
                            }
                            lastLayer = contentLayer;
                        }
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
//
//    -(void)setMinorTickAxisLabels:(nullable CPTAxisLabelSet *)newLabels
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
//    -(void)setLabelTextStyle:(nullable CPTTextStyle *)newStyle
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
//    -(void)setMinorTickLabelTextStyle:(nullable CPTTextStyle *)newStyle
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
//    -(void)setAxisTitle:(nullable CPTAxisTitle *)newTitle
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
//    -(void)setTitleOffset:(CGFloat)newOffset
//    {
//        if ( newOffset != titleOffset ) {
//            titleOffset = newOffset;
//
//            self.axisTitle.offset = titleOffset;
//            [self updateAxisTitle];
//        }
//    }
//
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
    func setTitleLocation(newLocation : Int?)
    {
        var needsUpdate = true;
        
        if ( newLocation  != nil) {
            let location = newLocation
            needsUpdate = titleLocation.isEqualToNumber(location)
        }
        
        if ( needsUpdate  == true ) {
            titleLocation = newLocation;
            self.updateAxisTitle
        }
    }
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
//    -(void)setLabelExclusionRanges:(nullable CPTPlotRangeArray *)ranges
//    {
//        if ( ranges != labelExclusionRanges ) {
//            labelExclusionRanges = ranges;
//            self.needsRelabel    = YES;
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
//
//    -(void)setMajorTickLength:(CGFloat)newLength
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
//    -(void)setMinorTickLength:(CGFloat)newLength
//    {
//        if ( newLength != minorTickLength ) {
//            minorTickLength = newLength;
//            [self setNeedsDisplay];
//        }
//    }
//
//    -(void)setLabelOffset:(CGFloat)newOffset
//    {
//        if ( newOffset != labelOffset ) {
//            labelOffset = newOffset;
//
//            [self updateMajorTickLabelOffsets];
//            [self updateMajorTickLabels];
//        }
//    }
//
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
//    -(void)setTickDirection:(CPTSign)newDirection
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
//    -(void)setTickLabelDirection:(CPTSign)newDirection
//    {
//        if ( newDirection != tickLabelDirection ) {
//            tickLabelDirection = newDirection;
//
//            [self updateMajorTickLabelOffsets];
//            [self updateMajorTickLabels];
//        }
//    }
//
//    -(void)setMinorTickLabelDirection:(CPTSign)newDirection
//    {
//        if ( newDirection != minorTickLabelDirection ) {
//            minorTickLabelDirection = newDirection;
//
//            [self updateMinorTickLabelOffsets];
//            [self updateMinorTickLabels];
//        }
//    }
//
//    -(void)setGridLinesRange:(nullable CPTPlotRange *)newRange
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
//    -(void)setVisibleRange:(nullable CPTPlotRange *)newRange
//    {
//        if ( newRange != visibleRange ) {
//            visibleRange      = [newRange copy];
//            self.needsRelabel = YES;
//        }
//    }
//
//    -(void)setVisibleAxisRange:(nullable CPTPlotRange *)newRange
//    {
//        if ( newRange != visibleAxisRange ) {
//            visibleAxisRange  = [newRange copy];
//            self.needsRelabel = YES;
//        }
//    }
//
//    -(void)setSeparateLayers:(BOOL)newSeparateLayers
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
//    -(void)setMinorGridLines:(nullable CPTGridLines *)newGridLines
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
//                gridLines.major = NO;
//                gridLines.axis  = self;
//
//                CPTPlotArea *thePlotArea = self.plotArea;
//                [thePlotArea.minorGridLineGroup insertSublayer:gridLines atIndex:[thePlotArea sublayerIndexForAxis:self layerType:CPTGraphLayerTypeMinorGridLines]];
//            }
//        }
//    }
//
//    -(void)setMajorGridLines:(nullable CPTGridLines *)newGridLines
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
//                gridLines.major = YES;
//                gridLines.axis  = self;
//
//                CPTPlotArea *thePlotArea = self.plotArea;
//                [thePlotArea.majorGridLineGroup insertSublayer:gridLines atIndex:[thePlotArea sublayerIndexForAxis:self layerType:CPTGraphLayerTypeMajorGridLines]];
//            }
//        }
//    }
//
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
    func setHidden(newHidden: Bool)
    {
        if ( newHidden != self.isHidden ) {
            super.isHidden = newHidden;
            self.setNeedsRelabel()
        }
    }
    
    func updateCustomTickLabels()
    {
//        let range = NSRange(location: 0,length: 0) //self.plotSpace.plotRangeForCoordinate(self.coordinate)
        let range = self.plotSpace.plotRangeForCoordinate(self.coordinate)

        if ( range ) {
            let theVisibleRange = self.visibleRange;
            if (( theVisibleRange ) != nil) {
                range.intersectionPlotRange(theVisibleRange)
            }

            if ( range.lengthDouble != 0.0 ) {
                let orthogonalCoordinate = CPTUtilities.shared.CPTOrthogonalCoordinate(self.coordinate)

                var direction = self.tickLabelDirection;

                if ( direction == CPTSign.none ) {
                    direction = self.tickDirection;
                }

                for label in self.axisLabels {
                    let isVisible = range.containsNumber(label.tickLocation)
                    label.contentLayer.hidden = !isVisible;
                    if ( isVisible == true) {
                        let tickBasePoint = self.viewPointForCoordinateValue(coordinateValue: label.tickLocation)
                        label.positionRelativeToViewPoint(tickBasePoint, forCoordinate:orthogonalCoordinate, inDirection:direction)
                    }
                }

                for label in self.minorTickAxisLabels {
                    let isVisible = range.containsNumber(label.tickLocation)
                    label.contentLayer.hidden = !isVisible
                    if ( isVisible == true) {
                        let tickBasePoint = self.viewPointForCoordinateValue(coordinateValue: label.tickLocation)
                        label.positionRelativeToViewPoint(tickBasePoint, forCoordinate:orthogonalCoordinate, inDirection:direction)
                    }
                }
            }
        }
    }
//
//    -(void)updateMajorTickLabelOffsets
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
//    -(void)updateMinorTickLabelOffsets
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
//    -(void)updateMajorTickLabels
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
    func updateMinorTickLabels() {
        let orthogonalCoordinate = CPTOrthogonalCoordinate(coordinate)

        var direction = minorTickLabelDirection

        if direction == CPTSign.none {
            direction = tickDirection
        }

        for label in minorTickAxisLabels {
            let tickBasePoint = viewPoint(forCoordinateValue: label.tickLocation)
            label.positionRelative(toViewPoint: tickBasePoint, for: orthogonalCoordinate, inDirection: direction)
        }
    }
}
