//
//  CPTGraph ext.swift
//  corePlot
//
//  Created by thierryH24 on 19/11/2020.
//

import AppKit


func |= (left: inout  Bool, right: Bool) {
   left = left || right
}

extension CPTGraph {
    
    
    // MARK: - Drawing
    override func layoutAndRender(context: CGContext)
    {
        self.reloadDataIfNeeded()
        
        for theAxis in self.axisSet!.axes {
            theAxis.relabel()
        }
        
//        if let appearance = NSView.effectiveAppearance  {
            let  oldAppearance = NSAppearance.current
            let view  = self.hostingView
            
            NSAppearance.current = view?.effectiveAppearance
            super.layoutAndRender(context: context)
            NSAppearance.current = oldAppearance
//        }
//        else {
            super.layoutAndRender(context: context)
//        }
    }
    
    // MARK: Animation
    func needsDisplayForKey(aKey: String )-> Bool
    {
        var keys    = Set<String>()
        
        keys.insert("titleDisplacement")
        keys.insert("legendDisplacement")
        
        if keys.contains(aKey ) {
            return true;
        }
        else {
            return CPTBorderedLayer.needsDisplay(forKey: aKey)
        }
    }
    
    // MARK: - Retrieving Plots
    func reloadData()
    {
        for plot in plots {
            plot.reloadData()
        }
        for plotSpace in plotSpaces {
            plotSpace.removeAllCategories()
        }
    }
    
    //   @brief Makes all plots reload their data if their data cache is out of date.
    func reloadDataIfNeeded()
    {
        for plot in plots {
            plot.reloadDataIfNeeded()
        }
    }
    
    /** @brief All plots associated with the graph.
     *  @return An array of all plots associated with the graph.
     **/
    func allPlots()-> [CPTPlot]
    {
        return self.plots
    }
    
    /** @brief Gets the plot at the given index in the plot array.
     *  @param idx An index within the bounds of the plot array.
     *  @return The plot at the given index.
     **/
    func plotAtIndex(idx : Int) -> CPTPlot?
    {
        if ( idx < self.plots.count ) {
            return self.plots[idx]
        }
        else {
            return nil;
        }
    }
    
    /** @brief Gets the plot with the given identifier from the plot array.
     *  @param identifier A plot identifier.
     *  @return The plot with the given identifier or @nil if it was not found.
     **/
    func plotWithIdentifier(identifier: String)-> CPTPlot?
    {
        for plot in self.plots {
            if plot.identifier == identifier {
                return plot
            }
        }
        return nil
    }
    
    // MARK: - Organizing Plots
    
    /** @brief Add a plot to the default plot space.
     *  @param plot The plot.
     **/
    func addPlot(plot : CPTPlot )
    {
        self.addPlot(plot: plot , space: self.defaultPlotSpace()!)
    }
    
    /** @brief Add a plot to the given plot space.
     *  @param plot The plot.
     *  @param space The plot space.
     **/
    func addPlot(plot: CPTPlot?, space: CPTPlotSpace )
    {
        if ( plot  != nil) {
            self.plots.append(plot!)
            plot?.plotSpace = space
            plot?.graph     = self;
            self.plotAreaFrame?.plotGroup.addPlot(plot: plot!)
        }
    }
    
    /** @brief Remove a plot from the graph.
     *  @param plot The plot to remove.
     **/
    func removePlot(plot: CPTPlot? )
    {
        if (( plot ) != nil) {
            let thePlot = plot
            
            if self.plots.contains(plot! ) {
                thePlot?.plotSpace = nil
                thePlot?.graph     = nil
                self.plotAreaFrame?.plotGroup.removePlot(plot: thePlot!)
                
                let index = plots.firstIndex(of: thePlot!)
                self.plots.remove( at: index! )
            }
            else {
                print("Tried to remove CPTPlot which did not exist.")
            }
        }
    }
    
