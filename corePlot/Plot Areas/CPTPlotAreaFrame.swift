//
//  CPTPlotAreaFrame.swift
//  corePlot
//
//  Created by thierryH24 on 11/11/2020.
//

import Cocoa

class CPTPlotAreaFrame: CPTBorderedLayer {
    
    var lotArea: CPTPlotArea?
    var axisSet: CPTAxisSet?
    var plotGroup: CPTPlotGroup?

    // MARK: - Init/Dealloc

    /// @name Initialization
    /// @{

    /** @brief Initializes a newly allocated CPTPlotAreaFrame object with the provided frame rectangle.
     *
     *  This is the designated initializer. The initialized layer will have the following properties:
     *  - @ref plotArea = a new CPTPlotArea with the same frame rectangle
     *  - @ref masksToBorder = @YES
     *  - @ref needsDisplayOnBoundsChange = @YES
     *
     *  @param newFrame The frame rectangle.
     *  @return The initialized CPTPlotAreaFrame object.
     **/
    init(newFrame: CGRect)
    {
        super.init(frame: newFrame)
            plotArea = nil;

            let newPlotArea = CPTPlotArea(frame:newFrame)
            self.plotArea = newPlotArea;

            self.masksToBorder              = true
    }

    init(layer: Any)
    {
        super.init(layer: layer)
        let theLayer = CPTPlotAreaFrame(layer: layer)
        
        plotArea = theLayer.plotArea
    }

    // MARK: - Event Handling

    func pointingDeviceDownEvent(event: CPTNativeEvent, interactionPoint:CGPoint) -> Bool
    {
        if self.plotArea.pointingDeviceDownEvent(event, interactionPoint:interactionPoint) {
            return true
        }
        else {
            return super.pointingDeviceDownEvent(event: event, interactionPoint:interactionPoint)
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
    -(BOOL)pointingDeviceUpEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
    {
        if ( [self.plotArea pointingDeviceUpEvent:event atPoint:interactionPoint] ) {
            return YES;
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
     *  @param event The OS event.
     *  @param interactionPoint The coordinates of the interaction.
     *  @return Whether the event was handled or not.
     **/
    -(BOOL)pointingDeviceDraggedEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
    {
        if ( [self.plotArea pointingDeviceDraggedEvent:event atPoint:interactionPoint] ) {
            return YES;
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
     *  @param event The OS event.
     *  @return Whether the event was handled or not.
     **/
    -(BOOL)pointingDeviceCancelledEvent:(nonnull CPTNativeEvent *)event
    {
        if ( [self.plotArea pointingDeviceCancelledEvent:event] ) {
            return YES;
        }
        else {
            return [super pointingDeviceCancelledEvent:event];
        }
    }

    /// @}


    // MARK: - Accessors

    /// @cond

    -(void)setPlotArea:(nullable CPTPlotArea *)newPlotArea
    {
        if ( newPlotArea != plotArea ) {
            [plotArea removeFromSuperlayer];
            plotArea = newPlotArea;

            if ( newPlotArea ) {
                CPTPlotArea *theArea = newPlotArea;

                [self insertSublayer:theArea atIndex:0];
                theArea.graph = self.graph;
            }

    self.setNeedsLayout()
        }
    }

    -(nullable CPTAxisSet *)axisSet
    {
        return self.plotArea.axisSet;
    }

    -(void)setAxisSet:(nullable CPTAxisSet *)newAxisSet
    {
        self.plotArea.axisSet = newAxisSet;
    }

    -(nullable CPTPlotGroup *)plotGroup
    {
        return self.plotArea.plotGroup;
    }

    -(void)setPlotGroup:(nullable CPTPlotGroup *)newPlotGroup
    {
        self.plotArea.plotGroup = newPlotGroup;
    }

    -(void)setGraph:(nullable CPTGraph *)newGraph
    {
        if ( newGraph != self.graph ) {
            super.graph = newGraph;

            self.plotArea.graph = newGraph;
        }
    }

}
