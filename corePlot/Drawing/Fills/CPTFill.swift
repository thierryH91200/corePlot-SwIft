//
//  CPTFill.swift
//  corePlot
//
//  Created by thierryH24 on 09/11/2020.
//

import Cocoa

public class CPTFill: NSObject  {
    
// MARK: - Init/Dealloc
    var isOpaque = false

    class func fill(with aColor: CPTColor) -> Self {
        return CPTFillColor(color: aColor)
    }
    
    class func fill(with aGradient: CPTGradient) -> Self {
        return CPTFillGradient(gradient: aGradient)
    }
    
    class func fill(with anImage: CPTImage) -> Self {
        return CPTFillImage(image: anImage)
    }
    
    
    func fillRect(rect :CGRect,  inContext: CGContext)
    {
        // do nothing--subclasses override to do drawing here
    }
    
    func fillPathInContext(context:  CGContext)
    {
        // do nothing--subclasses override to do drawing here
    }
    
}