    /** @brief Add a plot to the default plot space at the given index in the plot array.
     *  @param plot The plot.
     *  @param idx An index within the bounds of the plot array.
     **/
    func insertPlot(plot: CPTPlot, index:Int)
    {
        self.insertPlot(plot: plot, index: index, space:self.defaultPlotSpace()!)
    }
    
    /** @brief Add a plot to the given plot space at the given index in the plot array.
     *  @param plot The plot.
     *  @param idx An index within the bounds of the plot array.
     *  @param space The plot space.
     **/
    func insertPlot(plot: CPTPlot?, index:Int, space: CPTPlotSpace)
    {
        if (( plot ) != nil) {
            self.plots.insert(plot!, at: index)
            plot?.plotSpace = space
            plot?.graph     = self
            self.plotAreaFrame?.plotGroup.insertPlot(plot: plot!, atIndex: index)
        }
    }
    
    /** @brief Remove a plot from the graph.
     *  @param identifier The identifier of the plot to remove.
     **/
    func removePlotWithIdentifier(identifier: String)
    {
        let plotToRemove = self.plotWithIdentifier(identifier: identifier)
        
        if (( plotToRemove ) != nil) {
            plotToRemove?.plotSpace = nil
            plotToRemove?.graph     = nil
            self.plotAreaFrame?.plotGroup.removePlot(plot: plotToRemove!)
//            self.plots.removeObjectIdentical(plotToRemove)
            self.plots = self.plots.filter { $0 != plotToRemove } // Keeps only what is

        }
    }
    
    // MARK: - Retrieving Plot Spaces
    func defaultPlotSpace() ->CPTPlotSpace?
    {
        return self.plotSpaces.count > 0 ? self.plotSpaces[0] : nil;
    }
    
    /** @brief All plot spaces associated with the graph.
     *  @return An array of all plot spaces associated with the graph.
     **/
    func allPlotSpaces() -> [CPTPlotSpace]
    {
        return self.plotSpaces
    }
    
    /** @brief Gets the plot space at the given index in the plot space array.
     *  @param idx An index within the bounds of the plot space array.
     *  @return The plot space at the given index.
     **/
    func plotSpaceAtIndex(idx : Int) -> CPTPlotSpace?
    {
        return self.plotSpaces.count > idx ? self.plotSpaces[idx] : nil
    }
    
    /** @brief Gets the plot space with the given identifier from the plot space array.
     *  @param identifier A plot space identifier.
     *  @return The plot space with the given identifier or @nil if it was not found.
     **/
    func plotSpaceWithIdentifier(identifier: String) -> CPTPlotSpace?
    {
        for plotSpace in self.plotSpaces  {
            if plotSpace.identifier == identifier {
                return plotSpace;
            }
        }
        return nil;
    }
    
    // MARK: Set Plot Area
    func setPlotAreaFrame(newArea: CPTPlotAreaFrame?)
    {
        if ( plotAreaFrame != newArea ) {
            plotAreaFrame?.graph = nil;
            plotAreaFrame?.removeFromSuperlayer()
            
            plotAreaFrame = newArea!;
            
            if (( newArea ) != nil) {
                let theFrame = newArea
                
                self.addSublayer(theFrame!)
                theFrame?.graph = self;
            }
            
            for space in self.plotSpaces  {
                space.graph = self
            }
        }
    }
    
    // MARK: - Organizing Plot Spaces
    
    /** @brief Add a plot space to the graph.
     *  @param space The plot space.
     **/
    func addPlotSpace(space : CPTPlotSpace )
    {
        self.plotSpaces.append(space)
        space.graph = self
        
        NotificationCenter.receive(
            instance: self,
            name:.CPTPlotSpaceCoordinateMappingDidChangeNotification,
            selector:#selector(plotSpaceMappingDidChange(_:)),
            object:space)
        
        NotificationCenter.send(
            name: .CPTGraphDidAddPlotSpaceNotification,
            object: self)
    }
    
