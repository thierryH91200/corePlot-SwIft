//
//  CPTPlotArea.swift
//  corePlot
//
//  Created by thierryH24 on 11/11/2020.
//

import AppKit

@objc
public protocol CPTLayerDelegate: CALayerDelegate {
    
    @objc optional func plotAreaWasSelected( plotArea: CPTPlotArea )
    func plotAreaWasSelected( plotArea: CPTPlotArea, withEvent event: CPTNativeEvent )
    @objc optional func plotAreaTouchDown  ( plotArea: CPTPlotArea )
    @objc optional func plotAreaTouchDown  ( plotArea: CPTPlotArea, withEvent event: CPTNativeEvent)
    func plotAreaTouchUp    ( plotArea: CPTPlotArea)
    func plotAreaTouchUp    ( plotArea: CPTPlotArea, withEvent event: CPTNativeEvent)
}


public class CPTPlotArea: CPTAnnotationHostLayer {
    
    let kCPTNumberOfLayers = 6; // number of primary layers to arrange

    var touchedPoint = CGPoint(x: 0,y: 0)
    
    //MARK: Layers
    var minorGridLineGroup : CPTGridLineGroup?
    var majorGridLineGroup : CPTGridLineGroup?
    var axisSet: CPTAxisSet?
    var plotGroup: CPTPlotGroup?
    var axisLabelGroup : CPTAxisLabelGroup?
    var axisTitleGroup : CPTAxisLabelGroup?

    //MARK:  Layer Ordering
    var topDownLayerOrder = [CGFloat]()
    var bottomUpLayerOrder = [CPTGraphLayerType]()

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
        
        minorGridLineGroup = nil
        majorGridLineGroup = nil
        axisSet            = nil
        plotGroup          = nil
        axisLabelGroup     = nil
        axisTitleGroup     = nil
        fill               = nil
        touchedPoint       = CGPoint(x:CGFloat.nan,y:  CGFloat.nan)
        topDownLayerOrder.removeAll()
        
        bottomUpLayerOrder.removeAll()
        
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
        
        widthDecimal  = theLayer.widthDecimal
        heightDecimal = theLayer.heightDecimal
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

        if (( maskPath ) != nil) {
            context.beginPath();
            context.addPath(maskPath!);
            context.clip();
        }

        self.fill?.fillRect(rect: self.bounds, inContext:context)
        let theAxes = self.axisSet?.axes

        for axis in theAxes! {
            axis.drawBackgroundBandsInContext(context: context)
        }
        for axis in theAxes! {
            axis.drawBackgroundLimitsInContext(context: context)
        }

