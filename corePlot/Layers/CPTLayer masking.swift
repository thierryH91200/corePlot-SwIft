//
//  CPTLayer masking.swift
//  corePlot
//
//  Created by thierryH24 on 23/11/2020.
//

import Foundation


extension CPTLayer {
    
    // MARK: Masking
    
    // default path is the rounded rect layer bounds
    
    func sublayerMaskingPath() -> CGPath
    {
        return self.innerBorderPath!;
    }
    
    func applyyMaskToContext(context: CGContext)
    {
        let mySuperlayer = self.superlayer as? CPTLayer
        if mySuperlayer != nil {
            let sup = mySuperlayer!

            sup.applySublayerMaskToContext(context: context, forSublayer: self, withOffset: CGPoint.zero)
        }
        
        let maskPath = maskingPath
        if let maskPath = maskPath {
            context.addPath(maskPath)
            context.clip()
        }
    }
    
    public override func setNeedsLayout() {
        super.setNeedsLayout()
        
        let theGraph = graph
        if let theGraph = theGraph {
            NotificationCenter.send(
                name: .CPTGraphNeedsRedrawNotification,
                object: theGraph)
        }
    }
    
    public override func setNeedsDisplay() {
        super.setNeedsDisplay()
        
        let theGraph = graph
        
        if let theGraph = theGraph {
            NotificationCenter.send(
                name: .CPTGraphNeedsRedrawNotification,
                object: theGraph)
        }
    }
    
}