    /** @brief Remove a plot space from the graph.
     *  @param plotSpace The plot space.
     **/
    func removePlotSpace(plotSpace: CPTPlotSpace? )
    {
        if (( plotSpace ) != nil) {
            let thePlotSpace = plotSpace
            
            if self.plotSpaces.contains(thePlotSpace! ) {
                NotificationCenter.remove(
                    instance: self,
                    name: Notification.Name.CPTPlotSpaceCoordinateMappingDidChangeNotification,
                    object:thePlotSpace)
                
                // Remove space
                thePlotSpace?.graph = nil
                self.plotSpaces.removeObject(thePlotSpace!)
                
                // Update axes that referenced space
                for axis in self.axisSet!.axes {
                    if ( axis.plotSpace == thePlotSpace ) {
                        axis.plotSpace = nil
                    }
                }
                let user = Notification.Name.CPTPlotSpaceCoordinateMappingDidChangeNotification.rawValue
                let userInfo = [user: thePlotSpace as Any]
                NotificationCenter.send(
                    name: .CPTGraphDidRemovePlotSpaceNotification,
                    object:self,
                    userInfo: userInfo)
            }
            else {
                print("Tried to remove CPTPlotSpace which did not exist.")
            }
        }
    }
    
    // MARK: - Coordinate Changes in Plot Spaces
    
    /// @cond
    
    @objc func plotSpaceMappingDidChange(_ notif: Notification )
    {
        let plotSpace        = notif.object as! CPTPlotSpace
        var backgroundBandsNeedRedraw = false;
        
        for axis in self.axisSet!.axes {
            if  axis.plotSpace == plotSpace {
                axis.setNeedsRelabel()
                axis.updateAxisTitle()
                
                if backgroundBandsNeedRedraw == false {
                    backgroundBandsNeedRedraw = (axis.alternatingBandFills.count > 0) || (axis.backgroundLimitBands.count > 0);
                }
            }
        }
        for plot in self.plots {
            if ( plot.plotSpace == plotSpace ) {
                plot.setNeedsDisplay()
            }
        }
        if ( backgroundBandsNeedRedraw ) {
            self.plotAreaFrame?.plotArea?.setNeedsDisplay()
        }
    }
        
    // MARK: - Themes
    
    /** @brief Apply a theme to style the graph.
     *  @param theme The theme object used to style the graph.
     **/
    func applyTheme(theme: CPTTheme )
    {
        theme.applyThemeToGraph(graph: self)
    }
    
    // MARK: - Legend
    func setLegend(newLegend: CPTLegend )
    {
        if ( newLegend != legend ) {
            legend = newLegend;
            let theLegendAnnotation = self.legendAnnotation;
            if (( legend ) != nil) {
                if (( theLegendAnnotation ) != nil) {
                    theLegendAnnotation?.contentLayer = legend;
                }
                else {
                    let newLegendAnnotation = CPTLayerAnnotation(newAnchorLayer: self)
                    newLegendAnnotation.contentLayer       = legend
                    newLegendAnnotation.displacement       = self.legendDisplacement
                    newLegendAnnotation.rectAnchor         = self.legendAnchor
                    newLegendAnnotation.contentAnchorPoint = self.contentAnchorForRectAnchor(anchor: self.legendAnchor!)
                    self.addAnnotation(newLegendAnnotation)
                    self.legendAnnotation = newLegendAnnotation
                }
            }
            else {
                if (( theLegendAnnotation ) != nil) {
                    self.removeAnnotation(theLegendAnnotation!)
                    self.legendAnnotation = nil;
                }
            }
        }
    }
    
    func setLegendAnchor(newLegendAnchor: CPTRectAnchor)
    {
        if ( newLegendAnchor != legendAnchor ) {
            legendAnchor = newLegendAnchor;
            let theLegendAnnotation = self.legendAnnotation;
            if (( theLegendAnnotation ) != nil) {
                theLegendAnnotation?.rectAnchor         = newLegendAnchor;
                theLegendAnnotation?.contentAnchorPoint = self.contentAnchorForRectAnchor(anchor: self.legendAnchor!)
            }
        }
    }
    
