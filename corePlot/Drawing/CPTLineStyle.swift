//
//  CPTLineStyle.swift
//  corePlot
//
//  Created by thierryH24 on 11/11/2020.
//

import Cocoa
import Foundation


class CPTLineStyle: NSObject {
    
    var lineCap = CGLineCap.butt
    var lineJoin : CGLineJoin
    var miterLimit : CGFloat
    var lineWidth : CGFloat
    var dashPattern : [Double]
    var patternPhase: CGFloat 
    var lineColor: NSColor
    var lineFill : CPTFill?
    var lineGradient: CPTGradient?
    var isOpaque = true
    
    override init()
    {
        lineCap      = .butt
        lineJoin     = .miter
        miterLimit   = CGFloat(10.0)
        lineWidth    = CGFloat(1.0)
        dashPattern  = []
        patternPhase = CGFloat(0.0)
        lineColor    = NSColor.black
        lineFill     = nil
        lineGradient = nil
    }
    
    func lineStyleWithStyle( lineStyle: CPTLineStyle  ) -> CPTLineStyle
    {
        let newLineStyle = CPTLineStyle()

        newLineStyle.lineCap      = lineStyle.lineCap
        newLineStyle.lineJoin     = lineStyle.lineJoin
        newLineStyle.miterLimit   = lineStyle.miterLimit
        newLineStyle.lineWidth    = lineStyle.lineWidth;
        newLineStyle.dashPattern  = lineStyle.dashPattern
        newLineStyle.patternPhase = lineStyle.patternPhase
        newLineStyle.lineColor    = lineStyle.lineColor
        newLineStyle.lineFill     = lineStyle.lineFill
        newLineStyle.lineGradient = lineStyle.lineGradient

        return newLineStyle
    }
    
    func sizeof <T> (_ : T.Type) -> Int
    {
        return (MemoryLayout<T>.size)
    }

    func sizeof <T> (_ : T) -> Int
    {
        return (MemoryLayout<T>.size)
    }

    func sizeof <T> (_ value : [T]) -> Int
    {
        return (MemoryLayout<T>.size * value.count)
    }



    // MARK:  - Drawing
    func setLineStyleInContext(context: CGContext)
    {
        context.setLineCap(self.lineCap);
        context.setLineJoin(self.lineJoin);
        context.setMiterLimit(self.miterLimit);
        context.setLineWidth(self.lineWidth);

        let myDashPattern = self.dashPattern;
        let dashCount = myDashPattern.count;

        if dashCount > 0  {
            let sz = sizeof(Double.self)
            var dashLengths = (Double)calloc(dashCount, sizeof(Double.self))

            var dashCounter = 0;
            for  currentDashLength in myDashPattern {
                dashCounter += 1
                dashLengths[dashCounter] = currentDashLength.cgFloatValue
            }

            CGContextSetLineDash(context, self.patternPhase, dashLengths, dashCount)
        }
        else {
            CGContextSetLineDash(context, CGFloat(0.0), nil, 0)
        }
        context.setStrokeColor(self.lineColor.cgColor);
    }

    /** @brief Stroke the current path in the given graphics context.
     *  Call @link CPTLineStyle::setLineStyleInContext: -setLineStyleInContext: @endlink first to set up the drawing properties.
     *
     *  @param context The graphics context.
     **/
    func strokePathInContext(context: CGContext)
    {
        let gradient = self.lineGradient
        let fill     = self.lineFill

        if (( gradient ) != nil) {
            self.strokePathWithGradient(gradient: gradient!, context:context)
        }
        else if (( fill ) != nil) {
            context.replacePathWithStrokedPath();
            fill?.fillPathInContext(context: context)
        }
        else {
            context.strokePath();
        }
    }

    /** @brief Stroke a rectangular path in the given graphics context.
     *  Call @link CPTLineStyle::setLineStyleInContext: -setLineStyleInContext: @endlink first to set up the drawing properties.
     *
     *  @param rect The rectangle to draw.
     *  @param context The graphics context.
     **/
    func strokeRect(rect: CGRect, context: CGContext)
    {
        let gradient = self.lineGradient;
        let fill         = self.lineFill;

        if (( gradient ) != nil) {
            context.beginPath()
            context.addRect(rect)
            self.strokePathWithGradient(gradient: gradient! ,context:context)
        }
        else if (( fill ) != nil) {
            context.beginPath();
            context.addRect(rect);
            context.replacePathWithStrokedPath();
            fill!.fillPathInContext(context: context)
        }
        else {
            context.stroke(rect);
        }
    }

    /// @cond

    func strokePathWithGradient(gradient:  CPTGradient, context: CGContext)
    {
        if ( gradient != nil ) {
            let deviceRect = context.convertToDeviceSpace(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0));

            let step = CGFloat(2.0) / deviceRect.size.height;

            let startWidth = self.lineWidth;

            let path = context.path;
            context.beginPath();

            var width = startWidth
            while ( width > CGFloat(0.0)) {
                context.setLineWidth(width);

                let gradientColor = gradient.newColorAtPosition(CGFloat(1.0) - width / startWidth)
                CGContextSetStrokeColorWithColor(context, gradientColor);
                CGColorRelease(gradientColor);

                context.addPath(path!);
                context.strokePath();

                width -= step;
            }

        }
    }

    // MARK:  - Opacity
    func isOpaque()-> Bool
    {
        var opaqueLine = false;

        if ( self.dashPattern.count <= 1 ) {
            if (( self.lineGradient ) != nil) {
                opaqueLine = self.lineGradient.opaque;
            }
            else if ( self.lineFill ) {
                opaqueLine = self.lineFill.opaque;
            }
            else if ( self.lineColor ) {
                opaqueLine = self.lineColor.opaque;
            }
        }

        return opaqueLine;
    }



    
}
