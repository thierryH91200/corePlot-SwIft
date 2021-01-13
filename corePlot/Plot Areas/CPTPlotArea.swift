//
//  CPTPlotArea.swift
//  corePlot
//
//  Created by thierryH24 on 11/11/2020.
//

import AppKit

enum CPTGraphLayerType : String, CaseIterable {
    case minorGridLines = "minorGridLines"   //< Minor grid lines.
    case majorGridLines = "majorGridLines"
    case axisLines      = "axisLines"
    case plots          = "plots"
    case axisLabels     = "axisLabels"
    case axisTitles     = "axisTitles"
}

@objc
public protocol CPTPlotAreaDelegate: CALayerDelegate {
    
    @objc optional func plotAreaWasSelected( plotArea: CPTPlotArea )
    @objc optional func plotAreaWasSelected( plotArea: CPTPlotArea, withEvent event: CPTNativeEvent )
    
    @objc optional func plotAreaTouchDown  ( plotArea: CPTPlotArea )
    @objc optional func plotAreaTouchDown  ( plotArea: CPTPlotArea, withEvent event: CPTNativeEvent)
    
    @objc optional func plotAreaTouchUp    ( plotArea: CPTPlotArea)
    @objc optional func plotAreaTouchUp    ( plotArea: CPTPlotArea, withEvent event: CPTNativeEvent)
}

public class CPTPlotArea: CPTAnnotationHostLayer {
    
    let kCPTNumberOfLayers = 6; // number of primary layers to arrange

    var touchedPoint = CGPoint(x: 0,y: 0)

    //MARK:  Layer Ordering
    var topDownLayerOrder  = [CPTGraphLayerType]()
    var bottomUpLayerOrder = [CPTGraphLayerType]()

    //MARK:  Dimensions
    var isUpdatingLayers = false
    var widthDecimal = CGFloat(0)
    var heightDecimal = CGFloat(0)
    
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
        touchedPoint       = CGPoint(x: CGFloat.nan, y: CGFloat.nan)
        
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

        self.fill?.fillRect(rect: self.bounds, context:context)
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
        var buLayerOrder = bottomUpLayerOrder
        buLayerOrder     = CPTGraphLayerType.allCases.map { $0 }

        let tdLayerOrder = self.topDownLayerOrder
        if  tdLayerOrder.count > 0 {
            
            buLayerOrder = self.bottomUpLayerOrder;
            for layerIndex in 0..<tdLayerOrder.count {
                let layerType = tdLayerOrder[layerIndex]
                var i  = kCPTNumberOfLayers - layerIndex - 1

                while ( buLayerOrder[i] != layerType ) {
                    if ( i == 0 ) {
                        break;
                    }
                    i -= 1
                }
                while ( i < kCPTNumberOfLayers - layerIndex - 1 ) {
                    buLayerOrder[i] = buLayerOrder[i + 1]
                    i += 1
                }
                buLayerOrder[kCPTNumberOfLayers - layerIndex - 1] = layerType
            }
        }
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
            }
        }
        return idx;
    }
    
    
    
// MARK: - Axis set layer management

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
                if  axis.axisTitle  != nil {
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
    

    /** @brief Ensures that a group layer is set for the given layer type.
     *  @param layerType The layer type being updated.
     **/
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

    /** @brief Computes the sublayer index for the given layer type and axis.
     *  @param axis The axis of interest.
     *  @param layerType The layer type being updated.
     *  @return The sublayer index for the given layer type.
     **/
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
                if ( currentAxis.axisTitle != nil) {
                    idx += 1
                }
                
            default:
                break;
            }
        }
        return idx;
    }

