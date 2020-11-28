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
    
    func applySublayerMaskToContext(context: CGContext, forSublayer sublayer: CPTLayer, withOffset offset:CGPoint)
    {
        let  sublayerBoundsOrigin = sublayer.bounds.origin
        var layerOffset          = offset
        
        if self.renderingRecursively == false {
            let convertedOffset = self.convert(sublayerBoundsOrigin , from:sublayer)
            layerOffset.x += convertedOffset.x;
            layerOffset.y += convertedOffset.y;
        }
        
        let sublayerTransform = CATransform3DGetAffineTransform(sublayer.transform)
        
        context.concatenate(sublayerTransform.inverted());
        
        let superlayer = self.superlayer;
        
        if ( superlayer is CPTLayer ) == true {
            superlayer.applySublayerMaskToContext(context, forSublayer:self, withOffset:layerOffset)
        }
        
        let maskPath = self.sublayerMaskingPath;
        
        if ( maskPath ) {
            context.translateBy(x: -layerOffset.x, y: -layerOffset.y);
            context.addPath(maskPath());
            context.clip();
            context.translateBy(x: layerOffset.x, y: layerOffset.y);
        }
        context.concatenate(sublayerTransform);
    }
    
    func applyyMaskToContext(context: CGContextRef)
    {
        let mySuperlayer = superlayer as? CPTLayer
        if mySuperlayer is CPTLayer {
            mySuperlayer?.applySublayerMask(toContext: context, forSublayer: self, withOffset: CGPoint.zero)
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
