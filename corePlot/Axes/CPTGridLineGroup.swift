//
//  CPTGridLineGroup.swift
//  corePlot
//
//  Created by thierryH24 on 11/11/2020.

//==============================
//  OK
// 05/12/20
//==============================

import AppKit

class CPTGridLineGroup: CPTLayer {
    
    var axis : CPTAxis?
    var major = true
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        axis  = nil
        major = false
        
        self.needsDisplayOnBoundsChange = true
    }
    
    override init(layer: Any) {
        
        super.init(layer: layer)
        
        let theLayer = layer as? CPTGridLineGroup
        axis = theLayer!.axis
        major = theLayer!.major
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Drawing
    @objc override func renderAsVectorInContext(context : CGContext)
    {
        guard self.isHidden == false else { return }
        let thePlotArea = self.plotArea
    
        for  axis in thePlotArea.axisSet!.axes {
            if  axis.separateLayers == false  {
                axis.drawGridLinesInContext(context: context, isMajor:self.major)
            }
        }
    }
    
    // MARK:- Accessors
    var _plotArea:  CPTPlotArea?
    var plotArea: CPTPlotArea {
        get {
            return(_plotArea!)
        }
        set {
            if _plotArea != newValue {
                _plotArea = newValue
                
                if ( _plotArea != nil) {
                    self.setNeedsDisplay()
                }
            }
        }
    }
}
