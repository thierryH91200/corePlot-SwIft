//
//  CPTFillGradient.swift
//  corePlot
//
//  Created by thierryH24 on 09/11/2020.
//

import AppKit

class CPTFillGradient: CPTFill {
    
    var fillGradient :CPTGradient
    
    // MARK: - Init/Dealloc
    init( gradient: CPTGradient)
    {
        super.init()
        fillGradient = gradient;
    }
    
    // MARK: - Drawing
    override func fillRect(rect: CGRect, context: CGContext)
    {
        self.fillGradient.fillRect(rect: rect, inContext:context)
    }

    override func fillPathInContext(context : CGContext)
    {
        self.fillPathInContext(context: context)
    }
    
    // MARK: - Opacity
    override var isOpaque: Bool {
        get { return self.fillGradient.isOpaque }
        set { }
    }
    
}
