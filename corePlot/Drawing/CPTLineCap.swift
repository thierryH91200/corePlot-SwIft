//
//  CPTLineCap.swift
//  corePlot
//
//  Created by thierryH24 on 09/11/2020.
//



//private var export: String {
//    get {
//        return exportTmp
//    }
//    set {
//        exportTmp += newValue
//    }
//}

import AppKit

enum CPTLineCapType: Int {
    case none     ///< No line cap.
    case openArrow  ///< Open arrow line cap.
    case solidArrow ///< Solid arrow line cap.
    case sweptArrow ///< Swept arrow line cap.
    case rectangle  ///< Rectangle line cap.
    case ellipse    ///< Elliptical line cap.
    case diamond    ///< Diamond line cap.
    case pentagon   ///< Pentagon line cap.
    case hexagon    ///< Hexagon line cap.
    case bar        ///< Bar line cap.
    case cross      ///< X line cap.
    case snow       ///< Snowflake line cap.
    case custom      ///< Custom line cap.
}

class CPTLineCap: NSObject {
    
    var _size  = CGSize()
    var _lineCapType =  CPTLineCapType.none
    var lineStyle =  CPTLineStyle()
    var fill :  CPTFill?
    var _customLineCapPath: CGPath?
    var usesEvenOddClipRule = false
    
    var  _cachedLineCapPath : CGPath?
    
    //MARK: - Init/Dealloc
    override init()
    {
        super.init()
        size                = CGSize(width: 5.0, height: 5.0)
        lineCapType         = .none;
        lineStyle           = CPTLineStyle()
        fill                = nil;
        customLineCapPath   = nil
        usesEvenOddClipRule = false
    }
    
    var size: CGSize {
        get {
            return _size
        }
        set {
            if !_size.equalTo(newValue) {
                _size = newValue
                self.cachedLineCapPath = nil
            }
        }
    }
    var lineCapType: CPTLineCapType {
        get {
            return _lineCapType
        }
        set {
            if newValue != lineCapType {
                _lineCapType    = newValue
                self.cachedLineCapPath = nil
            }
        }
    }
    
    var customLineCapPath: CGPath? {
        get {
            return _customLineCapPath!
        }
        set {
            if newValue != customLineCapPath {
                _customLineCapPath      = newValue
                self.cachedLineCapPath = nil
            }
        }
    }
    
    var cachedLineCapPath: CGPath? {
        get {
            return _customLineCapPath!
        }
        set {
            if newValue != customLineCapPath {
                _customLineCapPath      = newValue
                self.cachedLineCapPath = nil
            }
        }
    }
    
    //MARK: - Factory methods
    func lineCap() -> CPTLineCap {
        let lineCap = CPTLineCap()
        lineCap.lineCapType = .none
        return lineCap
    }
     func openArrowPlotLineCap() -> CPTLineCap {
        let lineCap = CPTLineCap()
        lineCap.lineCapType = .openArrow
        return lineCap
    }
    
    func solidArrowPlotLineCap() -> CPTLineCap {
        let lineCap = CPTLineCap()
        lineCap.lineCapType = .solidArrow
        return lineCap
    }

    func sweptArrowPlotLineCap()  -> CPTLineCap {
        let lineCap = CPTLineCap()
        lineCap.lineCapType = .sweptArrow
        return lineCap
    }
    
    func rectanglePlotLineCap()-> CPTLineCap {
        let lineCap = CPTLineCap()
        lineCap.lineCapType = .rectangle
        return lineCap;
    }
    
    func ellipsePlotLineCap()-> CPTLineCap {
        let lineCap = CPTLineCap()
        lineCap.lineCapType = .ellipse
        return lineCap
    }
    
    func diamondPlotLineCap()-> CPTLineCap {
        let lineCap = CPTLineCap()
        
        lineCap.lineCapType = .diamond;
        
        return lineCap;
    }
    
    func pentagonPlotLineCap()-> CPTLineCap {
        let lineCap = CPTLineCap()
        lineCap.lineCapType = .pentagon;
        return lineCap;
    }

    func hexagonPlotLineCap()-> CPTLineCap
    {
        let lineCap = CPTLineCap()
        lineCap.lineCapType = .hexagon
        return lineCap;
    }

    func barPlotLineCap()-> CPTLineCap
    {
        let lineCap = CPTLineCap()
        lineCap.lineCapType = .bar;
        return lineCap;
    }
    
    func crossPlotLineCap()-> CPTLineCap
    {
        let lineCap = CPTLineCap()
        lineCap.lineCapType = .cross
        return lineCap;
    }