    func setLegendDisplacement(newLegendDisplacement: CGPoint)
    {
        if ( !newLegendDisplacement.equalTo(legendDisplacement)) {
            legendDisplacement                 = newLegendDisplacement;
            self.legendAnnotation?.displacement = newLegendDisplacement;
        }
    }
    
    func contentAnchorForRectAnchor(anchor: CPTRectAnchor)->CGPoint
    {
        var contentAnchor = CGPoint()
        
        switch ( anchor ) {
        case .bottomLeft:
            contentAnchor = CGPoint()
            
        case .bottom:
            contentAnchor = CGPoint(x: 0.5, y: 0.0);
            
        case .bottomRight:
            contentAnchor = CGPoint(x: 1.0, y: 0.0);
            
        case .left:
            contentAnchor = CGPoint(x: 0.0, y: 0.5);
            
        case .right:
            contentAnchor = CGPoint(x: 1.0, y: 0.5);
            
        case .topLeft:
            contentAnchor = CGPoint(x: 0.0, y: 1.0);
            
        case .top:
            contentAnchor = CGPoint(x: 0.5, y: 1.0);
            
        case .topRight:
            contentAnchor = CGPoint(x: 1.0, y: 1.0);
            
        case .center:
            contentAnchor = CGPoint(x: 0.5, y: 0.5);
        }
        return contentAnchor;
    }
    
    
    //    func topDownLayerOrder() -> [CPTGraphLayerType] {
    //        return plotAreaFrame.plotArea.topDownLayerOrder()
    //    }
    
    func setTopDownLayerOrder(_ newArray: [CPTGraphLayerType]) {
        plotAreaFrame?.plotArea?.topDownLayerOrder = newArray
    }
    
    func setTitle(newTitle : String)
    {
        if ( newTitle != title ) {
            title = newTitle
            
            if self.inTitleUpdate == false {
                self.inTitleUpdate   = true
                self.attributedTitle = NSAttributedString(string: "")
                self.inTitleUpdate   = false
                
                let theTitleAnnotation = self.titleAnnotation
                
                if title != "" {
                    if (( theTitleAnnotation ) != nil) {
                        let textLayer = theTitleAnnotation?.contentLayer as! CPTTextLayer
                        textLayer.text = title
                    }
                    else {
                        let frameLayer = self.plotAreaFrame
                        if (( frameLayer ) != nil) {
                            let newTitleAnnotation = CPTLayerAnnotation( newAnchorLayer: frameLayer!)
                            
                            let newTextLayer = CPTTextLayer(newText: title, newStyle: titleTextStyle!)
                            
                            newTitleAnnotation.contentLayer       = newTextLayer
                            newTitleAnnotation.displacement       = self.titleDisplacement
                            newTitleAnnotation.rectAnchor         = self.titlePlotAreaFrameAnchor
                            newTitleAnnotation.contentAnchorPoint = self.contentAnchorForRectAnchor(anchor: titlePlotAreaFrameAnchor!)
                            self.addAnnotation(newTitleAnnotation)
                            self.titleAnnotation = newTitleAnnotation;
                        }
                    }
                }
                else {
                    if  (theTitleAnnotation != nil)  {
                        self.removeAnnotation(theTitleAnnotation!)
                        self.titleAnnotation = nil;
                    }
                }
            }
        }
    }
    
