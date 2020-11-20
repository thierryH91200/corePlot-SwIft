//
//  CPTLayer extDrawing.swift
//  corePlot
//
//  Created by thierryH24 on 20/11/2020.
//

import AppKit

extension CPTLayer {
    // MARK: - Drawing
    -(void)display
    {
        if ( self.hidden ) {
            return;
        }
        else {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    #if TARGET_OS_OSX
            // Workaround since @available macro is not there

            if ( [NSView instancesRespondToSelector:@selector(effectiveAppearance)] ) {
                NSAppearance *oldAppearance = NSAppearance.currentAppearance;
                NSAppearance.currentAppearance = ((NSView *)self.graph.hostingView).effectiveAppearance;
                [super display];
                NSAppearance.currentAppearance = oldAppearance;
            }
            else {
                [super display];
            }
    #else
    #ifdef __IPHONE_13_0
            if ( @available(iOS 13, *)) {
                if ( [UITraitCollection instancesRespondToSelector:@selector(performAsCurrentTraitCollection:)] ) {
                    UITraitCollection *traitCollection = ((UIView *)self.graph.hostingView).traitCollection;
                    if ( traitCollection ) {
                        [traitCollection performAsCurrentTraitCollection: ^{
                            [super display];
                        }];
                    }
                    else {
                        [super display];
                    }
                }
                else {
                    [super display];
                }
            }
            else {
                [super display];
            }
    #else
            [super display];
    #endif
    #endif
    #pragma clang diagnostic pop
        }
    }

    -(void)drawInContext:(nonnull CGContextRef)context
    {
        if ( context ) {
            self.useFastRendering = YES;
            [self renderAsVectorInContext:context];
            self.useFastRendering = NO;
        }
        else {
            NSLog(@"%@: Tried to draw into a NULL context", self);
        }
    }

    /// @endcond

    /**
     * @brief Recursively marks this layer and all sublayers as needing to be redrawn.
     **/
    -(void)setNeedsDisplayAllLayers
    {
        [self setNeedsDisplay];

        for ( CPTLayer *subLayer in self.sublayers ) {
            if ( [subLayer respondsToSelector:@selector(setNeedsDisplayAllLayers)] ) {
                [subLayer setNeedsDisplayAllLayers];
            }
            else {
                [subLayer setNeedsDisplay];
            }
        }
    }

    /** @brief Draws layer content into the provided graphics context.
     *
     *  This method replaces the CALayer @link CALayer::drawInContext: -drawInContext: @endlink method
     *  to ensure that layer content is always drawn as vectors
     *  and objects rather than as a cached bit-mapped image representation.
     *  Subclasses should do all drawing here and must call @super to set up the clipping path.
     *
     *  @param context The graphics context to draw into.
     **/
    -(void)renderAsVectorInContext:(nonnull CGContextRef)context
    {
        // This is where subclasses do their drawing
        if ( self.renderingRecursively ) {
            [self applyMaskToContext:context];
        }
        [self.shadow setShadowInContext:context];
    }

    /** @brief Draws layer content and the content of all sublayers into the provided graphics context.
     *  @param context The graphics context to draw into.
     **/
    -(void)recursivelyRenderInContext:(nonnull CGContextRef)context
    {
        if ( !self.hidden ) {
            // render self
            CGContextSaveGState(context);

            [self applyTransform:self.transform toContext:context];

            self.renderingRecursively = YES;
            if ( !self.masksToBounds ) {
                CGContextSaveGState(context);
            }
            [self renderAsVectorInContext:context];
            if ( !self.masksToBounds ) {
                CGContextRestoreGState(context);
            }
            self.renderingRecursively = NO;

            // render sublayers
            CPTSublayerArray *sublayersCopy = [self.sublayers copy];
            for ( CALayer *currentSublayer in sublayersCopy ) {
                CGContextSaveGState(context);

                // Shift origin of context to match starting coordinate of sublayer
                CGPoint currentSublayerFrameOrigin = currentSublayer.frame.origin;
                CGRect currentSublayerBounds       = currentSublayer.bounds;
                CGContextTranslateCTM(context,
                                      currentSublayerFrameOrigin.x - currentSublayerBounds.origin.x,
                                      currentSublayerFrameOrigin.y - currentSublayerBounds.origin.y);
                [self applyTransform:self.sublayerTransform toContext:context];
                if ( [currentSublayer isKindOfClass:[CPTLayer class]] ) {
                    [(CPTLayer *) currentSublayer recursivelyRenderInContext:context];
                }
                else {
                    if ( self.masksToBounds ) {
                        CGContextClipToRect(context, currentSublayer.bounds);
                    }
                    [currentSublayer drawInContext:context];
                }
                CGContextRestoreGState(context);
            }

            CGContextRestoreGState(context);
        }
    }

