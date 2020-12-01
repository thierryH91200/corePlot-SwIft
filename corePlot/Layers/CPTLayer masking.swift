//
//  CPTLayer masking.swift
//  corePlot
//
//  Created by thierryH24 on 23/11/2020.
//

import Foundation


extension CPTLayer {
    
    // MARK: Masking
    
    /// @cond
    
    // default path is the rounded rect layer bounds
    func maskingPath()-> CGPath?
    {
        if ( self.masksToBounds ) {
            let path = self.outerBorderPath;
            if (( path ) != nil) {
                return path;
            }
            
            path            = CPTCreateRoundedRectPath(self.bounds, self.cornerRadius);
            self.outerBorderPath = path;
            
            return self.outerBorderPath;
        }
        else {
            return nil;
        }
    }
    
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
            NotificationCenter.default.post(
                name: .CPTGraphNeedsRedrawNotification,
                object: theGraph)
        }
    }
    
    public override func setNeedsDisplay() {
        super.setNeedsDisplay()
        
        let theGraph = graph
        
        if let theGraph = theGraph {
            NotificationCenter.default.post(
                name: .CPTGraphNeedsRedrawNotification,
                object: theGraph)
        }
    }
    
}
