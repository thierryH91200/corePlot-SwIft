//
//  CPTFillColor.swift
//  corePlot
//
//  Created by thierryH24 on 10/11/2020.
//

import Cocoa

class CPTFillColor: CPTFill {
    
    var  fillColor = NSColor.black
    
    // MARK: Opacity
    //    static var isOpaque: Bool = fillColor.opaque

        
    
    init(aColor : NSColor)
    {
        fillColor = aColor
    }
    
    
    
    
    func fillRect(rect :CGRect, context : CGContext)
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
    
    
    
    
    // MARK: Color
    
    func cgColor()-> CGColor
    {
        return self.fillColor.cgColor
    }
    
    
    
}