// MARK: - Event Handling
    override func pointingDeviceDownEvent(event: CPTNativeEvent, atPoint interactionPoint:CGPoint)-> Bool
    {
        let theGraph = self.graph;
        guard (theGraph != nil) || self.isHidden == false else { return false }
        
        weak var theDelegate = self.delegate as? CPTPlotAreaDelegate
        
        // Inform delegate if a point was hit
        let plotAreaPoint = theGraph?.convert(interactionPoint, to: self)
        
        if self.bounds.contains( plotAreaPoint!)  {
            self.touchedPoint = plotAreaPoint!
            
            theDelegate?.plotAreaTouchDown?(plotArea: self)
            theDelegate?.plotAreaTouchDown?(plotArea: self, withEvent:event)
            
            return false // don't block other events in the responder chain
        }
        return super.pointingDeviceDownEvent(event: event, atPoint: interactionPoint)
    }

    /**
     *  @brief Informs the receiver that the user has
     *  @if MacOnly released the mouse button. @endif
     *  @if iOSOnly ended touching the screen. @endif
     *
     *
     *  If this plot area has a delegate that responds to the
     *  @link CPTPlotAreaDelegate::plotAreaTouchUp: -plotAreaTouchUp: @endlink,
     *  @link CPTPlotAreaDelegate::plotAreaTouchUp:withEvent: -plotAreaTouchUp:withEvent: @endlink,
     *  @link CPTPlotAreaDelegate::plotAreaWasSelected: -plotAreaWasSelected: @endlink, and/or
     *  @link CPTPlotAreaDelegate::plotAreaWasSelected:withEvent: -plotAreaWasSelected:withEvent: @endlink
     *  methods, the delegate method will be called and this method returns @true if the @par{interactionPoint} is within the
     *  plot area bounds.
     *
     *  @param event The OS event.
     *  @param interactionPoint The coordinates of the interaction.
     *  @return Whether the event was handled or not.
     **/
    override func pointingDeviceUpEvent(event: CPTNativeEvent, atPoint interactionPoint : CGPoint)-> Bool
    {
        let theGraph = self.graph;
        
        guard self.isHidden == false else { return false }
        guard theGraph != nil else { return false }
        
        let lastPoint = self.touchedPoint;
        self.touchedPoint = CGPoint(x: 0, y: 0);
        weak var theDelegate = self.delegate as? CPTPlotAreaDelegate
        
        
        // Inform delegate if a point was hit
        let plotAreaPoint = theGraph?.convert(interactionPoint, to:self)
        
        if self.bounds.contains(plotAreaPoint!) {
            let offset = CGVector(dx: plotAreaPoint!.x - lastPoint.x, dy: plotAreaPoint!.y - lastPoint.y);
            if ((offset.dx * offset.dx + offset.dy * offset.dy) <= CGFloat(25.0)) {
                if ((theDelegate?.plotAreaTouchUp(plotArea:)) != nil) {
                    theDelegate?.plotAreaTouchUp!(plotArea: self)
                }
                
                if ((theDelegate?.plotAreaTouchUp(plotArea: withEvent:)) != nil) {
                    theDelegate?.plotAreaTouchUp!(plotArea:self, withEvent:event)
                }
                
                if ((theDelegate?.plotAreaWasSelected(plotArea:)) != nil)  {
                    theDelegate?.plotAreaWasSelected!(plotArea: self)
                }
                
                if theDelegate?.plotAreaWasSelected(plotArea: withEvent:) != nil {
                    theDelegate?.plotAreaWasSelected!(plotArea: self, withEvent:event)
                }
                
                return false // don't block other events in the responder chain
            }
        }
        return super.pointingDeviceUpEvent(event: event, atPoint:interactionPoint)
    }
    
    
    
    // MARK: - Accessors
    var _borderLineStyle: CPTLineStyle?
    var borderLineStyle : CPTLineStyle? {
        get { return (self.axisSet?.borderLineStyle)! }
        set { self.axisSet?.borderLineStyle = newValue}
    }

    //MARK:  Decorations
    var _fill: CPTFill?
    var fill: CPTFill? {
        get { }
        set {
            if ( newValue != _fill ) {
                _fill = newValue
                self.setNeedsDisplay()
            }
        }
    }

    //MARK: Layers
    var _minorGridLineGroup : CPTGridLineGroup?
    var minorGridLineGroup : CPTGridLineGroup? {
        get { }
        set {
            if ((newValue != _minorGridLineGroup) || self.isUpdatingLayers ) {
                _minorGridLineGroup?.removeFromSuperlayer()
                _minorGridLineGroup = newValue;
                if (( newValue ) != nil) {
                    let gridLines = newValue;
                    gridLines?.plotArea = self;
                    gridLines?.major    = false
                    self.insertSublayer(gridLines!, at:UInt32(self.indexForLayerType(layerType: .minorGridLines)))
                }
                self.setNeedsLayout()
            }
        }
    }

    var _majorGridLineGroup : CPTGridLineGroup?
    var majorGridLineGroup : CPTGridLineGroup? {
        get { return _majorGridLineGroup }
        set {
            if ((newValue != majorGridLineGroup) || self.isUpdatingLayers == true  ) {
                majorGridLineGroup?.removeFromSuperlayer()
                _majorGridLineGroup = newValue
                if (( newValue ) != nil) {
                    let gridLines = newValue;
                    
                    gridLines?.plotArea = self
                    gridLines?.major    = true
                    self.insertSublayer(gridLines!, at:UInt32(self.indexForLayerType(layerType: .majorGridLines)))
                }
                self.setNeedsLayout()
            }
        }
    }

    var _axisSet: CPTAxisSet?
    var axisSet: CPTAxisSet? {
        get { return _axisSet }
        set {
            if (newValue != _axisSet || self.isUpdatingLayers == true ) {
                axisSet?.removeFromSuperlayer()
                for axis in axisSet!.axes {
                    axis.plotArea = nil
                }
                
                _axisSet = newValue;
                self.updateAxisSetLayersForType(layerType: .majorGridLines)
                self.updateAxisSetLayersForType(layerType: .minorGridLines)
                self.updateAxisSetLayersForType(layerType: .axisLabels)
                self.updateAxisSetLayersForType(layerType: .axisTitles)
                
                if (( newValue ) != nil) {
                    let theGraph     = self.graph;
                    self.insertSublayer(newValue!, at: UInt32(self.indexForLayerType(layerType: .axisLines)))
                    for axis in newValue!.axes {
                        axis.plotArea = self
                        axis.graph    = theGraph
                    }
                }
                self.setNeedsLayout()
            }
        }
    }
    
    var _plotGroup: CPTPlotGroup?
    var plotGroup: CPTPlotGroup? {
        get { }
        set {
            if (newValue != plotGroup || self.isUpdatingLayers ) {
                _plotGroup?.removeFromSuperlayer()
                _plotGroup = newValue;
                if (( newValue ) != nil) {
                    self.insertSublayer(newValue!, at:UInt32(self.indexForLayerType(layerType: .plots)))
                }
                self.setNeedsLayout()
            }
        }
    }
    
    var _axisLabelGroup : CPTAxisLabelGroup?
    var axisLabelGroup : CPTAxisLabelGroup? {
        get { }
        set {
            if ( newValue != axisLabelGroup || self.isUpdatingLayers ) {
                _axisLabelGroup?.removeFromSuperlayer()
                _axisLabelGroup = newValue;
                if ( newValue  != nil) {
                    self.insertSublayer(newValue!, at:UInt32(self.indexForLayerType(layerType: .axisLabels)))
                }
                self.setNeedsLayout()
            }
        }
    }
    var _axisTitleGroup : CPTAxisLabelGroup?
    var axisTitleGroup : CPTAxisLabelGroup? {
        get { }
        set {
            if (newValue != axisTitleGroup || self.isUpdatingLayers ) {
                _axisTitleGroup?.removeFromSuperlayer()
                _axisTitleGroup = newValue;
                if (( newValue ) != nil) {
                    
                    self.insertSublayer(newValue!, at:UInt32(self.indexForLayerType(layerType: .axisTitles)))
                }
                self.setNeedsLayout()
            }
        }
    }

//    func setTopDownLayerOrder(newArray [CPTGraphLayerType])
//    {
//        if ( newArray != topDownLayerOrder ) {
//            topDownLayerOrder = newArray;
//            [self updateLayerOrder];
//        }
//    }
//
    
    override var graph : CPTGraph? {
        get { return super.graph  }
        set {
            if newValue != super.graph {
                super.graph = newValue;
                for axis in self.axisSet!.axes {
                    axis.graph = newValue
                }
            }
        }
    }

    func setBounds(newBounds: CGRect)
    {
        if  !self.bounds.equalTo( newBounds) {
            self.widthDecimal  = newBounds.size.width
            self.heightDecimal = newBounds.size.height

            super.bounds = newBounds;
        }
    }

}
