//
//  CPTAxisSet.swift
//  corePlot
//
//  Created by thierryH24 on 11/11/2020.
//

import Cocoa

class CPTAxisSet: CPTLayer {
    
    override init(frame : CGRect)
    {
        super.init(frame: frame)
        axes.removeAll()
        borderLineStyle = nil;
        
        self.needsDisplayOnBoundsChange = true
        
    }
    
    init(layer : Any)
    {
        super.init(layer: layer)
        axes = layer.axes
        borderLineStyle = layer.borderLineStyle
        
        self.needsDisplayOnBoundsChange = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Drawing
    override func display()
    {
        if (( self.borderLineStyle ) != nil) {
            super.display()
        }
    }
    
    // MARK: - Labeling
    func relabelAxes()
    {
        let theAxes = self.axes;

        theAxes.makeObjectsPerformSelector(#selector(setNeedsLayout))
        theAxes.makeObjectsPerformSelector(#selector(setNeedsRelabel))
    }

    // MARK: -  Axes
    func axisForCoordinate( coordinate:CPTCoordinate, idx:Int) -> CPTAxis?
    {
        let foundAxis : CPTAxis?
        var count   = 0

        for axis in self.axes  {
            if ( axis.coordinate == coordinate ) {
                if count == idx {
                    foundAxis = axis;
                    break;
                }
                else {
                    count += 1
                }
            }
        }
        return foundAxis;
    }
    
    func pointingDeviceDownEvent(event: CPTNativeEvent, interactionPoint:CGPoint)-> Bool
    {
        for axis in self.axes  {
            if axis.pointingDeviceDownEvent(event:event, atPoint:interactionPoint ) {
                return true;
            }
        }
        return super.pointingDeviceDownEvent(event:event, atPoint:interactionPoint)
    }

    /**
     *  @brief Informs the receiver that the user has
     *  @if MacOnly released the mouse button. @endif
     *  @if iOSOnly ended touching the screen. @endif
     *
     *
     *  The event will be passed to each axis belonging to the receiver in turn. This method
     *  returns @YES if any of its axes handle the event.
     *
     *  @param event The OS event.
     *  @param interactionPoint The coordinates of the interaction.
     *  @return Whether the event was handled or not.
     **/
    
    func pointingDeviceUpEvent(event: CPTNativeEvent, atPoint interactionPoint:CGPoint)-> Bool
    {
        for  axis in self.axes {
            if  axis.pointingDeviceUpEvent(event:event, atPoint:interactionPoint) {
                return true
            }
        }
        return super.pointingDeviceUpEvent(event:event, atPoint:interactionPoint)
    }
    
    func pointingDeviceDownEvent(event: CPTNativeEvent, atPoint interactionPoint:CGPoint) -> Bool
    {
        for  axis in self.axes {
            if axis.pointingDeviceDownEvent(event:event, atPoint:interactionPoint ) {
                return true
            }
        }
        return super.pointingDeviceDownEvent(event:event, atPoint:interactionPoint)
    }

    /**
     *  @brief Informs the receiver that the user has
     *  @if MacOnly released the mouse button. @endif
     *  @if iOSOnly ended touching the screen. @endif
     *
     *
     *  The event will be passed to each axis belonging to the receiver in turn. This method
     *  returns @YES if any of its axes handle the event.
     *
     *  @param event The OS event.
     *  @param interactionPoint The coordinates of the interaction.
     *  @return Whether the event was handled or not.
     **/
    func pointingDeviceUpEvent (event: CPTNativeEvent, atPoint interactionPoint:CGPoint)-> Bool
    {
        for axis in self.axes {
            if axis.pointingDeviceUpEven(event: event, atPoint:interactionPoint ) {
                return true
            }
        }
        return super.pointingDeviceUpEvent(event:event, atPoint:interactionPoint)
    }



    
    var _axes =  [CPTAxis]()
    var axes: [CPTAxis]
    {
        get {
            return _axes
        }
        set {
            
            if _axes != newValue  {
                for axis in axes {
                    axis.removeFromSuperlayer
                    axis.plotArea = nil
                    axis.graph    = nil
                }
                _axes = newValue;
                let plotArea = self.superlayer;
                let theGraph    = plotArea.graph;
                for  axis in axes  {
                    self.addSublayer( axis)
                    axis.plotArea = plotArea
                    axis.graph    = theGraph
                }
                self.setNeedsLayout()
                self.setNeedsDisplay()
            }
        }
    }
    
    var  _borderLineStyle: CPTLineStyle?
    var  borderLineStyle: CPTLineStyle? {
        get {
            return _borderLineStyle
        }
        set {
            if ( newValue != borderLineStyle ) {
                _borderLineStyle = newValue
                self.setNeedsLayout()
                self.setNeedsDisplay()
                
            }
        }
    }
}
