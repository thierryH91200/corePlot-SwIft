//
//  CPTImage ext2.swift
//  corePlot
//
//  Created by thierryH24 on 18/11/2020.
//

import Foundation

extension CPTImage{
    
    func draw(in rect: CGRect, in context: CGContext) {
        
        
        let theImage = self.image;
        
        // compute drawing scale
        let lastScale    = self.lastDrawnScale;
        var contextScale = CGFloat(1.0);
        
        if ( rect.size.height != CGFloat(0.0)) {
            let deviceRect = context.convertToDeviceSpace(rect);
            contextScale = deviceRect.size.height / rect.size.height;
        }
        
        // generate a Core Graphics image if needed
        if ( (theImage == nil) || (contextScale != lastScale)) {
            let theNativeImage = self.nativeImage;
            
            if (( theNativeImage ) != nil) {
                //                #if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
                //                theImage   = theNativeImage.CGImage;
                //                self.scale = theNativeImage.scale;
                //                #else
                //                let imageSize   = theNativeImage!.size;
                //                let drawingRect = NSRect(x: 0.0, y: 0.0, width: imageSize.width, height: imageSize.height);
                //
                //                theImage = theNativeImage.CGImageForProposedRect(drawingRect,
                //                                                                 context:[contextNSGraphicsContext graphicsContextWithGraphicsPort:context flipped:false)
                //                                                                    hints:nil)
                //
                //                                                                    theNativeImage.cgImage(forProposedRect proposedDestRect: UnsafeMutablePointer<NSRect>?,
                //                                                                    context referenceContext: NSGraphicsContext?,
                //                                                                    hints:  : nil)
                //
                //
                //
                //                                                                    self.scale = contextScale;
                //                #endif
                self.image = theImage;
            }
        }
        guard theImage != nil else  { return}
        
        
        // draw the image
        let imageScale = self.scale;
        let scaleRatio = contextScale / imageScale;
        
        let insets = self.edgeInsets;
        //
        if ( CPTEdgeInsetsEqualToEdgeInsets(  insets., EdgeInsets.zeto)) {
            self.drawImage(theImage: theImage, context:context, rect:rect, scaleRatio:scaleRatio)
        }
        else {
            var imageSlices = self.slices
            var hasSlices             = false;
            
            for  i in   0..<9 {
                if (imageSlices.slice[i] != nil)  {
                    hasSlices = true
                    break;
                }
            }
            //
            // create new slices if needed
            if ( !hasSlices || (contextScale != lastScale)) {
                self.makeImageSlices()
                imageSlices = self.slices;
            }
            
            let capTop    = insets!.top;
            let capLeft   = insets!.left;
            let capBottom = insets!.bottom;
            let capRight  = insets!.right;
            
            let centerSize = CGSize(width: rect.size.width - capLeft - capRight,
                                    height: rect.size.height - capTop - capBottom)
            
            // top row
            let rect = CGRect(x: 0.0, y: rect.size.height - capTop, width: capLeft, height: capTop)
            self.drawImage(imageSlices.slice[.topLeft]
            inContext:context,
            rect: rect,
            scaleRatio:scaleRatio]
            
            [self drawImage:imageSlices.slice[CPTSliceTop]
            inContext:context
            rect:CPTRectMake(capLeft, rect.size.height - capTop, centerSize.width, capTop)
            scaleRatio:scaleRatio];
            [self drawImage:imageSlices.slice[CPTSliceTopRight]
            inContext:context
            rect:CPTRectMake(rect.size.width - capRight, rect.size.height - capTop, capRight, capTop)
            scaleRatio:scaleRatio];
            
            //        // middle row
            //        [self drawImage:imageSlices.slice[CPTSliceLeft]
            //        inContext:context
            //        rect:CPTRectMake(0.0, capBottom, capLeft, centerSize.height)
            //        scaleRatio:scaleRatio];
            //        [self drawImage:imageSlices.slice[CPTSliceMiddle]
            //        inContext:context
            //        rect:CPTRectMake(capLeft, capBottom, centerSize.width, centerSize.height)
            //        scaleRatio:scaleRatio];
            //        [self drawImage:imageSlices.slice[CPTSliceRight]
            //        inContext:context
            //        rect:CPTRectMake(rect.size.width - capRight, capBottom, capRight, centerSize.height)
            //        scaleRatio:scaleRatio];
            //
            //        // bottom row
            //        [self drawImage:imageSlices.slice[CPTSliceBottomLeft]
            //        inContext:context
            //        rect:CPTRectMake(0.0, 0.0, capLeft, capBottom)
            //        scaleRatio:scaleRatio];
            //        [self drawImage:imageSlices.slice[CPTSliceBottom]
            //        inContext:context
            //        rect:CPTRectMake(capLeft, 0.0, centerSize.width, capBottom)
            //        scaleRatio:scaleRatio];
            //        [self drawImage:imageSlices.slice[CPTSliceBottomRight]
            //        inContext:context
            //        rect:CPTRectMake(rect.size.width - capRight, 0.0, capRight, capBottom)
            //        scaleRatio:scaleRatio];
            //    }
            //
            //    self.lastDrawnScale = contextScale;
            }
            
        }
