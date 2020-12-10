 //
//  CPTLegend.swift
//  corePlot
//
//  Created by thierryH24 on 13/11/2020.
//

import AppKit
 
 
 
 enum CPTLegendSwatchLayout : Int {
     case left ///< Lay out the swatch to the left side of the title.
     case right ///< Lay out the swatch to the right side of the title.
     case top ///< Lay out the swatch above the title.
     case bottom ///< Lay out the swatch below the title.
 }

 
 @objc public protocol CPTLegendDelegate: CPTLayerDelegate {


    func legend( legend: CPTLegend, fillForEntryAtIndex:Int, forPlot plot: CPTPlot) -> CPTFill
    
    func legend(legend: CPTLegend, fillForSwatchAtIndex:Int,idx forPlot: CPTPlot)-> CPTFill
    func legend( legend: CPTLegend, lineStyleForSwatchAtIndex:Int, forPlot: CPTPlot) ->CPTLineStyle
    
    func legend( legend: CPTLegend, shouldDrawSwatchAtIndex:Int, forPlot: CPTPlot, inRect:CGRect, inContext: CGContext)->Bool
    func legend( legend: CPTLegend, legendEntryForPlot plot: CPTPlot, wasSelectedAtIndex:Int)
    func legend( legend: CPTLegend, legendEntryForPlot plot: CPTPlot, wasSelectedAtIndex:Int, withEvent: CPTNativeEvent)
    func legend( legend: CPTLegend, legendEntryForPlot plot: CPTPlot, touchDownAtIndex:Int)
    
    func legend( legend: CPTLegend, legendEntryForPlot plot: CPTPlot, touchDownAtIndex:Int, withEvent:CPTNativeEvent )
    func legend( legend: CPTLegend, legendEntryForPlot plot: CPTPlot, touchUpAtIndex: Int)
    func legend( legend: CPTLegend, legendEntryForPlot plot: CPTPlot, touchUpAtIndex:Int, withEvent: CPTNativeEvent)
}
    
 public class CPTLegend: CPTBorderedLayer {
    
    
    var textStyle = CPTTextStyle()
    var swatchSize = CGSize()
    var swatchBorderLineStyle = CPTLineStyle()
    var swatchCornerRadius = CGFloat(0)
    var swatchFill = CPTFill()
    
    var entryBorderLineStyle = CPTLineStyle()
    var entryCornerRadius = CGFloat(0)
    var entryFill = CPTFill()
    var entryPaddingLeft  = CGFloat(0)
    var entryPaddingTop  = CGFloat(0)
    var entryPaddingRight = CGFloat(0)
    var entryPaddingBottom = CGFloat(0)
    
    // @name Layout
    var layoutChanged = false
    var numberOfRows = 0
    var numberOfColumns = 0
    var equalRows = false
    var equalColumns = false;
    var rowHeights  = [Int]()
    var rowHeightsThatFit  = [Int]()
    var columnWidths = CGFloat(0)
    var columnWidthsThatFit = [Int]()
    var columnMargin = CGFloat(0)
    var rowMargin = CGFloat(0)
    var titleOffset = CGFloat(0)
    var swatchLayout = CPTLegendSwatchLayout(rawValue: 0)
    
    
    var plots = [CPTPlot]()
    var legendEntries [LegendEntry]()Array
    var rowHeightsThatFit = [CGFLoat]()
    var columnWidthsThatFit = [CGFLoat]()
    var layoutChanged= false
    var pointingDeviceDownEntry : CPTLegendEntry


//
//    #pragma mark -
// MARK: Factory Methods
//
//    /** @brief Creates and returns a new CPTLegend instance with legend entries for each plot in the given array.
//     *  @param newPlots An array of plots.
//     *  @return A new CPTLegend instance.
//     **/
//    +(nonnull instancetype)legendWithPlots:(nullable CPTPlotArray *)newPlots
//    {
//        return [[self alloc] initWithPlots:newPlots];
//    }
//
//    /** @brief Creates and returns a new CPTLegend instance with legend entries for each plot in the given graph.
//     *  @param graph The graph.
//     *  @return A new CPTLegend instance.
//     **/
//    +(nonnull instancetype)legendWithGraph:(nullable __kindof CPTGraph *)graph
//    {
//        return [[self alloc] initWithGraph:graph];
//    }
//
//  MARK: Init/Dealloc

    init(newFrame : CGRect)
    {
        super.init(frame:newFrame) 
        plots                 = [[NSMutableArray alloc] init];
        legendEntries         = [[NSMutableArray alloc] init];
        layoutChanged         = true
        textStyle             = CPTTextStyle()
        swatchSize            = CGSize()
        swatchBorderLineStyle = nil;
        swatchCornerRadius    = CGFloat(0.0);
        swatchFill            = nil;
        entryBorderLineStyle  = nil;
        entryCornerRadius     = CGFloat(0.0);
        entryFill             = nil;
        entryPaddingLeft      = CGFloat(0.0);
        entryPaddingTop       = CGFloat(0.0);
        entryPaddingRight     = CGFloat(0.0);
        entryPaddingBottom    = CGFloat(0.0);
        numberOfRows          = 0;
        numberOfColumns       = 0;
        equalRows             = true
        equalColumns          = NO;
        rowHeights            = nil;
        rowHeightsThatFit     = nil;
        columnWidths          = nil;
        columnWidthsThatFit   = nil;
        columnMargin          = CGFloat(10.0);
        rowMargin             = CGFloat(5.0);
        titleOffset           = CGFloat(5.0);
        swatchLayout          = CPTLegendSwatchLayoutLeft;
        
        pointingDeviceDownEntry = nil;
        
        self.paddingLeft   = CGFloat(5.0);
        self.paddingTop    = CGFloat(5.0);
        self.paddingRight  = CGFloat(5.0);
        self.paddingBottom = CGFloat(5.0);
        
        self.needsDisplayOnBoundsChange = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    return self;
 }
//
//    /// @}
//
//    /** @brief Initializes a newly allocated CPTLegend object and adds legend entries for each plot in the given array.
//     *  @param newPlots An array of plots.
//     *  @return The initialized CPTLegend object.
//     **/
//    -(nonnull instancetype)initWithPlots:(nullable CPTPlotArray *)newPlots
//    {
//        if ((self = [self initWithFrame:CGRectZero])) {
//            for ( CPTPlot *plot in newPlots ) {
//                [self addPlot:plot];
//            }
//        }
//        return self;
//    }
//
//    /** @brief Initializes a newly allocated CPTLegend object and adds legend entries for each plot in the given graph.
//     *  @param graph A graph.
//     *  @return The initialized CPTLegend object.
//     **/
//    -(nonnull instancetype)initWithGraph:(nullable __kindof CPTGraph *)graph
//    {
//        if ((self = [self initWithFrame:CGRectZero])) {
//            for ( CPTPlot *plot in [graph allPlots] ) {
//                [self addPlot:plot];
//            }
//        }
//        return self;
//    }
//
//    /// @cond
//
    init (layer: CP         TLayer)
    {
        super.init(layer:layer)
        let theLayer = CPTLegend(layer:CPTLayer)
        
        plots                 = theLayer->plots
        legendEntries         = theLayer.legendEntries;
        layoutChanged         = theLayer.layoutChanged;
        textStyle             = theLayer.textStyle;
        swatchSize            = theLayer.swatchSize;
        swatchBorderLineStyle = theLayer.swatchBorderLineStyle;
        swatchCornerRadius    = theLayer.swatchCornerRadius;
        swatchFill            = theLayer.swatchFill;
        entryBorderLineStyle  = theLayer.entryBorderLineStyle;
        entryCornerRadius     = theLayer.entryCornerRadius;
        entryFill             = theLayer.entryFill;
        entryPaddingLeft      = theLayer.entryPaddingLeft;
        entryPaddingTop       = theLayer.entryPaddingTop;
        entryPaddingRight     = theLayer.entryPaddingRight;
        entryPaddingBottom    = theLayer.entryPaddingBottom;
        numberOfRows          = theLayer.numberOfRows;
        numberOfColumns       = theLayer.numberOfColumns;
        equalRows             = theLayer.equalRows;
        equalColumns          = theLayer.equalColumns;
        rowHeights            = theLayer.rowHeights;
        rowHeightsThatFit     = theLayer.rowHeightsThatFit;
        columnWidths          = theLayer.columnWidths;
        columnWidthsThatFit   = theLayer.columnWidthsThatFit;
        columnMargin          = theLayer.columnMargin;
        rowMargin             = theLayer.rowMargin;
        titleOffset           = theLayer.titleOffset;
        swatchLayout          = theLayer.swatchLayout;
        
        pointingDeviceDownEntry = theLayer.pointingDeviceDownEntry;
    }
}
//