    func snowPlotLineCap()-> CPTLineCap
    {
        let lineCap = CPTLineCap()
        lineCap.lineCapType = .snow
        return lineCap;
    }

    func customLineCapWithPath(aPath: CGPath)-> CPTLineCap
    {
        let lineCap = CPTLineCap()
        lineCap.lineCapType       = .custom;
        lineCap.customLineCapPath = aPath
        return lineCap;
    }

    func newLineCapPath() ->CGPath
    {
        var dx = CGFloat(0)
        var dy = CGFloat(0)
        
        let lineCapSize = self.size;
        let halfSize    = CGSize(width: lineCapSize.width / CGFloat(2.0), height: lineCapSize.height / CGFloat(2.0));
        
        let lineCapPath = CGMutablePath();
        
        switch ( self.lineCapType ) {
        case .none:
            // empty path
            break
            
            
        case .openArrow:
            lineCapPath.move(to: CGPoint( x: -halfSize.width, y: -halfSize.height))
            lineCapPath.addLine(to: CGPoint( x: CGFloat(0.0), y: CGFloat(0.0)))
            lineCapPath.addLine(to: CGPoint(   x: halfSize.width, y: -halfSize.height))
            
        case .solidArrow:
            lineCapPath.move(to: CGPoint(x: -halfSize.width, y: -halfSize.height))
            lineCapPath.addLine(to: CGPoint( x: CGFloat (0.0), y: CGFloat (0.0)))
            lineCapPath.addLine(to: CGPoint( x: halfSize.width, y: -halfSize.height))
            lineCapPath.closeSubpath()
            break;
            
        case .sweptArrow:
            
            lineCapPath.move(to: CGPoint( x: -halfSize.width, y: -halfSize.height))
            lineCapPath.addLine(to: CGPoint( x: CGFloat (0.0), y: CGFloat (0.0)))
            lineCapPath.addLine(to: CGPoint( x: halfSize.width, y: -halfSize.height))
            lineCapPath.addLine(to: CGPoint( x: CGFloat (0.0), y: -lineCapSize.height * CGFloat (0.375)))
            lineCapPath.closeSubpath()
            break;
            
        case .rectangle:
            lineCapPath.addRect(CGRect(x: -halfSize.width, y: -halfSize.height, width: halfSize.width * CGFloat (2.0), height: halfSize.height * CGFloat (2.0)))
            
        case .ellipse:
            lineCapPath.addEllipse(in: CGRect(x: -halfSize.width, y: -halfSize.height, width: halfSize.width * CGFloat (2.0), height: halfSize.height * CGFloat (2.0)))
            break
            
        case .diamond:
            lineCapPath.move(to: CGPoint( x: CGFloat (0.0), y: halfSize.height))
            lineCapPath.addLine(to: CGPoint( x: halfSize.width, y: CGFloat (0.0)))
            lineCapPath.addLine(to: CGPoint( x: CGFloat (0.0), y: -halfSize.height))
            lineCapPath.addLine(to: CGPoint( x: -halfSize.width, y: CGFloat (0.0)))
            lineCapPath.closeSubpath()
            break;
            
        case .pentagon:
            lineCapPath.move(to: CGPoint( x: CGFloat (0.0), y: halfSize.height))
            lineCapPath.addLine(to: CGPoint( x: halfSize.width * CGFloat (0.95105651630), y: halfSize.height * CGFloat (0.30901699437)))
            lineCapPath.addLine(to: CGPoint( x: halfSize.width * CGFloat (0.58778525229), y: -halfSize.height * CGFloat (0.80901699437)))
            lineCapPath.addLine(to: CGPoint( x: -halfSize.width * CGFloat (0.58778525229), y: -halfSize.height * CGFloat (0.80901699437)))
            lineCapPath.addLine(to: CGPoint( x: -halfSize.width * CGFloat (0.95105651630), y: halfSize.height * CGFloat (0.30901699437)))
                lineCapPath.closeSubpath()
                break;
            
        case .hexagon:
            dx = halfSize.width * CGFloat (0.86602540378); // sqrt(3.0) / 2.0;
            dy = halfSize.height / CGFloat (2.0);
            
            lineCapPath.move(to: CGPoint( x: CGFloat (0.0), y: halfSize.height))
            lineCapPath.addLine(to: CGPoint( x: dx, y: dy))
            lineCapPath.addLine(to: CGPoint( x: dx, y: -dy))
            lineCapPath.addLine(to: CGPoint( x: CGFloat (0.0), y: -halfSize.height))
            lineCapPath.addLine(to: CGPoint( x: -dx, y: -dy))
            lineCapPath.addLine(to: CGPoint( x: -dx, y: dy))
            lineCapPath.closeSubpath()
            break;
            
        case .bar:
            lineCapPath.move(to: CGPoint( x: halfSize.width, y: CGFloat (0.0)))
            lineCapPath.addLine(to: CGPoint( x: -halfSize.width, y: CGFloat (0.0)))
            break;
            
        case .cross:
            lineCapPath.move(to: CGPoint( x: -halfSize.width, y: halfSize.height))
            lineCapPath.addLine(to: CGPoint( x: halfSize.width, y: -halfSize.height))
            lineCapPath.move(to: CGPoint( x: halfSize.width, y: halfSize.height))
            lineCapPath.addLine(to: CGPoint( x: -halfSize.width, y: -halfSize.height))
            break;
            
        case .snow:
            dx = halfSize.width * CGFloat (0.86602540378); // sqrt(3.0) / 2.0;
            dy = halfSize.height / CGFloat (2.0);
            
            lineCapPath.move(to: CGPoint( x: CGFloat (0.0), y: halfSize.height))
            lineCapPath.addLine(to: CGPoint( x: CGFloat (0.0), y: -halfSize.height))
            lineCapPath.move(to: CGPoint( x: dx, y: -dy))
            lineCapPath.addLine(to: CGPoint( x: -dx, y: dy))
            lineCapPath.move(to: CGPoint( x: -dx, y: -dy))
            lineCapPath.addLine(to: CGPoint( x: dx, y: dy))
            break
            
        case .custom:
            
            let customPath = self.customLineCapPath;
            if ( customPath != nil) {
                let oldBounds = customPath?.boundingBox
                let dx1      = lineCapSize.width / (oldBounds?.size.width)!;
                let dy1      = lineCapSize.height / (oldBounds?.size.height)!;
                
                var scaleTransform = CGAffineTransform.identity.scaledBy(x: dx1, y: dy1);
                scaleTransform = scaleTransform.concatenating(CGAffineTransform(translationX: -halfSize.width, y: -halfSize.height))
                
                CGPathAddPath(lineCapPath, &scaleTransform, customPath);
            }
            break
        }
        return lineCapPath;
    }
    
