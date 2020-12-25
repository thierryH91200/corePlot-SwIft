//
//  CPTGradient.swift
//  corePlot
//
//  Created by thierryH24 on 09/11/2020.
//

import AppKit


// https://stackoverflow.com/questions/49399089/binary-tree-with-struct-in-swift

class CPTGradientElement {
    
    var color : CPTRGBAColor    ///< Color
    var position: CGFloat      ///< Gradient position (0 ≤ @par{position} ≤ 1)
    
    var nextElement : CPTGradientElement?
    
    init() {
        self.position = CGFloat(0)
        self.color.alpha = 0
        self.color.red = 0
        self.color.green = 0
        self.color.blue = 0
    }
    
}

class CPTGradient: NSObject {
    
    // Enumeration of gradient types
    enum  CPTGradientType: Int  {
        case axial             ///< Axial gradient
        case radial   ///< Radial gradient
    }

    enum CPTGradientBlendingMode: Int {
        case linear          ///< Linear blending mode
        case chromatic       ///< Chromatic blending mode
        case inverseChromatic ///< Inverse chromatic blending mode
    };
    
    
    var colorspace : CPTColorSpace?
    var blendingMode:  CPTGradientBlendingMode?
    var elementList:  CPTGradientElement?
    var gradientFunction : CGFunction
    
    var gradientType : CPTGradientType
    var  angle = CGFloat(0)
    
    var startAnchor: CGPoint
    var endAnchor: CGPoint
        
    override init()
    {
        super.init()
        self.commonInit()
        
        self.blendingMode = .linear
        
        angle        = CGFloat(0.0)
        gradientType = .axial
        startAnchor  = CGPoint(x: 0.5, y: 0.5)
        endAnchor    = CGPoint(x: 0.5, y: 0.5)
    }
    
    func commonInit()
    {
        self.colorspace  = CPTColorSpace.shared.genericRGBSpace()
        self.elementList = nil;
    }
    
    func CPTTransformHSV_RGB(components :[CGFloat] ) // H,S,B -> R,G,B
    {
        var components = components
        var R = CGFloat(0.0), G = CGFloat(0.0), B = CGFloat(0.0);
        
        let H = fmod(components[0], CGFloat(360.0)); // map to [0,360)
        let S = components[1];
        let V = components[2];
        
        let Hi    = Int(lrint(floor(Double(H / CGFloat(60.0)))) % 6)
        let f = H / CGFloat(60.0) - CGFloat(Hi)
        let p = V * (CGFloat(1.0) - S);
        let q = V * (CGFloat(1.0) - f * S)
        let t = V * (CGFloat(1.0) - (CGFloat(1.0) - f) * S);
        switch ( Hi ) {
        case 0:
            R = V;
            G = t;
            B = p;
            break;
            
        case 1:
            R = q;
            G = V;
            B = p;
            break;
            
        case 2:
            R = p;
            G = V;
            B = t;
            break;
            
        case 3:
            R = p;
            G = q;
            B = V;
            break;
            
        case 4:
            R = t;
            G = p;
            B = V
            break;
            
        case 5:
            R = V
            G = p
            B = q
            break;
            
        default:
            break;
        }
        
        components[0] = R;
        components[1] = G;
        components[2] = B;
    }
    
    
    func addElement( newElement: CPTGradientElement )
    {
        var curElement = self.elementList
        
        if curElement == nil || (newElement.position < curElement!.position) {
            let tmpNext        = curElement;
            var newElementList = CPTGradientElement()
            if ( newElementList ) {
                newElementList             = newElement;
                newElementList.nextElement = tmpNext;
                self.elementList           = newElementList;
            }
        }
        else {
            while ( curElement!.nextElement != nil &&
                        !((curElement!.position <= newElement.position) &&
                            (newElement.position < curElement!.nextElement!.position))) {
                curElement = curElement?.nextElement
            }
            
            let tmpNext = curElement?.nextElement;
            curElement?.nextElement        = CPTGradientElement()
            curElement?.nextElement       = newElement
            curElement?.nextElement?.nextElement = tmpNext
        }
    }
    
//    (nonnull instancetype)gradientWithBeginningColor:(nonnull CPTColor *)begin endingColor:(nonnull CPTColor *)end
//    {
//        return [self gradientWithBeginningColor:begin endingColor:end beginningPosition:CPTFloat(0.0) endingPosition:CPTFloat(1.0)];
//    }

//    /** @brief Creates and returns a new CPTGradient instance initialized with an axial linear gradient between two given colors, at two given normalized positions.
//     *  @param begin The beginning color.
//     *  @param end The ending color.
//     *  @param beginningPosition The beginning position (@num{0} ≤ @par{beginningPosition} ≤ @num{1}).
//     *  @param endingPosition The ending position (@num{0} ≤ @par{endingPosition} ≤ @num{1}).
//     *  @return A new CPTGradient instance initialized with an axial linear gradient between the two given colors, at two given normalized positions.
//     **/
    class func gradient(withBeginning begin: CPTColor, ending end: CPTColor, beginningPosition: CGFloat, endingPosition: CGFloat) -> CPTGradient {

        let newInstance = CPTGradient()

        let color1 = CPTGradientElement()
        let color2 = CPTGradientElement()

        color1.color = CPTRGBAColorFromCGColor(begin.cgColor);
        color2.color = CPTRGBAColorFromCGColor(end.cgColor);