// MARK: Animation
//
//    /// @cond
//
//    +(BOOL)needsDisplayForKey:(nonnull NSString *)aKey
//    {
//        static NSSet<NSString *> *keys   = nil;
//        static dispatch_once_t onceToken = 0;
//
//        dispatch_once(&onceToken, ^{
//            keys = [NSSet setWithArray:@[@"swatchSize",
//                                         @"swatchCornerRadius"]];
//        });
//
//        if ( [keys containsObject:aKey] ) {
//            return true
//        }
//        else {
//            return [super needsDisplayForKey:aKey];
//        }
//    }
//
//    /// @endcond
//
//    #pragma mark -
 // MARK: LAYOUT
//
//    /**
//     *  @brief Marks the receiver as needing to update the layout of its legend entries.
//     **/
//    func )setLayoutChanged
//    {
//        self.layoutChanged = true
//    }
//
//    /// @cond
//
//    func layoutSublayers
//    {
//        [self recalculateLayout];
//        [super layoutSublayers];
//    }
//
//    func recalculateLayout
//    {
//        if ( !self.layoutChanged ) {
//            return;
//        }
//
//        BOOL isHorizontalLayout;
//
//        switch ( self.swatchLayout ) {
//            case CPTLegendSwatchLayoutLeft:
//            case CPTLegendSwatchLayoutRight:
//                isHorizontalLayout = true
//                break;
//
//            case CPTLegendSwatchLayoutTop:
//            case CPTLegendSwatchLayoutBottom:
//                isHorizontalLayout = NO;
//                break;
//        }
//
//        // compute the number of rows and columns needed to hold the legend entries
//        NSUInteger rowCount           = self.numberOfRows;
//        NSUInteger columnCount        = self.numberOfColumns;
//        NSUInteger desiredRowCount    = rowCount;
//        NSUInteger desiredColumnCount = columnCount;
//
//        NSUInteger legendEntryCount = self.legendEntries.count;
//
//        if ((rowCount == 0) && (columnCount == 0)) {
//            rowCount    = (NSUInteger)lrint(sqrt((double)legendEntryCount));
//            columnCount = rowCount;
//            if ( rowCount * columnCount < legendEntryCount ) {
//                columnCount++;
//            }
//            if ( rowCount * columnCount < legendEntryCount ) {
//                rowCount++;
//            }
//        }
//        else if ((rowCount == 0) && (columnCount > 0)) {
//            rowCount = legendEntryCount / columnCount;
//            if ( legendEntryCount % columnCount ) {
//                rowCount++;
//            }
//        }
//        else if ((rowCount > 0) && (columnCount == 0)) {
//            columnCount = legendEntryCount / rowCount;
//            if ( legendEntryCount % rowCount ) {
//                columnCount++;
//            }
//        }
//
//        // compute row heights and column widths
//        NSUInteger row                      = 0;
//        NSUInteger col                      = 0;
//        CGFloat *maxTitleHeight             = calloc(rowCount, sizeof(CGFloat));
//        CGFloat *maxTitleWidth              = calloc(columnCount, sizeof(CGFloat));
//        CGSize theSwatchSize                = self.swatchSize;
//        CPTNumberArray *desiredRowHeights   = self.rowHeights;
//        CPTNumberArray *desiredColumnWidths = self.columnWidths;
//        Class numberClass                   = [NSNumber class];
//
//        for ( CPTLegendEntry *legendEntry in self.legendEntries ) {
//            legendEntry.row    = row;
//            legendEntry.column = col;
//            CGSize titleSize = legendEntry.titleSize;
//
//            if ((desiredRowCount == 0) || (row < desiredRowCount)) {
//                maxTitleHeight[row] = MAX(maxTitleHeight[row], titleSize.height);
//                if ( isHorizontalLayout ) {
//                    maxTitleHeight[row] = MAX(maxTitleHeight[row], theSwatchSize.height);
//                }
//
//                if ( row < desiredRowHeights.count ) {
//                    id desiredRowHeight = desiredRowHeights[row];
//                    if ( [desiredRowHeight isKindOfClass:numberClass] ) {
//                        maxTitleHeight[row] = MAX(maxTitleHeight[row], [(NSNumber *) desiredRowHeight cgFloatValue]);
//                    }
//                }
//            }
//
//            if ((desiredColumnCount == 0) || (col < desiredColumnCount)) {
//                maxTitleWidth[col] = MAX(maxTitleWidth[col], titleSize.width);
//                if ( !isHorizontalLayout ) {
//                    maxTitleWidth[col] = MAX(maxTitleWidth[col], theSwatchSize.width);
//                }
//
//                if ( col < desiredColumnWidths.count ) {
//                    id desiredColumnWidth = desiredColumnWidths[col];
//                    if ( [desiredColumnWidth isKindOfClass:numberClass] ) {
//                        maxTitleWidth[col] = MAX(maxTitleWidth[col], [(NSNumber *) desiredColumnWidth cgFloatValue]);
//                    }
//                }
//            }
//
//            col++;
//            if ( col >= columnCount ) {
//                row++;
//                col = 0;
//                if ( row >= rowCount ) {
//                    break;
//                }
//            }
//        }
//
//        // save row heights and column widths
//        CPTMutableNumberArray *maxRowHeights = [[NSMutableArray alloc] initWithCapacity:rowCount];
//
//        for ( NSUInteger i = 0; i < rowCount; i++ ) {
//            [maxRowHeights addObject:@(maxTitleHeight[i])];
//        }
//        self.rowHeightsThatFit = maxRowHeights;
//
//        CPTMutableNumberArray *maxColumnWidths = [[NSMutableArray alloc] initWithCapacity:columnCount];
//
//        for ( NSUInteger i = 0; i < columnCount; i++ ) {
//            [maxColumnWidths addObject:@(maxTitleWidth[i])];
//        }
//        self.columnWidthsThatFit = maxColumnWidths;
//
//        free(maxTitleHeight);
//        free(maxTitleWidth);
//
//        // compute the size needed to contain all legend entries, margins, and padding
//        CGSize legendSize = CPTSizeMake(self.paddingLeft + self.paddingRight, self.paddingTop + self.paddingBottom);
//
//        CGFloat lineWidth = self.borderLineStyle.lineWidth;
//
//        legendSize.width  += lineWidth;
//        legendSize.height += lineWidth;
//
//        if ( self.equalColumns ) {
//            NSNumber *maxWidth = [maxColumnWidths valueForKeyPath:@"@max.doubleValue"];
//            legendSize.width += [maxWidth cgFloatValue] * columnCount;
//        }
//        else {
//            for ( NSNumber *width in maxColumnWidths ) {
//                legendSize.width += [width cgFloatValue];
//            }
//        }
//        if ( columnCount > 0 ) {
//            legendSize.width += ((self.entryPaddingLeft + self.entryPaddingRight) * columnCount) + (self.columnMargin * (columnCount - 1));
//            if ( isHorizontalLayout ) {
//                legendSize.width += (theSwatchSize.width + self.titleOffset) * columnCount;
//            }
//        }
//
//        NSUInteger rows = row;
//
//        if ( col ) {
//            rows++;
//        }
//        for ( NSNumber *height in maxRowHeights ) {
//            legendSize.height += [height cgFloatValue];
//        }
//        if ( rows > 0 ) {
//            legendSize.height += ((self.entryPaddingBottom + self.entryPaddingTop) * rowCount) + (self.rowMargin * (rows - 1));
//            if ( !isHorizontalLayout ) {
//                legendSize.height += (theSwatchSize.height + self.titleOffset) * rowCount;
//            }
//        }
//
//        self.bounds = CPTRectMake(0.0, 0.0, ceil(legendSize.width), ceil(legendSize.height));
//        [self pixelAlign];
//
//        self.layoutChanged = NO;
//    }
//
/
//  MARK: - Plots
//
//    /** @brief All plots associated with the legend.
//     *  @return An array of all plots associated with the legend.
//     **/
//    -(nonnull CPTPlotArray *)allPlots
//    {
//        return [NSArray arrayWithArray:self.plots];
//    }
//
//    /** @brief Gets the plot at the given index in the plot array.
//     *  @param idx An index within the bounds of the plot array.
//     *  @return The plot at the given index.
//     **/
//    -(nullable CPTPlot *)plotAtIndex:(NSUInteger)idx
//    {
//        if ( idx < self.plots.count ) {
//            return (self.plots)[idx];
//        }
//        else {
//            return nil;
//        }
//    }
//
//    /** @brief Gets the plot with the given identifier from the plot array.
//     *  @param identifier A plot identifier.
//     *  @return The plot with the given identifier or nil if it was not found.
//     **/
//    -(nullable CPTPlot *)plotWithIdentifier:(nullable id<NSCopying>)identifier
//    {
//        for ( CPTPlot *plot in self.plots ) {
//            if ( [plot.identifier isEqual:identifier] ) {
//                return plot;
//            }
//        }
//        return nil;
//    }
//
// MARK:  Organizing Plots
//
//    /** @brief Add a plot to the legend.
//     *  @param plot The plot.
//     **/
//    func addPlot:(nonnull CPTPlot *)plot
//    {
//        if ( [plot isKindOfClass:[CPTPlot class]] ) {
//            [self.plots addObject:plot];
//            self.layoutChanged = true
//
//            CPTMutableLegendEntryArray *theLegendEntries = self.legendEntries;
//            CPTTextStyle *theTextStyle                   = self.textStyle;
//            NSUInteger numberOfLegendEntries             = [plot numberOfLegendEntries];
//            for ( NSUInteger i = 0; i < numberOfLegendEntries; i++ ) {
//                NSString *newTitle = [plot titleForLegendEntryAtIndex:i];
//                if ( newTitle ) {
//                    CPTLegendEntry *newLegendEntry = [[CPTLegendEntry alloc] init];
//                    newLegendEntry.plot      = plot;
//                    newLegendEntry.index     = i;
//                    newLegendEntry.textStyle = theTextStyle;
//                    [theLegendEntries addObject:newLegendEntry];
//                }
//            }
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(legendNeedsRedraw:) name:CPTLegendNeedsRedrawForPlotNotification object:plot];
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(legendNeedsLayout:) name:CPTLegendNeedsLayoutForPlotNotification object:plot];
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(legendNeedsReloadEntries:) name:CPTLegendNeedsReloadEntriesForPlotNotification object:plot];
//        }
//    }
//
//    /** @brief Add a plot to the legend at the given index in the plot array.
//     *  @param plot The plot.
//     *  @param idx An index within the bounds of the plot array.
//     **/
//    func insertPlot:(nonnull CPTPlot *)plot atIndex:(NSUInteger)idx
//    {
//        if ( [plot isKindOfClass:[CPTPlot class]] ) {
//            CPTMutablePlotArray *thePlots = self.plots;
//            NSAssert(idx <= thePlots.count, @"index greater than the number of plots");
//
//            CPTMutableLegendEntryArray *theLegendEntries = self.legendEntries;
//            NSUInteger legendEntryIndex                  = 0;
//            if ( idx == thePlots.count ) {
//                legendEntryIndex = theLegendEntries.count;
//            }
//            else {
//                CPTPlot *lastPlot = thePlots[idx];
//                for ( CPTLegendEntry *legendEntry in theLegendEntries ) {
//                    if ( legendEntry.plot == lastPlot ) {
//                        break;
//                    }
//                    legendEntryIndex++;
//                }
//            }
//
//            [thePlots insertObject:plot atIndex:idx];
//            self.layoutChanged = true
//
//            CPTTextStyle *theTextStyle       = self.textStyle;
//            NSUInteger numberOfLegendEntries = [plot numberOfLegendEntries];
//            for ( NSUInteger i = 0; i < numberOfLegendEntries; i++ ) {
//                NSString *newTitle = [plot titleForLegendEntryAtIndex:i];
//                if ( newTitle ) {
//                    CPTLegendEntry *newLegendEntry = [[CPTLegendEntry alloc] init];
//                    newLegendEntry.plot      = plot;
//                    newLegendEntry.index     = i;
//                    newLegendEntry.textStyle = theTextStyle;
//                    [theLegendEntries insertObject:newLegendEntry atIndex:legendEntryIndex++];
//                }
//            }
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(legendNeedsRedraw:) name:CPTLegendNeedsRedrawForPlotNotification object:plot];
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(legendNeedsLayout:) name:CPTLegendNeedsLayoutForPlotNotification object:plot];
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(legendNeedsReloadEntries:) name:CPTLegendNeedsReloadEntriesForPlotNotification object:plot];
//        }
//    }
//
//    /** @brief Remove a plot from the legend.
//     *  @param plot The plot to remove.
//     **/
//    func removePlot:(nonnull CPTPlot *)plot
//    {
//        if ( [self.plots containsObject:plot] ) {
//            [self.plots removeObjectIdenticalTo:plot];
//            [self removeLegendEntriesForPlot:plot];
//            self.layoutChanged = true
//            [[NSNotificationCenter defaultCenter] removeObserver:self name:CPTLegendNeedsRedrawForPlotNotification object:plot];
//            [[NSNotificationCenter defaultCenter] removeObserver:self name:CPTLegendNeedsLayoutForPlotNotification object:plot];
//            [[NSNotificationCenter defaultCenter] removeObserver:self name:CPTLegendNeedsReloadEntriesForPlotNotification object:plot];
//        }
//        else {
//            [NSException raise:CPTException format:@"Tried to remove CPTPlot which did not exist."];
//        }
//    }
//
//    /** @brief Remove a plot from the legend.
//     *  @param identifier The identifier of the plot to remove.
//     **/
//    func removePlotWithIdentifier:(nullable id<NSCopying>)identifier
//    {
//        CPTPlot *plotToRemove = [self plotWithIdentifier:identifier];
//
//        if ( plotToRemove ) {
//            [self.plots removeObjectIdenticalTo:plotToRemove];
//            [self removeLegendEntriesForPlot:plotToRemove];
//            self.layoutChanged = true
//            [[NSNotificationCenter defaultCenter] removeObserver:self name:CPTLegendNeedsRedrawForPlotNotification object:plotToRemove];
//            [[NSNotificationCenter defaultCenter] removeObserver:self name:CPTLegendNeedsLayoutForPlotNotification object:plotToRemove];
//            [[NSNotificationCenter defaultCenter] removeObserver:self name:CPTLegendNeedsReloadEntriesForPlotNotification object:plotToRemove];
//        }
//    }
//
//    /// @cond
//
//    /** @internal
//     *  @brief Remove all legend entries for the given plot from the legend.
//     *  @param plot The plot.
//     **/
//    func removeLegendEntriesForPlot:(nonnull CPTPlot *)plot
//    {
//        CPTMutableLegendEntryArray *theLegendEntries = self.legendEntries;
//        CPTMutableLegendEntryArray *entriesToRemove  = [[NSMutableArray alloc] init];
//
//        for ( CPTLegendEntry *legendEntry in theLegendEntries ) {
//            if ( legendEntry.plot == plot ) {
//                [entriesToRemove addObject:legendEntry];
//            }
//        }
//        [theLegendEntries removeObjectsInArray:entriesToRemove];
//    }
//
// MARK: Notifications
//
//    /// @cond
//
//    func legendNeedsRedraw:(nonnull NSNotification *__unused)notif
//    {
//        [self setNeedsDisplay];
//    }
//
//    func legendNeedsLayout:(nonnull NSNotification *__unused)notif
//    {
//        self.layoutChanged = true
//        [self setNeedsDisplay];
//    }
//
//    func legendNeedsReloadEntries:(nonnull NSNotification *)notif
//    {
//        CPTPlot *thePlot = (CPTPlot *)notif.object;
//
//        CPTMutableLegendEntryArray *theLegendEntries = self.legendEntries;
//
//        NSUInteger legendEntryIndex = 0;
//
//        for ( CPTLegendEntry *legendEntry in theLegendEntries ) {
//            if ( legendEntry.plot == thePlot ) {
//                break;
//            }
//            legendEntryIndex++;
//        }
//
//        [self removeLegendEntriesForPlot:thePlot];
//
//        CPTTextStyle *theTextStyle       = self.textStyle;
//        NSUInteger numberOfLegendEntries = [thePlot numberOfLegendEntries];
//
//        for ( NSUInteger i = 0; i < numberOfLegendEntries; i++ ) {
//            NSString *newTitle = [thePlot titleForLegendEntryAtIndex:i];
//            if ( newTitle ) {
//                CPTLegendEntry *newLegendEntry = [[CPTLegendEntry alloc] init];
//                newLegendEntry.plot      = thePlot;
//                newLegendEntry.index     = i;
//                newLegendEntry.textStyle = theTextStyle;
//                [theLegendEntries insertObject:newLegendEntry atIndex:legendEntryIndex++];
//            }
//        }
//        self.layoutChanged = true
//    }
//
//    /// @endcond
//
//    #pragma mark -
//    #pragma mark Responder Chain and User interaction
//
//    /// @cond
//
//    func legendEntryForInteractionPoint:(CGPoint)interactionPoint row:(nonnull NSUInteger *)row col:(nonnull NSUInteger *)col
//    {
//        // Convert the interaction point to the local coordinate system
//        CPTGraph *theGraph = self.graph;
//
//        if ( theGraph ) {
//            interactionPoint = [self convertPoint:interactionPoint fromLayer:theGraph];
//        }
//        else {
//            for ( CPTPlot *plot in self.plots ) {
//                CPTGraph *plotGraph = plot.graph;
//
//                if ( plotGraph ) {
//                    interactionPoint = [self convertPoint:interactionPoint fromLayer:plotGraph];
//                    break;
//                }
//            }
//        }
//
//        // Update layout if needed
//        [self recalculateLayout];
//
//        // Hit test the legend entries
//        CGFloat rMargin = self.rowMargin;
//        CGFloat cMargin = self.columnMargin;
//
//        CGFloat swatchWidth = self.swatchSize.width + self.titleOffset;
//
//        CGFloat padHorizontal = self.entryPaddingLeft + self.entryPaddingRight;
//        CGFloat padVertical   = self.entryPaddingTop + self.entryPaddingBottom;
//
//        // Rows
//        CGFloat position = CGRectGetMaxY(self.bounds) - self.paddingTop;
//
//        NSUInteger i = 0;
//
//        for ( NSNumber *height in self.rowHeightsThatFit ) {
//            CGFloat rowHeight = height.cgFloatValue + padVertical;
//            if ((interactionPoint.y <= position) && (interactionPoint.y >= position - rowHeight)) {
//                *row = i;
//                break;
//            }
//
//            position -= rowHeight + rMargin;
//            i++;
//        }
//
//        // Columns
//        position = self.paddingLeft;
//
//        i = 0;
//
//        for ( NSNumber *width in self.columnWidthsThatFit ) {
//            CGFloat colWidth = width.cgFloatValue + swatchWidth + padHorizontal;
//            if ((interactionPoint.x >= position) && (interactionPoint.x <= position + colWidth)) {
//                *col = i;
//                break;
//            }
//
//            position += colWidth + cMargin;
//            i++;
//        }
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
//     *  If this legend has a delegate that responds to the
//     *  @link CPTLegendDelegate::legend:legendEntryForPlot:touchDownAtIndex: -legend:legendEntryForPlot:touchDownAtIndex: @endlink or
//     *  @link CPTLegendDelegate::legend:legendEntryForPlot:touchDownAtIndex:withEvent: -legend:legendEntryForPlot:touchDownAtIndex:withEvent: @endlink
//     *  methods, the legend entries are searched to find the plot and index of the one whose swatch or title contains the @par{interactionPoint}.
//     *  The delegate method will be called and this method returns @YES if the @par{interactionPoint} is within a legend entry.
//     *  This method returns @NO if the @par{interactionPoint} is too far away from all of the legend entries.
//     *
//     *  @param event The OS event.
//     *  @param interactionPoint The coordinates of the interaction.
//     *  @return Whether the event was handled or not.
//     **/
//    -(BOOL)pointingDeviceDownEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
//    {
//        if ( self.hidden || (self.plots.count == 0)) {
//            return NO;
//        }
//
//        id<CPTLegendDelegate> theDelegate = (id<CPTLegendDelegate>)self.delegate;
//
//        if ( [theDelegate respondsToSelector:@selector(legend:legendEntryForPlot:touchDownAtIndex:)] ||
//             [theDelegate respondsToSelector:@selector(legend:legendEntryForPlot:touchDownAtIndex:withEvent:)] ||
//             [theDelegate respondsToSelector:@selector(legend:legendEntryForPlot:wasSelectedAtIndex:)] ||
//             [theDelegate respondsToSelector:@selector(legend:legendEntryForPlot:wasSelectedAtIndex:withEvent:)] ) {
//            NSUInteger row = NSNotFound;
//            NSUInteger col = NSNotFound;
//            [self legendEntryForInteractionPoint:interactionPoint row:&row col:&col];
//
//            // Notify the delegate if we found a hit
//            if ((row != NSNotFound) && (col != NSNotFound)) {
//                for ( CPTLegendEntry *legendEntry in self.legendEntries ) {
//                    if ((legendEntry.row == row) && (legendEntry.column == col)) {
//                        self.pointingDeviceDownEntry = legendEntry;
//
//                        CPTPlot *legendPlot = legendEntry.plot;
//                        BOOL handled        = NO;
//
//                        if ( [theDelegate respondsToSelector:@selector(legend:legendEntryForPlot:touchDownAtIndex:)] ) {
//                            handled = true
//                            [theDelegate legend:self legendEntryForPlot:legendPlot touchDownAtIndex:legendEntry.index];
//                        }
//                        if ( [theDelegate respondsToSelector:@selector(legend:legendEntryForPlot:touchDownAtIndex:withEvent:)] ) {
//                            handled = true
//                            [theDelegate legend:self legendEntryForPlot:legendPlot touchDownAtIndex:legendEntry.index withEvent:event];
//                        }
//
//                        if ( handled ) {
//                            return true
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
//     *  If this legend has a delegate that responds to the
//     *  @link CPTLegendDelegate::legend:legendEntryForPlot:touchUpAtIndex: -legend:legendEntryForPlot:touchUpAtIndex: @endlink or
//     *  @link CPTLegendDelegate::legend:legendEntryForPlot:touchUpAtIndex:withEvent: -legend:legendEntryForPlot:touchUpAtIndex:withEvent: @endlink
//     *  methods, the legend entries are searched to find the plot and index of the one whose swatch or title contains the @par{interactionPoint}.
//     *  The delegate method will be called and this method returns @YES if the @par{interactionPoint} is within a legend entry.
//     *  This method returns @NO if the @par{interactionPoint} is too far away from all of the legend entries.
//     *
//     *  If the bar being released is the same as the one that was pressed (see
//     *  @link CPTLegend::pointingDeviceDownEvent:atPoint: -pointingDeviceDownEvent:atPoint: @endlink), if the delegate responds to the
//     *  @link CPTLegendDelegate::legend:legendEntryForPlot:wasSelectedAtIndex: -legend:legendEntryForPlot:wasSelectedAtIndex: @endlink and/or
//     *  @link CPTLegendDelegate::legend:legendEntryForPlot:wasSelectedAtIndex:withEvent: -legend:legendEntryForPlot:wasSelectedAtIndex:withEvent: @endlink
//     *  methods, these will be called.
//     *
//     *  @param event The OS event.
//     *  @param interactionPoint The coordinates of the interaction.
//     *  @return Whether the event was handled or not.
//     **/
//    -(BOOL)pointingDeviceUpEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
//    {
//        CPTLegendEntry *selectedDownEntry = self.pointingDeviceDownEntry;
//
//        self.pointingDeviceDownEntry = nil;
//
//        if ( self.hidden || (self.plots.count == 0)) {
//            return NO;
//        }
//
//        theDelegate = self.delegate
//
//        if ( [theDelegate respondsToSelector:@selector(legend:legendEntryForPlot:touchUpAtIndex:)] ||
//             [theDelegate respondsToSelector:@selector(legend:legendEntryForPlot:touchUpAtIndex:withEvent:)] ||
//             [theDelegate respondsToSelector:@selector(legend:legendEntryForPlot:wasSelectedAtIndex:)] ||
//             [theDelegate respondsToSelector:@selector(legend:legendEntryForPlot:wasSelectedAtIndex:withEvent:)] ) {
//            NSUInteger row = NSNotFound;
//            NSUInteger col = NSNotFound;
//            [self legendEntryForInteractionPoint:interactionPoint row:&row col:&col];
//
//            // Notify the delegate if we found a hit
//            if ((row != NSNotFound) && (col != NSNotFound)) {
//                for ( CPTLegendEntry *legendEntry in self.legendEntries ) {
//                    if ((legendEntry.row == row) && (legendEntry.column == col)) {
//                        BOOL handled = NO;
//
//                        CPTPlot *entryPlot = legendEntry.plot;
//
//                        if ( [theDelegate respondsToSelector:@selector(legend:legendEntryForPlot:touchUpAtIndex:)] ) {
//                            handled = true
//                            [theDelegate legend:self legendEntryForPlot:entryPlot touchUpAtIndex:legendEntry.index];
//                        }
//                        if ( [theDelegate respondsToSelector:@selector(legend:legendEntryForPlot:touchUpAtIndex:withEvent:)] ) {
//                            handled = true
//                            [theDelegate legend:self legendEntryForPlot:entryPlot touchUpAtIndex:legendEntry.index withEvent:event];
//                        }
//
//                        if ( legendEntry == selectedDownEntry ) {
//                            if ( [theDelegate respondsToSelector:@selector(legend:legendEntryForPlot:wasSelectedAtIndex:)] ) {
//                                handled = true
//                                [theDelegate legend:self legendEntryForPlot:entryPlot wasSelectedAtIndex:legendEntry.index];
//                            }
//
//                            if ( [theDelegate respondsToSelector:@selector(legend:legendEntryForPlot:wasSelectedAtIndex:withEvent:)] ) {
//                                handled = true
//                                [theDelegate legend:self legendEntryForPlot:entryPlot wasSelectedAtIndex:legendEntry.index withEvent:event];
//                            }
//                        }
//
//                        if ( handled ) {
//                            return true
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
//  MARK: Description
//
//    /// @cond
//
//    -(nullable NSString *)description
//    {
//        return [NSString stringWithFormat:@"<%@ for plots %@>", super.description, self.plots];
//    }
//
//    /// @endcond
//
//    #pragma mark Accessors
//
//    /// @cond
//
//    func setTextStyle(newTextStyle: CPTTextStyle)
//    {
//        if ( newTextStyle != textStyle ) {
//            textStyle = newTextStyle
//            
//            self.legendEntries makeObjectsPerformSelector:@selector(setTextStyle:) withObject:textStyle];
//            
//            for legendEntry in self.legendEntries {
//                legendEntry.setTextStyle(w)
//            }
//            
//            self.layoutChanged = true
//        }
//    }
    
 var  _swatchSize = CGSize()
 var swatchSize : CGSize {
    get {
        var theSwatchSize = _swatchSize
        
        if theSwatchSize.equalTo( CGSize()) {
            let theTextStyle = textStyle
            let fontSize        = theTextStyle.fontSize
            if ( fontSize > CGFloat(0.0)) {
                fontSize     *= CGFloat(1.5)
                fontSize      = round(fontSize)
                theSwatchSize = CGSize(fontSize, fontSize)
            }
            else {
                theSwatchSize = CGSize(width: 15.0, height: 15.0)
            }
        }
        return theSwatchSize
    }
    
    set {
        if ( !_swatchSize.equalTo( newValue)) {
            _swatchSize         = newValue
            layoutChanged = true
        }
        }
 }
 

    
    