     // MARK: - Drawing

    func renderAsVectorInContext(context:  CGContext, center:CGPoint, direction:CGPoint)
    {
        let theLineCapPath = self.cachedLineCapPath
        
        if (( theLineCapPath ) != nil) {
            var theLineStyle : CPTLineStyle? = nil;
            var theFill  :CPTFill?  = nil;
            
            switch ( self.lineCapType ) {
            case .solidArrow: break
            case .sweptArrow: break
            case .rectangle: break
            case .ellipse: break
            case .diamond: break
            case .pentagon: break
            case .hexagon: break
            case .custom:
                theLineStyle = self.lineStyle;
                theFill      = self.fill;
                break;
                
            case .openArrow: break
            case .bar: break
            case .cross: break
            case .snow:
                theLineStyle = self.lineStyle;
                break;
            default:
                break;
            }
            
            if ( (theLineStyle != nil) || (theFill != nil) ) {
                context.saveGState();
                context.translateBy(x: center.x, y: center.y);
                context.rotate(by: atan2(direction.y, direction.x) - CGFloat(Double.pi/2)); // standard symbol points up
                
                if (( theFill ) != nil) {
                    // use fillRect instead of fillPath so that images and gradients are properly centered in the symbol
                    let symbolSize = self.size;
                    let halfSize   = CGSize(width: symbolSize.width / CGFloat(2.0), height: symbolSize.height / CGFloat(2.0));
                    let bounds = CGRect(x: -halfSize.width, y: -halfSize.height, width: symbolSize.width, height: symbolSize.height);
                    
                    context.saveGState();
                    if ( !theLineCapPath!.isEmpty) {
                        context.beginPath();
                        context.addPath(theLineCapPath!);
                        if self.usesEvenOddClipRule == true {
                            context.clip(using: .evenOdd)
                        }
                        else {
                            context.clip();
                        }
                    }
                    theFill?.fillRect(rect: bounds, context: context)
                    context.restoreGState();
                }
                
                if (( theLineStyle ) != nil) {
                    theLineStyle?.setLineStyleInContext(context: context)
                    context.beginPath()
                    context.addPath(theLineCapPath!);
                    theLineStyle?.strokePathInContext(context: context)
                }
                context.restoreGState();
            }
        }
    }
}
