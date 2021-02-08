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
    
    static let shared = CPTGradient()
    
    // Enumeration of gradient types
    enum  CPTGradientType: Int  {
        case axial             ///< Axial gradient
        case radial   ///< Radial gradient
    }

    enum CPTGradientBlendingMode: Int {
        case linear          ///< Linear blending mode
        case chromatic       ///< Chromatic blending mode
        case inverseChromatic ///< Inverse chromatic blending mode
    }
    
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
    
    
    func addElement( newElement: inout CPTGradientElement )
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
    
    /** @brief Creates and returns a new CPTGradient instance initialized with an axial linear gradient between two given colors, at two given normalized positions.
     *  @param begin The beginning color.
     *  @param end The ending color.
     *  @param beginningPosition The beginning position (@num{0} ≤ @par{beginningPosition} ≤ @num{1}).
     *  @param endingPosition The ending position (@num{0} ≤ @par{endingPosition} ≤ @num{1}).
     *  @return A new CPTGradient instance initialized with an axial linear gradient between the two given colors, at two given normalized positions.
     **/
    func gradient( beginColor: NSUIColor, endColor: NSUIColor, beginPosition: CGFloat = CGFloat(0), endPosition: CGFloat = CGFloat(1.0)) -> CPTGradient {

        let newInstance = CPTGradient()

        var color1 = CPTGradientElement()
        var color2 = CPTGradientElement()

        color1.color = CPTRGBAColorFromCGColor(beginColor.cgColor);
        color2.color = CPTRGBAColorFromCGColor(endColor.cgColor);

        color1.position = beginPosition;
        color2.position = endPosition;

        newInstance.addElement(newElement: &color1)
        newInstance.addElement(newElement: &color2)

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
    
    func newColorAtPosition( position: CGFloat) -> CGColor? {
        
        var position = position
        let components = [CGFloat(0.0), CGFloat(0.0), CGFloat(0.0), CGFloat(0.0)]
        let gradientColor: CGColor? = nil
        
        switch blendingMode {
        case .linear:
            CPTLinearEvaluation(self, &position, components)
        case .chromatic:
            CPTChromaticEvaluation(self, &position, components)
        case .inverseChromatic:
            CPTInverseChromaticEvaluation(self, &position, components)
        default:
            break
        }
        
        #if targetEnvironment(simulator) || os(iOS)
        let colorComponents = [components[0], components[1], components[2], components[3]]
        gradientColor = CGColor(colorSpace: colorspace.cgColorSpace, components: &colorComponents)
        #else
        gradientColor = UIColor(red: components[0], green: components[1], blue: components[2], alpha: components[3]).cgColor
        
        #endif
        return gradientColor;
        
        
    }
    
    // MARK: - Core Graphics
    func CPTLinearEvaluation(_ info: CPTGradient, _ inEval: CGFloat, _ outEval: [CGFloat]) {
        
        
        let position = inEval
        var outEval = outEval
        let gradient = info
        
        // This grabs the first two colors in the sequence
        var color1 = gradient.elementList;
        
        if color1 == nil {
            outEval = [CGFloat](repeating: 1.0, count: 4)
            return
        }
        
        var color2 = color1?.nextElement;

        // make sure first color and second color are on other sides of position
        while ( color2 != nil && color2!.position < position ) {
            color1 = color2
        color2 = color1?.nextElement;
        }
        // if we don't have another color then make next color the same color
        if color2 == nil {
            color2 = color1;
        }

        // ----------FailSafe settings----------
        // color1.red   = 1; color2.red   = 0;
        // color1.green = 1; color2.green = 0;
        // color1.blue  = 1; color2.blue  = 0;
        // color1.alpha = 1; color2.alpha = 1;
        // color1.position = 0.5;
        // color2.position = 0.5;
        // -------------------------------------

        if ( position <= color1?.position ) {
            out[0] = color1.color.red;
            out[1] = color1.color.green;
            out[2] = color1.color.blue;
            out[3] = color1.color.alpha;
        }
        else if ( position >= color2.position ) {
            out[0] = color2.color.red;
            out[1] = color2.color.green;
            out[2] = color2.color.blue;
            out[3] = color2.color.alpha;
        }
        else {
            // adjust position so that it goes from 0 to 1 in the range from color 1 & 2's position
            position = (position - color1.position) / (color2.position - color1.position);

            out[0] = (color2.color.red - color1.color.red) * position + color1.color.red;
            out[1] = (color2.color.green - color1.color.green) * position + color1.color.green;
            out[2] = (color2.color.blue - color1.color.blue) * position + color1.color.blue;
            out[3] = (color2.color.alpha - color1.color.alpha) * position + color1.color.alpha;
        }
    }

    // Chromatic Evaluation -
    // This blends colors by their Hue, Saturation, and Value(Brightness) right now I just
    // transform the RGB values stored in the CPTGradientElements to HSB, in the future I may
    // streamline it to avoid transforming in and out of HSB colorspace *for later*
    //
    // For the chromatic blend we shift the hue of color1 to meet the hue of color2. To do
    // this we will add to the hue's angle (if we subtract we'll be doing the inverse
    // chromatic...scroll down more for that). All we need to do is keep adding to the hue
    // until we wrap around the color wheel and get to color2.
    void CPTChromaticEvaluation(void *__nullable info, const CGFloat *__nonnull in, CGFloat *__nonnull out)
    {
        CGFloat position      = *in;
        CPTGradient *gradient = (__bridge CPTGradient *)info;

        // This grabs the first two colors in the sequence
        CPTGradientElement *color1 = gradient.elementList;

        if ( color1 == NULL ) {
            out[0] = out[1] = out[2] = out[3] = CPTFloat(1.0);
            return;
        }

        CPTGradientElement *color2 = color1.nextElement;

        CGFloat c1[4];
        CGFloat c2[4];

        // make sure first color and second color are on other sides of position
        while ( color2 != NULL && color2.position < position ) {
            color1 = color2;
            color2 = color1.nextElement;
        }

        // if we don't have another color then make next color the same color
        if ( color2 == NULL ) {
            color2 = color1;
        }

        c1[0] = color1.color.red;
        c1[1] = color1.color.green;
        c1[2] = color1.color.blue;
        c1[3] = color1.color.alpha;

        c2[0] = color2.color.red;
        c2[1] = color2.color.green;
        c2[2] = color2.color.blue;
        c2[3] = color2.color.alpha;

        CPTTransformRGB_HSV(c1);
        CPTTransformRGB_HSV(c2);
        CPTResolveHSV(c1, c2);

        if ( c1[0] > c2[0] ) {        // if color1's hue is higher than color2's hue then
            c2[0] += CPTFloat(360.0); // we need to move c2 one revolution around the wheel
        }

        if ( position <= color1.position ) {
            out[0] = c1[0];
            out[1] = c1[1];
            out[2] = c1[2];
            out[3] = c1[3];
        }
        else if ( position >= color2.position ) {
            out[0] = c2[0];
            out[1] = c2[1];
            out[2] = c2[2];
            out[3] = c2[3];
        }
        else {
            // adjust position so that it goes from 0 to 1 in the range from color 1 & 2's position
            position = (position - color1.position) / (color2.position - color1.position);

            out[0] = (c2[0] - c1[0]) * position + c1[0];
            out[1] = (c2[1] - c1[1]) * position + c1[1];
            out[2] = (c2[2] - c1[2]) * position + c1[2];
            out[3] = (c2[3] - c1[3]) * position + c1[3];
        }

        CPTTransformHSV_RGB(out);
    }

    // Inverse Chromatic Evaluation -
    // Inverse Chromatic is about the same story as Chromatic Blend, but here the Hue
    // is strictly decreasing, that is we need to get from color1 to color2 by decreasing
    // the 'angle' (i.e. 90º . 180º would be done by subtracting 270º and getting -180º...
    // which is equivalent to 180º mod 360º
    void CPTInverseChromaticEvaluation(void *__nullable info, const CGFloat *__nonnull in, CGFloat *__nonnull out)
    {
        CGFloat position      = *in;
        CPTGradient *gradient = (__bridge CPTGradient *)info;

        // This grabs the first two colors in the sequence
        CPTGradientElement *color1 = gradient.elementList;

        if ( color1 == NULL ) {
            out[0] = out[1] = out[2] = out[3] = CPTFloat(1.0);
            return;
        }

        CPTGradientElement *color2 = color1.nextElement;

        CGFloat c1[4];
        CGFloat c2[4];

        // make sure first color and second color are on other sides of position
        while ( color2 != NULL && color2.position < position ) {
            color1 = color2;
            color2 = color1.nextElement;
        }

        // if we don't have another color then make next color the same color
        if ( color2 == NULL ) {
            color2 = color1;
        }

        c1[0] = color1.color.red;
        c1[1] = color1.color.green;
        c1[2] = color1.color.blue;
        c1[3] = color1.color.alpha;

        c2[0] = color2.color.red;
        c2[1] = color2.color.green;
        c2[2] = color2.color.blue;
        c2[3] = color2.color.alpha;

        CPTTransformRGB_HSV(c1);
        CPTTransformRGB_HSV(c2);
        CPTResolveHSV(c1, c2);

        if ( c1[0] < c2[0] ) {        // if color1's hue is higher than color2's hue then
            c1[0] += CPTFloat(360.0); // we need to move c2 one revolution back on the wheel
        }
        if ( position <= color1.position ) {
            out[0] = c1[0];
            out[1] = c1[1];
            out[2] = c1[2];
            out[3] = c1[3];
        }
        else if ( position >= color2.position ) {
            out[0] = c2[0];
            out[1] = c2[1];
            out[2] = c2[2];
            out[3] = c2[3];
        }
        else {
            // adjust position so that it goes from 0 to 1 in the range from color 1 & 2's position
            position = (position - color1.position) / (color2.position - color1.position);

            out[0] = (c2[0] - c1[0]) * position + c1[0];
            out[1] = (c2[1] - c1[1]) * position + c1[1];
            out[2] = (c2[2] - c1[2]) * position + c1[2];
            out[3] = (c2[3] - c1[3]) * position + c1[3];
        }

        CPTTransformHSV_RGB(out);
    }




}
