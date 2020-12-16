//
//  CPTLayer accessors.swift
//  corePlot
//
//  Created by thierryH24 on 23/11/2020.
//

import AppKit


extension CPTLayer {
    
    // MARK: Sublayers
    public override var sublayers : [CALayer]?  {
        get {
            return super.sublayers
        }
        set {
            super.sublayers = newValue
            
            let scale    = self.contentsScale;
            for layer in newValue!  {
                if layer is CPTLayer {
                    layer.contentsScale = scale
                }
            }
        }
    }
      
    public override func addSublayer(_ layer: CALayer )
    {
        super.addSublayer(layer)
        if layer is CPTLayer  {
            layer.contentsScale = self.contentsScale;
        }
    }
    
    public override func insertSublayer(_ layer: CALayer, at idx:UInt32)
    {
        super.insertSublayer(layer , at:idx)
        if layer is CPTLayer {
            layer.contentsScale = self.contentsScale
        }
    }
    
    public override func insertSublayer(_ layer: CALayer, below sibling: CALayer? )
    {
        super.insertSublayer(layer, below:sibling)
        if layer is CPTLayer {
            layer.contentsScale = self.contentsScale
        }
    }
    
    public override func insertSublayer(_ layer: CALayer, above sibling: CALayer? )
    {
        super.insertSublayer(layer, above:sibling)
        if  layer is CPTLayer {
            layer.contentsScale = self.contentsScale
        }
    }
    
    public override func replaceSublayer(_ layer: CALayer , with newLayer: CALayer )
    {
        super.replaceSublayer(layer, with: newLayer)
        if layer is CPTLayer {
            layer.contentsScale = self.contentsScale
        }
    }
    
    // MARK: -Accessors
    public override var contentsScale : CGFloat {
        get {
            var scale = CGFloat(1.0);
            scale = super.contentsScale
            return scale;
        }
        set {
            if ( self.contentsScale != newValue ) {
                super.contentsScale = newValue;
                self.setNeedsDisplay()
                
                let sublayers = super.sublayers
                for subLayer in sublayers! {
                    if ( subLayer is CPTLayer ) {
                        subLayer.contentsScale = newValue
                    }
                }
            }
        }
    }

    
}
