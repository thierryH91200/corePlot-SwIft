//
//  CPTGradient Extension.swift
//  corePlot
//
//  Created by thierryH24 on 15/11/2020.
//

import Foundation


extension CPTGradient {
    
    
    func aquaPressedGradient()-> CPTGradient
    {
        let newInstance = CPTGradient()
        
        let color1 : CPTGradientElement
        
        color1.color.red   = color1.color.green = color1.color.blue = CGFloat(0.80);
        color1.color.alpha = CGFloat(1.00);
        color1.position    = CGFloat(0.0);
        
        let color2 : CPTGradientElement
        color2.color.red   = color2.color.green = color2.color.blue = CGFloat(0.64);
        color2.color.alpha = CGFloat(1.00);
        color2.position    = CGFloat(0.5);
        
        let color3 : CPTGradientElement
        color3.color.red   = color3.color.green = color3.color.blue = CGFloat(0.80);
        color3.color.alpha = CGFloat(1.00);
        color3.position    = CGFloat(0.5);
        
        let color4 : CPTGradientElement
        color4.color.red   = color4.color.green = color4.color.blue = CGFloat(0.77);
        color4.color.alpha = CGFloat(1.00);
        color4.position    = CGFloat(1.0);
        
        newInstance.addElement(newElement: color1)
        newInstance.addElement(newElement: color2)
                               newInstance.addElement(newElement: color3)
        newInstance.addElement(newElement: color4)
        
        return newInstance;
    }
    
    func aquaNormalGradient() -> CPTGradient
    {
        let newInstance = CPTGradient()
        
        let color1 : CPTGradientElement
        color1.color.red   = color1.color.green = color1.color.blue = CGFloat(0.95);
        color1.color.alpha = CGFloat(1.00);
        color1.position    = CGFloat(0.0);
        
        let color2 : CPTGradientElement
        color2.color.red   = color2.color.green = color2.color.blue = CGFloat(0.83);
        color2.color.alpha = CGFloat(1.00);
        color2.position    = CGFloat(0.5);
        
        let color3 : CPTGradientElement
        color3.color.red   = color3.color.green = color3.color.blue = CGFloat(0.95)
        color3.color.alpha = CGFloat(1.00);
        color3.position    = CGFloat(0.5);
        
        let color4 : CPTGradientElement
        color4.color.red   = color4.color.green = color4.color.blue = CGFloat(0.92);
        color4.color.alpha = CGFloat(1.00);
        color4.position    = CGFloat(1.0);
        
        newInstance.addElement(newElement: color1)
        newInstance.addElement(newElement: color2)
        newInstance.addElement(newElement: color3)
        newInstance.addElement(newElement: color4)
        
        return newInstance;
    }
    
    func rainbowGradient() -> CPTGradient
    {
        let newInstance = CPTGradient()

        let color1 : CPTGradientElement
        color1.color.red   = CGFloat(1.00);
        color1.color.green = CGFloat(0.00);
        color1.color.blue  = CGFloat(0.00);
        color1.color.alpha = CGFloat(1.00);
        color1.position    = CGFloat(0.0);

        let color2 : CPTGradientElement
        color2.color.red   = CGFloat(0.54);
        color2.color.green = CGFloat(0.00);
        color2.color.blue  = CGFloat(1.00);
        color2.color.alpha = CGFloat(1.00);
        color2.position    = CGFloat(1.0);

        newInstance.addElement(newElement: color1)
        newInstance.addElement(newElement: color2)

        newInstance.blendingMode = .chromatic

        return newInstance;
    }

    
    /** @brief Creates and returns a new CPTGradient instance initialized with a hydrogen spectrum gradient.
     *  @return A new CPTGradient instance initialized with a hydrogen spectrum gradient.
     **/
    func hydrogenSpectrumGradient() -> CPTGradient
    {
        let newInstance = CPTGradient()
        
        struct _colorBands {
            var hue : CGFloat
            var position : CGFloat
            var width : CGFloat
        }
        
        var colorBands = [_colorBands]()
        
        colorBands[0].hue      = CGFloat(22);
        colorBands[0].position = CGFloat(0.145);
        colorBands[0].width    = CGFloat(0.01);
        
        colorBands[1].hue      = CGFloat(200);
        colorBands[1].position = CGFloat(0.71);
        colorBands[1].width    = CGFloat(0.008);
        
        colorBands[2].hue      = CGFloat(253);
        colorBands[2].position = CGFloat(0.885);
        colorBands[2].width    = CGFloat(0.005);
        
        colorBands[3].hue      = CGFloat(275);
        colorBands[3].position = CGFloat(0.965);
        colorBands[3].width    = CGFloat(0.003);
        
        for i in 0..<4 {
            var color = [CGFloat]()
            
            color[0] = colorBands[i].hue - CGFloat(180.0) * colorBands[i].width;
            color[1] = CGFloat(1.0);
            color[2] = CGFloat(0.001);
            color[3] = CGFloat(1.0);
            CPTTransformHSV_RGB(color);
            
            let fadeIn : CPTGradientElement
            fadeIn.color.red   = color[0];
            fadeIn.color.green = color[1];
            fadeIn.color.blue  = color[2];
            fadeIn.color.alpha = color[3];
            fadeIn.position    = colorBands[i].position - colorBands[i].width;
            
            color[0] = colorBands[i].hue;
            color[1] = CGFloat(1.0);
            color[2] = CGFloat(1.0);
            color[3] = CGFloat(1.0);
            CPTTransformHSV_RGB(color);
            
            let band : CPTGradientElement
            band.color.red   = color[0];
            band.color.green = color[1];
            band.color.blue  = color[2];
            band.color.alpha = color[3];
            band.position    = colorBands[i].position;
            
            color[0] = colorBands[i].hue + CGFloat(180.0) * colorBands[i].width;
            color[1] = CGFloat(1.0);
            color[2] = CGFloat(0.001);
            color[3] = CGFloat(1.0);
            CPTTransformHSV_RGB(color);
            
            let fadeOut : CPTGradientElement
            fadeOut.color.red   = color[0];
            fadeOut.color.green = color[1];
            fadeOut.color.blue  = color[2];
            fadeOut.color.alpha = color[3];
            fadeOut.position    = colorBands[i].position + colorBands[i].width;
            
            newInstance.addElement(newElement: fadeIn)
            newInstance.addElement(newElement: band)
            newInstance.addElement(newElement: fadeOut)
        }
        
        newInstance.blendingMode = .chromatic
        
        return newInstance
    }
    
