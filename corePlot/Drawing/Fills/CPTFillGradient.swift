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
    init( aGradient: CPTGradient)
    {
        super.init()
        fillGradient = aGradient;
    }
    
    // MARK: - Drawing
    override func fillRect(rect: CGRect, inContext context: CGContext)
    {
        self.fillGradient.fillRect(rect: rect, inContext:context)
    }

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