//
//    func setSwatchBorderLineStyle:(nullable CPTLineStyle *)newSwatchBorderLineStyle
//    {
//        if ( newSwatchBorderLineStyle != swatchBorderLineStyle ) {
//            swatchBorderLineStyle = [newSwatchBorderLineStyle copy];
//            [self setNeedsDisplay];
//        }
//    }
//
    func setSwatchCornerRadius(newSwatchCornerRadius: CGFloat)
    {
        if ( newSwatchCornerRadius != swatchCornerRadius ) {
            swatchCornerRadius = newSwatchCornerRadius;
            [self.setNeedsDisplay];
        }
    }
//
//    func setSwatchFill:(nullable CPTFill *)newSwatchFill
//    {
//        if ( newSwatchFill != swatchFill ) {
//            swatchFill = [newSwatchFill copy];
//            [self setNeedsDisplay];
//        }
//    }
//
//    func setEntryBorderLineStyle:(nullable CPTLineStyle *)newEntryBorderLineStyle
//    {
//        if ( newEntryBorderLineStyle != entryBorderLineStyle ) {
//            entryBorderLineStyle = [newEntryBorderLineStyle copy];
//            [self setNeedsDisplay];
//        }
//    }
//
//    func setEntryCornerRadius:(CGFloat)newEntryCornerRadius
//    {
//        if ( newEntryCornerRadius != entryCornerRadius ) {
//            entryCornerRadius = newEntryCornerRadius;
//            [self setNeedsDisplay];
//        }
//    }
//
//    func setEntryFill:(nullable CPTFill *)newEntryFill
//    {
//        if ( newEntryFill != entryFill ) {
//            entryFill = [newEntryFill copy];
//            [self setNeedsDisplay];
//        }
//    }
//
//    func setEntryPaddingLeft:(CGFloat)newPadding
//    {
//        if ( newPadding != entryPaddingLeft ) {
//            entryPaddingLeft   = newPadding;
//            self.layoutChanged = true
//        }
//    }
//
//    func setEntryPaddingTop:(CGFloat)newPadding
//    {
//        if ( newPadding != entryPaddingTop ) {
//            entryPaddingTop    = newPadding;
//            self.layoutChanged = true
//        }
//    }
//
//    func setEntryPaddingRight:(CGFloat)newPadding
//    {
//        if ( newPadding != entryPaddingRight ) {
//            entryPaddingRight  = newPadding;
//            self.layoutChanged = true
//        }
//    }
//
//    func setEntryPaddingBottom:(CGFloat)newPadding
//    {
//        if ( newPadding != entryPaddingBottom ) {
//            entryPaddingBottom = newPadding;
//            self.layoutChanged = true
//        }
//    }
//
//    func setNumberOfRows:(NSUInteger)newNumberOfRows
//    {
//        if ( newNumberOfRows != numberOfRows ) {
//            numberOfRows       = newNumberOfRows;
//            self.layoutChanged = true
//        }
//    }
//
//    func setNumberOfColumns:(NSUInteger)newNumberOfColumns
//    {
//        if ( newNumberOfColumns != numberOfColumns ) {
//            numberOfColumns    = newNumberOfColumns;
//            self.layoutChanged = true
//        }
//    }
//
//    func setEqualRows:(BOOL)newEqualRows
//    {
//        if ( newEqualRows != equalRows ) {
//            equalRows          = newEqualRows;
//            self.layoutChanged = true
//        }
//    }
//
//    func setEqualColumns:(BOOL)newEqualColumns
//    {
//        if ( newEqualColumns != equalColumns ) {
//            equalColumns       = newEqualColumns;
//            self.layoutChanged = true
//        }
//    }
//
//    func setRowHeights:(nullable CPTNumberArray *)newRowHeights
//    {
//        if ( newRowHeights != rowHeights ) {
//            rowHeights         = [newRowHeights copy];
//            self.layoutChanged = true
//        }
//    }
//
//    func setColumnWidths:(nullable CPTNumberArray *)newColumnWidths
//    {
//        if ( newColumnWidths != columnWidths ) {
//            columnWidths       = [newColumnWidths copy];
//            self.layoutChanged = true
//        }
//    }
//
//    func setColumnMargin:(CGFloat)newColumnMargin
//    {
//        if ( newColumnMargin != columnMargin ) {
//            columnMargin       = newColumnMargin;
//            self.layoutChanged = true
//        }
//    }
//
//    func setRowMargin:(CGFloat)newRowMargin
//    {
//        if ( newRowMargin != rowMargin ) {
//            rowMargin          = newRowMargin;
//            self.layoutChanged = true
//        }
//    }
//
//    func setTitleOffset:(CGFloat)newTitleOffset
//    {
//        if ( newTitleOffset != titleOffset ) {
//            titleOffset        = newTitleOffset;
//            self.layoutChanged = true
//        }
//    }
//
//    func setSwatchLayout:(CPTLegendSwatchLayout)newSwatchLayout
//    {
//        if ( newSwatchLayout != swatchLayout ) {
//            swatchLayout       = newSwatchLayout;
//            self.layoutChanged = true
//        }
//    }
//
//    func setLayoutChanged:(BOOL)newLayoutChanged
//    {
//        if ( newLayoutChanged != layoutChanged ) {
//            layoutChanged = newLayoutChanged;
//            if ( newLayoutChanged ) {
//                self.rowHeightsThatFit   = nil;
//                self.columnWidthsThatFit = nil;
//                [self setNeedsLayout];
//            }
//        }
//    }
//
//    func setPaddingLeft:(CGFloat)newPadding
//    {
//        if ( newPadding != self.paddingLeft ) {
//            super.paddingLeft  = newPadding;
//            self.layoutChanged = true
//        }
//    }
//
//    func setPaddingTop:(CGFloat)newPadding
//    {
//        if ( newPadding != self.paddingTop ) {
//            super.paddingTop   = newPadding;
//            self.layoutChanged = true
//        }
//    }
//
//    func setPaddingRight:(CGFloat)newPadding
//    {
//        if ( newPadding != self.paddingRight ) {
//            super.paddingRight = newPadding;
//            self.layoutChanged = true
//        }
//    }
//
//    func setPaddingBottom:(CGFloat)newPadding
//    {
//        if ( newPadding != self.paddingBottom ) {
//            super.paddingBottom = newPadding;
//            self.layoutChanged  = true
//        }
//    }
//
//    func setBorderLineStyle:(nullable CPTLineStyle *)newLineStyle
//    {
//        CPTLineStyle *oldLineStyle = self.borderLineStyle;
//
//        if ( newLineStyle != oldLineStyle ) {
//            super.borderLineStyle = newLineStyle;
//
//            if ( newLineStyle.lineWidth != oldLineStyle.lineWidth ) {
//                self.layoutChanged = true
//            }
//        }
//    }
//
//    -(nullable CPTNumberArray *)rowHeightsThatFit
//    {
//        if ( !rowHeightsThatFit ) {
//            [self recalculateLayout];
//        }
//        return rowHeightsThatFit;
//    }
//
//    -(nullable CPTNumberArray *)columnWidthsThatFit
//    {
//        if ( !columnWidthsThatFit ) {
//            [self recalculateLayout];
//        }
//        return columnWidthsThatFit;
//    }
//
//    /// @endcond
//
//}
}
