//
//  CPTGridLines.swift
//  corePlot
//
//  Created by thierryH24 on 11/11/2020.
//

//==============================
//  OK
// 16/12/20
//==============================



import AppKit

class CPTGridLines: CPTLayer {
    
//    var axis : CPTAxis?
    var major = false
    
    // MARK: Init/Dealloc
    override init(frame:CGRect)
    {
        super.init(frame: frame)
        axis  = nil
        major = false
        
        self.needsDisplayOnBoundsChange = true;
    }
    
    override init(layer: Any)
    {
        super.init(layer:layer)
        
        let theLayer = CPTGridLines(layer: layer)
        axis  = theLayer.axis;
        major = theLayer.major
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Drawing
    override func renderAsVectorInContext(context: CGContext)
    {
        guard ( self.isHidden == false) else { return }
        
        super.renderAsVectorInContext(context: context)
        let theAxis = self.axis
        theAxis?.drawGridLinesInContext(context: context, isMajor:self.major)
    }
    
    
    // MARK: Accessors
    var _axis : CPTAxis?
    var axis: CPTAxis? {
        get {
            return _axis
        }
        set {
            if ( newValue != _axis ) {
                _axis = newValue
                self.setNeedsDisplay()
            }
        }
    }
}
