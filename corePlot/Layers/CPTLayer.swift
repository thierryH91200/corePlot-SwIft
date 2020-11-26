
import AppKit

@objc
public protocol CPTLayerDelegate {
    
}

public class CPTLayer : CALayer
{
    var paddingLeft : CGFloat         = 0.0
    var paddingTop   : CGFloat        = 0.0
    var paddingRight : CGFloat        = 0.0
    var paddingBottom : CGFloat       = 0.0
    
    var masksToBorder     = false;
    var shadow   : CPTShadow?            = nil
    
    var _shadowMargin   : CGSize? = nil
    var shadowMargin : CGSize {
        get {
            var margin = CGSize()
            let myShadow = self.shadow;
            
            if (( myShadow ) != nil) {
                let shadowOffset  = myShadow?.shadowOffset
                let shadowRadius = myShadow?.shadowBlurRadius
                
                margin = CGSize(width: ceil(abs(shadowOffset!.width) + abs(shadowRadius!)),
                                height: ceil(abs(shadowOffset!.height) + abs(shadowRadius!)));
            }
            return margin;
        }
        
        set {
            _shadowMargin = newValue
        }
    }
    
    var renderingRecursively = false
    var useFastRendering     = false
    var graph   : CPTGraph?     = nil
    
    var outerBorderPath  :CGPath?    = nil
    var innerBorderPath  :CGPath?    = nil;
    var identifier  : Any?         = nil;
    
    typealias CPTSublayerSet = Set<CALayer>
    
    init ( frame : CGRect) {
        
        paddingLeft          = 0.0
        paddingTop           = 0.0
        paddingRight         = 0.0
        paddingBottom        = 0.0
        
        masksToBorder        = false
        shadow               = nil
        renderingRecursively = false
        useFastRendering     = false
        graph                = nil
        outerBorderPath      = nil
        innerBorderPath      = nil
        identifier           = nil
        
        self.frame                      = frame;
        self.needsDisplayOnBoundsChange = false
        self.isOpaque                     = false
        self.masksToBounds              = false
    }
    
    init( layer: CPTLayer) {
        super.init()
    }
    