    func unifiedSelectedGradient() -> CPTGradient
    {
        let newInstance = CPTGradient()

        let color1 : CPTGradientElement
        color1.color.red   = color1.color.green = color1.color.blue = CGFloat(0.85);
        color1.color.alpha = CGFloat(1.00);
        color1.position    = CGFloat(0.0);

        let color2 : CPTGradientElement
        color2.color.red   = color2.color.green = color2.color.blue = CGFloat(0.95);
        color2.color.alpha = CGFloat(1.00);
        color2.position    = CGFloat(1.0);

        newInstance.addElement(newElement: color1)
        newInstance.addElement(newElement: color2)

        return newInstance;
    }

    /** @brief Creates and returns a new CPTGradient instance initialized with the unified normal gradient.
     *  @return A new CPTGradient instance initialized with the unified normal gradient.
     **/
    func unifiedNormalGradient() -> CPTGradient
    {
        let newInstance = CPTGradient()

        let color1 : CPTGradientElement
        color1.color.red   = color1.color.green = color1.color.blue = CGFloat(0.75);
        color1.color.alpha = CGFloat(1.00);
        color1.position    = CGFloat(0.0);

        let color2 : CPTGradientElement
        color2.color.red   = color2.color.green = color2.color.blue = CGFloat(0.90);
        color2.color.alpha = CGFloat(1.00);
        color2.position    = CGFloat(1.0);

        newInstance.addElement(newElement: color1)
        newInstance.addElement(newElement: color2)

        return newInstance;
    }

    /** @brief Creates and returns a new CPTGradient instance initialized with the unified pressed gradient.
     *  @return A new CPTGradient instance initialized with the unified pressed gradient.
     **/
    func unifiedPressedGradient() -> CPTGradient
    {
    let newInstance = CPTGradient()

        let color1 : CPTGradientElement
        color1.color.red   = color1.color.green = color1.color.blue = CGFloat(0.60);
        color1.color.alpha = CGFloat(1.00);
        color1.position    = CGFloat(0.0);

        let color2 : CPTGradientElement
        color2.color.red   = color2.color.green = color2.color.blue = CGFloat(0.75);
        color2.color.alpha = CGFloat(1.00);
        color2.position    = CGFloat(1.0);

        newInstance.addElement(newElement: color1)
        newInstance.addElement(newElement: color2)

        return newInstance;
    }

    /** @brief Creates and returns a new CPTGradient instance initialized with the unified dark gradient.
     *  @return A new CPTGradient instance initialized with the unified dark gradient.
     **/
    func unifiedDarkGradient() -> CPTGradient
    {
    let newInstance = CPTGradient()

        let color1 : CPTGradientElement
        color1.color.red   = color1.color.green = color1.color.blue = CGFloat(0.68);
        color1.color.alpha = CGFloat(1.00);
        color1.position    = CGFloat(0.0);

        let color2 : CPTGradientElement
        color2.color.red   = color2.color.green = color2.color.blue = CGFloat(0.83);
        color2.color.alpha = CGFloat(1.00);
        color2.position    = CGFloat(1.0);

        newInstance.addElement(newElement: color1)
        newInstance.addElement(newElement: color2)

        return newInstance;
    }