    /// @cond

func applyTransform(transform3D: CATransform3D, context: CGContext)
    {
        if ( !CATransform3DIsIdentity(transform3D)) {
            if ( CATransform3DIsAffine(transform3D)) {
                let  selfBounds    = self.bounds;
                let anchorPoint  = self.anchorPoint;
                let anchorOffset = CGPoint(anchorOffset.x = selfBounds.origin.x + anchorPoint.x * selfBounds.size.width,
                                           anchorOffset.y = selfBounds.origin.y + anchorPoint.y * selfBounds.size.height);

                let affineTransform = CGAffineTransformMakeTranslation(-anchorOffset.x, -anchorOffset.y);
                affineTransform = CGAffineTransformConcat(affineTransform, CATransform3DGetAffineTransform(transform3D));
                affineTransform = CGAffineTransformTranslate(affineTransform, anchorOffset.x, anchorOffset.y);

                let transformedBounds = CGRectApplyAffineTransform(selfBounds, affineTransform);

                CGContextTranslateCTM(context, -transformedBounds.origin.x, -transformedBounds.origin.y);
                CGContextConcatCTM(context, affineTransform);
            }
        }
    }

    /// @endcond

    /** @brief Updates the layer layout if needed and then draws layer content and the content of all sublayers into the provided graphics context.
     *  @param context The graphics context to draw into.
     */
    -(void)layoutAndRenderInContext:(nonnull CGContextRef)context
    {
        [self layoutIfNeeded];
        [self recursivelyRenderInContext:context];
    }

    /** @brief Draws layer content and the content of all sublayers into a PDF document.
     *  @return PDF representation of the layer content.
     **/
    -(nonnull NSData *)dataForPDFRepresentationOfLayer
    {
        NSMutableData *pdfData         = [[NSMutableData alloc] init];
        CGDataConsumerRef dataConsumer = CGDataConsumerCreateWithCFData((__bridge CFMutableDataRef)pdfData);

        const CGRect mediaBox   = CPTRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);
        CGContextRef pdfContext = CGPDFContextCreate(dataConsumer, &mediaBox, NULL);

        CPTPushCGContext(pdfContext);

        CGContextBeginPage(pdfContext, &mediaBox);
        [self layoutAndRenderInContext:pdfContext];
        CGContextEndPage(pdfContext);
        CGPDFContextClose(pdfContext);

        CPTPopCGContext();

        CGContextRelease(pdfContext);
        CGDataConsumerRelease(dataConsumer);

        return pdfData;
    }

    #pragma mark -
    #pragma mark Responder Chain and User interaction

    /// @name User Interaction
    /// @{

    -(BOOL)pointingDeviceDownEvent:(nonnull CPTNativeEvent *__unused)event atPoint:(CGPoint __unused)interactionPoint
    {
        return NO;
    }

    -(BOOL)pointingDeviceUpEvent:(nonnull CPTNativeEvent *__unused)event atPoint:(CGPoint __unused)interactionPoint
    {
        return NO;
    }

    -(BOOL)pointingDeviceDraggedEvent:(nonnull CPTNativeEvent *__unused)event atPoint:(CGPoint __unused)interactionPoint
    {
        return NO;
    }

    -(BOOL)pointingDeviceCancelledEvent:(nonnull CPTNativeEvent *__unused)event
    {
        return NO;
    }

    #if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
    #else
    -(BOOL)scrollWheelEvent:(nonnull CPTNativeEvent *__unused)event fromPoint:(CGPoint __unused)fromPoint toPoint:(CGPoint __unused)toPoint
    {
        return NO;
    }

    #endif

    /// @}
}
