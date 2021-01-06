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
 
 
 @objc protocol CPTLegendDelegate : CPTLayerDelegate {
    
    @objc optional func legend( legend: CPTLegend, fillForEntryAtIndex:Int, forPlot plot: CPTPlot) -> CPTFill
    @objc optional func legend( legend: CPTLegend, fillForSwatchAtIndex:Int, forPlot: CPTPlot)-> CPTFill
    
    @objc optional func legend( legend: CPTLegend, lineStyleForSwatchAtIndex:Int, forPlot: CPTPlot) -> CPTLineStyle
    
    @objc optional func legend( legend: CPTLegend, shouldDrawSwatchAtIndex:Int, forPlot: CPTPlot, inRect:CGRect, inContext: CGContext)-> Bool
    @objc optional func legend( legend: CPTLegend, legendEntryForPlot plot: CPTPlot, wasSelectedAtIndex:Int)
    @objc optional func legend( legend: CPTLegend, legendEntryForPlot plot: CPTPlot, wasSelectedAtIndex:Int, withEvent: CPTNativeEvent)
    
    @objc optional func legend( legend: CPTLegend, legendEntryForPlot plot: CPTPlot, touchDownAtIndex:Int)
    @objc optional func legend( legend: CPTLegend, legendEntryForPlot plot: CPTPlot, touchDownAtIndex:Int, withEvent: CPTNativeEvent )
    @objc optional func legend( legend: CPTLegend, legendEntryForPlot plot: CPTPlot, touchUpAtIndex: Int)
    @objc optional func legend( legend: CPTLegend, legendEntryForPlot plot: CPTPlot, touchUpAtIndex:Int, withEvent: CPTNativeEvent)
 }
 
 public class CPTLegend: CPTBorderedLayer {
    
    var _textStyle = CPTTextStyle()
    override var textStyle : CPTTextStyle {
        get {return _textStyle}
        set {_textStyle = newValue}
    }
    //    var swatchSize = CGSize()
    var swatchBorderLineStyle = CPTLineStyle()
    var swatchCornerRadius = CGFloat(0)
    var swatchFill : CPTFill?
    
    var entryBorderLineStyle = CPTLineStyle()
    var entryCornerRadius = CGFloat(0)
    var entryFill : CPTFill?
    var entryPaddingLeft  = CGFloat(0)
    var entryPaddingTop  = CGFloat(0)
    var entryPaddingRight = CGFloat(0)
    var entryPaddingBottom = CGFloat(0)
    
    // @name Layout
    var layoutChanged = false
    var numberOfRows = 0
    var numberOfColumns = 0
    var equalRows = false
    var equalColumns = false
    var rowHeights  = [CGFloat]()
    //    var rowHeightsThatFit  = [Int]()
    var columnWidths = [CGFloat]()
    //    var columnWidthsThatFit = [Int]()
    var columnMargin = CGFloat(0)
    var rowMargin = CGFloat(0)
    var titleOffset = CGFloat(0)
    var swatchLayout = CPTLegendSwatchLayout.left
    
    var plots = [CPTPlot]()
    var legendEntries = [CPTLegendEntry]()
    var pointingDeviceDownEntry : CPTLegendEntry?
    
    
    //    #pragma mark -
    // MARK: Factory Methods
    //
    //    /** @brief Creates and returns a new CPTLegend instance with legend entries for each plot in the given array.
    //     *  @param newPlots An array of plots.
    //     *  @return A new CPTLegend instance.
    //     **/
    //    class func legend(withPlots newPlots: [CPTPlot]?) -> Self {
    //        return self.init(plots: newPlots!)
    //    }
    

    //    /** @brief Creates and returns a new CPTLegend instance with legend entries for each plot in the given graph.
    //     *  @param graph The graph.
    //     *  @return A new CPTLegend instance.
    //     **/
    //    class func legend(with graph: CPTGraph?) -> Self {
    //        return self.init(graph: graph)
    //    }
    
    //
    //  MARK: Init/Dealloc
    
    init(newFrame : CGRect)
    {
        super.init(frame:newFrame) 
        plots.removeAll()
        legendEntries.removeAll()
        layoutChanged         = true
        textStyle             = CPTTextStyle()
        swatchSize            = CGSize()
        swatchBorderLineStyle = CPTLineStyle();
        swatchCornerRadius    = CGFloat(0.0);
        swatchFill            = nil;
        entryBorderLineStyle  = CPTLineStyle();
        entryCornerRadius     = CGFloat(0.0);
        entryFill             = nil;
        entryPaddingLeft      = CGFloat(0.0);
        entryPaddingTop       = CGFloat(0.0);
        entryPaddingRight     = CGFloat(0.0);
        entryPaddingBottom    = CGFloat(0.0);
        numberOfRows          = 0;
        numberOfColumns       = 0;
        equalRows             = true
        equalColumns          = false
        rowHeights.removeAll()
        columnWidths.removeAll()
        columnWidthsThatFit.removeAll()
        columnMargin          = CGFloat(10.0);
        rowMargin             = CGFloat(5.0);
        titleOffset           = CGFloat(5.0);
        swatchLayout          = .left
        
        pointingDeviceDownEntry = nil;
        
        self.paddingLeft   = CGFloat(5.0);
        self.paddingTop    = CGFloat(5.0);
        self.paddingRight  = CGFloat(5.0);
        self.paddingBottom = CGFloat(5.0);
        
        self.needsDisplayOnBoundsChange = true
    }
    
    //
    //    /// @}
    //
    //    /** @brief Initializes a newly allocated CPTLegend object and adds legend entries for each plot in the given array.
    //     *  @param newPlots An array of plots.
    //     *  @return The initialized CPTLegend object.
    //     **/
    
//    convenience init(plots newPlots: [CPTPlot]) {
//        self.init(newFrame: CGRect.zero)
//        if let newPlots = newPlots {
//            for plot in newPlots {
//                guard let plot = plot as? CPTPlot else {   continue }
//                self.add(plot)
//            }
//        }
//    }
    
    
    //    /** @brief Initializes a newly allocated CPTLegend object and adds legend entries for each plot in the given graph.
    //     *  @param graph A graph.
    //     *  @return The initialized CPTLegend object.
    //     **/
    //    -(nonnull instancetype)initWithGraph:(nullable __kindof CPTGraph *)graph
    //{
    //    if ((self = [self initWithFrame:CGRectZero])) {
    //        for ( CPTPlot *plot in [graph allPlots] ) {
    //            [self addPlot:plot];
    //        }
    //    }
    //    return self;
    //}
    //
    //    /// @cond
    //
    override init (layer: Any)
    {
        super.init(layer : layer)
        
        let theLayer = CPTLegend(layer : layer)
        
        plots                 = theLayer.plots
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Animation
    func needsDisplayForKey(forKey key: String )-> Bool
    {
        var keys        = Set<String>()
        
        keys.insert("swatchSize")
        keys.insert("swatchCornerRadius")
        
        if keys.contains(key ) {
            return true;
        }
        else {
            return CPTBorderedLayer.needsDisplay(forKey: key)
        }
    }
    
    // MARK: LAYOUT
    func setLayoutChanged()
    {
        self.layoutChanged = true
    }
    
    public override func layoutSublayers()
    {
        self.recalculateLayout()
        super.layoutSublayers()
    }
    
    func recalculateLayout()
    {
        guard ( !self.layoutChanged ) else { return }
        
        var isHorizontalLayout = false
        
        switch ( self.swatchLayout ) {
        case .left:
            fallthrough
        case .right:
            isHorizontalLayout = true
            break;
            
        case .top:
            fallthrough
        case .bottom:
            isHorizontalLayout = false
            break;
        }
        
        // compute the number of rows and columns needed to hold the legend entries
        var rowCount           = self.numberOfRows;
        var columnCount        = self.numberOfColumns;
        let desiredRowCount    = rowCount;
        let desiredColumnCount = columnCount;
        
        let legendEntryCount = self.legendEntries.count;
        
        if ((rowCount == 0) && (columnCount == 0)) {
            rowCount    = Int(sqrt((Double(legendEntryCount))))
            columnCount = rowCount
            if ( rowCount * columnCount < legendEntryCount ) {
                columnCount += 1
            }
            if ( rowCount * columnCount < legendEntryCount ) {
                rowCount += 1
            }
        }
        else if ((rowCount == 0) && (columnCount > 0)) {
            rowCount = legendEntryCount / columnCount;
            if ((legendEntryCount % columnCount) != 0) {
                rowCount += 1
            }
        }
        else if ((rowCount > 0) && (columnCount == 0)) {
            columnCount = legendEntryCount / rowCount;
            if (( legendEntryCount % rowCount ) != 0) {
                columnCount += 1
            }
        }
        
        // compute row heights and column widths
        var row                      = 0;
        var col                      = 0;
        var maxTitleHeight             = [CGFloat]()
        var maxTitleWidth              = [CGFloat]()
        let theSwatchSize                = self.swatchSize;
        let desiredRowHeights   = self.rowHeights
        let desiredColumnWidths = self.columnWidths
        //            Class numberClass                   = [NSNumber class];
        
        for legendEntry in self.legendEntries  {
            legendEntry.row    = row;
            legendEntry.column = col;
            let titleSize = legendEntry.titleSize;
            
            if ((desiredRowCount == 0) || (row < desiredRowCount)) {
                maxTitleHeight[row] = max(maxTitleHeight[row], titleSize.height)
                
                if ( isHorizontalLayout == true) {
                    maxTitleHeight[row] = max(maxTitleHeight[row], theSwatchSize.height);
                }
                
                if ( row < desiredRowHeights.count ) {
                    let desiredRowHeight = desiredRowHeights[row];
                    
                    maxTitleHeight[row] = max(maxTitleHeight[row], desiredRowHeight)
                }
            }
            
            if ((desiredColumnCount == 0) || (col < desiredColumnCount)) {
                maxTitleWidth[col] = max(maxTitleWidth[col], titleSize.width);
                if ( isHorizontalLayout == false) {
                    maxTitleWidth[col] = max(maxTitleWidth[col], theSwatchSize.width);
                }
                
                if ( col < desiredColumnWidths.count ) {
                    let desiredColumnWidth = desiredColumnWidths[col];
                    //                        if desiredColumnWidth is CGFloat {
                    maxTitleWidth[col] = max(maxTitleWidth[col], desiredColumnWidth )
                    //                        }
                }
            }
            
            col += 1
            if ( col >= columnCount ) {
                row += 1;
                col = 0;
                if row >= rowCount {
                    break;
                }
            }
        }
        
        // save row heights and column widths
        var maxRowHeights = [CGFloat]()
        for i in  0..<rowCount {
            maxRowHeights.append(maxTitleHeight[i])
        }
        self.rowHeightsThatFit = maxRowHeights;
        
        var maxColumnWidths = [CGFloat]()
        for i in 0..<columnCount {
            maxColumnWidths.append(maxTitleWidth[i])
        }
        self.columnWidthsThatFit = maxColumnWidths;
        
        // compute the size needed to contain all legend entries, margins, and padding
        let width = self.paddingLeft + self.paddingRight
        let height = self.paddingTop + self.paddingBottom
        var legendSize = CGSize(width: width, height: height)
        
        let lineWidth = self.borderLineStyle?.lineWidth;
        
        legendSize.width  += lineWidth!
        legendSize.height += lineWidth!
        
        if self.equalColumns  == true {
            
            let maxWidth = maxColumnWidths.max()
            legendSize.width = legendSize.width + (maxWidth!  * CGFloat(columnCount))
        }
        else {
            for width in maxColumnWidths  {
                legendSize.width += width
            }
        }
        if columnCount > 0 {
            
            let horizon = (self.entryPaddingLeft + self.entryPaddingRight) * CGFloat(columnCount)
            legendSize.width = legendSize.width +  horizon + (self.columnMargin * CGFloat((columnCount - 1)))
            
            if isHorizontalLayout == true  {
                legendSize.width = legendSize.width + (theSwatchSize.width + self.titleOffset) * CGFloat(columnCount)
            }
        }
        
        var rows = row
        
        if (( col ) != 0) {
            rows += 1
        }
        for height in maxRowHeights  {
            legendSize.height += height
        }
        if ( rows > 0 ) {
            let vertical = (self.entryPaddingBottom + self.entryPaddingTop) * CGFloat(rowCount)
            
            legendSize.height += vertical + (self.rowMargin * CGFloat((rows - 1)))

            if ( !isHorizontalLayout == false ) {
                legendSize.height += (theSwatchSize.height + self.titleOffset) * CGFloat(rowCount);
            }
        }
        
        
        self.bounds = CGRect(x: 0.0, y: 0.0, width: ceil(legendSize.width), height: ceil(legendSize.height))
        self.pixelAlign()
        
        self.layoutChanged = false
    }

    //  MARK: - Plots
    //
    //    /** @brief All plots associated with the legend.
    //     *  @return An array of all plots associated with the legend.
    //     **/
        func allPlots() -> [ CPTPlot]
        {
            return self.plots
        }
    //
    //    /** @brief Gets the plot at the given index in the plot array.
    //     *  @param idx An index within the bounds of the plot array.
    //     *  @return The plot at the given index.
    //     **/
    
    func plotAtIndex(idx : Int)-> CPTPlot?
    {
        if ( idx < self.plots.count ) {
            return self.plots[idx];
        }
        else {
            return nil
        }
    }
    
    /** @brief Gets the plot with the given identifier from the plot array.
     *  @param identifier A plot identifier.
     *  @return The plot with the given identifier or nil if it was not found.
     **/
    func plotWithIdentifier(identifier: String) ->CPTPlot?
    {
        let identifier = identifier
        for plot in self.plots {
            if plot.identifier == identifier {
                return plot
            }
        }
        return nil;
    }
    
    // MARK:  Organizing Plots
    
        /** @brief Add a plot to the legend.
         *  @param plot The plot.
         **/
    func addPlot(plot : CPTPlot)
    {
        self.plots.append(plot)
        self.layoutChanged = true
        
        var theLegendEntries = self.legendEntries
        let theTextStyle   = self.textStyle
        let numberOfLegendEntries    = plot.numberOfLegendEntries()
        for i in 0..<numberOfLegendEntries {
            let newTitle = plot.titleForLegendEntryAtIndex(idx: i)
            if ( newTitle.count > 0 ) {
                let newLegendEntry = CPTLegendEntry()
                newLegendEntry.plot      = plot
                newLegendEntry.index     = i
                newLegendEntry.textStyle = theTextStyle
                theLegendEntries.append(newLegendEntry);
            }
        }
        
        NotificationCenter.receive(
            instance: self,
            name: .CPTLegendNeedsLayoutForPlotNotification,
            selector: #selector(legendNeedsLayout(_:)))
        
        NotificationCenter.receive(
            instance: self,
            name:.CPTLegendNeedsRedrawForPlotNotification,
            selector:#selector(legendNeedsRedraw))
        
        NotificationCenter.receive(
            instance: self,
            name:.CPTLegendNeedsReloadEntriesForPlotNotification ,
            selector:#selector(legendNeedsReloadEntries(_:)))
    }
    
    //
    //    /** @brief Add a plot to the legend at the given index in the plot array.
    //     *  @param plot The plot.
    //     *  @param idx An index within the bounds of the plot array.
    //     **/
    
    func insertPlot(plot: CPTPlot, atIndex idx :Int)
    {
        var thePlots = self.plots;
        
        var theLegendEntries = self.legendEntries;
        var legendEntryIndex                  = 0;
        if ( idx == thePlots.count ) {
            legendEntryIndex = theLegendEntries.count;
        }
        else {
            let lastPlot = thePlots[idx];
            for legendEntry in theLegendEntries {
                if ( legendEntry.plot == lastPlot ) {
                    break;
                }
                legendEntryIndex += 1
            }
        }
        
        thePlots.insert(plot, at:idx)
        self.layoutChanged = true
        
        let theTextStyle       = self.textStyle;
        let numberOfLegendEntries = plot.numberOfLegendEntries()
        for idx in 0..<numberOfLegendEntries {
            
            let newTitle = plot.titleForLegendEntryAtIndex(idx: idx)
            if ( newTitle.count > 0 ) {
                let newLegendEntry = CPTLegendEntry()
                newLegendEntry.plot      = plot
                newLegendEntry.index     = idx
                newLegendEntry.textStyle = theTextStyle
                theLegendEntries.insert(newLegendEntry,  at:legendEntryIndex)
                legendEntryIndex += legendEntryIndex
            }
        }
        
        NotificationCenter.receive(
            instance:self,
            name: .CPTLegendNeedsRedrawForPlotNotification,
            selector: #selector(legendNeedsRedraw(_:)),
            object:plot)
        
        NotificationCenter.receive(
            instance: self,
            name: .CPTLegendNeedsLayoutForPlotNotification,
            selector: #selector(legendNeedsLayout(_:)),
            object:plot)
        
        NotificationCenter.receive(
            instance: self,
            name: .CPTLegendNeedsReloadEntriesForPlotNotification,
            selector: #selector(legendNeedsReloadEntries(_:)),
            object:plot)
    }
    
    //    /** @brief Remove a plot from the legend.
    //     *  @param plot The plot to remove.
    //     **/
    func removePlot(plot: CPTPlot)
    {
        if ( self.plots.contains(plot) ) {
            //                [self.plots removeObjectIdenticalTo:plot];
            self.removeLegendEntriesForPlot(plot: plot)
            self.layoutChanged = true
            
            NotificationCenter.remove(
                instance: self,
                name: .CPTLegendNeedsRedrawForPlotNotification,
                object: plot)
            
            NotificationCenter.remove(
                instance: self,
                name: .CPTLegendNeedsLayoutForPlotNotification,
                object: plot)
            
            NotificationCenter.remove(
                instance: self,
                name: .CPTLegendNeedsReloadEntriesForPlotNotification,
                object: plot)
        }
        else {
            print("CPTException format:@Tried to remove CPTPlot which did not exist.")
        }
    }
    //
    //    /** @brief Remove a plot from the legend.
    //     *  @param identifier The identifier of the plot to remove.
    //     **/
    func removePlotWithIdentifier(identifier: Any)
    {
        let plotToRemove = self.plotWithIdentifier(identifier: identifier)
        
        if (( plotToRemove ) != nil) {
//            self.plots.removeObjectIdenticalTo(plotToRemove)
            self.plots.removeObject(plotToRemove!)
            self.removeLegendEntriesForPlot(plot: plotToRemove!)
            self.layoutChanged = true
            
            NotificationCenter.remove(
                instance: self,
                name: .CPTLegendNeedsRedrawForPlotNotification,
                object: plotToRemove)
            
            NotificationCenter.remove(
                instance: self,
                name:.CPTLegendNeedsLayoutForPlotNotification,
                object:plotToRemove)
            
            NotificationCenter.remove(
                instance: self,
                name:.CPTLegendNeedsReloadEntriesForPlotNotification,
                object:plotToRemove)
        }
    }

    func removeLegendEntriesForPlot(plot: CPTPlot)
    {
        var theLegendEntries = self.legendEntries;
        
        for idx in 0..<theLegendEntries.count {
            if theLegendEntries[idx].plot == plot {
                theLegendEntries.remove(at: idx)
            }
        }
    }

    // MARK: Notifications
    @objc func legendNeedsRedraw(_ notif: Notification )
    {
        self.setNeedsDisplay()
    }
    
    @objc func legendNeedsLayout(_ notif: Notification )
    {
        self.layoutChanged = true
        self.setNeedsDisplay()
    }
    
    @objc func legendNeedsReloadEntries(_ notif: Notification )
    {
        let thePlot = notif.object as! CPTPlot
        var theLegendEntries = self.legendEntries;
        var legendEntryIndex = 0
        
        for legendEntry in theLegendEntries {
            if ( legendEntry.plot == thePlot ) {
                break
            }
            legendEntryIndex += 1
        }
        self.removeLegendEntriesForPlot(plot: thePlot)
        
        let theTextStyle  = self.textStyle;
        let numberOfLegendEntries = thePlot.numberOfLegendEntries()
        
        for i in 0..<numberOfLegendEntries {
            let newTitle = thePlot.titleForLegendEntryAtIndex(idx: i)
            if ( newTitle.count > 0 ) {
                let newLegendEntry = CPTLegendEntry()
                newLegendEntry.plot      = thePlot
                newLegendEntry.index     = i
                newLegendEntry.textStyle = theTextStyle
                theLegendEntries.insert(newLegendEntry, at: legendEntryIndex)
                legendEntryIndex += 1
            }
        }
        self.layoutChanged = true
    }
    
    
    // MARK: - Responder Chain and User interaction
    func legendEntryForInteractionPoint(interactionPoint:CGPoint, row: inout Int, col: inout Int )
    {
        var interactionPoint = interactionPoint

        // Convert the interaction point to the local coordinate system
        let theGraph = self.graph;
        
        if (( theGraph ) != nil) {
            interactionPoint = self.convert(interactionPoint, from:theGraph)
        }
        else {
            for plot in self.plots {
                let plotGraph = plot.graph;
                
                if (( plotGraph ) != nil) {
                    interactionPoint = self.convert(interactionPoint, from:plotGraph)
                    break;
                }
            }
        }
        
        // Update layout if needed
        self.recalculateLayout()
        
        // Hit test the legend entries
        let rMargin = self.rowMargin;
        let cMargin = self.columnMargin;
        
        let swatchWidth = self.swatchSize.width + self.titleOffset;
        
        let padHorizontal = self.entryPaddingLeft + self.entryPaddingRight;
        let padVertical   = self.entryPaddingTop + self.entryPaddingBottom;
        
        // Rows
        var position = self.bounds.maxY - self.paddingTop;
        
        var i = 0;
        
        for height in self.rowHeightsThatFit  {
            let rowHeight = height + padVertical;
            if interactionPoint.y <= position && (interactionPoint.y >= position - rowHeight) {
                row = i;
                break;
            }
            
            position -= rowHeight + rMargin;
            i += 1
        }
        
        // Columns
        position = self.paddingLeft;
        
        i = 0;
        
        for width in self.columnWidthsThatFit  {
            let colWidth = width + swatchWidth + padHorizontal;
            if (interactionPoint.x >= position) && (interactionPoint.x <= position + colWidth) {
                col = i
                break;
            }
            
            position += colWidth + cMargin;
            i += 1
        }
    }
    
    override func pointingDeviceDownEvent(event: CPTNativeEvent, atPoint interactionPoint: CGPoint) -> Bool
    {
        guard  self.isHidden == false || (self.plots.count != 0) else { return false }
        
        weak var theDelegate = self.delegate as? CPTLegendDelegate
        
        var row = NSNotFound
        var col = NSNotFound
        self.legendEntryForInteractionPoint(interactionPoint: interactionPoint, row:&row,  col:&col)
        
        // Notify the delegate if we found a hit
        if (row != NSNotFound) && (col != NSNotFound) {
            for legendEntry in self.legendEntries {
                
                if ((legendEntry.row == row) && (legendEntry.column == col)) {
                    
                    self.pointingDeviceDownEntry = legendEntry
                    let legendPlot = legendEntry.plot
                    var handled = false
                    
                    if ((theDelegate?.legend( legend: legendEntryForPlot: touchDownAtIndex:)) != nil) {
                        
                        theDelegate?.legend?( legend: self, legendEntryForPlot:legendPlot!, touchDownAtIndex:legendEntry.index)
                        handled = true
                    }
                    
                    if ((theDelegate?.legend( legend: legendEntryForPlot: touchDownAtIndex: withEvent:)) != nil) {
                        
                        theDelegate?.legend?( legend: self, legendEntryForPlot:legendPlot!, touchDownAtIndex:legendEntry.index, withEvent:event)
                        handled = true
                    }
                    
                    if ((theDelegate?.legend!(legend: self, legendEntryForPlot:legendPlot!, wasSelectedAtIndex:legendEntry.index, withEvent:event)) != nil) {
                        theDelegate?.legend!(legend: self, legendEntryForPlot:legendPlot!, wasSelectedAtIndex:legendEntry.index, withEvent:event)
                        handled = true
                    }
                    
                    guard handled == false else { return true }
                    
                }
            }
        }
        return super.pointingDeviceDownEvent(event: event, atPoint:interactionPoint)
    }
    
    override func pointingDeviceUpEvent(event: CPTNativeEvent, atPoint interactionPoint:CGPoint ) -> Bool
    {
        let selectedDownEntry = self.pointingDeviceDownEntry
        
        self.pointingDeviceDownEntry = nil;
        
        guard self.isHidden == false else { return false }
        guard self.plots.count != 0 else { return false }
        
        
        weak var theDelegate = self.delegate as? CPTLegendDelegate
        
        var row = NSNotFound
        var col = NSNotFound
        
        self.legendEntryForInteractionPoint (interactionPoint: interactionPoint, row:&row, col:&col)
        
        // Notify the delegate if we found a hit
        if ((row != NSNotFound) && (col != NSNotFound)) {
            
            for legendEntry in self.legendEntries {
                
                if ((legendEntry.row == row) && (legendEntry.column == col)) {
                    var handled = false
                    
                    let entryPlot = legendEntry.plot;
                    
                    if ((theDelegate?.legend( legend: legendEntryForPlot: touchUpAtIndex:)) != nil) {
                        handled = true
                        theDelegate?.legend?(legend:self, legendEntryForPlot:entryPlot!, touchUpAtIndex:legendEntry.index)
                    }
                    
                    if ((theDelegate?.legend(legend: legendEntryForPlot: touchUpAtIndex: withEvent:)) != nil) {
                        handled = true
                        theDelegate?.legend?(legend: self, legendEntryForPlot:entryPlot!, touchUpAtIndex:legendEntry.index, withEvent:event)
                    }
                    
                    if ( legendEntry == selectedDownEntry ) {
                        if ((theDelegate?.legend(legend: legendEntryForPlot: wasSelectedAtIndex:)) != nil) {
                            handled = true
                            theDelegate?.legend!(legend: self , legendEntryForPlot:entryPlot!, wasSelectedAtIndex:legendEntry.index)
                        }
                        
                        if (( theDelegate?.legend(legend: legendEntryForPlot: wasSelectedAtIndex: withEvent:)) != nil) {
                            handled = true
                            theDelegate?.legend!(legend: self, legendEntryForPlot:entryPlot!, wasSelectedAtIndex:legendEntry.index, withEvent:event)
                        }
                    }
                    guard handled == false else { return true }
                }
            }
        }
        
        return super.pointingDeviceUpEvent(event: event, atPoint:interactionPoint)
    }
    

    // MARK: - Accessors
    func setTextStyle(newTextStyle: CPTTextStyle)
    {
        if ( newTextStyle != textStyle ) {
            textStyle = newTextStyle
            
            self.legendEntries.makeObjectsPerformSelector:@selector(setTextStyle:) withObject:textStyle];
            
            for legendEntry in self.legendEntries {
                legendEntry.setTextStyle(w)
            }
            self.layoutChanged = true
        }
    }

    var  _swatchSize = CGSize()
    var swatchSize : CGSize {
        get {
            var theSwatchSize = _swatchSize
            
            if theSwatchSize.equalTo( CGSize()) {
                let theTextStyle = textStyle
                var fontSize        = theTextStyle.fontSize
                if fontSize > CGFloat(0.0) {
                    fontSize     *= CGFloat(1.5)
                    fontSize      = round(fontSize)
                    theSwatchSize = CGSize(width: fontSize, height: fontSize)
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
    
    func setSwatchBorderLineStyle(newSwatchBorderLineStyle: CPTLineStyle )
    {
        if ( newSwatchBorderLineStyle != swatchBorderLineStyle ) {
            swatchBorderLineStyle = newSwatchBorderLineStyle ;
            self.setNeedsDisplay()
        }
    }
    
    func setSwatchCornerRadius(newSwatchCornerRadius: CGFloat)
    {
        if ( newSwatchCornerRadius != swatchCornerRadius ) {
            swatchCornerRadius = newSwatchCornerRadius;
            self.setNeedsDisplay()
        }
    }
    
    func setSwatchFill(newSwatchFill: CPTFill )
    {
        if newSwatchFill != swatchFill {
            swatchFill = newSwatchFill
            self.setNeedsDisplay()
        }
    }
    
    func setEntryBorderLineStyle(newEntryBorderLineStyle: CPTLineStyle )
        {
            if ( newEntryBorderLineStyle != entryBorderLineStyle ) {
                entryBorderLineStyle = newEntryBorderLineStyle
                self.setNeedsDisplay()
            }
        }

    func setEntryCornerRadius(newEntryCornerRadius: CGFloat)
    {
        if ( newEntryCornerRadius != entryCornerRadius ) {
            entryCornerRadius = newEntryCornerRadius;
            self.setNeedsDisplay()
        }
    }
    
    func setEntryFill(newEntryFill: CPTFill )
        {
            if ( newEntryFill != entryFill ) {
                entryFill = newEntryFill
                self.setNeedsDisplay()
            }
        }
    
    func setEntryPaddingLeft(newPadding: CGFloat)
        {
            if ( newPadding != entryPaddingLeft ) {
                entryPaddingLeft   = newPadding;
                self.layoutChanged = true
            }
        }
    
    func setEntryPaddingTop(newPadding: CGFloat)
        {
            if ( newPadding != entryPaddingTop ) {
                entryPaddingTop    = newPadding;
                self.layoutChanged = true
            }
        }
    
    func setEntryPaddingRight(newPadding: CGFloat)
        {
            if ( newPadding != entryPaddingRight ) {
                entryPaddingRight  = newPadding;
                self.layoutChanged = true
            }
        }
    
    func setEntryPaddingBottom(newPadding: CGFloat)
        {
            if ( newPadding != entryPaddingBottom ) {
                entryPaddingBottom = newPadding;
                self.layoutChanged = true
            }
        }
    
    func setNumberOfRows(newNumberOfRows: Int)
        {
            if ( newNumberOfRows != numberOfRows ) {
                numberOfRows       = newNumberOfRows
                self.layoutChanged = true
            }
        }
    
    func setNumberOfColumns(newNumberOfColumns: Int)
        {
            if ( newNumberOfColumns != numberOfColumns ) {
                numberOfColumns    = newNumberOfColumns
                self.layoutChanged = true
            }
        }
    
    func setEqualRows(newEqualRows: Bool)
        {
            if ( newEqualRows != equalRows ) {
                equalRows = newEqualRows;
                self.layoutChanged = true
            }
        }
    
    func setEqualColumns(newEqualColumns : Bool)
    {
        if ( newEqualColumns != equalColumns ) {
            equalColumns       = newEqualColumns;
            self.layoutChanged = true
        }
    }
    
    func setRowHeights(newRowHeights: [CGFloat] )
    {
        if ( newRowHeights != rowHeights ) {
            rowHeights         = newRowHeights
            self.layoutChanged = true
        }
    }
    
    func setColumnWidths(newColumnWidths: [CGFloat] )
    {
        if ( newColumnWidths != columnWidths ) {
            columnWidths       = newColumnWidths
            self.layoutChanged = true
        }
    }
    
    func setColumnMargin(newColumnMargin: CGFloat)
    {
        if ( newColumnMargin != columnMargin ) {
            columnMargin       = newColumnMargin;
            self.layoutChanged = true
        }
    }
    
    func setRowMargin(newRowMargin: CGFloat )
    {
        if ( newRowMargin != rowMargin ) {
            rowMargin          = newRowMargin;
            self.layoutChanged = true
        }
    }
    
    func setTitleOffset( newTitleOffset: CGFloat)
    {
        if ( newTitleOffset != titleOffset ) {
            titleOffset        = newTitleOffset;
            self.layoutChanged = true
        }
    }
    
    func setSwatchLayout(newSwatchLayout: CPTLegendSwatchLayout)
    {
        if ( newSwatchLayout != swatchLayout ) {
            swatchLayout       = newSwatchLayout;
            self.layoutChanged = true
        }
    }
    
    func setLayoutChanged(newLayoutChanged : Bool)
    {
        if ( newLayoutChanged != layoutChanged ) {
            layoutChanged = newLayoutChanged;
            if ( newLayoutChanged ) {
                self._rowHeightsThatFit.removeAll()
                self._columnWidthsThatFit.removeAll()
                self.setNeedsLayout();
            }
        }
    }
    
    func setPaddingLeft(newPadding : CGFloat)
    {
        if ( newPadding != self.paddingLeft ) {
            super.paddingLeft  = newPadding;
            self.layoutChanged = true
        }
    }
    
    func setPaddingTop(newPadding : CGFloat)
    {
        if ( newPadding != self.paddingTop ) {
            super.paddingTop   = newPadding;
            self.layoutChanged = true
        }
    }
    
    func setPaddingRight(newPadding : CGFloat)
    {
        if ( newPadding != self.paddingRight ) {
            super.paddingRight = newPadding;
            self.layoutChanged = true
        }
    }
    
    func setPaddingBottom(newPadding : CGFloat)
    {
        if ( newPadding != self.paddingBottom ) {
            super.paddingBottom = newPadding;
            self.layoutChanged  = true
        }
    }
    
    func setBorderLineStyle(newLineStyle: CPTLineStyle)
    {
        let oldLineStyle = self.borderLineStyle;
        
        if ( newLineStyle != oldLineStyle ) {
            super.borderLineStyle = newLineStyle;
            
            if ( newLineStyle.lineWidth != oldLineStyle?.lineWidth ) {
                self.layoutChanged = true
            }
        }
    }
    
    var _rowHeightsThatFit     = [CGFloat]()
    var  rowHeightsThatFit : [CGFloat] {
        get {
            if !_rowHeightsThatFit.isEmpty {
                recalculateLayout()
            }
            return _rowHeightsThatFit
        }
        set {}
    }
    
    var _columnWidthsThatFit = [CGFloat]()
    var columnWidthsThatFit : [CGFloat] {
        get {
            if !_columnWidthsThatFit.isEmpty {
                recalculateLayout()
            }
            return _columnWidthsThatFit
        }
        set {}
    }
 }
 