    /** @brief Creates and returns a new CPTGradient instance initialized with the source list selected gradient.
     *  @return A new CPTGradient instance initialized with the source list selected gradient.
     **/
    func sourceListSelectedGradient() -> CPTGradient
    {
    let newInstance = CPTGradient()

        let color1 : CPTGradientElement
        color1.color.red   = CGFloat(0.06);
        color1.color.green = CGFloat(0.37);
        color1.color.blue  = CGFloat(0.85);
        color1.color.alpha = CGFloat(1.00);
        color1.position    = CGFloat(0.0);

        let color2 : CPTGradientElement
        color2.color.red   = CGFloat(0.30);
        color2.color.green = CGFloat(0.60);
        color2.color.blue  = CGFloat(0.92);
        color2.color.alpha = CGFloat(1.00);
        color2.position    = CGFloat(1.0);

        newInstance.addElement(newElement: color1)
        newInstance.addElement(newElement: color2)

        return newInstance;
    }

    /** @brief Creates and returns a new CPTGradient instance initialized with the source list unselected gradient.
     *  @return A new CPTGradient instance initialized with the source list unselected gradient.
     **/
    func sourceListUnselectedGradient() -> CPTGradient
    {
        let newInstance = CPTGradient()

        let color1 : CPTGradientElement
        color1.color.red   = CGFloat(0.43);
        color1.color.green = CGFloat(0.43);
        color1.color.blue  = CGFloat(0.43);
        color1.color.alpha = CGFloat(1.00);
        color1.position    = CGFloat(0.0);

        let color2 : CPTGradientElement
        color2.color.red   = CGFloat(0.60);
        color2.color.green = CGFloat(0.60);
        color2.color.blue  = CGFloat(0.60);
        color2.color.alpha = CGFloat(1.00);
        color2.position    = CGFloat(1.0);

        newInstance.addElement(newElement: color1)
        newInstance.addElement(newElement: color2)

        return newInstance;
    }
    
}

struct RGB {
    // Percent
    let r: Float // [0,1]
    let g: Float // [0,1]
    let b: Float // [0,1]
    
    static func hsv(r: Float, g: Float, b: Float) -> HSV {
        let min = r < g ? (r < b ? r : b) : (g < b ? g : b)
        let max = r > g ? (r > b ? r : b) : (g > b ? g : b)
        
        let v = max
        let delta = max - min
        
        guard delta > 0.00001 else { return HSV(h: 0, s: 0, v: max) }
        guard max > 0 else { return HSV(h: -1, s: 0, v: v) } // Undefined, achromatic grey
        let s = delta / max
        
        let hue: (Float, Float) -> Float = { max, delta -> Float in
            if r == max { return (g-b)/delta } // between yellow & magenta
            else if g == max { return 2 + (b-r)/delta } // between cyan & yellow
            else { return 4 + (r-g)/delta } // between magenta & cyan
        }
        
        let h = hue(max, delta) * 60 // In degrees
        
        return HSV(h: (h < 0 ? h+360 : h) , s: s, v: v)
    }
    
    static func hsv(rgb: RGB) -> HSV {
        return hsv(rgb.r, g: rgb.g, b: rgb.b)
    }
    
    var hsv: HSV {
        return RGB.hsv(self)
    }
}

struct RGBA {
    let a: Float
    let rgb: RGB
    
    init(r: Float, g: Float, b: Float, a: Float) {
        self.a = a
        self.rgb = RGB(r: r, g: g, b: b)
    }
}

struct HSV {
    let h: Float // Angle in degrees [0,360] or -1 as Undefined
    let s: Float // Percent [0,1]
    let v: Float // Percent [0,1]
    
    static func rgb(h: Float, s: Float, v: Float) -> RGB {
        if s == 0 { return RGB(r: v, g: v, b: v) } // Achromatic grey
        
        let angle = (h >= 360 ? 0 : h)
        let sector = angle / 60 // Sector
        let i = floor(sector)
        let f = sector - i // Factorial part of h
        
        let p = v * (1 - s)
        let q = v * (1 - (s * f))
        let t = v * (1 - (s * (1 - f)))
        
        switch(i) {
        case 0:
            return RGB(r: v, g: t, b: p)
        case 1:
            return RGB(r: q, g: v, b: p)
        case 2:
            return RGB(r: p, g: v, b: t)
        case 3:
            return RGB(r: p, g: q, b: v)
        case 4:
            return RGB(r: t, g: p, b: v)
        default:
            return RGB(r: v, g: p, b: q)
        }
    }
    
    static func rgb(hsv: HSV) -> RGB {
        return rgb(hsv.h, s: hsv.s, v: hsv.v)
    }
    
    var rgb: RGB {
        return HSV.rgb(self)
    }
    
    /// Returns a normalized point with x=h and y=v
    var point: CGPoint {
        return CGPoint(x: CGFloat(h/360), y: CGFloat(v))
    }
}
