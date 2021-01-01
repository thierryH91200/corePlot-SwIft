//
//  CPTShadow.swift
//  corePlot
//
//  Created by thierryH24 on 07/11/2020.
//

import AppKit

class CPTShadow : NSObject {
    
    var shadowOffset = CGSize()
    var shadowColor : NSColor?
    
    //MARK: - Init/Dealloc
    override init()
    {
        shadowOffset     = .zero;
        shadowBlurRadius = 0.0
        shadowColor      = nil
    }
    
    func setShadowInContext (context: CGContext)
    {
        context.setShadow(offset: self.shadowOffset,
                          blur: self.shadowBlurRadius,
                          color: self.shadowColor?.cgColor)
    }
    
    //MARK: Accessors
    var _shadowBlurRadius = CGFloat(0)
    var shadowBlurRadius : CGFloat {
        get { return _shadowBlurRadius }
        set {
            if newValue != _shadowBlurRadius {
                _shadowBlurRadius = newValue
            }
        }
    }
}
