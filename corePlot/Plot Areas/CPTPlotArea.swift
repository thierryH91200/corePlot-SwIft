//
//  CPTPlotArea.swift
//  corePlot
//
//  Created by thierryH24 on 11/11/2020.
//

import AppKit

class CPTPlotArea: CPTAnnotationHostLayer {
    
    let kCPTNumberOfLayers = 6; // number of primary layers to arrange

    
    var touchedPoint = CGPoint(x: 0,y: 0)
    var bottomUpLayerOrder : CPTGraphLayerType?
    
    //MARK: Layers
    var minorGridLineGroup : CPTGridLineGroup?
    var majorGridLineGroup: CPTGridLineGroup?
    var axisSet: CPTAxisSet?
    var plotGroup: CPTPlotGroup?
    var axisLabelGroup : CPTAxisLabelGroup?
    var axisTitleGroup: CPTAxisLabelGroup?

    //MARK:  Layer Ordering
    var topDownLayerOrder = [CGFloat]()

    //MARK:  Decorations
    var borderLineStyle: CPTLineStyle?
    var fill: CPTFill?

    //MARK:  Dimensions
    var   widthDecimal = CGFloat(0)
    var  heightDecimal = CGFloat(0)
    
    //MARK:  Init/Dealloc
    override init(frame:CGRect)
    {
        super.init()
        
        minorGridLineGroup = nil;
        majorGridLineGroup = nil;
        axisSet            = nil;
        plotGroup          = nil;
        axisLabelGroup     = nil;
        axisTitleGroup     = nil;
        fill               = nil;
        touchedPoint       = CGPoint(x:CGFloat.nan,y:  CGFloat.nan)
        topDownLayerOrder.removeAll()
        
        bottomUpLayerOrder = calloc(kCPTNumberOfLayers, sizeof(CPTGraphLayerType));
        
        self.updateLayerOrder()
        
        let newPlotGroup = CPTPlotGroup(frame:frame)
        self.plotGroup = newPlotGroup;
        
        let boundsSize = self.bounds.size;
        widthDecimal  = boundsSize.width
        heightDecimal = boundsSize.height
        
        self.needsDisplayOnBoundsChange = true;
    }

