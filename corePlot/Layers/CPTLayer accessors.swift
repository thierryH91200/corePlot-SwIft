//
//  CPTLayer accessors.swift
//  corePlot
//
//  Created by thierryH24 on 23/11/2020.
//

import AppKit


extension CPTLayer {
    
    func setPaddingLeft(_ newPadding: CGFloat) {
        if newPadding != paddingLeft {
            paddingLeft = newPadding
            setNeedsLayout()
        }
    }
    
    func setPaddingRight(_ newPadding: CGFloat) {
        if newPadding != paddingRight {
            paddingRight = newPadding
            setNeedsLayout()
        }
    }
    
    func setPaddingTop(_ newPadding: CGFloat) {
        if newPadding != paddingTop {
            paddingTop = newPadding
            setNeedsLayout()
        }
    }
    
    func setPaddingBottom(_ newPadding: CGFloat) {
        if newPadding != paddingBottom {
            paddingBottom = newPadding
            setNeedsLayout()
        }
    }
    
    
    // MARK: Sublayers
    func setSublayers(sublayers: CPTSublayerArray)
    {
        super.sublayers = sublayers;
        
        let scale    = self.contentsScale;
        
        for layer in sublayers  {
            if layer is CPTLayer {
                layer.contentsScale = scale
            }
        }
    }
    
    func addSublayer(layer: CALayer )
    {
        super.addSublayer(layer)
        
        if layer is CPTLayer  {
            layer.contentsScale = self.contentsScale;
        }
    }
    
    func insertSublayer(layer: CALayer, atIndex idx:UInt32)
    {
        super.insertSublayer(layer , at:idx)
        
        if layer is CPTLayer {
            layer.contentsScale = self.contentsScale
        }
    }
    
    func insertSublayer(layer: CALayer, below sibling: CALayer )
    {
        super.insertSublayer(layer, below:sibling)
        
        if layer is CPTLayer {
            layer.contentsScale = self.contentsScale
        }
    }
    
    func insertSublayer(layer: CALayer, above sibling: CALayer )
    {
        super.insertSublayer(layer, above:sibling)
        
        if  layer is CPTLayer {
            layer.contentsScale = self.contentsScale
        }
    }
    
    func replaceSublayer(layer: CALayer , with layer2: CALayer )
    {
        super.replaceSublayer(layer, with:layer2)
        
        if layer is CPTLayer {
            layer.contentsScale = self.contentsScale
        }
    }
    
    // MARK: -Accessors
    func setPosition(newPosition: CGPoint)
    {
        super.position = newPosition;
    }

    public override var isHidden: Bool {
        get {
            return super.isHidden
        }
        set {
            if ( newValue != self.isHidden ) {
                super.isHidden = newValue;
                if ( newValue == true ) {
                    self.setNeedsDisplay()
                }
            }
        }
    }
    
    
    var contentScale : CGFloat {
        get {
            var scale = CGFloat(1.0);
            
            if ( CALayer.instancesRespondToSelector(#selector(contentsScale(:))) ) {
                scale = super.contentsScale
            }
            return scale;
        }
        set {
            if ( self.contentsScale != newValue ) {
                if ( CALayer instancesRespondToSelector:@selector(setContentsScale:)) {
                    super.contentsScale = newValue;
                    self.setNeedsDisplay()
                    
                    for subLayer in self.sublayers  {
                        if ( subLayer is CPTLayer ) {
                            subLayer.contentsScale = newValue
                        }
                    }
                }
            }
        }
    }

    func setShadow(newShadow: CPTShadow)
    {
        if ( newShadow != shadow ) {
            shadow = newShadow
            self.setNeedsLayout()
            self.setNeedsDisplay();
        }
    }
    
    func setOuterBorderPath(newPath: CGPath)
    {
        if ( newPath != outerBorderPath ) {
            outerBorderPath = newPath
        }
    }
    
    func setInnerBorderPath(newPath: CGPath)
    {
        if ( newPath != innerBorderPath ) {
            innerBorderPath = newPath
            self.mask?.setNeedsDisplay()
        }
    }
}
