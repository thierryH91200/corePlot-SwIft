//
//  CPTFillColor.swift
//  corePlot
//
//  Created by thierryH24 on 10/11/2020.
//

import AppKit

class CPTFillColor: CPTFill {
    
    var  fillColor = NSColor.black
    
    
    init(aColor : NSUIColor)
    {
        fillColor = aColor
    }
    
    // MARK: - Drawing    
    override func fillRect(rect : CGRect, context : CGContext)
    {
        context.saveGState();
        context.setFillColor(self.fillColor.cgColor);
        context.fill(rect);
        context.restoreGState();
    }
    
    override func fillPathInContext(context : CGContext)
    {
        context.saveGState();
        context.setFillColor(self.fillColor.cgColor);
        context.fillPath();
        context.restoreGState();
    }
    
    // MARK: Opacity
    override var isOpaque: Bool {
        get { return self.fillColor.isOpaque }
        set { }
    }
    
    // MARK: Color
    override func cgColor()-> CGColor
    {
        return self.fillColor.cgColor
    }
    
    
    
}
