//
//  CPTLayer accessors.swift
//  corePlot
//
//  Created by thierryH24 on 23/11/2020.
//

import AppKit


extension CPTLayer {
    
    
    /// @cond
    
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
    
    /** @brief Returns the margins that should be left between the bounds of the receiver and all sublayers.
     *  @param left The left margin.
     *  @param top The top margin.
     *  @param right The right margin.
     *  @param bottom The bottom margin.
     **/
    
    //Invalid redeclaration of 'sublayerMargin(left:top:right:bottom:)'
    //    func sublayerMargin(left: inout CGFloat, top: inout CGFloat, right: inout CGFloat , bottom: inout CGFloat)
    //    {
    //        left   = self.paddingLeft;
    //        top    = self.paddingTop
    //        right  = self.paddingRight
    //        bottom = self.paddingBottom
    //    }
    
    // MARK: Sublayers
    func setSublayers(sublayers: CPTSublayerArray)
    {
        super.sublayers = sublayers;
        
        //        Class layerClass = [CPTLayer class];
        let scale    = self.contentsScale;
        
        for ( layer in sublayers ) {
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
    
    // MARK: Masking
    
    /// @cond
    
    // default path is the rounded rect layer bounds
    -(nullable CGPathRef)maskingPath
    {
    if ( self.masksToBounds ) {
    CGPathRef path = self.outerBorderPath;
    if ( path ) {
    return path;
    }
    
    path                 = CPTCreateRoundedRectPath(self.bounds, self.cornerRadius);
    self.outerBorderPath = path;
    CGPathRelease(path);
    
    return self.outerBorderPath;
    }
    else {
    return NULL;
    }
    }
    
    //    func sublayerMaskingPath() -> CGPath
    //    {
    //        return self.innerBorderPath!;
    //    }
    
    /// @endcond
    
    /** @brief Recursively sets the clipping path of the given graphics context to the sublayer masking paths of its superlayers.
     *
     *  The clipping path is built by recursively climbing the layer tree and combining the sublayer masks from
     *  each super layer. The tree traversal stops when a layer is encountered that is not a CPTLayer.
     *
     *  @param context The graphics context to clip.
     *  @param sublayer The sublayer that called this method.
     *  @param offset The cumulative position offset between the receiver and the first layer in the recursive calling chain.
     **/
    
    /** @brief Sets the clipping path of the given graphics context to mask the content.
     *
     *  The clipping path is built by recursively climbing the layer tree and combining the sublayer masks from
     *  each super layer. The tree traversal stops when a layer is encountered that is not a CPTLayer.
     *
     *  @param context The graphics context to clip.
     **/
//    func applyMaskToContext:(nonnull CGContextRef)context
//    {
//    CPTLayer *mySuperlayer = (CPTLayer *)self.superlayer;
//
//    if ( [mySuperlayer isKindOfClass:[CPTLayer class]] ) {
//    [mySuperlayer applySublayerMaskToContext:context forSublayer:self.withOffset:CGPointZero];
//    }
//
//    CGPathRef maskPath = self.maskingPath;
//
//    if ( maskPath ) {
//    CGContextAddPath(context, maskPath);
//    CGContextClip(context);
//    }
//    }
    
    /// @cond
    
//    override func setNeedsLayout()
//    {
//        super.setNeedsLayout()
//
//        let theGraph = self.graph
//
//        if (( theGraph ) != nil) {
//            NotificationCenter.default.post(name:.CPTGraphNeedsRedrawNotification,
//                                            object:theGraph)
//        }
//    }
    
    
    
    // MARK: -Accessors
    func setPosition(newPosition: CGPoint)
    {
        super.position = newPosition;
    }
    
    func setHidden(newHidden: Bool)
    {
        if ( newHidden != self.isHidden ) {
            super.isHidden = newHidden;
            if ( !newHidden ) {
                self.setNeedsDisplay()
            }
        }
    }
    
    func setContentsScale(newContentsScale: CGFloat)
    {
        if ( self.contentsScale != newContentsScale ) {
            if ( [CALayer instancesRespondToSelector:@selector(setContentsScale:)] ) {
                super.contentsScale = newContentsScale;
                self.setNeedsDisplay()
                
                Class layerClass = [CPTLayer class];
                for ( CALayer *subLayer in self.sublayers ) {
                    if ( [subLayer isKindOfClass:layerClass] ) {
                        subLayer.contentsScale = newContentsScale;
                    }
                }
            }
        }
    }
    
    func contentsScale()-> CGFloat
    {
        var scale = CGFloat(1.0);
        
        if ( [CALayer instancesRespondToSelector:@selector(contentsScale)] ) {
            scale = super.contentsScale;
        }
        
        return scale;
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
            //            CGPathRelease(outerBorderPath!);
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


