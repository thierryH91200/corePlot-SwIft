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
        
        if NSEdgeInsetsEqual(insets!, NSEdgeInsets()) == true {
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
            self.drawImage(theImage: imageSlices.slice[CPTSlice.topLeft.rawValue],
                           context:context,
                           rect: CGRect(x: 0.0, y: rect.size.height - capTop, width: capLeft, height: capTop),
                           scaleRatio:scaleRatio)
            
            self.drawImage(theImage: imageSlices.slice[CPTSlice.top.rawValue],
                           context:context,
                           rect:CGRect(x: capLeft, y: rect.size.height - capTop, width: centerSize.width, height: capTop),
                           scaleRatio:scaleRatio)
            
            self.drawImage(theImage: imageSlices.slice[CPTSlice.topRight.rawValue],
                           context:context,
                           rect:CGRect(x: rect.size.width - capRight, y: rect.size.height - capTop, width: capRight, height: capTop),
                           scaleRatio:scaleRatio)
            
            // middle row
            self.drawImage(theImage: imageSlices.slice[CPTSlice.left.rawValue],
                           context:context,
                           rect:CGRect(x: 0.0, y: capBottom, width: capLeft, height: centerSize.height),
                           scaleRatio:scaleRatio)
            
            self.drawImage(theImage: imageSlices.slice[CPTSlice.middle.rawValue],
                           context:context,
                           rect:CGRect(x: capLeft, y: capBottom, width: centerSize.width, height: centerSize.height),
                           scaleRatio:scaleRatio)
            
            self.drawImage(theImage: imageSlices.slice[CPTSlice.right.rawValue],
                           context:context,
                           rect:CGRect(x: rect.size.width - capRight, y: capBottom, width: capRight, height: centerSize.height),
                           scaleRatio:scaleRatio)
            
            // bottom row
            self.drawImage(theImage: imageSlices.slice[CPTSlice.bottomLeft.rawValue],
                           context:context,
                           rect:CGRect(x: 0.0, y: 0.0, width: capLeft, height: capBottom),
                           scaleRatio:scaleRatio)
            
            self.drawImage(theImage: imageSlices.slice[CPTSlice.bottom.rawValue],
                           context:context,
                           rect:CGRect(x: capLeft, y: 0.0, width: centerSize.width, height: capBottom),
                           scaleRatio:scaleRatio)
            
            self.drawImage(theImage: imageSlices.slice[CPTSlice.bottomRight.rawValue],
                           context:context,
                           rect:CGRect(x: rect.size.width - capRight, y: 0.0, width: capRight, height: capBottom),
                           scaleRatio:scaleRatio)
            //    }
            //
            //    self.lastDrawnScale = contextScale;
        }
        
    }
}
