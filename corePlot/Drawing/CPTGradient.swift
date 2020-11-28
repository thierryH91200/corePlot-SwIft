//
//  CPTGradient.swift
//  corePlot
//
//  Created by thierryH24 on 09/11/2020.
//

import Cocoa


// https://stackoverflow.com/questions/49399089/binary-tree-with-struct-in-swift

class CPTGradientElement {
    var color : CPTRGBAColor    ///< Color
    var position: CGFloat      ///< Gradient position (0 ≤ @par{position} ≤ 1)
    
    var nextElement : CPTGradientElement?
    
    init(value: CGFloat) {
        self.position = value
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
        startAnchor  = CGPoint(x: 0.5, y: 0.5);
        endAnchor    = CGPoint(x: 0.5, y: 0.5);
    }
    
    func commonInit()
    {
        self.colorspace  = CPTColorSpace.genericRGBSpace()
        self.elementList = nil;
    }
    

    func CPTTransformHSV_RGB(components :[CGFloat] ) // H,S,B -> R,G,B
    {
        
        let R = CGFloat(0.0), G = CGFloat(0.0), B = CGFloat(0.0);
        
        let H = fmod(components[0], CGFloat(360.0)); // map to [0,360)
        let S = components[1];
        let V = components[2];
        
        let Hi    = (Int)lrint(floor(H / CGFloat(60.0))) % 6;
        let f = H / CGFloat(60.0) - Hi;
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
        let curElement = self.elementList
        
        if curElement == nil || (newElement.position < curElement.position)) {
            CPTGradientElement tmpNext        = curElement;
            CPTGradientElement newElementList = calloc(1, sizeof(CPTGradientElement));
            if ( newElementList ) {
                *newElementList             = *newElement;
                newElementList->nextElement = tmpNext;
                self.elementList            = newElementList;
            }
        }
        else {
            while ( curElement->nextElement != NULL &&
                        !((curElement->position <= newElement->position) &&
                            (newElement->position < curElement->nextElement->position))) {
                curElement = curElement->nextElement;
            }
            
            let tmpNext = curElement?.nextElement;
            curElement->nextElement              = calloc(1, sizeof(CPTGradientElement));
            *(curElement.nextElement)           = newElement
            curElement.nextElement->nextElement = tmpNext;
        }
    }
    
    
}
