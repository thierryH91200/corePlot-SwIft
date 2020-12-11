//
//  CPTGraph ext.swift
//  corePlot
//
//  Created by thierryH24 on 19/11/2020.
//

import AppKit


extension CPTGraph {
    
    
    // MARK: - Drawing
    override func layoutAndRenderInContext(context: CGContext)
    {
        self.reloadDataIfNeeded()
        
        
        for theAxis in self.axisSet().axes {
            theAxis.relabel()
        }
        
        if  NSView.instancesRespondToSelector(#selector(effectiveAppearance))  {
            let  oldAppearance = NSAppearance.current
            let view  = self.hostingView
            
            NSAppearance.current = view?.effectiveAppearance
            super.layoutAndRenderInContext(context: context)
            NSAppearance.current = oldAppearance
        }
        else {
            super.layoutAndRenderInContext(context: context)
        }
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
    func plotWithIdentifier(identifier: UUID)-> CPTPlot?
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
        self.addPlot(plot: plot , space:self.defaultPlotSpace)
    }
    
    /** @brief Add a plot to the given plot space.
     *  @param plot The plot.
     *  @param space The plot space.
     **/
    func addPlot(plot: CPTPlot, space: CPTPlotSpace )
    {
        if ( plot ) {
            self.plots.append(plot)
            plot.plotSpace = space
            plot.graph     = self;
            self.plotAreaFrame.plotGroup.addPlot(plot)
        }
    }
    
