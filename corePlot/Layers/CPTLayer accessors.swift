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
    func sublayerMargin(left: inout CGFloat, top: inout CGFloat, right: inout CGFloat , bottom: inout CGFloat)
    {
        left   = self.paddingLeft;
        top    = self.paddingTop
        right  = self.paddingRight
        bottom = self.paddingBottom
    }

    // MARK: Sublayers

    /// @cond

    -(void)setSublayers:(nullable CPTSublayerArray *)sublayers
    {
        super.sublayers = sublayers;

        Class layerClass = [CPTLayer class];
        CGFloat scale    = self.contentsScale;

        for ( CALayer *layer in sublayers ) {
            if ( [layer isKindOfClass:layerClass] ) {
                ((CPTLayer *)layer).contentsScale = scale;
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
//    -(void)applySublayerMaskToContext:(nonnull CGContextRef)context forSublayer:(nonnull CPTLayer *)sublayer withOffset:(CGPoint)offset
//    {
//        CGPoint sublayerBoundsOrigin = sublayer.bounds.origin;
//        CGPoint layerOffset          = offset;
//
//        if ( !self.renderingRecursively ) {
//            CGPoint convertedOffset = [self convertPoint:sublayerBoundsOrigin fromLayer:sublayer];
//            layerOffset.x += convertedOffset.x;
//            layerOffset.y += convertedOffset.y;
//        }
//
//        CGAffineTransform sublayerTransform = CATransform3DGetAffineTransform(sublayer.transform);
//
//        CGContextConcatCTM(context, CGAffineTransformInvert(sublayerTransform));
//
//        CALayer *superlayer = self.superlayer;
//
//        if ( [superlayer isKindOfClass:[CPTLayer class]] ) {
//            [(CPTLayer *) superlayer applySublayerMaskToContext:context forSublayer:self withOffset:layerOffset];
//        }
//
//        CGPathRef maskPath = self.sublayerMaskingPath;
//
//        if ( maskPath ) {
//            CGContextTranslateCTM(context, -layerOffset.x, -layerOffset.y);
//            CGContextAddPath(context, maskPath);
//            CGContextClip(context);
//            CGContextTranslateCTM(context, layerOffset.x, layerOffset.y);
//        }
//
//        CGContextConcatCTM(context, sublayerTransform);
//    }

    /** @brief Sets the clipping path of the given graphics context to mask the content.
     *
     *  The clipping path is built by recursively climbing the layer tree and combining the sublayer masks from
     *  each super layer. The tree traversal stops when a layer is encountered that is not a CPTLayer.
     *
     *  @param context The graphics context to clip.
     **/
    -(void)applyMaskToContext:(nonnull CGContextRef)context
    {
        CPTLayer *mySuperlayer = (CPTLayer *)self.superlayer;

        if ( [mySuperlayer isKindOfClass:[CPTLayer class]] ) {
            [mySuperlayer applySublayerMaskToContext:context forSublayer:self withOffset:CGPointZero];
        }

        CGPathRef maskPath = self.maskingPath;

        if ( maskPath ) {
            CGContextAddPath(context, maskPath);
            CGContextClip(context);
        }
    }

    /// @cond

    fun setNeedsLayout()
    {
    super.setNeedsLayout;

        let theGraph = self.graph

        if ( theGraph ) {
    NotificationCenter.defaultCenter.post(NotificationName:CPTGraphNeedsRedrawNotification,  object:theGraph)
        }
    }

//    func setNeedsDisplay()
//    {
//        super.setNeedsDisplay()
//
//        let theGraph = self.graph;
//
//        if (( theGraph ) != nil) {
//            NotificationCenter .default.post(name:.CPTGraphNeedsRedrawNotification,
//                                                  object:theGraph)
//        }
//    }

    // MARK: -Accessors

    /// @cond

    -(void)setPosition:(CGPoint)newPosition
    {
        super.position = newPosition;
    }

    -(void)setHidden:(BOOL)newHidden
    {
        if ( newHidden != self.hidden ) {
            super.hidden = newHidden;
            if ( !newHidden ) {
                [self setNeedsDisplay];
            }
        }
    }

    -(void)setContentsScale:(CGFloat)newContentsScale
    {
        NSParameterAssert(newContentsScale > CPTFloat(0.0));

        if ( self.contentsScale != newContentsScale ) {
            if ( [CALayer instancesRespondToSelector:@selector(setContentsScale:)] ) {
                super.contentsScale = newContentsScale;
                [self setNeedsDisplay];

                Class layerClass = [CPTLayer class];
                for ( CALayer *subLayer in self.sublayers ) {
                    if ( [subLayer isKindOfClass:layerClass] ) {
                        subLayer.contentsScale = newContentsScale;
                    }
                }
            }
        }
    }

    -(CGFloat)contentsScale
    {
        CGFloat scale = CPTFloat(1.0);

        if ( [CALayer instancesRespondToSelector:@selector(contentsScale)] ) {
            scale = super.contentsScale;
        }

        return scale;
    }

    -(void)setShadow:(nullable CPTShadow *)newShadow
    {
        if ( newShadow != shadow ) {
            shadow = [newShadow copy];
            [self setNeedsLayout];
            [self setNeedsDisplay];
        }
    }

    -(void)setOuterBorderPath:(nullable CGPathRef)newPath
    {
        if ( newPath != outerBorderPath ) {
            CGPathRelease(outerBorderPath);
            outerBorderPath = CGPathRetain(newPath);
        }
    }

    -(void)setInnerBorderPath:(nullable CGPathRef)newPath
    {
        if ( newPath != innerBorderPath ) {
            CGPathRelease(innerBorderPath);
            innerBorderPath = CGPathRetain(newPath);
            [self.mask setNeedsDisplay];
        }
    }

    -(CGRect)bounds
    {
        CGRect actualBounds = super.bounds;

        if ( self.shadow ) {
            CGSize sizeOffset = self.shadowMargin;

            actualBounds.origin.x    += sizeOffset.width;
            actualBounds.origin.y    += sizeOffset.height;
            actualBounds.size.width  -= sizeOffset.width * CPTFloat(2.0);
            actualBounds.size.height -= sizeOffset.height * CPTFloat(2.0);
        }

        return actualBounds;
    }

    -(void)setBounds:(CGRect)newBounds
    {
        if ( !CGRectEqualToRect(self.bounds, newBounds)) {
            if ( self.shadow ) {
                CGSize sizeOffset = self.shadowMargin;

                newBounds.origin.x    -= sizeOffset.width;
                newBounds.origin.y    -= sizeOffset.height;
                newBounds.size.width  += sizeOffset.width * CPTFloat(2.0);
                newBounds.size.height += sizeOffset.height * CPTFloat(2.0);
            }

            super.bounds = newBounds;

            self.outerBorderPath = NULL;
            self.innerBorderPath = NULL;

            [[NSNotificationCenter defaultCenter] postNotificationName:CPTLayerBoundsDidChangeNotification
                                                                object:self];
        }
    }

    -(CGPoint)anchorPoint
    {
        CGPoint adjustedAnchor = super.anchorPoint;

        if ( self.shadow ) {
            CGSize sizeOffset   = self.shadowMargin;
            CGRect selfBounds   = self.bounds;
            CGSize adjustedSize = CGSizeMake(selfBounds.size.width + sizeOffset.width * CPTFloat(2.0),
                                             selfBounds.size.height + sizeOffset.height * CPTFloat(2.0));

            if ( selfBounds.size.width > CPTFloat(0.0)) {
                adjustedAnchor.x = (adjustedAnchor.x - CPTFloat(0.5)) * (adjustedSize.width / selfBounds.size.width) + CPTFloat(0.5);
            }
            if ( selfBounds.size.height > CPTFloat(0.0)) {
                adjustedAnchor.y = (adjustedAnchor.y - CPTFloat(0.5)) * (adjustedSize.height / selfBounds.size.height) + CPTFloat(0.5);
            }
        }

        return adjustedAnchor;
    }

    -(void)setAnchorPoint:(CGPoint)newAnchorPoint
    {
        if ( self.shadow ) {
            CGSize sizeOffset   = self.shadowMargin;
            CGRect selfBounds   = self.bounds;
            CGSize adjustedSize = CGSizeMake(selfBounds.size.width + sizeOffset.width * CPTFloat(2.0),
                                             selfBounds.size.height + sizeOffset.height * CPTFloat(2.0));

            if ( adjustedSize.width > CPTFloat(0.0)) {
                newAnchorPoint.x = (newAnchorPoint.x - CPTFloat(0.5)) * (selfBounds.size.width / adjustedSize.width) + CPTFloat(0.5);
            }
            if ( adjustedSize.height > CPTFloat(0.0)) {
                newAnchorPoint.y = (newAnchorPoint.y - CPTFloat(0.5)) * (selfBounds.size.height / adjustedSize.height) + CPTFloat(0.5);
            }
        }

        super.anchorPoint = newAnchorPoint;
    }

    -(void)setCornerRadius:(CGFloat)newRadius
    {
        if ( newRadius != self.cornerRadius ) {
            super.cornerRadius = newRadius;

            [self setNeedsDisplay];

            self.outerBorderPath = NULL;
            self.innerBorderPath = NULL;
        }
    }

    /// @endcond

    #pragma mark -
    #pragma mark Description

    /// @cond

    -(nullable NSString *)description
    {
        return [NSString stringWithFormat:@"<%@ bounds: %@>", super.description, CPTStringFromRect(self.bounds)];
    }

    /// @endcond

    /**
     *  @brief Logs this layer and all of its sublayers.
     **/
    -(void)logLayers
    {
        NSLog(@"Layer tree:\n%@", [self subLayersAtIndex:0]);
    }

    /// @cond

    -(nonnull NSString *)subLayersAtIndex:(NSUInteger)idx
    {
        NSMutableString *result = [NSMutableString string];

        for ( NSUInteger i = 0; i < idx; i++ ) {
            [result appendString:@".   "];
        }
        [result appendString:self.description];

        for ( CPTLayer *sublayer in self.sublayers ) {
            [result appendString:@"\n"];

            if ( [sublayer respondsToSelector:@selector(subLayersAtIndex:)] ) {
                [result appendString:[sublayer subLayersAtIndex:idx + 1]];
            }
            else {
                [result appendString:sublayer.description];
            }
        }

        return result;
    }

    /// @endcond

    #pragma mark -
    #pragma mark Debugging

    /// @cond

    -(nullable id)debugQuickLookObject
    {
        return [self imageOfLayer];
    }
    
}