    func setAttributedTitle(newTitle: NSAttributedString )
    {
        if ( newTitle != attributedTitle ) {
            attributedTitle = newTitle
            
            if self.inTitleUpdate == false {
                self.inTitleUpdate = true
                
                var theTitleAnnotation = self.titleAnnotation;
                
                if ( attributedTitle.string != "" ) {
                    self.titleTextStyle = CPTTextStyle( textStyleWithAttribute(attributedTitle.attributesAtIndex(0, effectiveRange:nil)))
                    self.title = attributedTitle.string
                    
                    if (( theTitleAnnotation ) != nil) {
                        theTitleAnnotation?.contentLayer.attributedText = attributedTitle;
                    }
                    else {
                        let frameLayer = self.plotAreaFrame;
                        if (( frameLayer ) != nil) {
                            let newTitleAnnotation = CPTLayerAnnotation( newAnchorLayer: frameLayer)
                            let newTextLayer             = CPTTextLayer(attributedText: attributedTitle)
                            newTitleAnnotation.contentLayer       = newTextLayer;
                            newTitleAnnotation.displacement       = self.titleDisplacement;
                            newTitleAnnotation.rectAnchor         = self.titlePlotAreaFrameAnchor;
                            newTitleAnnotation.contentAnchorPoint = self.contentAnchorForRectAnchor(anchor: self.titlePlotAreaFrameAnchor!)
                            self.addAnnotation(newTitleAnnotation)
                            self.titleAnnotation = newTitleAnnotation;
                        }
                    }
                }
                else {
                    self.titleTextStyle = nil;
                    self.title          = ""
                    
                    if (( theTitleAnnotation ) != nil) {
                        self.removeAnnotation(theTitleAnnotation!)
                        self.titleAnnotation = nil;
                    }
                }
                self.inTitleUpdate = false
            }
        }
    }
    
    func setTitleTextStyle(newStyle: CPTTextStyle )
    {
        if ( newStyle != titleTextStyle ) {
            titleTextStyle = newStyle
            
            if self.inTitleUpdate == false {
                self.attributedTitle = NSAttributedString(string: "")
                
                let titleLayer = self.titleAnnotation?.contentLayer as! CPTTextLayer
//                if ( titleLayer is CPTTextLayer) {
                    titleLayer.textStyle = titleTextStyle!
//                }
            }
        }
    }
    
    func setTitleDisplacement(newDisplace:CGPoint)
    {
        if ( !newDisplace.equalTo(titleDisplacement!)) {
            titleDisplacement = newDisplace
            
            self.titleAnnotation?.displacement = newDisplace;
        }
    }
    
    func setTitlePlotAreaFrameAnchor(newAnchor : CPTRectAnchor)
    {
        if ( newAnchor != titlePlotAreaFrameAnchor ) {
            titlePlotAreaFrameAnchor = newAnchor;
            
            let theTitleAnnotation = self.titleAnnotation;
            if (( theTitleAnnotation ) != nil) {
                theTitleAnnotation?.rectAnchor         = titlePlotAreaFrameAnchor;
                theTitleAnnotation?.contentAnchorPoint = self.contentAnchorForRectAnchor(anchor:titlePlotAreaFrameAnchor!)
            }
        }
    }
    
    /// @endcond
    
    // MARK: - Event Handling
    override func pointingDeviceDownEvent(event : CPTNativeEvent,  atPoint interactionPoint: CGPoint) ->Bool
    {
        // Plots
        let reversedCollection = plots.reversed()
        
        for  plot in reversedCollection {
            if plot.pointingDeviceDownEvent(event:event, atPoint:interactionPoint) {
                return true
            }
        }
        
        // Axes Set
        if ((self.axisSet?.pointingDeviceDownEvent(event :event, atPoint:interactionPoint )) != nil) {
            return true
        }
        
        // Plot area
        if ((self.plotAreaFrame?.pointingDeviceDownEvent(event: event, atPoint:interactionPoint )) != nil) {
            return true
        }
        
        // Legend
        if ((self.legend?.pointingDeviceDownEvent(event:event, atPoint:interactionPoint)) != nil) {
            return true;
        }
        
        // Plot spaces
        // Plot spaces do not block events, because several spaces may need to receive
        // the same event sequence (e.g., dragging coordinate translation)
        
        var handledEvent = false;
        
        for space in self.plotSpaces {
            let handled = space.pointingDeviceDownEvent(event:event, atPoint: interactionPoint)
            handledEvent |= handled;
        }
        
        if  handledEvent == true {
            return true
        }
        else {
            return super.pointingDeviceDownEvent(event :event, atPoint : interactionPoint)
        }
    }
    
