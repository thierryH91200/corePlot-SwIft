//
//  CPTGraph ext.swift
//  corePlot
//
//  Created by thierryH24 on 19/11/2020.
//

import Foundation


extension CPTGraph {
   
    
    // MARK: - Drawing

    func layoutAndRenderInContext(context: CGContext)
    {
        self.reloadDataIfNeeded()
        self.axisSet.axes.makeObjectsPerformSelector(@selector(relabel))
        
        if ( [NSView instancesRespondToSelector:@selector(effectiveAppearance)] ) {
            let  *oldAppearance = NSAppearance.currentAppearance;
            let view                = self.hostingView;
            NSAppearance.currentAppearance = view.effectiveAppearance
            super.layoutAndRenderInContext(context)
            NSAppearance.currentAppearance = oldAppearance;
        }
        else {
            super.layoutAndRenderInContext(context: context)
        }
    }

// MARK: Animation
    func needsDisplayForKey(aKey: String )-> Bool
    {
        var keys        = Set<String>()
        
        
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

    /**
     *  @brief Makes all plots reload their data.
     **/
    func reloadData()
    {
        [self.plots makeObjectsPerformSelector:@selector(reloadData)];
        [self.plotSpaces makeObjectsPerformSelector:@selector(removeAllCategories)];
    }

    /**
     *  @brief Makes all plots reload their data if their data cache is out of date.
     **/
    func reloadDataIfNeeded()
    {
        [self.plots makeObjectsPerformSelector:@selector(reloadDataIfNeeded)];
    }

    /** @brief All plots associated with the graph.
     *  @return An array of all plots associated with the graph.
     **/
    -(nonnull CPTPlotArray *)allPlots
    {
        return [NSArray arrayWithArray:self.plots];
    }

    /** @brief Gets the plot at the given index in the plot array.
     *  @param idx An index within the bounds of the plot array.
     *  @return The plot at the given index.
     **/
    func plotAtIndex(idx : Int) -> CPTPlot?
    {
        if ( idx < self.plots.count ) {
            return (self.plots)[idx];
        }
        else {
            return nil;
        }
    }

    /** @brief Gets the plot with the given identifier from the plot array.
     *  @param identifier A plot identifier.
     *  @return The plot with the given identifier or @nil if it was not found.
     **/
    func plotWithIdentifier(identifier: Any)-> CPTPlot?
    {
        for plot in self.plots {
            if (plot.identifier as AnyObject).isEqual(identifier ) {
                return plot;
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
        [self addPlot:plot toPlotSpace:self.defaultPlotSpace];
    }

    /** @brief Add a plot to the given plot space.
     *  @param plot The plot.
     *  @param space The plot space.
     **/
    func addPlot(plot: CPTPlot, space:CPTPlotSpace )
    {
        if ( plot ) {
            [self.plots addObject:plot];
            plot.plotSpace = space;
            plot.graph     = self;
            [self.plotAreaFrame.plotGroup addPlot:plot];
        }
    }

    /** @brief Remove a plot from the graph.
     *  @param plot The plot to remove.
     **/
    func removePlot(plot: CPTPlot )
    {
        if ( plot ) {
            let thePlot = plot;

            if self.plots.contains(plot ) {
                thePlot.plotSpace = nil
                thePlot.graph     = nil
                self.plotAreaFrame.plotGroup.removePlot:thePlot
                self.plots.removeObject:thePlot
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
        [self insertPlot:plot atIndex:idx intoPlotSpace:self.defaultPlotSpace];
    }

    /** @brief Add a plot to the given plot space at the given index in the plot array.
     *  @param plot The plot.
     *  @param idx An index within the bounds of the plot array.
     *  @param space The plot space.
     **/
    func insertPlot(plot: CPTPlot, atIndex:Int, space: CPTPlotSpace)
    {
        if ( plot ) {
            [self.plots insertObject:plot atIndex:idx];
            plot.plotSpace = space;
            plot.graph     = self;
            [self.plotAreaFrame.plotGroup insertPlot:plot atIndex:idx];
        }
    }

    /** @brief Remove a plot from the graph.
     *  @param identifier The identifier of the plot to remove.
     **/
    func removePlotWithIdentifier(identifier: Any)
    {
        CPTPlot *plotToRemove = [self plotWithIdentifier:identifier];

        if ( plotToRemove ) {
            plotToRemove.plotSpace = nil;
            plotToRemove.graph     = nil;
            [self.plotAreaFrame.plotGroup removePlot:plotToRemove];
            [self.plots removeObjectIdenticalTo:plotToRemove];
        }
    }

    // MARK: - Retrieving Plot Spaces

    -(nullable CPTPlotSpace *)defaultPlotSpace
    {
        return self.plotSpaces.count > 0 ? (self.plotSpaces)[0] : nil;
    }

    /** @brief All plot spaces associated with the graph.
     *  @return An array of all plot spaces associated with the graph.
     **/
    -(nonnull CPTPlotSpaceArray *)allPlotSpaces
    {
        return [NSArray arrayWithArray:self.plotSpaces];
    }

    /** @brief Gets the plot space at the given index in the plot space array.
     *  @param idx An index within the bounds of the plot space array.
     *  @return The plot space at the given index.
     **/
    -(nullable CPTPlotSpace *)plotSpaceAtIndex:(NSUInteger)idx
    {
        return self.plotSpaces.count > idx ? (self.plotSpaces)[idx] : nil;
    }

    /** @brief Gets the plot space with the given identifier from the plot space array.
     *  @param identifier A plot space identifier.
     *  @return The plot space with the given identifier or @nil if it was not found.
     **/
    -(nullable CPTPlotSpace *)plotSpaceWithIdentifier:(nullable id<NSCopying>)identifier
    {
        for ( CPTPlotSpace *plotSpace in self.plotSpaces ) {
            if ( [plotSpace.identifier isEqual:identifier] ) {
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
            [plotAreaFrame removeFromSuperlayer];

            plotAreaFrame = newArea;

            if ( newArea ) {
                CPTPlotAreaFrame *theFrame = newArea;

                [self addSublayer:theFrame];
                theFrame.graph = self;
            }

            for space in self.plotSpaces  {
                space.graph = self
            }
        }
    }

    /// @endcond

    // MARK: Organizing Plot Spaces

    /** @brief Add a plot space to the graph.
     *  @param space The plot space.
     **/
    func addPlotSpace(space : CPTPlotSpace )
    {
        NSParameterAssert(space);

        [self.plotSpaces addObject:space];
        space.graph = self;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(plotSpaceMappingDidChange:)
                                                     name:CPTPlotSpaceCoordinateMappingDidChangeNotification
                                                   object:space];

        [[NSNotificationCenter defaultCenter] postNotificationName:CPTGraphDidAddPlotSpaceNotification
                                                            object:self
                                                          userInfo:@{ CPTGraphPlotSpaceNotificationKey: space }
        ];
    }

    /** @brief Remove a plot space from the graph.
     *  @param plotSpace The plot space.
     **/
    func removePlotSpace(plotSpace: CPTPlotSpace )
    {
        if ( plotSpace ) {
            CPTPlotSpace *thePlotSpace = plotSpace;

            if ( [self.plotSpaces containsObject:thePlotSpace] ) {
                [[NSNotificationCenter defaultCenter] removeObserver:self
                                                                name:CPTPlotSpaceCoordinateMappingDidChangeNotification
                                                              object:thePlotSpace];

                // Remove space
                thePlotSpace.graph = nil;
                [self.plotSpaces removeObject:thePlotSpace];

                // Update axes that referenced space
                for ( CPTAxis *axis in self.axisSet.axes ) {
                    if ( axis.plotSpace == thePlotSpace ) {
                        axis.plotSpace = nil;
                    }
                }

                [[NSNotificationCenter defaultCenter] postNotificationName:CPTGraphDidRemovePlotSpaceNotification
                                                                    object:self
                                                                  userInfo:@{ CPTGraphPlotSpaceNotificationKey: thePlotSpace }
                ];
            }
            else {
                [NSException raise:CPTException format:@"Tried to remove CPTPlotSpace which did not exist."];
            }
        }
    }

    #pragma mark -
    #pragma mark Coordinate Changes in Plot Spaces

    /// @cond

    -(void)plotSpaceMappingDidChange:(nonnull NSNotification *)notif
    {
        CPTPlotSpace *plotSpace        = notif.object;
        BOOL backgroundBandsNeedRedraw = NO;

        for ( CPTAxis *axis in self.axisSet.axes ) {
            if ( axis.plotSpace == plotSpace ) {
                [axis setNeedsRelabel];
                [axis updateAxisTitle];

                if ( !backgroundBandsNeedRedraw ) {
                    backgroundBandsNeedRedraw = (axis.alternatingBandFills.count > 0) || (axis.backgroundLimitBands.count > 0);
                }
            }
        }
        for ( CPTPlot *plot in self.plots ) {
            if ( plot.plotSpace == plotSpace ) {
                [plot setNeedsDisplay];
            }
        }
        if ( backgroundBandsNeedRedraw ) {
            [self.plotAreaFrame.plotArea setNeedsDisplay];
        }
    }

    /// @endcond

    #pragma mark -
    #pragma mark Axis Set

    /// @cond

    -(nullable CPTAxisSet *)axisSet
    {
        return self.plotAreaFrame.axisSet;
    }

    -(void)setAxisSet:(nullable CPTAxisSet *)newSet
    {
        self.plotAreaFrame.axisSet = newSet;
    }

    /// @endcond

    #pragma mark -
    #pragma mark Themes

    /** @brief Apply a theme to style the graph.
     *  @param theme The theme object used to style the graph.
     **/
    -(void)applyTheme:(nullable CPTTheme *)theme
    {
        [theme applyThemeToGraph:self];
    }

    #pragma mark -
    #pragma mark Legend

    /// @cond

    -(void)setLegend:(nullable CPTLegend *)newLegend
    {
        if ( newLegend != legend ) {
            legend = newLegend;
            CPTLayerAnnotation *theLegendAnnotation = self.legendAnnotation;
            if ( legend ) {
                if ( theLegendAnnotation ) {
                    theLegendAnnotation.contentLayer = legend;
                }
                else {
                    CPTLayerAnnotation *newLegendAnnotation = [[CPTLayerAnnotation alloc] initWithAnchorLayer:self];
                    newLegendAnnotation.contentLayer       = legend;
                    newLegendAnnotation.displacement       = self.legendDisplacement;
                    newLegendAnnotation.rectAnchor         = self.legendAnchor;
                    newLegendAnnotation.contentAnchorPoint = [self contentAnchorForRectAnchor:self.legendAnchor];
                    [self addAnnotation:newLegendAnnotation];
                    self.legendAnnotation = newLegendAnnotation;
                }
            }
            else {
                if ( theLegendAnnotation ) {
                    [self removeAnnotation:theLegendAnnotation];
                    self.legendAnnotation = nil;
                }
            }
        }
    }

    -(void)setLegendAnchor:(CPTRectAnchor)newLegendAnchor
    {
        if ( newLegendAnchor != legendAnchor ) {
            legendAnchor = newLegendAnchor;
            CPTLayerAnnotation *theLegendAnnotation = self.legendAnnotation;
            if ( theLegendAnnotation ) {
                theLegendAnnotation.rectAnchor         = newLegendAnchor;
                theLegendAnnotation.contentAnchorPoint = [self contentAnchorForRectAnchor:self.legendAnchor];
            }
        }
    }

    -(void)setLegendDisplacement:(CGPoint)newLegendDisplacement
    {
        if ( !CGPointEqualToPoint(newLegendDisplacement, legendDisplacement)) {
            legendDisplacement                 = newLegendDisplacement;
            self.legendAnnotation.displacement = newLegendDisplacement;
        }
    }

    -(CGPoint)contentAnchorForRectAnchor:(CPTRectAnchor)anchor
    {
        CGPoint contentAnchor = CGPointZero;

        switch ( anchor ) {
            case CPTRectAnchorBottomLeft:
                contentAnchor = CGPointZero;
                break;

            case CPTRectAnchorBottom:
                contentAnchor = CPTPointMake(0.5, 0.0);
                break;

            case CPTRectAnchorBottomRight:
                contentAnchor = CPTPointMake(1.0, 0.0);
                break;

            case CPTRectAnchorLeft:
                contentAnchor = CPTPointMake(0.0, 0.5);
                break;

            case CPTRectAnchorRight:
                contentAnchor = CPTPointMake(1.0, 0.5);
                break;

            case CPTRectAnchorTopLeft:
                contentAnchor = CPTPointMake(0.0, 1.0);
                break;

            case CPTRectAnchorTop:
                contentAnchor = CPTPointMake(0.5, 1.0);
                break;

            case CPTRectAnchorTopRight:
                contentAnchor = CPTPointMake(1.0, 1.0);
                break;

            case CPTRectAnchorCenter:
                contentAnchor = CPTPointMake(0.5, 0.5);
                break;
        }

        return contentAnchor;
    }

    /// @endcond

    #pragma mark -
    #pragma mark Accessors

    /// @cond

    -(void)setPaddingLeft:(CGFloat)newPadding
    {
        if ( newPadding != self.paddingLeft ) {
            super.paddingLeft = newPadding;
            [self.axisSet.axes makeObjectsPerformSelector:@selector(setNeedsDisplay)];
        }
    }

    -(void)setPaddingRight:(CGFloat)newPadding
    {
        if ( newPadding != self.paddingRight ) {
            super.paddingRight = newPadding;
            [self.axisSet.axes makeObjectsPerformSelector:@selector(setNeedsDisplay)];
        }
    }

    -(void)setPaddingTop:(CGFloat)newPadding
    {
        if ( newPadding != self.paddingTop ) {
            super.paddingTop = newPadding;
            [self.axisSet.axes makeObjectsPerformSelector:@selector(setNeedsDisplay)];
        }
    }

    -(void)setPaddingBottom:(CGFloat)newPadding
    {
        if ( newPadding != self.paddingBottom ) {
            super.paddingBottom = newPadding;
            [self.axisSet.axes makeObjectsPerformSelector:@selector(setNeedsDisplay)];
        }
    }

    -(nullable CPTNumberArray *)topDownLayerOrder
    {
        return self.plotAreaFrame.plotArea.topDownLayerOrder;
    }

    -(void)setTopDownLayerOrder:(nullable CPTNumberArray *)newArray
    {
        self.plotAreaFrame.plotArea.topDownLayerOrder = newArray;
    }

    -(void)setTitle:(nullable NSString *)newTitle
    {
        if ( newTitle != title ) {
            title = [newTitle copy];

            if ( !self.inTitleUpdate ) {
                self.inTitleUpdate   = true
                self.attributedTitle = nil;
                self.inTitleUpdate   = NO;

                CPTLayerAnnotation *theTitleAnnotation = self.titleAnnotation;

                if ( title ) {
                    if ( theTitleAnnotation ) {
                        ((CPTTextLayer *)theTitleAnnotation.contentLayer).text = title;
                    }
                    else {
                        CPTPlotAreaFrame *frameLayer = self.plotAreaFrame;
                        if ( frameLayer ) {
                            CPTLayerAnnotation *newTitleAnnotation = [[CPTLayerAnnotation alloc] initWithAnchorLayer:frameLayer];
                            CPTTextLayer *newTextLayer             = [[CPTTextLayer alloc] initWithText:title style:self.titleTextStyle];
                            newTitleAnnotation.contentLayer       = newTextLayer;
                            newTitleAnnotation.displacement       = self.titleDisplacement;
                            newTitleAnnotation.rectAnchor         = self.titlePlotAreaFrameAnchor;
                            newTitleAnnotation.contentAnchorPoint = [self contentAnchorForRectAnchor:self.titlePlotAreaFrameAnchor];
                            [self addAnnotation:newTitleAnnotation];
                            self.titleAnnotation = newTitleAnnotation;
                        }
                    }
                }
                else {
                    if ( theTitleAnnotation ) {
                        [self removeAnnotation:theTitleAnnotation];
                        self.titleAnnotation = nil;
                    }
                }
            }
        }
    }

    -(void)setAttributedTitle:(nullable NSAttributedString *)newTitle
    {
        if ( newTitle != attributedTitle ) {
            attributedTitle = [newTitle copy];

            if ( !self.inTitleUpdate ) {
                self.inTitleUpdate = true

                CPTLayerAnnotation *theTitleAnnotation = self.titleAnnotation;

                if ( attributedTitle ) {
                    self.titleTextStyle = [CPTTextStyle textStyleWithAttributes:[attributedTitle attributesAtIndex:0
                                                                                                    effectiveRange:NULL]];
                    self.title = [attributedTitle.string copy];

                    if ( theTitleAnnotation ) {
                        ((CPTTextLayer *)theTitleAnnotation.contentLayer).attributedText = attributedTitle;
                    }
                    else {
                        CPTPlotAreaFrame *frameLayer = self.plotAreaFrame;
                        if ( frameLayer ) {
                            CPTLayerAnnotation *newTitleAnnotation = [[CPTLayerAnnotation alloc] initWithAnchorLayer:frameLayer];
                            CPTTextLayer *newTextLayer             = [[CPTTextLayer alloc] initWithAttributedText:attributedTitle];
                            newTitleAnnotation.contentLayer       = newTextLayer;
                            newTitleAnnotation.displacement       = self.titleDisplacement;
                            newTitleAnnotation.rectAnchor         = self.titlePlotAreaFrameAnchor;
                            newTitleAnnotation.contentAnchorPoint = [self contentAnchorForRectAnchor:self.titlePlotAreaFrameAnchor];
                            [self addAnnotation:newTitleAnnotation];
                            self.titleAnnotation = newTitleAnnotation;
                        }
                    }
                }
                else {
                    self.titleTextStyle = nil;
                    self.title          = nil;

                    if ( theTitleAnnotation ) {
                        [self removeAnnotation:theTitleAnnotation];
                        self.titleAnnotation = nil;
                    }
                }

                self.inTitleUpdate = NO;
            }
        }
    }

func setTitleTextStyle(newStyle: CPTTextStyle )
{
    if ( newStyle != titleTextStyle ) {
        titleTextStyle = newStyle
        
        if ( !self.inTitleUpdate ) {
            self.inTitleUpdate   = true
            self.attributedTitle = nil;
            self.inTitleUpdate   = false;
            
            CPTTextLayer *titleLayer = (CPTTextLayer *)self.titleAnnotation.contentLayer;
            if ( [titleLayer isKindOfClass:[CPTTextLayer class]] ) {
                titleLayer.textStyle = titleTextStyle;
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

            CPTLayerAnnotation *theTitleAnnotation = self.titleAnnotation;
            if ( theTitleAnnotation ) {
                theTitleAnnotation.rectAnchor         = titlePlotAreaFrameAnchor;
                theTitleAnnotation.contentAnchorPoint = [self contentAnchorForRectAnchor:titlePlotAreaFrameAnchor];
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
        for ( CPTPlot *plot in [self.plots reverseObjectEnumerator] ) {
            if ( [plot pointingDeviceDownEvent:event atPoint:interactionPoint] ) {
                return true;
            }
        }

        // Axes Set
        if ( [self.axisSet pointingDeviceDownEvent:event atPoint:interactionPoint] ) {
            return true
        }

        // Plot area
        if ( [self.plotAreaFrame pointingDeviceDownEvent:event atPoint:interactionPoint] ) {
            return true
        }

        // Legend
        if ( [self.legend pointingDeviceDownEvent:event atPoint:interactionPoint] ) {
            return true;
        }

        // Plot spaces
        // Plot spaces do not block events, because several spaces may need to receive
        // the same event sequence (e.g., dragging coordinate translation)
        
        var handledEvent = false;

        for space in self.plotSpaces {
            BOOL handled = [space pointingDeviceDownEvent:event atPoint:interactionPoint];
            handledEvent |= handled;
        }

        if  handledEvent == true {
            return true
        }
        else {
            return [super pointingDeviceDownEvent:event atPoint:interactionPoint];
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
            if ( [plot pointingDeviceUpEvent:event, atPoint:interactionPoint] ) {
                handledEvent = true
                break;
            }
        }

        // Axes Set
        if ( !handledEvent && [self.axisSet pointingDeviceUpEvent:event atPoint:interactionPoint] ) {
            handledEvent = true
        }

        // Plot area
        if ( !handledEvent && [self.plotAreaFrame pointingDeviceUpEvent:event atPoint:interactionPoint] ) {
            handledEvent = true
        }

        // Legend
        if ( !handledEvent && [self.legend pointingDeviceUpEvent:event atPoint:interactionPoint] ) {
            handledEvent = true;
        }

        // Plot spaces
        // Plot spaces do not block events, because several spaces may need to receive
        // the same event sequence (e.g., dragging coordinate translation)
        for ( CPTPlotSpace *space in self.plotSpaces ) {
            if ( !handledEvent || (handledEvent && space.isDragging)) {
                BOOL handled = [space pointingDeviceUpEvent:event atPoint:interactionPoint];
                handledEvent |= handled;
            }
        }

        if ( handledEvent ) {
            return true;
        }
        else {
            return [super pointingDeviceUpEvent:event atPoint:interactionPoint];
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
        for ( CPTPlot *plot in [self.plots reverseObjectEnumerator] ) {
            if ( [plot pointingDeviceDraggedEvent:event atPoint:interactionPoint] ) {
                return true
            }
        }

        // Axes Set
        if ( [self.axisSet pointingDeviceDraggedEvent:event atPoint:interactionPoint] ) {
            return true
        }

        // Plot area
        if ( [self.plotAreaFrame pointingDeviceDraggedEvent:event atPoint:interactionPoint] ) {
            return true
        }

        // Legend
        if ( [self.legend pointingDeviceDraggedEvent:event atPoint:interactionPoint] ) {
            return true
        }

        // Plot spaces
        // Plot spaces do not block events, because several spaces may need to receive
        // the same event sequence (e.g., dragging coordinate translation)
        BOOL handledEvent = NO;

        for space in self.plotSpaces  {
            BOOL handled = [space pointingDeviceDraggedEvent:event atPoint:interactionPoint];
            handledEvent |= handled;
        }

        if ( handledEvent ) {
            return true
        }
        else {
            return [super pointingDeviceDraggedEvent:event atPoint:interactionPoint];
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
        for ( CPTPlot *plot in [self.plots reverseObjectEnumerator] ) {
            if ( [plot pointingDeviceCancelledEvent:event] ) {
                return true
            }
        }

        // Axes Set
    if self.axisSet.pointingDeviceCancelledEvent:(event ) {
            return true
        }

        // Plot area
        if ( [self.plotAreaFrame pointingDeviceCancelledEvent:event] ) {
            return true
        }

        // Legend
        if ( [self.legend pointingDeviceCancelledEvent:event] ) {
            return true
        }

        // Plot spaces
        let handledEvent = false

        for ( CPTPlotSpace *space in self.plotSpaces ) {
            BOOL handled = [space pointingDeviceCancelledEvent:event];
            handledEvent |= handled;
        }

        if ( handledEvent ) {
            return true
        }
        else {
            return super.pointingDeviceCancelledEvent:event];
        }
    }

    #if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
    #else

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
    -(BOOL)scrollWheelEvent:(nonnull CPTNativeEvent *)event fromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint
    {
        // Plots
        for ( CPTPlot *plot in [self.plots reverseObjectEnumerator] ) {
            if ( [plot scrollWheelEvent:event fromPoint:fromPoint toPoint:toPoint] ) {
                return true
            }
        }

        // Axes Set
        if ( [self.axisSet scrollWheelEvent:event fromPoint:fromPoint toPoint:toPoint] ) {
            return true
        }

        // Plot area
        if ( [self.plotAreaFrame scrollWheelEvent:event fromPoint:fromPoint toPoint:toPoint] ) {
            return true
        }

        // Legend
        if ( [self.legend scrollWheelEvent:event fromPoint:fromPoint toPoint:toPoint] ) {
            return true
        }

        // Plot spaces
        BOOL handledEvent = NO;

        for ( CPTPlotSpace *space in self.plotSpaces ) {
            BOOL handled = [space scrollWheelEvent:event fromPoint:fromPoint toPoint:toPoint];
            handledEvent |= handled;
        }

        if ( handledEvent ) {
            return true
        }
        else {
            return [super scrollWheelEvent:event fromPoint:fromPoint toPoint:toPoint];
        }
    }

    #endif

    /// @}

    @end

    #pragma mark -

    @implementation CPTGraph(AbstractFactoryMethods)

    /** @brief Creates a new plot space for the graph.
     *  @return A new plot space.
     **/
    -(nullable CPTPlotSpace *)newPlotSpace
    {
        return nil;
    }

    /** @brief Creates a new axis set for the graph.
     *  @return A new axis set.
     **/
    -(nullable CPTAxisSet *)newAxisSet
    {
        return nil;
    }

    @end

}
