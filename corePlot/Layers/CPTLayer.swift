
import AppKit


//if ((TARGET_OS_SIMULATOR || TARGET_OS_IPHONE || TARGET_OS_TV) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= 100000)) \
//    || (TARGET_OS_MAC && (MAC_OS_X_VERSION_MAX_ALLOWED >= 101200))
//// CALayerDelegate is defined by Core Animation in iOS 10.0+, macOS 10.12+, and tvOS 10.0+
@objc protocol CPTLayerDelegate: CALayerDelegate
{
    
}
//#else
//protocol CPTLayerDelegate: NSObject
//#endif


public class CPTLayer : CALayer
{
    typealias CPTSublayerArray = [CALayer]
    typealias CPTSublayerSet = Set<CALayer>
    
    var graph  : CPTGraph?     = nil
    var identifier  : String?

    var maskingPath :  CGPath? {
        set {   }
        get {
            if ( self.masksToBounds ) {
                var path = self.outerBorderPath;
                if (( path ) != nil) {
                    return path;
                }
                
                path = CPTPathExtensions.shared.CPTCreateRoundedRectPath(rect: self.bounds, cornerRadius: self.cornerRadius);
                self.outerBorderPath = path;
                return self.outerBorderPath;
            }
            else {
                return nil;
            }
        }
    }

    public override var isHidden: Bool {
        get {
            return super.isHidden
        }
        set {
            if ( newValue != self.isHidden ) {
                super.isHidden = newValue;
                if ( newValue == true ) {
                    self.setNeedsDisplay()
                }
            }
        }
    }

    var _paddingLeft : CGFloat = 0.0
    var paddingLeft : CGFloat {
        get { return  _paddingLeft }
        set {
            if _paddingLeft != newValue {
                _paddingLeft = newValue
                setNeedsLayout()
            }
        }
    }

    var _paddingTop   : CGFloat = 0.0
    var paddingTop : CGFloat {
        get { return  _paddingLeft }
        set {
            if _paddingTop != newValue {
                _paddingTop = newValue
                setNeedsLayout()
            }
        }
    }

    var _paddingRight : CGFloat = 0.0
    var paddingRight : CGFloat {
        get { return  _paddingLeft }
        set {
            if _paddingRight != newValue {
                _paddingRight = newValue
                setNeedsLayout()
            }
        }
    }

    var _paddingBottom : CGFloat = 0.0
    var paddingBottom : CGFloat {
        get { return  _paddingLeft }
        set {
            if _paddingBottom != newValue {
                _paddingBottom = newValue
                setNeedsLayout()
            }
        }
    }

    var masksToBorder     = false;
    
    var _shadow   : CPTShadow? = nil
    var shadow   : CPTShadow? {
        get { return _shadow}
        set {
            if ( _shadow != newValue ) {
                _shadow = newValue
                self.setNeedsLayout()
                self.setNeedsDisplay();
            }
        }
    } 
    
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
    
    public override var position : CGPoint {
        get { return super.position }
        set {
            super.position = newValue
        }
    }

    var renderingRecursively = false
    var useFastRendering     = false
    
    var _outerBorderPath : CGPath?   = nil
    var outerBorderPath  : CGPath? {
        get { return _outerBorderPath }
        set {
            if ( newValue != _outerBorderPath ) {
                _outerBorderPath = newValue
            }
        }
    }
    
    var _innerBorderPath : CGPath?   = nil
    var innerBorderPath  : CGPath?   {
        get {return _innerBorderPath }
        set {
            if ( _innerBorderPath != newValue ) {
                _innerBorderPath = newValue
                self.mask?.setNeedsDisplay()
            }
        }
    }

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
        self.identifier           = nil
        
        self.frame                      = frame;
        self.needsDisplayOnBoundsChange = false
        self.isOpaque                   = false
        self.masksToBounds              = false
    }
    
    override init () {
        super.init ()
    }
    
    override init(layer: Any)
    {
        super.init(layer: layer)
        
        let theLayer = layer as! CPTLayer
        
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(in context: CGContext) {
        useFastRendering = true
        renderAsVector(in: context)
        useFastRendering = false
    }
    
    func applyMask(to context: CGContext) {
        
        let mySuperlayer = self.superlayer
        
        if (mySuperlayer is CPTLayer) == true {
            let sup = superlayer as! CPTLayer
            sup.applySublayerMaskToContext(context: context, forSublayer: self, withOffset: CGPoint.zero)
        }
        
        let maskPath = self.maskingPath
        
        if  maskPath != nil {
            context.addPath(maskPath!)
            context.clip()
        }
    }
    
    func renderAsVector(in context: CGContext) {
        // This is where subclasses do their drawing
        if renderingRecursively == true {
            applyMask(to: context)
        }
        shadow?.setShadowInContext(context:  context)
    }

    public override var cornerRadius: CGFloat {
        get {
            return super.cornerRadius
        }
        set(newValue) {
            if newValue != cornerRadius {
                super.cornerRadius = newValue
                
                setNeedsDisplay()
                
                outerBorderPath = nil
                innerBorderPath = nil
            }
        }
    }
    
    public override var anchorPoint: CGPoint {
        get {
            var adjustedAnchor = super.anchorPoint
            
            if (( self.shadow ) != nil) {
                let sizeOffset   = self.shadowMargin;
                let selfBounds   = self.bounds;
                let adjustedSize = CGSize(width: selfBounds.size.width + sizeOffset.width * CGFloat(2.0),
                                          height: selfBounds.size.height + sizeOffset.height * CGFloat(2.0));
                
                if ( selfBounds.size.width > CGFloat(0.0)) {
                    adjustedAnchor.x = (adjustedAnchor.x - CGFloat(0.5)) * (adjustedSize.width / selfBounds.size.width) + CGFloat(0.5);
                }
                if ( selfBounds.size.height > CGFloat(0.0)) {
                    adjustedAnchor.y = (adjustedAnchor.y - CGFloat(0.5)) * (adjustedSize.height / selfBounds.size.height) + CGFloat(0.5);
                }
            }
            
            super.anchorPoint = adjustedAnchor
            return super.anchorPoint
        }
        set(newValue) {
            var newAnchorPoint = newValue
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
                
                NotificationCenter.send(
                    name: .CPTLayerBoundsDidChangeNotification ,
                    object:self)
            }
        }
    }
    
    func applyMaskToContext(context : CGContext)
    {
        let mySuperlayer = self.superlayer
        
        if (mySuperlayer is CPTLayer ) == true {
            
            let sup = superlayer as! CPTLayer
            sup.applySublayerMaskToContext(context: context,forSublayer:self, withOffset:CGPoint())
        }
        
        let maskPath = self.maskingPath
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
        context.concatenate(sublayerTransform.inverted())
        
        let superlayer = self.superlayer
        if ( superlayer is CPTLayer ) == true {
            
            let sup = superlayer as! CPTLayer
            sup.applySublayerMaskToContext(context: context, forSublayer:self, withOffset:layerOffset)
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
