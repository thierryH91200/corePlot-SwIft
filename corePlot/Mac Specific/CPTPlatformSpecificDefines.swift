//
//  CPTPlatformSpecificDefines.swift
//  corePlot
//
//  Created by thierryH24 on 16/11/2020.
//

import AppKit


typealias NSUIColor = NSColor ///< Platform-native color.
typealias CPTNativeImage = NSImage ///< Platform-native image format.
public typealias CPTNativeEvent = NSEvent ///< Platform-native OS event.
typealias CPTNativeFont = NSFont ///< Platform-native font.


extension CPTLayer {

/** @brief Gets an image of the layer contents.
 *  @return A native image representation of the layer content.
 **/
func imageOfLayer() -> CPTNativeImage
{
    let boundsSize = self.bounds.size;

    // Figure out the scale of pixels to points
    var scale = CGFloat(0.0)

    if ( self.respondsToSelector(#selector(hostingView) ) {
        
        
        scale = (self as? CPTGraph)?.hostingView.window.backingScaleFactor
        
    }
    if ((scale == 0.0) && CALayer.instancesRespondToSelector(#selector(contentsScale) ) {
        scale = self.contentsScale
    }
    if ( scale == 0.0 ) {
        let myWindow = self.graph?.hostingView.window;

        if ( myWindow ) {
            scale = myWindow.backingScaleFactor;
        }
        else {
            scale = NSScreen.mainScreen!.backingScaleFactor;
        }
    }
    scale = max(scale, CGFloat(1.0));

    let layerImage = NSBitmapImageRep(bitmapDataPlanes: nil,
                                      pixelsWide: Int(boundsSize.width * scale),
                                      pixelsHigh: Int(boundsSize.height * scale),
                                      bitsPerSample: 8, samplesPerPixel: 4,
                                      hasAlpha: true,
                                      isPlanar: false,
                                      colorSpaceName: .calibratedRGB,
                                      bitmapFormat: NSAlphaFirstBitmapFormat, bytesPerRow: 0,
                                      bitsPerPixel: 0)
    
    
    

    // Setting the size communicates the dpi; enables proper scaling for Retina screens
    layerImage?.size = NSSizeFromCGSize(boundsSize);

    let bitmapContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:layerImage];
    let context             = (CGContextRef)bitmapContext.graphicsPort;

    CGContextClearRect(context, CPTRectMake(0.0, 0.0, boundsSize.width, boundsSize.height));
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldSmoothFonts(context, false);
    [self layoutAndRenderInContext:context];
    CGContextFlush(context);

    NSImage *image = [[NSImage alloc] initWithSize:NSSizeFromCGSize(boundsSize)];

    [image addRepresentation:layerImage];

    return image;
}

@

// MARK:- NSAttributedString

    extension NSAttributedString {

/** @brief Draws the styled text into the given graphics context.
 *  @param rect The bounding rectangle in which to draw the text.
 *  @param context The graphics context to draw into.
 **/
        func drawInRect(rect: CGRect, inContext: CGContext)
    {
        CPTPushCGContext(context);

            self.draw( rect :NSRectFromCGRect, 
                   options:CPTStringDrawingOptions];

        CPTPopCGContext();
    }

/**
 *  @brief Computes the size of the styled text when drawn rounded up to the nearest whole number in each dimension.
 **/
        func sizeAsDrawn() -> CGSize
        {
            var rect = CGRect()
            
            if (self.respondsToSelector(to: #@selector(boundingRectWithSize:options:context:)) {
                rect = self.boundingRectWithSize:CGSize(10000.0, 10000.0)
                options:CPTStringDrawingOptions
                context:nil)
            }
            else {
            rect = self.boundingRectWithSize(CGSize(10000.0, 10000.0)
            options:CPTStringDrawingOptions)
            }
            
            var textSize = rect.size;
            
            textSize.width  = ceil(textSize.width)
            textSize.height = ceil(textSize.height)
            
            return textSize
            
        }
    }
}