    override init(layer: Any)
    {
        super.init(layer:layer)
        let theLayer = CPTPlotArea(layer: layer)
        
        minorGridLineGroup = theLayer.minorGridLineGroup;
        majorGridLineGroup = theLayer.majorGridLineGroup;
        axisSet            = theLayer.axisSet;
        plotGroup          = theLayer.plotGroup;
        axisLabelGroup     = theLayer.axisLabelGroup;
        axisTitleGroup     = theLayer.axisTitleGroup;
        fill               = theLayer.fill;
        touchedPoint       = theLayer.touchedPoint;
        topDownLayerOrder  = theLayer.topDownLayerOrder;
        bottomUpLayerOrder = calloc(kCPTNumberOfLayers, sizeof(CPTGraphLayerType));
        memcpy(bottomUpLayerOrder, theLayer.bottomUpLayerOrder, kCPTNumberOfLayers * sizeof(CPTGraphLayerType));
        widthDecimal  = theLayer.widthDecimal;
        heightDecimal = theLayer.heightDecimal;
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func renderAsVectorInContext(context: CGContext)
    {
        guard self.isHidden == false else {  return }

        super.renderAsVectorInContext(context: context)

        let useMask = self.masksToBounds;

        self.masksToBounds = true;
        context.saveGState();

        let maskPath = self.maskingPath;

        if ( maskPath ) {
            context.beginPath();
            CGContextAddPath(context, maskPath);
            context.clip();
        }

        self.fill?.fillRect(rect: self.bounds, inContext:context)

        let theAxes = self.axisSet?.axes

        for axis in theAxes! {
            axis.drawBackgroundBandsInContext(context)
        }
        for axis in theAxes {
            axis.drawBackgroundLimitsInContext(context)
        }

        context.restoreGState()
        self.masksToBounds = useMask
    }





//
//    #pragma mark -
//    #pragma mark Layer ordering
//
//    /// @cond
//
    func updateLayerOrder()
    {
        let buLayerOrder = self.bottomUpLayerOrder;
        
        for ( size_t i = 0; i < kCPTNumberOfLayers; i++ ) {
            *(buLayerOrder++) = (CPTGraphLayerType)i;
        }
        
        CPTNumberArray *tdLayerOrder = self.topDownLayerOrder;
        
        if ( tdLayerOrder ) {
            buLayerOrder = self.bottomUpLayerOrder;
            
            for ( NSUInteger layerIndex = 0; layerIndex < tdLayerOrder.count; layerIndex++ ) {
                CPTGraphLayerType layerType = (CPTGraphLayerType)tdLayerOrder[layerIndex].intValue;
                NSUInteger i                = kCPTNumberOfLayers - layerIndex - 1;
                while ( buLayerOrder[i] != layerType ) {
                    if ( i == 0 ) {
                        break;
                    }
                    i--;
                }
                while ( i < kCPTNumberOfLayers - layerIndex - 1 ) {
                    buLayerOrder[i] = buLayerOrder[i + 1];
                    i++;
                }
                buLayerOrder[kCPTNumberOfLayers - layerIndex - 1] = layerType;
            }
        }
        
        // force the layer hierarchy to update
        self.updatingLayers     = true;
        self.minorGridLineGroup = self.minorGridLineGroup;
        self.majorGridLineGroup = self.majorGridLineGroup;
        self.axisSet            = self.axisSet;
        self.plotGroup          = self.plotGroup;
        self.axisLabelGroup     = self.axisLabelGroup;
        self.axisTitleGroup     = self.axisTitleGroup;
        self.updatingLayers     = NO;
    }

    func layerType()->indexForLayerType
    {
        let buLayerOrder = self.bottomUpLayerOrder;
        Int idx                    = 0

        for ( size_t i = 0; i < kCPTNumberOfLayers; i++ ) {
            if ( buLayerOrder[i] == layerType ) {
                break;
            }
            switch ( buLayerOrder[i] ) {
                case CPTGraphLayerTypeMinorGridLines:
                    if ( self.minorGridLineGroup ) {
                        idx++;
                    }
                    break;

                case CPTGraphLayerTypeMajorGridLines:
                    if ( self.majorGridLineGroup ) {
                        idx++;
                    }
                    break;

                case CPTGraphLayerTypeAxisLines:
                    if ( self.axisSet ) {
                        idx++;
                    }
                    break;

                case CPTGraphLayerTypePlots:
                    if ( self.plotGroup ) {
                        idx++;
                    }
                    break;

                case CPTGraphLayerTypeAxisLabels:
                    if ( self.axisLabelGroup ) {
                        idx++;
                    }
                    break;

                case CPTGraphLayerTypeAxisTitles:
                    if ( self.axisTitleGroup ) {
                        idx++;
                    }
                    break;
            }
        }
        return idx;
    }
    
    
    
// MARK: - mark Axis set layer management
//
//    /** @brief Checks for the presence of the specified layer group and adds or removes it as needed.
//     *  @param layerType The layer type being updated.
//     **/
    func updateAxisSetLayersForType(layerType: CPTGraphLayerType)
    {
        var needsLayer = false
        var theAxisSet = self.axisSet
        
        for axis in theAxisSet!.axes {
            switch ( layerType ) {
            case .minorGridLines:
                if (( axis.minorGridLineStyle ) != nil) {
                    needsLayer = true
                }
                break;
                
            case .majorGridLines:
                if (( axis.majorGridLineStyle ) != nil) {
                    needsLayer = true
                }
                break;
                
            case .axisLabels:
                if ( axis.axisLabels.count > 0 ) {
                    needsLayer = true
                }
                break;
                
            case .axisTitles:
                if (( axis.axisTitle ) != nil) {
                    needsLayer = true
                }
                break;
                
            default:
                break;
            }
        }
        
        if needsLayer == true {
            self.setAxisSetLayersForType(layerType: layerType)
        }
        else {
            switch ( layerType ) {
            case .minorGridLines:
                self.minorGridLineGroup = nil;
                break;
                
            case .majorGridLines:
                self.majorGridLineGroup = nil;
                break;
                
            case .axisLabels:
                self.axisLabelGroup = nil;
                break;
                
            case .axisTitles:
                self.axisTitleGroup = nil;
                break;
                
            default:
                break;
            }
        }
    }
//
//    /** @brief Ensures that a group layer is set for the given layer type.
//     *  @param layerType The layer type being updated.
//     **/
    func setAxisSetLayersForType(layerType: CPTGraphLayerType)
    {
        switch ( layerType ) {
        case .minorGridLines:
            if ( self.minorGridLineGroup == nil ) {
                self.minorGridLineGroup = CPTGridLineGroup(frame: self.bounds)
            }
            break
            
        case .majorGridLines:
            if ( (self.majorGridLineGroup == nil) ) {
                self.majorGridLineGroup = CPTGridLineGroup(frame:self.bounds)
            }
            break
            
        case .axisLabels:
            if ( (self.axisLabelGroup == nil) ) {
                self.axisLabelGroup = CPTAxisLabelGroup(frame:self.bounds)
            }
            break
            
        case .axisTitles:
            if ( (self.axisTitleGroup == nil) ) {
                self.axisTitleGroup = CPTAxisLabelGroup(frame:self.bounds)
            }
            break
            
        default:
            break;
        }
    }
//
//    /** @brief Computes the sublayer index for the given layer type and axis.
//     *  @param axis The axis of interest.
//     *  @param layerType The layer type being updated.
//     *  @return The sublayer index for the given layer type.
//     **/
    func sublayerIndexForAxis(axis: CPTAxis , layerType:CPTGraphLayerType)->Int
    {
        var idx = 0;
        
        for currentAxis in self.axisSet!.axes  {
            if ( currentAxis == axis ) {
                break;
            }
            
            switch ( layerType ) {
            case .minorGridLines:
                if (( currentAxis.minorGridLineStyle ) != nil) {
                    idx += 1
                }
                break;
                
            case .majorGridLines:
                if (( currentAxis.majorGridLineStyle ) != nil) {
                    idx += 1
                }
                break;
                
            case .axisLabels:
                if ( currentAxis.axisLabels.count > 0 ) {
                    idx += 1
                }
                break;
                
            case .axisTitles:
                if (( currentAxis.axisTitle ) != nil) {
                    idx += 1
                }
                break;
                
            default:
                break;
            }
        }
        
        return idx;
    }

// MARK: - Event Handling
//
//    /// @name User Interaction
//    /// @{
//
//    /**
//     *  @brief Informs the receiver that the user has
//     *  @if MacOnly pressed the mouse button. @endif
//     *  @if iOSOnly touched the screen. @endif
//     *
//     *
//     *  If this plot area has a delegate that responds to the
//     *  @link CPTPlotAreaDelegate::plotAreaTouchDown: -plotAreaTouchDown: @endlink and/or
//     *  @link CPTPlotAreaDelegate::plotAreaTouchDown:withEvent: -plotAreaTouchDown:withEvent: @endlink
//     *  methods, the delegate method will be called and this method returns @true if the @par{interactionPoint} is within the
//     *  plot area bounds.
//     *
//     *  @param event The OS event.
//     *  @param interactionPoint The coordinates of the interaction.
//     *  @return Whether the event was handled or not.
//     **/
//    -(BOOL)pointingDeviceDownEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
//    {
//        CPTGraph *theGraph = self.graph;
//
//        if ( !theGraph || self.hidden ) {
//            return NO;
//        }
//
//        id<CPTPlotAreaDelegate> theDelegate = (id<CPTPlotAreaDelegate>)self.delegate;
//
//        if ( [theDelegate respondsToSelector:@selector(plotAreaTouchDown:)] ||
//             [theDelegate respondsToSelector:@selector(plotAreaTouchDown:withEvent:)] ||
//             [theDelegate respondsToSelector:@selector(plotAreaWasSelected:)] ||
//             [theDelegate respondsToSelector:@selector(plotAreaWasSelected:withEvent:)] ) {
//            // Inform delegate if a point was hit
//            CGPoint plotAreaPoint = [theGraph convertPoint:interactionPoint toLayer:self];
//
//            if ( CGRectContainsPoint(self.bounds, plotAreaPoint)) {
//                self.touchedPoint = plotAreaPoint;
//
//                if ( [theDelegate respondsToSelector:@selector(plotAreaTouchDown:)] ) {
//                    [theDelegate plotAreaTouchDown:self];
//                }
//                if ( [theDelegate respondsToSelector:@selector(plotAreaTouchDown:withEvent:)] ) {
//                    [theDelegate plotAreaTouchDown:self withEvent:event];
//                }
//
//                return NO; // don't block other events in the responder chain
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
//     *  If this plot area has a delegate that responds to the
//     *  @link CPTPlotAreaDelegate::plotAreaTouchUp: -plotAreaTouchUp: @endlink,
//     *  @link CPTPlotAreaDelegate::plotAreaTouchUp:withEvent: -plotAreaTouchUp:withEvent: @endlink,
//     *  @link CPTPlotAreaDelegate::plotAreaWasSelected: -plotAreaWasSelected: @endlink, and/or
//     *  @link CPTPlotAreaDelegate::plotAreaWasSelected:withEvent: -plotAreaWasSelected:withEvent: @endlink
//     *  methods, the delegate method will be called and this method returns @true if the @par{interactionPoint} is within the
//     *  plot area bounds.
//     *
//     *  @param event The OS event.
//     *  @param interactionPoint The coordinates of the interaction.
//     *  @return Whether the event was handled or not.
//     **/
//    -(BOOL)pointingDeviceUpEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
//    {
//        CPTGraph *theGraph = self.graph;
//
//        if ( !theGraph || self.hidden ) {
//            return NO;
//        }
//
//        CGPoint lastPoint = self.touchedPoint;
//
//        self.touchedPoint = CPTPointMake(NAN, NAN);
//
//        id<CPTPlotAreaDelegate> theDelegate = (id<CPTPlotAreaDelegate>)self.delegate;
//
//        if ( [theDelegate respondsToSelector:@selector(plotAreaTouchUp:)] ||
//             [theDelegate respondsToSelector:@selector(plotAreaTouchUp:withEvent:)] ||
//             [theDelegate respondsToSelector:@selector(plotAreaWasSelected:)] ||
//             [theDelegate respondsToSelector:@selector(plotAreaWasSelected:withEvent:)] ) {
//            // Inform delegate if a point was hit
//            CGPoint plotAreaPoint = [theGraph convertPoint:interactionPoint toLayer:self];
//
//            if ( CGRectContainsPoint(self.bounds, plotAreaPoint)) {
//                CGVector offset = CGVectorMake(plotAreaPoint.x - lastPoint.x, plotAreaPoint.y - lastPoint.y);
//                if ((offset.dx * offset.dx + offset.dy * offset.dy) <= CPTFloat(25.0)) {
//                    if ( [theDelegate respondsToSelector:@selector(plotAreaTouchUp:)] ) {
//                        [theDelegate plotAreaTouchUp:self];
//                    }
//
//                    if ( [theDelegate respondsToSelector:@selector(plotAreaTouchUp:withEvent:)] ) {
//                        [theDelegate plotAreaTouchUp:self withEvent:event];
//                    }
//
//                    if ( [theDelegate respondsToSelector:@selector(plotAreaWasSelected:)] ) {
//                        [theDelegate plotAreaWasSelected:self];
//                    }
//
//                    if ( [theDelegate respondsToSelector:@selector(plotAreaWasSelected:withEvent:)] ) {
//                        [theDelegate plotAreaWasSelected:self withEvent:event];
//                    }
//
//                    return NO; // don't block other events in the responder chain
//                }
//            }
//        }
//
//        return [super pointingDeviceUpEvent:event atPoint:interactionPoint];
//    }
//
//    /// @}
//

    
    // MARK: - Accessors
//
//    /// @cond
//
//    -(nullable CPTLineStyle *)borderLineStyle
//    {
//        return self.axisSet.borderLineStyle;
//    }
//
//    -(void)setBorderLineStyle:(nullable CPTLineStyle *)newLineStyle
//    {
//        self.axisSet.borderLineStyle = newLineStyle;
//    }
//
//    -(void)setFill:(nullable CPTFill *)newFill
//    {
//        if ( newFill != fill ) {
//            fill = [newFill copy];
//            [self setNeedsDisplay];
//        }
//    }
//
//    -(void)setMinorGridLineGroup:(nullable CPTGridLineGroup *)newGridLines
//    {
//        if ((newGridLines != minorGridLineGroup) || self.isUpdatingLayers ) {
//            [minorGridLineGroup removeFromSuperlayer];
//            minorGridLineGroup = newGridLines;
//            if ( newGridLines ) {
//                CPTGridLineGroup *gridLines = newGridLines;
//
//                gridLines.plotArea = self;
//                gridLines.major    = NO;
//                [self insertSublayer:gridLines atIndex:[self indexForLayerType:CPTGraphLayerTypeMinorGridLines]];
//            }
//            [self setNeedsLayout];
//        }
//    }
//
//    -(void)setMajorGridLineGroup:(nullable CPTGridLineGroup *)newGridLines
//    {
//        if ((newGridLines != majorGridLineGroup) || self.isUpdatingLayers ) {
//            [majorGridLineGroup removeFromSuperlayer];
//            majorGridLineGroup = newGridLines;
//            if ( newGridLines ) {
//                CPTGridLineGroup *gridLines = newGridLines;
//
//                gridLines.plotArea = self;
//                gridLines.major    = true;
//                [self insertSublayer:gridLines atIndex:[self indexForLayerType:CPTGraphLayerTypeMajorGridLines]];
//            }
//            [self setNeedsLayout];
//        }
//    }
//
//    -(void)setAxisSet:(nullable CPTAxisSet *)newAxisSet
//    {
//        if ((newAxisSet != axisSet) || self.isUpdatingLayers ) {
//            [axisSet removeFromSuperlayer];
//            for ( CPTAxis *axis in axisSet.axes ) {
//                axis.plotArea = nil;
//            }
//
//            axisSet = newAxisSet;
//            [self updateAxisSetLayersForType:CPTGraphLayerTypeMajorGridLines];
//            [self updateAxisSetLayersForType:CPTGraphLayerTypeMinorGridLines];
//            [self updateAxisSetLayersForType:CPTGraphLayerTypeAxisLabels];
//            [self updateAxisSetLayersForType:CPTGraphLayerTypeAxisTitles];
//
//            if ( newAxisSet ) {
//                CPTGraph *theGraph     = self.graph;
//                CPTAxisSet *theAxisSet = newAxisSet;
//
//                [self insertSublayer:theAxisSet atIndex:[self indexForLayerType:CPTGraphLayerTypeAxisLines]];
//                for ( CPTAxis *axis in theAxisSet.axes ) {
//                    axis.plotArea = self;
//                    axis.graph    = theGraph;
//                }
//            }
//            [self setNeedsLayout];
//        }
//    }
//
//    -(void)setPlotGroup:(nullable CPTPlotGroup *)newPlotGroup
//    {
//        if ((newPlotGroup != plotGroup) || self.isUpdatingLayers ) {
//            [plotGroup removeFromSuperlayer];
//            plotGroup = newPlotGroup;
//            if ( newPlotGroup ) {
//                CPTPlotGroup *group = newPlotGroup;
//
//                [self insertSublayer:group atIndex:[self indexForLayerType:CPTGraphLayerTypePlots]];
//            }
//            [self setNeedsLayout];
//        }
//    }
//
//    -(void)setAxisLabelGroup:(nullable CPTAxisLabelGroup *)newAxisLabelGroup
//    {
//        if ((newAxisLabelGroup != axisLabelGroup) || self.isUpdatingLayers ) {
//            [axisLabelGroup removeFromSuperlayer];
//            axisLabelGroup = newAxisLabelGroup;
//            if ( newAxisLabelGroup ) {
//                CPTAxisLabelGroup *group = newAxisLabelGroup;
//
//                [self insertSublayer:group atIndex:[self indexForLayerType:CPTGraphLayerTypeAxisLabels]];
//            }
//            [self setNeedsLayout];
//        }
//    }
//
//    -(void)setAxisTitleGroup:(nullable CPTAxisLabelGroup *)newAxisTitleGroup
//    {
//        if ((newAxisTitleGroup != axisTitleGroup) || self.isUpdatingLayers ) {
//            [axisTitleGroup removeFromSuperlayer];
//            axisTitleGroup = newAxisTitleGroup;
//            if ( newAxisTitleGroup ) {
//                CPTAxisLabelGroup *group = newAxisTitleGroup;
//
//                [self insertSublayer:group atIndex:[self indexForLayerType:CPTGraphLayerTypeAxisTitles]];
//            }
//            [self setNeedsLayout];
//        }
//    }
//
//    -(void)setTopDownLayerOrder:(nullable CPTNumberArray *)newArray
//    {
//        if ( newArray != topDownLayerOrder ) {
//            topDownLayerOrder = newArray;
//            [self updateLayerOrder];
//        }
//    }
//
//    -(void)setGraph:(nullable CPTGraph *)newGraph
//    {
//        if ( newGraph != self.graph ) {
//            super.graph = newGraph;
//
//            for ( CPTAxis *axis in self.axisSet.axes ) {
//                axis.graph = newGraph;
//            }
//        }
//    }
//
//    -(void)setBounds:(CGRect)newBounds
//    {
//        if ( !CGRectEqualToRect(self.bounds, newBounds)) {
//            self.widthDecimal  = CPTDecimalFromCGFloat(newBounds.size.width);
//            self.heightDecimal = CPTDecimalFromCGFloat(newBounds.size.height);
//
//            super.bounds = newBounds;
//        }
//    }
//
//    /// @endcond
//
//    @end
//
//


}
