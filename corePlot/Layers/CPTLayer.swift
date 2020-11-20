
import AppKit

class CPTLayer : CALayer
{
    var paddingLeft : CGFloat         = 0.0
    var paddingTop   : CGFloat        = 0.0
    var paddingRight : CGFloat        = 0.0
    var paddingBottom : CGFloat       = 0.0
    
    var masksToBorder        = false;
    var shadow   : CPTShadow?            = nil

    var _shadowMargin   : CGSize?            = nil
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
    var identifier  : NSObject?         = nil;
    
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
//        super.init()
//        super.init ( frame : CGRect())
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
    
    @objc func setNeedsDisplayAllLayers() {
        setNeedsDisplay()
        
        for subLayer in sublayers! {
            if subLayer.responds(to: #selector(CPTLayer.setNeedsDisplayAllLayers)) {
                subLayer.setNeedsDisplay()
            } else {
                subLayer.setNeedsDisplay()
            }
        }
    }
    
    override func draw(in context: CGContext) {
        useFastRendering = true
        renderAsVector(in: context)
        useFastRendering = false
    }
    
    func applyMask(to context: CGContext) {
        let mySuperlayer = superlayer as? CPTLayer
        
        if mySuperlayer is CPTLayer {
            mySuperlayer?.applySublayerMask(to: context, forSublayer: self, withOffset: CGPoint.zero)
        }
        
        let maskPath = self.maskingPath
        
        if let maskPath = maskPath {
            context.addPath(maskPath)
            context.clip()
        }
    }
    
    
    override func display()
    {
        guard self.isHidden == false else {return}
        
        if NSView.instancesRespondToSelector:@selector(effectiveAppearance)] ) {
            let oldAppearance = NSAppearance.current;
            NSAppearance.currentAppearance = NSView self.graph.hostingView.effectiveAppearance
            
            super.display()
            NSAppearance.current = oldAppearance;
        }
        else {
            super.display()
        }
    }
        
    func renderAsVector(in context: CGContext) {
        // This is where subclasses do their drawing
        if renderingRecursively {
            applyMask(to: context)
        }
        shadow?.shadowIn(context:  context)
    }
    
    func recursivelyRenderInContext( context : CGContext)
    {
        if ( self.isHidden == false ) {
            // render self
            context.saveGState()
            
            self.applyTransform(self.transform, toContext:context)
            
            self.renderingRecursively = true;
            if ( !self.masksToBounds ) {
                context.saveGState();
            }
            self.renderAsVectorInContext(context: context)
            if ( !self.masksToBounds ) {
                context.restoreGState()
            }
            self.renderingRecursively = false;
            
            // render sublayers
            let sublayersCopy = self.sublayers
            for currentSublayer in sublayersCopy! {
                context.saveGState();
                
                // Shift origin of context to match starting coordinate of sublayer
                let currentSublayerFrameOrigin = currentSublayer.frame.origin;
                let currentSublayerBounds       = currentSublayer.bounds;
                context.translateBy(x: currentSublayerFrameOrigin.x - currentSublayerBounds.origin.x,
                                    y: currentSublayerFrameOrigin.y - currentSublayerBounds.origin.y);
                [self applyTransform:self.sublayerTransform toContext:context];
                
                if currentSublayer is CPTLayer == true {
                    [(CPTLayer *) currentSublayer recursivelyRenderInContext:context];
                }
                else {
                    if ( self.masksToBounds ) {
                        context.clip(to: currentSublayer.bounds);
                    }
                    currentSublayer.draw(in: context)
                }
                CGContextRestoreGState(context);
                
            }
            
            CGContextRestoreGState(context);
        }
    }
    
    func maskingPath() -> CGPath? {
        if masksToBounds {
            var path = outerBorderPath
            if let path = path {
                return path
            }
            
            path = CPTCreateRoundedRectPath(bounds, cornerRadius)
            outerBorderPath = path
            return outerBorderPath
        } else {
            return nil
        }
    }
    
    override var cornerRadius: CGFloat {
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
    
    override var anchorPoint: CGPoint {
        get {
            return super.anchorPoint
        }
        set(newAnchorPoint) {
            var newAnchorPoint = newAnchorPoint
            if (shadow != nil) {
                let sizeOffset = shadowMargin
                let selfBounds = bounds
                let adjustedSize = CGSize(
                    width: selfBounds.size.width + sizeOffset!.width * CGFloat(2.0),
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
    
    override var bounds : CGRect {
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
                    
                    newBounds.origin.x    -= sizeOffset!.width;
                    newBounds.origin.y    -= sizeOffset!.height
                    newBounds.size.width  += sizeOffset!.width * CGFloat(2.0);
                    newBounds.size.height += sizeOffset!.height * CGFloat(2.0);
                }
                super.bounds = newBounds
                
                self.outerBorderPath = nil
                self.innerBorderPath = nil
                
                NotificationCenter.default.post(name: NSNotification.Name( boundsDidChange),  object:self)
            }
        }
        
    }
    
    func renderAsVectorInContext(context: CGContext)
    {
        // This is where subclasses do their drawing
        if ( self.renderingRecursively ) {
            self.applyMaskToContext(context: context)
        }
        self.shadow?.shadowIn(context: context)
    }
    
    func applyMaskToContext(context : CGContext)
    {
        let *mySuperlayer = self.superlayer

        if ( [mySuperlayer isKindOfClass:[CPTLayer class]] ) {
            [mySuperlayer applySublayerMaskToContext:context forSublayer:self withOffset:CGPointZero];
        }

        let maskPath = self.maskingPath()
        if ( maskPath != nil ) {
            context.addPath(maskPath!);
            context.clip();
        }
    }


}
