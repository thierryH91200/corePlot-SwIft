//
//  CPTLineStyle.swift
//  corePlot
//
//  Created by thierryH24 on 11/11/2020.
//

import AppKit


public class CPTLineStyle: NSObject {
    
    var lineCap = CGLineCap.butt
    var lineJoin : CGLineJoin
    var miterLimit : CGFloat
    var lineWidth : CGFloat
    var dashPattern : [CGFloat]
    var patternPhase: CGFloat 
    var lineColor: NSUIColor
    var lineFill : CPTFill?
    var lineGradient: CPTGradient?
    
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
            var dashLengths =  [CGFloat]()

            for  currentDashLength in myDashPattern {
                dashLengths.append( CGFloat(currentDashLength))
            }
            context.setLineDash(phase: patternPhase, lengths:  [2, 2])
//            CGContextSetLineDash(context, self.patternPhase, dashLengths, dashCount)
        }
        else {
            context.setLineDash(phase: patternPhase, lengths:  [2, 2])
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

    func strokePathWithGradient(gradient:  CPTGradient?, context: CGContext)
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
    var isOpaque : Bool {
        
        get {
            var opaqueLine = false;
            
            if ( self.dashPattern.count <= 1 ) {
                if (( self.lineGradient ) != nil) {
                    opaqueLine = self.lineGradient.isOpaque
                }
                else if (( self.lineFill ) != nil) {
                    opaqueLine = self.lineFill!.isOpaque
                }
                else if ( self.lineColor ) {
                    opaqueLine = self.lineColor.isOpaque
                }
            }
            return opaqueLine;
        }
        set { }
    }
    
}
