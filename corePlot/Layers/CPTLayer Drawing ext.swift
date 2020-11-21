//
//  CPTLayer extDrawing.swift
//  corePlot
//
//  Created by thierryH24 on 20/11/2020.
//

import AppKit

extension CPTLayer {
    
    // MARK: - Drawing
    override func display()
    {
        guard self.isHidden == false else {return}
        
        if NSView.instancesRespondToSelector:@selector(effectiveAppearance)] ) {
            let oldAppearance = NSAppearance.current;
            NSAppearance.currentAppearance = NSView self.graph.hostingView.effectiveAppearance
            
            super.display()
            NSAppearance.current = oldAppearance;
        }
        else {
            super.display()
        }
    }
    
    func drawInContext(context: CGContext)
    {
        if ( context ) {
            self.useFastRendering = true
            self.renderAsVectorInContext(context: context)
            self.useFastRendering = false
        }
        else {
            print("%@: Tried to draw into a NULL context");
        }
    }
    
    
    /**
     * @brief Recursively marks this layer and all sublayers as needing to be redrawn.
     **/
    @objc func setNeedsDisplayAllLayers() {
        
        self.setNeedsDisplay()
        
        for subLayer in self.sublayers  {
            
            if subLayer.responds(to: #selector(setNeedsDisplayAllLayers)) {
                subLayer.setNeedsDisplayAllLayers()
            }
            else {
                subLayer.setNeedsDisplay()
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
    
    func renderAsVectorInContext(context: CGContext)
    {
        // This is where subclasses do their drawing
        if ( self.renderingRecursively ) {
            self.applyMaskToContext(context: context)
        }
        self.shadow?.shadowIn(context: context)
    }
    
    /** @brief Draws layer content and the content of all sublayers into the provided graphics context.
     *  @param context The graphics context to draw into.
     **/
//    func recursivelyRenderInContext(context: CGContext)
//    {
//        guard self.isHidden == false else { return }
//        // render self
//
//        context.saveGState();
//
//        [self.applyTransform(transform3D: self.transform ,context:context)
//
//        self.renderingRecursively = YES;
//        if ( !self.masksToBounds ) {
//            CGContextSaveGState(context);
//        }
//        [self renderAsVectorInContext(context)
//        if ( !self.masksToBounds ) {
//            CGContextRestoreGState(context);
//        }
//        self.renderingRecursively = false
//
//        // render sublayers
//        let sublayersCopy = self.sublayers
//        for currentSublayer in sublayersCopy {
//            CGContextSaveGState(context);
//
//            // Shift origin of context to match starting coordinate of sublayer
//            let currentSublayerFrameOrigin = currentSublayer.frame.origin;
//            let  currentSublayerBounds       = currentSublayer.bounds;
//            CGContextTranslateCTM(context,
//                                  currentSublayerFrameOrigin.x - currentSublayerBounds.origin.x,
//                                  currentSublayerFrameOrigin.y - currentSublayerBounds.origin.y);
//
//            self.applyTransform(transform3D: self.sublayerTransform ,context:context)
//
//
//            if ( [currentSublayer isKindOfClass:[CPTLayer class]] ) {
//                [(CPTLayer *) currentSublayer recursivelyRenderInContext:context];
//            }
//            else {
//                if ( self.masksToBounds ) {
//                    CGContextClipToRect(context, currentSublayer.bounds);
//                }
//                currentSublayer.drawInContext(context)
//            }
//            CGContextRestoreGState(context)
//        }
//        CGContextRestoreGState(context);
//    }
    
    
    func applyTransform(transform3D: CATransform3D, context: CGContext)
    {
        if ( !CATransform3DIsIdentity(transform3D)) {
            if ( CATransform3DIsAffine(transform3D)) {
                let  selfBounds    = self.bounds;
                let anchorPoint  = self.anchorPoint;
                let anchorOffset = CGPoint( x: selfBounds.origin.x + anchorPoint.x * selfBounds.size.width,
                                            y: selfBounds.origin.y + anchorPoint.y * selfBounds.size.height);
                
                var affineTransform = CGAffineTransform(translationX: -anchorOffset.x, y: -anchorOffset.y);
                affineTransform = CGAffineTransformConcat(affineTransform, CATransform3DGetAffineTransform(transform3D));
                affineTransform = CGAffineTransformTranslate(affineTransform, anchorOffset.x, anchorOffset.y);
                
                let transformedBounds = CGRectApplyAffineTransform(selfBounds, affineTransform);
                
                context.translateBy(x: -transformedBounds.origin.x, y: -transformedBounds.origin.y);
                context.concatenate(affineTransform);
            }
        }
    }
    
    /** @brief Updates the layer layout if needed and then draws layer content and the content of all sublayers into the provided graphics context.
     *  @param context The graphics context to draw into.
     */
    func layoutAndRenderInContext(context: CGContext)
    {
        self.layoutIfNeeded()
        self.recursivelyRenderInContext(context: context)
    }
    
    /** @brief Draws layer content and the content of all sublayers into a PDF document.
     *  @return PDF representation of the layer content.
     **/
    func dataForPDFRepresentationOfLayer () -> NSData
    {
        
        var pdfData = Data()
        var dataConsumer: CGDataConsumer? = nil
        if let data = pdfData as? CFMutableData {
            dataConsumer = CGDataConsumer(data: data)
        }
        
        let mediaBox = CPTRectMake(0.0, 0.0, bounds.size.width, bounds.size.height)
        var pdfContext: CGContext? = nil
        if let dataConsumer = dataConsumer {
            pdfContext = CGContext(consumer: dataConsumer, mediaBox: &mediaBox, nil)
        }
        
        CPTPushCGContext(pdfContext)
        
        pdfContext?.beginPage(mediaBox: &mediaBox)
        layoutAndRender(in: pdfContext)
        pdfContext?.endPage()
        pdfContext?.closePDF()
        
        CPTPopCGContext()
        
        CGContextRelease(pdfContext)
        CGDataConsumerRelease(dataConsumer)
        
        return pdfData;
    }
    
    //MARK: - Responder Chain and User interaction
    func pointingDeviceDownEvent(event : CPTNativeEvent,atPoint:CGPoint) -> Bool
    {
        return false;
    }
    
    func pointingDeviceUpEvent(event : CPTNativeEvent , atPoint: CGPoint)-> Bool
    {
        return false;
    }
    
    func pointingDeviceDraggedEvent(event : CPTNativeEvent, atPoint: GPoint)-> Bool
    {
        return false;
    }
    
    func pointingDeviceCancelledEvent(event: CPTNativeEvent ) -> Bool
    {
        return false;
    }
    
    func scrollWheelEvent(event : CPTNativeEvent, fromPoint:CGPoint, toPoint:CGPoint) -> Bool
    {
        return false
    }
    
}