        context.restoreGState()
        self.masksToBounds = useMask
    }

    // MARK: -  Layer ordering
    func updateLayerOrder()
    {
        var buLayerOrder = self.bottomUpLayerOrder;
        
        for  i in 0..<kCPTNumberOfLayers {
            buLayerOrder.append (i)
        }
        
        let tdLayerOrder = self.topDownLayerOrder;
        
        if  tdLayerOrder {
            buLayerOrder = self.bottomUpLayerOrder;
            
            for layerIndex in 0..<tdLayerOrder.count {
                let layerType = tdLayerOrder[layerIndex]
                var i  = kCPTNumberOfLayers - layerIndex - 1;
                
                while ( buLayerOrder[i] != layerType ) {
                    if ( i == 0 ) {
                        break;
                    }
                    i -= 1
                }
                while ( i < kCPTNumberOfLayers - layerIndex - 1 ) {
                    buLayerOrder[i] = buLayerOrder[i + 1];
                    i += 1
                }
                buLayerOrder[kCPTNumberOfLayers - layerIndex - 1] = layerType;
            }
        }
        
        // force the layer hierarchy to update
//        self.updatingLayers     = true;
//        self.minorGridLineGroup = minorGridLineGroup;
//        self.majorGridLineGroup = .majorGridLineGroup;
//        self.axisSet            = self.axisSet;
//        self.plotGroup          = self.plotGroup;
//        self.axisLabelGroup     = self.axisLabelGroup;
//        self.axisTitleGroup     = self.axisTitleGroup;
//        self.updatingLayers     = false
    }
    
    func indexForLayerType(layerType: CPTGraphLayerType)->Int
    {
        let buLayerOrder = self.bottomUpLayerOrder;
        var idx    = 0
        
        for  i in 0..<kCPTNumberOfLayers {
            if ( buLayerOrder[i] == layerType ) {
                break;
            }
            
            switch ( buLayerOrder[i] ) {
            case .minorGridLines:
                if (( self.minorGridLineGroup ) != nil) {
                    idx += 1
                }
                
            case .majorGridLines:
                if (( self.majorGridLineGroup ) != nil) {
                    idx += 1
                }
                
            case .axisLines:
                if (( self.axisSet ) != nil) {
                    idx += 1
                }
                
            case .plots:
                if (( self.plotGroup ) != nil) {
                    idx += 1
                }
                
            case .axisLabels:
                if (( self.axisLabelGroup ) != nil) {
                    idx += 1
                }
                
            case .axisTitles:
                if (( self.axisTitleGroup ) != nil) {
                    idx += 1
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
        let theAxisSet = self.axisSet
        
        for axis in theAxisSet!.axes {
            switch ( layerType ) {
            case .minorGridLines:
                if (( axis.minorGridLineStyle ) != nil) {
                    needsLayer = true
                }
                
            case .majorGridLines:
                if (( axis.majorGridLineStyle ) != nil) {
                    needsLayer = true
                }
                
            case .axisLabels:
                if ( axis.axisLabels.count > 0 ) {
                    needsLayer = true
                }
                
            case .axisTitles:
                if (( axis.axisTitle ) != nil) {
                    needsLayer = true
                }
                
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
                
            case .majorGridLines:
                self.majorGridLineGroup = nil;
                
            case .axisLabels:
                self.axisLabelGroup = nil;
                
            case .axisTitles:
                self.axisTitleGroup = nil;
                
            default:
                break
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
            
        case .majorGridLines:
            if ( (self.majorGridLineGroup == nil) ) {
                self.majorGridLineGroup = CPTGridLineGroup(frame:self.bounds)
            }
            
        case .axisLabels:
            if ( (self.axisLabelGroup == nil) ) {
                self.axisLabelGroup = CPTAxisLabelGroup(frame:self.bounds)
            }
            
        case .axisTitles:
            if ( (self.axisTitleGroup == nil) ) {
                self.axisTitleGroup = CPTAxisLabelGroup(frame:self.bounds)
            }
            
        default:
            break
        }
    }

//    /** @brief Computes the sublayer index for the given layer type and axis.
//     *  @param axis The axis of interest.
//     *  @param layerType The layer type being updated.
//     *  @return The sublayer index for the given layer type.
//     **/
    func sublayerIndexForAxis(axis: CPTAxis , layerType: CPTGraphLayerType)->Int
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
                
            case .majorGridLines:
                if (( currentAxis.majorGridLineStyle ) != nil) {
                    idx += 1
                }
                
            case .axisLabels:
                if ( currentAxis.axisLabels.count > 0 ) {
                    idx += 1
                }
                
            case .axisTitles:
                if (( currentAxis.axisTitle ) != nil) {
                    idx += 1
                }
                
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
    override func pointingDeviceDownEvent(event: CPTNativeEvent, atPoint interactionPoint:CGPoint)-> Bool
    {
        let theGraph = self.graph;

        if ( (theGraph == nil) || self.isHidden ) {
            return false
        }

        weak var theDelegate = self.delegate as? CPTPlotAreaDelegate

        if theDelegate?.respondsToSelector(to:#selector(plotAreaTouchDown(plotArea:))) ||
            theDelegate.respondsToSelector(to:#selector(plotAreaTouchDown(plotArea:withEvent:))) ||
           theDelegate.respondsToSelector(to:#selector(plotAreaWasSelected:) ||
           theDelegate.respondsToSelector(to:#selector(plotAreaWasSelected:withEvent:) {
            
            // Inform delegate if a point was hit
            let plotAreaPoint = theGraph?.convert(interactionPoint, to:self)

            if self.bounds.contains( plotAreaPoint!)  {
                self.touchedPoint = plotAreaPoint!

                if theDelegate?.respondsToSelector( to: #selector(plotAreaTouchDown!(plotArea:self)) {
                    theDelegate?.plotAreaTouchDown!(plotArea: self)
                }
                if theDelegate.respondsToSelector( to: #selector(plotAreaTouchDown:withEvent:) {
                    theDelegate.plotAreaTouchDown(plotArea: self, withEvent:event)
                }

                return false // don't block other events in the responder chain
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
//            return false
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
//                    return false // don't block other events in the responder chain
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
//    func setBorderLineStyle:(nullable CPTLineStyle *)newLineStyle
//    {
//        self.axisSet.borderLineStyle = newLineStyle;
//    }
//
//    func setFill:(nullable CPTFill *)newFill
//    {
//        if ( newFill != fill ) {
//            fill = [newFill copy];
//            [self setNeedsDisplay];
//        }
//    }
//
//    func setMinorGridLineGroup:(nullable CPTGridLineGroup *)newGridLines
//    {
//        if ((newGridLines != minorGridLineGroup) || self.isUpdatingLayers ) {
//            [minorGridLineGroup removeFromSuperlayer];
//            minorGridLineGroup = newGridLines;
//            if ( newGridLines ) {
//                CPTGridLineGroup *gridLines = newGridLines;
//
//                gridLines.plotArea = self;
//                gridLines.major    = false
//                [self insertSublayer:gridLines atIndex:[self indexForLayerType:CPTGraphLayerTypeMinorGridLines]];
//            }
//            [self setNeedsLayout];
//        }
//    }
//
//    func setMajorGridLineGroup:(nullable CPTGridLineGroup *)newGridLines
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
//    func setAxisSet:(nullable CPTAxisSet *)newAxisSet
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
//    func setPlotGroup:(nullable CPTPlotGroup *)newPlotGroup
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
//    func setAxisLabelGroup:(nullable CPTAxisLabelGroup *)newAxisLabelGroup
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
//    func setAxisTitleGroup:(nullable CPTAxisLabelGroup *)newAxisTitleGroup
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
//    func setTopDownLayerOrder:(nullable CPTNumberArray *)newArray
//    {
//        if ( newArray != topDownLayerOrder ) {
//            topDownLayerOrder = newArray;
//            [self updateLayerOrder];
//        }
//    }
//
//    func setGraph:(nullable CPTGraph *)newGraph
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
//    func setBounds:(CGRect)newBounds
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