    /**
     *  @brief Informs the receiver that the user has
     *  @if MacOnly released the mouse button. @endif
     *  @if iOSOnly lifted their finger off the screen. @endif
     *
     *
     *  The event is passed in turn to the following layers:
     *  -# All plots in reverse order (i.e., from front to back in the layer order)
     *  -# The axis set
     *  -# The plot area
     *  -# The legend
     *
     *  If any layer handles the event, subsequent layers are not notified and
     *  this method immediately returns @YES. If none of the layers
     *  handle the event, it is passed to all plot spaces whether they handle it or not.
     *
     *  @param event The OS event.
     *  @param interactionPoint The coordinates of the interaction.
     *  @return Whether the event was handled or not.
     **/
    override func pointingDeviceUpEvent(event : CPTNativeEvent, atPoint interactionPoint : CGPoint )-> Bool
    {
        var handledEvent = false
        
        // Plots
        let reversedCollection = plots.reversed() 
        for plot in reversedCollection {
            if plot.pointingDeviceUpEvent(event: event, atPoint:interactionPoint ) {
                handledEvent = true
                break;
            }
        }
        
        // Axes Set
        if  !handledEvent && ((self.axisSet?.pointingDeviceUpEvent(event:event, atPoint:interactionPoint )) != nil) {
            handledEvent = true
        }
        
        // Plot area
        if  !handledEvent && ((self.plotAreaFrame?.pointingDeviceUpEvent(event:event, atPoint:interactionPoint)) != nil) {
            handledEvent = true
        }
        
        // Legend
        if  !handledEvent == false && ((self.legend?.pointingDeviceUpEvent(event:event, atPoint:interactionPoint )) != nil) {
            handledEvent = true
        }
        
        // Plot spaces
        // Plot spaces do not block events, because several spaces may need to receive
        // the same event sequence (e.g., dragging coordinate translation)
        for space in plotSpaces  {
            if ( !handledEvent || (handledEvent && space.isDragging)) {
                let handled = space.pointingDeviceUpEvent(event:event, atPoint:interactionPoint)
                handledEvent |= handled;
            }
        }
        
        if ( handledEvent ) {
            return true;
        }
        else {
            return super.pointingDeviceUpEvent(event:event, atPoint:interactionPoint)
        }
    }
    
    override func pointingDeviceDraggedEvent(event : CPTNativeEvent, atPoint interactionPoint:CGPoint)-> Bool
    {
        // Plots
//        let reversedCollection = plots.reversed()
        for  plot in self.plots {
            if plot.pointingDeviceDraggedEvent(event:event, atPoint:interactionPoint ) {
                return true
            }
        }
        
        // Axes Set
        if ((self.axisSet?.pointingDeviceDraggedEvent(event: event, atPoint:interactionPoint )) != nil) {
            return true
        }
        
        // Plot area
        if ((self.plotAreaFrame?.pointingDeviceDraggedEvent(event:event, atPoint:interactionPoint)) != nil) {
            return true
        }
        
        // Legend
        if ((self.legend?.pointingDeviceDraggedEvent(event:event, atPoint:interactionPoint)) != nil) {
            return true
        }
        
        // Plot spaces
        // Plot spaces do not block events, because several spaces may need to receive
        // the same event sequence (e.g., dragging coordinate translation)
        var handledEvent = false
        
        for space in self.plotSpaces  {
            let handled = space.pointingDeviceDraggedEvent(event: event, atPoint:interactionPoint)
            handledEvent |= handled;
        }
        
        if ( handledEvent ) {
            return true
        }
        else {
            return super.pointingDeviceDraggedEvent(event: event, atPoint:interactionPoint)
        }
    }
    
