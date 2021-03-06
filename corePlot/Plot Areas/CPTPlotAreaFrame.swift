//
//  CPTPlotAreaFrame.swift
//  corePlot
//
//  Created by thierryH24 on 11/11/2020.
//

import AppKit

class CPTPlotAreaFrame: CPTBorderedLayer {
    
    var plotArea : CPTPlotArea?
    var axisSet  : CPTAxisSet?
//    var plotGroup: CPTPlotGroup?

    // MARK: - Init/Dealloc
    init(newFrame: CGRect)
    {
        super.init(frame: newFrame)
        
//        plotArea = nil;
//        let newPlotArea = CPTPlotArea(frame:newFrame)
//        self.plotArea = newPlotArea
        
        self.plotArea = CPTPlotArea(frame:newFrame)
        self.masksToBorder = true
    }

    override init(layer: Any)
    {
        super.init(layer: layer )
        
        let theLayer = CPTPlotAreaFrame(layer: layer)
        plotArea = theLayer.plotArea
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Event Handling

    override func pointingDeviceDownEvent(event: CPTNativeEvent, atPoint interactionPoint: CGPoint) -> Bool
    {
        if ((self.plotArea?.pointingDeviceDownEvent(event: event, atPoint:interactionPoint)) != nil) {
            return true
        }
        else {
            return super.pointingDeviceDownEvent(event: event, atPoint:interactionPoint)
        }
    }

    /**
     *  @brief Informs the receiver that the user has
     *  @if MacOnly released the mouse button. @endif
     *  @if iOSOnly lifted their finger off the screen. @endif
     *
     *  @param event The OS event.
     *  @param interactionPoint The coordinates of the interaction.
     *  @return Whether the event was handled or not.
     **/
    override func pointingDeviceUpEvent(event: CPTNativeEvent, atPoint interactionPoint:CGPoint) -> Bool
    {
        if ((self.plotArea?.pointingDeviceUpEvent(event: event, atPoint:interactionPoint )) != nil) {
            return true
        }
        else {
            return super.pointingDeviceUpEvent(event: event, atPoint:interactionPoint)
        }
    }

    /**
     *  @brief Informs the receiver that the user has moved
     *  @if MacOnly the mouse with the button pressed. @endif
     *  @if iOSOnly their finger while touching the screen. @endif
     *
     *  @param event The OS event.
     *  @param interactionPoint The coordinates of the interaction.
     *  @return Whether the event was handled or not.
     **/
    override func pointingDeviceDraggedEvent(event: CPTNativeEvent, atPoint interactionPoint:CGPoint)-> Bool
    {
        if ((self.plotArea?.pointingDeviceDraggedEvent(event: event, atPoint:interactionPoint)) != nil) {
            return true
        }
        else {
            return super.pointingDeviceDraggedEvent(event: event ,atPoint:interactionPoint)
        }
    }

    /**
     *  @brief Informs the receiver that tracking of
     *  @if MacOnly mouse moves @endif
     *  @if iOSOnly touches @endif
     *  has been cancelled for any reason.
     *
     *  @param event The OS event.
     *  @return Whether the event was handled or not.
     **/
    override func pointingDeviceCancelledEvent(event:CPTNativeEvent )-> Bool    {
        if  ((self.plotArea?.pointingDeviceCancelledEvent(event )) != nil) {
            return true
        }
        else {
            return super.pointingDeviceCancelledEvent(event)
        }
    }


    // MARK: - Accessors
    func setPlotArea(newPlotArea: CPTPlotArea? )
    {
        if newPlotArea != plotArea  {
            plotArea?.removeFromSuperlayer()
            plotArea = newPlotArea;
            
            if (( newPlotArea ) != nil) {
                let theArea = newPlotArea
                
                self.insertSublayer(theArea!, at:0)
                theArea!.graph = self.graph
            }
            self.setNeedsLayout()
        }
    }
    
    
    func setAxisSet(newAxisSet: CPTAxisSet)
    {
        self.plotArea?.axisSet = newAxisSet;
    }
    
    var plotGroup : CPTPlotGroup {
        get {return (self.plotArea?.plotGroup)!}
        set {
            self.plotArea?.plotGroup = newValue
        }
    }
    
    func setGraph(newGraph: CPTGraph )
    {
        if ( newGraph != self.graph ) {
            super.graph = newGraph;
            
            self.plotArea?.graph = newGraph
        }
    }
    
}