    /** @brief Remove a plot from the graph.
     *  @param plot The plot to remove.
     **/
    func removePlot(plot: CPTPlot )
    {
        if ( plot ) {
            let thePlot = plot
            
            if self.plots.contains(plot ) {
                thePlot.plotSpace = nil
                thePlot.graph     = nil
                self.plotAreaFrame.plotGroup.removePlot(thePlot)
                self.plots.remove(thePlot)
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
    func insertPlot(plot: CPTPlot, atIndex:Int)
    {
        self.insertPlo(plot, atIndex:idx, intoPlotSpace:self.defaultPlotSpace)
    }
    
    /** @brief Add a plot to the given plot space at the given index in the plot array.
     *  @param plot The plot.
     *  @param idx An index within the bounds of the plot array.
     *  @param space The plot space.
     **/
    func insertPlot(plot: CPTPlot, index:Int, space: CPTPlotSpace)
    {
        if ( plot ) {
            self.plots.insert(plot, at: index)
            plot.plotSpace = space
            plot.graph     = self
            self.plotAreaFrame.plotGroup.insertPlot(plot, at: index)
        }
    }
    
    /** @brief Remove a plot from the graph.
     *  @param identifier The identifier of the plot to remove.
     **/
    func removePlotWithIdentifier(identifier: Any)
    {
        let plotToRemove = self.plotWithIdentifier(identifier)
        
        if ( plotToRemove ) {
            plotToRemove.plotSpace = nil
            plotToRemove.graph     = nil
            self.plotAreaFrame.plotGroup.removePlot(plotToRemove)
            self.plots.removeObjectIdenticalTo(plotToRemove)
        }
    }
    
    // MARK: - Retrieving Plot Spaces
    func defaultPlotSpace() ->CPTPlotSpace
    {
        return self.plotSpaces.count > 0 ? (self.plotSpaces)[0] : nil;
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
    func plotSpaceAtIndex(idx : Int) -> CPTPlotSpace
    {
        return self.plotSpaces.count > idx ? self.plotSpaces[idx] : nil
    }
    
    /** @brief Gets the plot space with the given identifier from the plot space array.
     *  @param identifier A plot space identifier.
     *  @return The plot space with the given identifier or @nil if it was not found.
     **/
    func plotSpaceWithIdentifier(identifier: UUID) -> CPTPlotSpace?
    {
        for plotSpace in self.plotSpaces  {
            if plotSpace.identifier == identifier {
                return plotSpace;
            }
        }
        return nil;
    }
    
    // MARK: Set Plot Area
    func setPlotAreaFrame(newArea: CPTPlotAreaFrame)
    {
        if ( plotAreaFrame != newArea ) {
            plotAreaFrame.graph = nil;
            plotAreaFrame.removeFromSuperlayer()
            
            plotAreaFrame = newArea;
            
            if ( newArea ) {
                let theFrame = newArea
                
                self.addSublayer(theFrame)
                theFrame.graph = self;
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
            name:.CPTPlotSpaceCoordinateMapping,
            selector:#selector(plotSpaceMappingDidChange))
        
        NotificationCenter.default.post(
            name: .CPTGraphDidAddPlotSpaceNotification, object: self)
    }
    
    /** @brief Remove a plot space from the graph.
     *  @param plotSpace The plot space.
     **/
    func removePlotSpace(plotSpace: CPTPlotSpace )
    {
        if ( plotSpace ) {
            let thePlotSpace = plotSpace
            
            if self.plotSpaces.contains(thePlotSpace ) {
                NotificationCenter.remove(
                    instance: self,
                    name: .CPTPlotSpaceCoordinateMapping)
                
                // Remove space
                thePlotSpace.graph = nil
                self.plotSpaces.remove(thePlotSpace)
                
                // Update axes that referenced space
                for axis in self.axisSet.axes {
                    if ( axis.plotSpace == thePlotSpace ) {
                        axis.plotSpace = nil
                    }
                }
                
                NotificationCenter.send(
                    .CPTGraphDidRemovePlotSpaceNotification)
                
            }
            else {
                print("Tried to remove CPTPlotSpace which did not exist.")
            }
        }
    }
    
    // MARK: - Coordinate Changes in Plot Spaces
    
    /// @cond
    
    @objc func plotSpaceMappingDidChange(notif: NSNotification )
    {
        let plotSpace        = notif.object as! CPTPlotSpace
        let backgroundBandsNeedRedraw = false;
        
        for axis in self.axisSet().axes {
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
            self.plotAreaFrame.plotArea?.setNeedsDisplay()
        }
    }
    
    // MARK: - Axis Set
    func axisSet() ->CPTAxisSet
    {
        return self.plotAreaFrame.axisSet!
    }
    
    func setAxisSet(newSet :CPTAxisSet )
    {
        self.plotAreaFrame.axisSet = newSet
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
                    self.removeAnnotation(theLegendAnnotation)
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
    
    
    // MARK: - Accessors
    override func setPaddingLeft(newPadding: CGFloat)
    {
        if newPadding != self.paddingLeft  {
            super.paddingLeft = newPadding
            for theAxes in self.axisSet().axes{
                theAxes.setNeedsDisplay()
            }
        }
    }
    
    override func setPaddingRight(newPadding:CGFloat)
    {
        if ( newPadding != self.paddingRight ) {
            super.paddingRight = newPadding;
            for theAxes in self.axisSet().axes{
                theAxes.setNeedsDisplay()
            }
        }
    }
    
    override func setPaddingTop(newPadding:CGFloat)
    {
        if ( newPadding != self.paddingTop ) {
            super.paddingTop = newPadding
            for theAxes in self.axisSet().axes{
                theAxes.setNeedsDisplay()
            }
        }
    }
    
    override func setPaddingBottom(newPadding: CGFloat)
    {
        if ( newPadding != self.paddingBottom ) {
            super.paddingBottom = newPadding
            for theAxes in self.axisSet().axes{
                theAxes.setNeedsDisplay()
            }
        }
    }
    
//    func topDownLayerOrder() -> CPTNumberArray? {
//        return plotAreaFrame.plotArea.topDownLayerOrder()
//    }
    
    func setTopDownLayerOrder(_ newArray: CPTNumberArray?) {
        plotAreaFrame.plotArea.topDownLayerOrder = newArray
    }
    func setTitle(newTitle : String)
    {
        if ( newTitle != title ) {
            title = newTitle
            
            if self.inTitleUpdate == false {
                self.inTitleUpdate   = true
                self.attributedTitle = nil;
                self.inTitleUpdate   = false
                
                let theTitleAnnotation = self.titleAnnotation;
                
                if title != "" {
                    if ( theTitleAnnotation ) {
                        theTitleAnnotation.contentLayer.text = title;
                    }
                    else {
                        let frameLayer = self.plotAreaFrame;
                        if ( frameLayer ) {
                            let newTitleAnnotation = CPTLayerAnnotation( frame: frameLayer)
                            
                            let newTextLayer             = CPTTextLayer(text: title, style: titleTextStyle)
                            
                            newTitleAnnotation.contentLayer       = newTextLayer
                            newTitleAnnotation.displacement       = self.titleDisplacement
                            newTitleAnnotation.rectAnchor         = self.titlePlotAreaFrameAnchor
                            newTitleAnnotation.contentAnchorPoint = self.contentAnchorForRectAnchor(anchor: titlePlotAreaFrameAnchor)
                            self.addAnnotation(newTitleAnnotation)
                            self.titleAnnotation = newTitleAnnotation;
                        }
                    }
                }
                else {
                    if  theTitleAnnotation  {
                        self.removeAnnotation(theTitleAnnotation)
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
                
                if ( attributedTitle ) {
                    //                self.titleTextStyle = [CPTTextStyle textStyleWithAttributes:[attributedTitle attributesAtIndex:0
                    //                                       effectiveRange:NULL]];
                    self.title = attributedTitle
                    
                    if ( theTitleAnnotation ) {
                        theTitleAnnotation.contentLayer.attributedText = attributedTitle;
                    }
                    else {
                        let frameLayer = self.plotAreaFrame;
                        if ( frameLayer ) {
                            //                        let newTitleAnnotation = CPTLayerAnnotation( alloc] initWithAnchorLayer:frameLayer];
                            //                            let newTextLayer             = [[CPTTextLayer alloc] initWithAttributedText:attributedTitle];
                            //                            newTitleAnnotation.contentLayer       = newTextLayer;
                            //                            newTitleAnnotation.displacement       = self.titleDisplacement;
                            //                            newTitleAnnotation.rectAnchor         = self.titlePlotAreaFrameAnchor;
                            //                            newTitleAnnotation.contentAnchorPoint = [self contentAnchorForRectAnchor:self.titlePlotAreaFrameAnchor];
                            //                            [self addAnnotation:newTitleAnnotation];
                            //                            self.titleAnnotation = newTitleAnnotation;
                        }
                    }
                }
                else {
                    self.titleTextStyle = nil;
                    self.title          = nil;
                    
                    if (( theTitleAnnotation ) != nil) {
                        self.removeAnnotation(theTitleAnnotation)
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
                self.inTitleUpdate   = true
                self.attributedTitle = nil
                self.inTitleUpdate   = false
                
                let titleLayer = self.titleAnnotation?.contentLayer
                if ( titleLayer is CPTTextLayer) {
                    titleLayer.textStyle = titleTextStyle
                }
            }
        }
    }
    
    func setTitleDisplacement(newDisplace:CGPoint)
    {
        if ( !CGPointEqualToPoint(newDisplace, titleDisplacement)) {
            titleDisplacement = newDisplace;
            
            self.titleAnnotation.displacement = newDisplace;
        }
    }
    
    func setTitlePlotAreaFrameAnchor(newAnchor : CPTRectAnchor)
    {
        if ( newAnchor != titlePlotAreaFrameAnchor ) {
            titlePlotAreaFrameAnchor = newAnchor;
            
            theTitleAnnotation = self.titleAnnotation;
            if ( theTitleAnnotation ) {
                theTitleAnnotation.rectAnchor         = titlePlotAreaFrameAnchor;
                theTitleAnnotation.contentAnchorPoint = self.contentAnchorForRectAnchor(anchor:titlePlotAreaFrameAnchor)
            }
        }
    }
    
    /// @endcond
    
    // MARK: - Event Handling
    
    /// @name User Interaction
    /// @{
    
    /**
     *  @brief Informs the receiver that the user has
     *  @if MacOnly pressed the mouse button. @endif
     *  @if iOSOnly touched the screen. @endif
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
    func pointingDeviceDownEvent(event :CPTNativeEvent, interactionPoint:CGPoint) ->Bool
    {
        // Plots
        let reversedCollection = plots.reversed()
        
        for  plot in reversedCollection {
            if plot.pointingDeviceDownEvent(event:event, atPoint:interactionPoint) {
                return true
            }
        }
        
        // Axes Set
        if self.axisSet.pointingDeviceDownEvent(event :event, atPoint:interactionPoint ) {
            return true
        }
        
        // Plot area
        if self.plotAreaFrame.ointingDeviceDownEvent(event: event, atPoint:interactionPoint ) {
            return true
        }
        
        // Legend
        if self.legend.pointingDeviceDownEvent(event:event, atPoint:interactionPoint) {
            return true;
        }
        
        // Plot spaces
        // Plot spaces do not block events, because several spaces may need to receive
        // the same event sequence (e.g., dragging coordinate translation)
        
        var handledEvent = false;
        
        for space in self.plotSpaces {
            let handled = space.pointingDeviceDownEvent(event:event, atPoint:interactionPoint)
            handledEvent |= handled;
        }
        
        if  handledEvent == true {
            return true
        }
        else {
            return super.pointingDeviceDownEvent(event :event, atPoint:interactionPoint)
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
    func pointingDeviceUpEvent(event : CPTNativeEvent, interactionPoint:CGPoint)-> Bool
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
        if  !handledEvent && self.axisSet.pointingDeviceUpEvent(event:event, atPoint:interactionPoint ) {
            handledEvent = true
        }
        
        // Plot area
        if  !handledEvent && self.plotAreaFrame.pointingDeviceUpEvent(event:event, atPoint:interactionPoint) {
            handledEvent = true
        }
        
        // Legend
        if  !handledEvent == false && self.legend.pointingDeviceUpEvent(event:event, atPoint:interactionPoint ) {
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
    
    /**
     *  @brief Informs the receiver that the user has moved
     *  @if MacOnly the mouse with the button pressed. @endif
     *  @if iOSOnly their finger while touching the screen. @endif
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
    func pointingDeviceDraggedEvent(event : CPTNativeEvent, atPoint:CGPoint)-> Bool
    {
        // Plots
        let reversedCollection = plots.reversed()
        for  plot in self.plots {
            if plot.pointingDeviceDraggedEvent(event:event, atPoint:interactionPoint ) {
                return true
            }
        }
        
        // Axes Set
        if self.axisSet.pointingDeviceDraggedEvent(event: event, atPoint:interactionPoint ) {
            return true
        }
        
        // Plot area
        if self.plotAreaFrame.pointingDeviceDraggedEvent(event:event, atPoint:interactionPoint) {
            return true
        }
        
        // Legend
        if self.legend.pointingDeviceDraggedEvent(event:event, atPoint:interactionPoint) {
            return true
        }
        
        // Plot spaces
        // Plot spaces do not block events, because several spaces may need to receive
        // the same event sequence (e.g., dragging coordinate translation)
        var handledEvent = false
        
        for space in self.plotSpaces  {
            let handled = space.pointingDeviceDraggedEvent(event, atPoint:interactionPoint)
            handledEvent |= handled;
        }
        
        if ( handledEvent ) {
            return true
        }
        else {
            return super.pointingDeviceDraggedEvent(event, atPoint:interactionPoint)
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
    func pointingDeviceCancelledEvent(event: CPTNativeEvent )-> Bool
    {
        // Plots
        let reversedCollection = plots.reversed()
        for plot in reversedCollection {
            if plot.pointingDeviceCancelledEvent(event: event ) {
                return true
            }
        }
        
        // Axes Set
        if self.axisSet.pointingDeviceCancelledEvent(event ) {
            return true
        }
        
        // Plot area
        if  self.plotAreaFrame.pointingDeviceCancelledEvent( event ) {
            return true
        }
        
        // Legend
        if self.legend.pointingDeviceCancelledEvent(event) {
            return true
        }
        
        // Plot spaces
        let handledEvent = false
        
        for space in self.plotSpaces  {
            let handled = space.pointingDeviceCancelledEvent(event)
            handledEvent |= handled
        }
        
        if ( handledEvent ) {
            return true
        }
        else {
            return super.pointingDeviceCancelledEvent(event)
        }
    }
    
    /**
     *  @brief @required Informs the receiver that the user has moved the scroll wheel.
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
     *  @param fromPoint The starting coordinates of the interaction.
     *  @param toPoint The ending coordinates of the interaction.
     *  @return Whether the event was handled or not.
     **/
    @objc func scrollWheelEvent(event: CPTNativeEvent, fromPoint:CGPoint,  toPoint: CGPoint) -> Bool
    {
        // Plots
        let reversedCollection = plots.reversed()
        
        for  plot in reversedCollection  {
            if plot.scrollWheelEvent(event:event, fromPoint:fromPoint, toPoint:toPoint ) {
                return true
            }
        }
        
        // Axes Set
        if self.axisSet.scrollWheelEvent(event: event, fromPoint: fromPoint, toPoint: toPoint)  {
            return true
        }
        
        // Plot area
        if self.plotAreaFrame.scrollWheelEvent(event: event, fromPoint:fromPoint, toPoint:toPoint ) {
            return true
        }
        
        // Legend
        if ((self.legend?.scrollWheelEvent(event :event, fromPoint:fromPoint, toPoint:toPoint )) != nil) {
            return true
        }
        
        // Plot spaces
        let handledEvent = false
        
        for space in self.plotSpaces  {
            let handled = space.scrollWheelEvent(event :event, fromPoint:fromPoint, toPoint:toPoint)
            handledEvent |= handled;
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