    /**
     *  @brief Informs the receiver that tracking of
     *  @if MacOnly mouse moves @endif
     *  @if iOSOnly touches @endif
     *  has been cancelled for any reason.
     *
     *
     *  The event is passed in turn to the following layers:
     *  -# All plots in reverse order (i.e., from front to back in the layer order)
     *  -# The axis set
     *  -# The plot area
     *  -# The legend
     *
     *  If any layer handles the event, subsequent layers are not notified and
     *  this method immediately returns @YES. If none of the layers
     *  handle the event, it is passed to all plot spaces whether they handle it or not.
     *
     *  @param event The OS event.
     *  @return Whether the event was handled or not.
     **/
    override func pointingDeviceCancelledEvent(event: CPTNativeEvent )-> Bool
    {
        // Plots
        let reversedCollection = plots.reversed()
        for plot in reversedCollection {
            if plot.pointingDeviceCancelledEvent(event: event ) {
                return true
            }
        }
        
        // Axes Set
        if ((self.axisSet?.pointingDeviceCancelledEvent(event: event )) != nil) {
            return true
        }
        
        // Plot area
        if  ((self.plotAreaFrame?.pointingDeviceCancelledEvent( event )) != nil) {
            return true
        }
        
        // Legend
        if ((self.legend?.pointingDeviceCancelledEvent(event)) != nil) {
            return true
        }
        
        // Plot spaces
        var handledEvent = false
        for space in self.plotSpaces  {
            let handled = space.pointingDeviceCancelledEvent(event: event)
            handledEvent = !handled
        }
        
        if ( handledEvent ) {
            return true
        }
        else {
            return super.pointingDeviceCancelledEvent(event)
        }
    }
    
    override func scrollWheelEvent(event: CPTNativeEvent, fromPoint:CGPoint,  toPoint: CGPoint) -> Bool
    {
        // Plots
        let reversedCollection = plots.reversed()
        
        for  plot in reversedCollection  {
            if plot.scrollWheelEvent(event:event, fromPoint:fromPoint, toPoint:toPoint ) {
                return true
            }
        }
        
        // Axes Set
        if ((self.axisSet?.scrollWheelEvent(event: event, fromPoint: fromPoint, toPoint: toPoint)) != nil)  {
            return true
        }
        
        // Plot area
        if ((self.plotAreaFrame?.scrollWheelEvent(event: event, fromPoint:fromPoint, toPoint:toPoint )) != nil) {
            return true
        }
        
        // Legend
        if ((self.legend?.scrollWheelEvent(event :event, fromPoint:fromPoint, toPoint:toPoint )) != nil) {
            return true
        }
        
        // Plot spaces
        var handledEvent = false
        
        for space in self.plotSpaces  {
            let handled = space.scrollWheelEvent(event :event, fromPoint:fromPoint, toPoint:toPoint)
            handledEvent = !handled;
        }
        
        if handledEvent == true {
            return true
        }
        else {
            return super.scrollWheelEvent(event :event, fromPoint:fromPoint, toPoint:toPoint)
        }
    }
    
    
    //    #pragma mark -
    //
    //    @implementation CPTGraph(AbstractFactoryMethods)
    //
    //    /** @brief Creates a new plot space for the graph.
    //     *  @return A new plot space.
    //     **/
    //    -(nullable CPTPlotSpace *)newPlotSpace
    //    {
    //        return nil;
    //    }
    //
    //    /** @brief Creates a new axis set for the graph.
    //     *  @return A new axis set.
    //     **/
    //    -(nullable CPTAxisSet *)newAxisSet
    //    {
    //        return nil;
    //    }
    //
    //    @end
    
    //}
}

extension Array where Element: Equatable {
    
    mutating func removeEqualItems(_ item: Element) {
        self = self.filter { (currentItem: Element) -> Bool in
            return currentItem != item
        }
    }
    
    mutating func removeObject(_ item: Element) {
        guard var currentItem = self.first else { return }
        var index = 0
        while currentItem != item {
            index += 1
            currentItem = self[index]
        }
        self.remove(at: index)
    }
    
}

