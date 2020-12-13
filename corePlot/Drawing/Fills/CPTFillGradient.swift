//
//  CPTFillGradient.swift
//  corePlot
//
//  Created by thierryH24 on 09/11/2020.
//

import Cocoa

class CPTFillGradient: CPTFill {
    
    
    var fillGradient :CPTGradient
    
    override init() {
        
    }
    
    // MARK: - Init/Dealloc
    
    /** @brief Initializes a newly allocated _CPTFillGradient object with the provided gradient.
     *  @param aGradient The gradient.
     *  @return The initialized _CPTFillGradient object.
     **/
    init( aGradient: CPTGradient)
    {
        super.init()
        fillGradient = aGradient;
    }
    
    // MARK: - Drawing
    
    /** @brief Draws the gradient into the given graphics context inside the provided rectangle.
     *  @param rect The rectangle to draw into.
     *  @param context The graphics context to draw into.
     **/
    override func fillRect(rect: CGRect, inContext context: CGContext)
    {
        self.fillGradient.fillRect(rect, inContext:context)
    }
    
    /** @brief Draws the gradient into the given graphics context clipped to the current drawing path.
     *  @param context The graphics context to draw into.
     **/
    override func fillPathInContext(context : CGContext)
    {
        self.fillGradient.fillPathInContext(context)
    }
    
    // MARK: - Opacity
    override var isOpaque: Bool {
        get { return self.fillGradient.isOpaque }
        set {}
    }
    
}
