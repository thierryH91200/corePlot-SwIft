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
        
        if self.respondsToSelector(to: #selector(hostingView)) {
            scale = (self as? CPTGraph)?.hostingView.window.backingScaleFactor
        }
        
        if ((scale == 0.0) && CALayer.instancesRespondToSelector(to: #selector(contentsScale))) {
            scale = self.contentsScale
        }
        
        if ( scale == 0.0 ) {
            let myWindow = self.graph?.hostingView?.window;
            
            if (( myWindow ) != nil) {
                scale = myWindow!.backingScaleFactor;
            }
            else {
                scale = NSScreen.main!.backingScaleFactor;
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
//                                          bitmapFormat: NSAlphaFirstBitmapFormat,
                                          bytesPerRow: 0,
                                          bitsPerPixel: 0)
        
        // Setting the size communicates the dpi; enables proper scaling for Retina screens
        layerImage?.size = NSSizeFromCGSize(boundsSize);
        
        let bitmapContext = NSGraphicsContext(bitmapImageRep: layerImage!)
        let context       = bitmapContext?.cgContext
        
        context!.clear(CGRect(x: 0.0, y: 0.0, width: boundsSize.width, height: boundsSize.height))
        context!.setAllowsAntialiasing(true)
        context!.setShouldSmoothFonts(false)
        self.layoutAndRender(context: context!)
        context!.flush()
        
        let image = NSImage(size: boundsSize)
        image.addRepresentation(layerImage!)
        return image;
    }
}

// MARK:- NSAttributedString

extension NSAttributedString {
    
    /** @brief Draws the styled text into the given graphics context.
     *  @param rect The bounding rectangle in which to draw the text.
     *  @param context The graphics context to draw into.
     **/
    func drawInRect(rect: CGRect, context: CGContext)
    {
        NSUIGraphicsPushContext(context)
        self.draw( rect :NSRectFromCGRect, options:CPTStringDrawingOptions)
        NSUIGraphicsPopContext()
    }
    
    /**
     *  @brief Computes the size of the styled text when drawn rounded up to the nearest whole number in each dimension.
     **/
    func sizeAsDrawn() -> CGSize
    {
        var rect = CGRect()
        
        if self.respondsToSelector(to: #selector(boundingRectWithSize( options:context:))) {
            rect = self.boundingRectWithSize(CGSize(10000.0, 10000.0), options: CPTStringDrawingOptions, context:nil)
        }
        else
        {
            rect = self.boundingRectWithSize(CGSize(10000.0, 10000.0),  options: CPTStringDrawingOptions)
        }
        var textSize = rect.size
        textSize.width  = ceil(textSize.width)
        textSize.height = ceil(textSize.height)
        return textSize
    }
}




#if os(OSX)
import AppKit

public extension NSBezierPath {
    
    var cgPath: CGPath {
        let path = CGMutablePath()
        let points = NSPointArray.allocate(capacity: 3)
        
        for i in 0 ..< elementCount {
            let type = element(at: i, associatedPoints: points)
            switch type {
            case .moveTo:
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .curveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath:
                path.closeSubpath()
            @unknown default:
                break
            }
        }
        return path
    }
    
}
#endif