        color1.position = beginningPosition;
        color2.position = endingPosition;

        newInstance.addElement(&color1)
        newInstance.addElement(&color2)

        return newInstance
    }
    
    func fillRect(rect: CGRect, inContext context: CGContext)    {
        
        var myCGShading : CGShading?
        
        context.saveGState();
        context.clip(to: rect);
        
        switch ( self.gradientType ) {
        case .axial:
            myCGShading = self.newAxialGradientInRect(rect: rect)
            break;
            
        case .radial:
            myCGShading = self.newRadialGradientInRect(rect: rect, context:context)
            break;
        }
        context.drawShading(myCGShading!);
        context.restoreGState();
    }
    
    // MARK: Private Methods
    func newAxialGradientInRect(rect: CGRect)->CGShading
    {
        // First Calculate where the beginning and ending points should be
        var startPoint = CGPoint()
        var endPoint = CGPoint()
        
        if ( self.angle == CGFloat(0.0)) {
            startPoint = CGPoint(x: rect.minX, y: rect.minY) // right of rect
            endPoint   = CGPoint(x: rect.maxX, y: rect.minY) // left  of rect
        }
        else if ( self.angle == CGFloat(90.0)) {
            startPoint = CGPoint( x: rect.minX, y: rect.minY) // bottom of rect
            endPoint   = CGPoint( x: rect.minX, y: rect.maxY) // top    of rect
        }
        else { // ok, we'll do the calculations now
            var  x = CGFloat(0)
            var  y = CGFloat(0)
            
            var sinA = CGFloat(0)
            var cosA = CGFloat(0)
            var tanA = CGFloat(0)
            
            var length = CGFloat(0)
            var deltaX = CGFloat(0)
            var  deltaY = CGFloat(0)
            
            var rAngle = self.angle * CGFloat(Double.pi / 180.0); // convert the angle to radians
            
            if ( abs(tan(rAngle)) <= CGFloat(1.0)) { // for range [-45,45], [135,225]
                x = rect.width
                y = rect.height
                
                sinA = sin(rAngle);
                cosA = cos(rAngle);
                tanA = tan(rAngle);
                
                length = x / abs(cosA) + (y - x * abs(tanA)) * abs(sinA);
                
                deltaX = length * cosA / CGFloat(2.0);
                deltaY = length * sinA / CGFloat(2.0);
            }
            else { // for range [45,135], [225,315]
                x = rect.height
                y = rect.width
                
                rAngle -= CGFloat(Double.pi/2)
                
                sinA = sin(rAngle)
                cosA = cos(rAngle)
                tanA = tan(rAngle)
                
                length = x / abs(cosA) + (y - x * abs(tanA)) * abs(sinA)
                
                deltaX = -length * sinA / CGFloat(2.0)
                deltaY = length * cosA / CGFloat(2.0)
            }
            
            startPoint = CGPoint(x: rect.midX - deltaX, y: rect.midY - deltaY)
            endPoint   = CGPoint(x: rect.midX + deltaX, y: rect.midY + deltaY)
        }
        
        let myCGShading = CGShading(axialSpace: (self.colorspace?.cgColorSpace)!, start: startPoint, end: endPoint, function: self.gradientFunction, extendStart: false, extendEnd: false);
        
        return myCGShading!;
    }

    func newRadialGradientInRect(rect: CGRect, context: CGContext)->CGShading
    {
        var startPoint = CGPoint()
        var endPoint = CGPoint()
        
        var startRadius = CGFloat(0)
        var endRadius = CGFloat(0)
        var scaleX = CGFloat(0)
        var scaleY = CGFloat(0)
        
        let theStartAnchor = self.startAnchor;
        
        startPoint = CGPoint(x: fma(rect.width, theStartAnchor.x, rect.minX),
                             y: fma(rect.height, theStartAnchor.y, rect.minY))
        
        let theEndAnchor = self.endAnchor
        
        endPoint = CGPoint(x: fma(rect.width, theEndAnchor.x, rect.minX),
                           y: fma(rect.height, theEndAnchor.y, rect.minY))
        
        startRadius = CGFloat(-1.0)
        if rect.height > rect.width {
            scaleX        = rect.width / rect.height
            startPoint.x /= scaleX
            endPoint.x   /= scaleX
            scaleY        = CGFloat(1.0)
            endRadius     = rect.height / CGFloat(2.0)
        }
        else {
            scaleX        = CGFloat(1.0);
            scaleY        = rect.height / rect.width
            startPoint.y /= scaleY;
            endPoint.y   /= scaleY;
            endRadius     = rect.width / CGFloat(2.0)
        }
        
        context.scaleBy(x: scaleX, y: scaleY)
        
        let myCGShading = CGShading(radialSpace: (self.colorspace?.cgColorSpace)!, start: startPoint, startRadius: startRadius, end: endPoint, endRadius: endRadius, function: self.gradientFunction, extendStart: true, extendEnd: true);
        
        return myCGShading!;
    }

  // MARK: Opacity
    var isOpaque: Bool     {
        get {
            var opaqueGradient = true
            var list = self.elementList
            
            while ( opaqueGradient == true && (list != nil )) {
                opaqueGradient = opaqueGradient && ((list?.color.alpha)! >= CGFloat(1.0));
                list           = list?.nextElement;
            }
            return opaqueGradient
        }
        set {}
    }
}
