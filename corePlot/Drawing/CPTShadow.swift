//
//  CPTShadow.swift
//  corePlot
//
//  Created by thierryH24 on 07/11/2020.
//

import AppKit

class CPTShadow : NSObject {
    
    var shadowOffset = CGSize()
    var shadowBlurRadius = CGFloat(0)
    var shadowColor : NSColor?
    
    //MARK: - Init/Dealloc
    override init()
    {
        shadowOffset     = .zero;
        shadowBlurRadius = 0.0
        shadowColor      = nil
    }
    
    func shadowIn(context: CGContext)
    {
        context.setShadow(offset: self.shadowOffset,
                          blur: self.shadowBlurRadius,
                          color: self.shadowColor?.cgColor)
    }
    
    //MARK: Accessors
    func setShadowBlurRadius(newShadowBlurRadius : CGFloat)
    {
        assert(newShadowBlurRadius >= CGFloat(0.0));
        
        if ( newShadowBlurRadius != shadowBlurRadius ) {
            shadowBlurRadius = newShadowBlurRadius;
        }
    }
}
