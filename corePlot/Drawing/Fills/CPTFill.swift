//
//  CPTFill.swift
//  corePlot
//
//  Created by thierryH24 on 09/11/2020.
//

import AppKit

public class CPTFill: NSObject  {
    
// MARK: - Init/Dealloc
    class func fill(with   aColor: NSColor)->CPTColor  {
        let result = CPTFillColor(aColor: aColor)
        print (result)
    }

    class func fill(with aGradient: CPTGradient) -> CPTFillGradient {
        return CPTFillGradient(aGradient: aGradient)
    }
    
    class func fill(with anImage: CPTImage) -> CPTFillImage {
        return CPTFillImage(anImage: anImage)
    }
    
    // MARK: - Drawing
    func fillRect(rect :CGRect,  context: CGContext)
    {
        // do nothing--subclasses override to do drawing here
    }
    
    func fillPathInContext(context:  CGContext)
    {
        // do nothing--subclasses override to do drawing here
    }
    
    // MARK: Opacity
    var isOpaque : Bool {
        get { return false }
        set { }
    }

    // MARK: - Color
    func cgColor() -> CGColor? {
        // do nothing--subclasses override to describe the color
        return nil
    }

    
}