    override init () {
        super.init ( layer : CALayer())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(layer: CPTLayer?)
    {
        if  let theLayer = layer {
            
            paddingLeft          = theLayer.paddingLeft
            paddingTop           = theLayer.paddingTop
            paddingRight         = theLayer.paddingRight
            paddingBottom        = theLayer.paddingBottom
            
            masksToBorder        = theLayer.masksToBorder;
            shadow               = theLayer.shadow
            renderingRecursively = theLayer.renderingRecursively
            graph                = theLayer.graph
            outerBorderPath      = theLayer.outerBorderPath!
            innerBorderPath      = theLayer.innerBorderPath!
            identifier           = theLayer.identifier
        }
    }
    
    public override func draw(in context: CGContext) {
        useFastRendering = true
        renderAsVector(in: context)
        useFastRendering = false
    }
    
    func applyMask(to context: CGContext) {
        
        let mySuperlayer = self.superlayer
        
        if (mySuperlayer is CPTLayer) == true {
            mySuperlayer?.applySublayerMask(to: context, forSublayer: self, withOffset: CGPoint.zero)
        }
        
        //        let maskPath = self.maskingPath
        
        if let maskPath = self.maskingPath {
            context.addPath(maskPath)
            context.clip()
        }
    }
    
    func renderAsVector(in context: CGContext) {
        // This is where subclasses do their drawing
        if renderingRecursively {
            applyMask(to: context)
        }
        shadow?.shadowIn(context:  context)
    }
    
    
    
    //    func maskingPath() -> CGPath? {
    //        if masksToBounds {
    //            var path = outerBorderPath
    //            if let path = path {
    //                return path
    //            }
    //
    //            path = CPTCreateRoundedRectPath(bounds, cornerRadius)
    //            outerBorderPath = path
    //            return outerBorderPath
    //        } else {
    //            return nil
    //        }
    //    }
    
    public override var cornerRadius: CGFloat {
        get {
            return super.cornerRadius
        }
        set(newRadius) {
            if newRadius != cornerRadius {
                super.cornerRadius = newRadius
                
                setNeedsDisplay()
                
                outerBorderPath = nil
                innerBorderPath = nil
            }
        }
    }
    
    public override var anchorPoint: CGPoint {
        get {
            return super.anchorPoint
        }
        set(newAnchorPoint) {
            var newAnchorPoint = newAnchorPoint
            if (shadow != nil) {
                let sizeOffset = shadowMargin
                let selfBounds = bounds
                let adjustedSize = CGSize(
                    width: selfBounds.size.width + sizeOffset.width * CGFloat(2.0),
                    height: selfBounds.size.height + sizeOffset.height * CGFloat(2.0))
                
                if adjustedSize.width > CGFloat(0.0) {
                    newAnchorPoint.x = (newAnchorPoint.x - CGFloat(0.5)) * (selfBounds.size.width / adjustedSize.width) + CGFloat(0.5)
                }
                if adjustedSize.height > CGFloat(0.0) {
                    newAnchorPoint.y = (newAnchorPoint.y - CGFloat(0.5)) * (selfBounds.size.height / adjustedSize.height) + CGFloat(0.5)
                }
            }
            super.anchorPoint = newAnchorPoint
        }
    }
    
    public override var bounds : CGRect {
        get {
            var actualBounds = super.bounds
            
            if (( self.shadow ) != nil) {
                let sizeOffset = self.shadowMargin
                
                actualBounds.origin.x    += sizeOffset.width;
                actualBounds.origin.y    += sizeOffset.height;
                actualBounds.size.width  -= sizeOffset.width * CGFloat(2.0);
                actualBounds.size.height -= sizeOffset.height * CGFloat(2.0);
            }
            return actualBounds;
        }
        set {
            
            var newBounds = newValue
            if ( !self.bounds.equalTo(newBounds)) {
                if (( self.shadow ) != nil) {
                    let sizeOffset = self.shadowMargin;
                    
                    newBounds.origin.x    -= sizeOffset.width;
                    newBounds.origin.y    -= sizeOffset.height
                    newBounds.size.width  += sizeOffset.width * CGFloat(2.0);
                    newBounds.size.height += sizeOffset.height * CGFloat(2.0);
                }
                super.bounds = newBounds
                
                self.outerBorderPath = nil
                self.innerBorderPath = nil
                
                NotificationCenter.default.post(name: .CPTLayerBoundsDidChangeNotification , object:self)
            }
        }
    }
    
    func applyMaskToContext(context : CGContext)
    {
        let mySuperlayer = self.superlayer
        
        if (mySuperlayer is CPTLayer ) {
            mySuperlayer.applySublayerMaskToContext(context,forSublayer:self withOffset:CGPoint())
            
//            [(CPTLayer *) superlayer applySublayerMaskToContext:context forSublayer:self withOffset:layerOffset];
        }
        
        let maskPath = self.maskingPath()
        if ( maskPath != nil ) {
            context.addPath(maskPath!);
            context.clip();
        }
    }
    
    func applySublayerMaskToContext(context: CGContext, forSublayer sublayer: CPTLayer, withOffset offset:CGPoint)
    {
        let  sublayerBoundsOrigin = sublayer.bounds.origin
        var layerOffset          = offset
        
        if self.renderingRecursively == false {
            let convertedOffset = self.convert(sublayerBoundsOrigin , from:sublayer)
            layerOffset.x += convertedOffset.x;
            layerOffset.y += convertedOffset.y;
        }
        
        let sublayerTransform = CATransform3DGetAffineTransform(sublayer.transform)
        
        context.concatenate(sublayerTransform.inverted());
        
        let superlayer = self.superlayer;
        
        if ( superlayer is CPTLayer ) == true {
            superlayer.applySublayerMaskToContext(context, sublayer:self, withOffset:layerOffset)
        }
        
        let maskPath = self.sublayerMaskingPath;
        
//        if ( maskPath != nil  ) {
            context.translateBy(x: -layerOffset.x, y: -layerOffset.y);
            context.addPath(maskPath());
            context.clip();
            context.translateBy(x: layerOffset.x, y: layerOffset.y);
//        }

        context.concatenate(sublayerTransform);
    }

}
