
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
    
    public override func layoutSublayers()
    {
        let selfBounds = self.bounds;
        let mySublayers = self.sublayers;
        
        if (mySublayers!.count > 0) {
            
            var  leftPadding = CGFloat(0)
            var  topPadding = CGFloat(0)
            var  rightPadding = CGFloat(0)
            var  bottomPadding = CGFloat(0)
            
            self.sublayerMargin(left: &leftPadding ,top: &topPadding, right:&rightPadding, bottom:&bottomPadding)
            
            var subLayerSize = selfBounds.size;
            subLayerSize.width  -= leftPadding + rightPadding;
            subLayerSize.width   = max(subLayerSize.width, CGFloat(0.0));
            subLayerSize.width   = round(subLayerSize.width);
            subLayerSize.height -= topPadding + bottomPadding;
            subLayerSize.height  = max(subLayerSize.height, CGFloat(0.0));
            subLayerSize.height  = round(subLayerSize.height);
            
            var subLayerFrame = CGRect()
            subLayerFrame.origin = CGPoint(x: round(leftPadding), y: round(bottomPadding));
            subLayerFrame.size   = subLayerSize;
            
            let excludedSublayers = self.sublayersExcludedFromAutomaticLayout()
            
            for  subLayer in mySublayers! {
                if ( subLayer is CPTLayer) == true && (excludedSublayers?.contains(subLayer )) == false {
                    subLayer.frame = subLayerFrame
                }
            }
        }
    }
    
    @objc func sublayersExcludedFromAutomaticLayout() -> CPTSublayerSet? {
        return nil
    }
    
    func sublayerMargin( left: inout CGFloat, top: inout CGFloat, right: inout CGFloat, bottom: inout CGFloat )
    {
        left   = self.paddingLeft
        top    = self.paddingTop
        right  = self.paddingRight
        bottom = self.paddingBottom
    }
    
    func pixelAlign()
    {
        let scale           = self.contentsScale;
        let currentPosition = self.position;
        
        let boundsSize = self.bounds.size;
        let frameSize  = self.frame.size;
        
        var newPosition = CGPoint()
        
        if ( boundsSize.equalTo(frameSize)) { // rotated 0° or 180°
            let anchor = self.anchorPoint;
            
            let newAnchor = CGPoint(x: boundsSize.width * anchor.x,
                                    y: boundsSize.height * anchor.y);
            
            if ( scale == CGFloat(1.0)) {
                newPosition.x = ceil(currentPosition.x - newAnchor.x - CGFloat(0.5)) + newAnchor.x;
                newPosition.y = ceil(currentPosition.y - newAnchor.y - CGFloat(0.5)) + newAnchor.y;
            }
            else {
                newPosition.x = ceil((currentPosition.x - newAnchor.x) * scale - CGFloat(0.5)) / scale + newAnchor.x;
                newPosition.y = ceil((currentPosition.y - newAnchor.y) * scale - CGFloat(0.5)) / scale + newAnchor.y;
            }
        }
        else if ((boundsSize.width == frameSize.height) && (boundsSize.height == frameSize.width)) { // rotated 90° or 270°
            let anchor = self.anchorPoint;
            
            let newAnchor = CGPoint(x: boundsSize.height * anchor.y,
                                    y: boundsSize.width * anchor.x);
            
            if ( scale == CGFloat(1.0)) {
                newPosition.x = ceil(currentPosition.x - newAnchor.x - CGFloat(0.5)) + newAnchor.x;
                newPosition.y = ceil(currentPosition.y - newAnchor.y - CGFloat(0.5)) + newAnchor.y;
            }
            else {
                newPosition.x = ceil((currentPosition.x - newAnchor.x) * scale - CGFloat(0.5)) / scale + newAnchor.x;
                newPosition.y = ceil((currentPosition.y - newAnchor.y) * scale - CGFloat(0.5)) / scale + newAnchor.y;
            }
        }
        else {
            if ( scale == CGFloat(1.0)) {
                newPosition.x = round(currentPosition.x);
                newPosition.y = round(currentPosition.y);
            }
            else {
                newPosition.x = round(currentPosition.x * scale) / scale;
                newPosition.y = round(currentPosition.y * scale) / scale;
            }
        }
        self.position = newPosition;
    }
    
    // MARK: Masking
    
    // default path is the rounded rect layer bounds
    
    func sublayerMaskingPath() -> CGPath
    {
        return self.innerBorderPath!;
    }
    
    func applyyMaskToContext(context: CGContext)
    {
        let mySuperlayer = self.superlayer as? CPTLayer
        if mySuperlayer != nil {
            let sup = mySuperlayer!
            
            sup.applySublayerMaskToContext(context: context, forSublayer: self, withOffset: CGPoint.zero)
        }
        
        let maskPath = maskingPath
        if let maskPath = maskPath {
            context.addPath(maskPath)
            context.clip()
        }
    }
    
    public override func setNeedsLayout() {
        super.setNeedsLayout()
        
        let theGraph = graph
        if let theGraph = theGraph {
            NotificationCenter.send(
                name: .CPTGraphNeedsRedrawNotification,
                object: theGraph)
        }
    }
    
    public override func setNeedsDisplay() {
        super.setNeedsDisplay()
        
        let theGraph = graph
        
        if let theGraph = theGraph {
            NotificationCenter.send(
                name: .CPTGraphNeedsRedrawNotification,
                object: theGraph)
        }
    }
    
    
    // MARK: Sublayers
    public override var sublayers : [CALayer]?  {
        get {
            return super.sublayers
        }
        set {
            super.sublayers = newValue
            
            let scale    = self.contentsScale;
            for layer in newValue!  {
                if layer is CPTLayer {
                    layer.contentsScale = scale
                }
            }
        }
    }
    
    public override func addSublayer(_ layer: CALayer )
    {
        super.addSublayer(layer)
        if layer is CPTLayer  {
            layer.contentsScale = self.contentsScale;
        }
    }
    
    public override func insertSublayer(_ layer: CALayer, at idx:UInt32)
    {
        super.insertSublayer(layer , at:idx)
        if layer is CPTLayer {
            layer.contentsScale = self.contentsScale
        }
    }
    
    public override func insertSublayer(_ layer: CALayer, below sibling: CALayer? )
    {
        super.insertSublayer(layer, below:sibling)
        if layer is CPTLayer {
            layer.contentsScale = self.contentsScale
        }
    }
    
    public override func insertSublayer(_ layer: CALayer, above sibling: CALayer? )
    {
        super.insertSublayer(layer, above:sibling)
        if  layer is CPTLayer {
            layer.contentsScale = self.contentsScale
        }
    }
    
    public override func replaceSublayer(_ layer: CALayer , with newLayer: CALayer )
    {
        super.replaceSublayer(layer, with: newLayer)
        if layer is CPTLayer {
            layer.contentsScale = self.contentsScale
        }
    }
    
    // MARK: -Accessors
    public override var contentsScale : CGFloat {
        get {
            var scale = CGFloat(1.0);
            scale = super.contentsScale
            return scale;
        }
        set {
            if ( self.contentsScale != newValue ) {
                super.contentsScale = newValue;
                self.setNeedsDisplay()
                
                let sublayers = super.sublayers
                for subLayer in sublayers! {
                    if ( subLayer is CPTLayer ) {
                        subLayer.contentsScale = newValue
                    }
                }
            }
        }
    }
    
    
    // MARK: - Drawing
    public override func display()
    {
        guard self.isHidden == false else {return}
        
        _ = NSApp.effectiveAppearance //{
        let oldAppearance = NSAppearance.current
        NSAppearance.current = self.graph?.hostingView?.effectiveAppearance
        
        super.display()
        NSAppearance.current = oldAppearance;
        //        }
        //        else {
        //            super.display()
        //        }
    }
    
    @objc func drawInContext(context: CGContext)
    {
        self.useFastRendering = true
        self.renderAsVectorInContext(context: context)
        self.useFastRendering = false
    }
    
    /**
     * @brief Recurs@objc ively marks this layer and all sublayers as needing to be redrawn.
     **/
    @objc func setNeedsDisplayAllLayers() {
        self.setNeedsDisplay()
        
        for subLayer in self.sublayers!  {
            let sub = subLayer as! CPTLayer
            //            if let setNeedsDisplayAllLayers = sub.setNeedsDisplayAllLayers() {
            sub.setNeedsDisplayAllLayers()
            //            }
            //            else {
            //                subLayer.setNeedsDisplay()
            //            }
        }
    }
    
    func renderAsVectorInContext(context: CGContext)
    {
        // This is where subclasses do their drawing
        if ( self.renderingRecursively == true ) {
            self.applyMaskToContext(context: context)
        }
        self.shadow?.shadowInContext(context: context)
    }
    
    /** @brief Draws layer content and the content of all sublayers into the provided graphics context.
     *  @param context The graphics context to draw into.
     **/
    func recursivelyRenderInContext( context : CGContext)
    {
        guard self.isHidden == false else { return}
        // render self
        context.saveGState()
        
        self.applyTransform(transform3D: self.transform, context:context)
        
        self.renderingRecursively = true;
        if self.masksToBounds == false  {
            context.restoreGState()
        }
        self.renderAsVectorInContext(context: context)
        if self.masksToBounds == false {
            context.restoreGState()
        }
        self.renderingRecursively = false;
        
        // render sublayers
        let sublayersCopy = self.sublayers
        for currentSublayer in sublayersCopy! {
            let currentSublayer = currentSublayer
            context.saveGState();
            
            // Shift origin of context to match starting coordinate of sublayer
            let currentSublayerFrameOrigin = currentSublayer.frame.origin;
            let currentSublayerBounds       = currentSublayer.bounds;
            context.translateBy(x: currentSublayerFrameOrigin.x - currentSublayerBounds.origin.x,
                                y: currentSublayerFrameOrigin.y - currentSublayerBounds.origin.y);
            self.applyTransform(transform3D: self.sublayerTransform, context:context)
            
            if currentSublayer is CPTLayer == true {
                
                let currentSublayer = currentSublayer as! CPTLayer
                currentSublayer.recursivelyRenderInContext(context: context)
            }
            else {
                if ( self.masksToBounds ) {
                    context.clip(to: currentSublayer.bounds);
                }
                currentSublayer.draw(in: context)
            }
            context.restoreGState();
        }
        context.restoreGState();
    }
    
    
    func applyTransform(transform3D: CATransform3D, context: CGContext)
    {
        if ( !CATransform3DIsIdentity(transform3D)) {
            if ( CATransform3DIsAffine(transform3D)) {
                let  selfBounds    = self.bounds;
                let anchorPoint  = self.anchorPoint;
                let anchorOffset = CGPoint( x: selfBounds.origin.x + anchorPoint.x * selfBounds.size.width,
                                            y: selfBounds.origin.y + anchorPoint.y * selfBounds.size.height);
                
                var affineTransform = CGAffineTransform(translationX: -anchorOffset.x, y: -anchorOffset.y);
                affineTransform = affineTransform.concatenating(CATransform3DGetAffineTransform(transform3D));
                affineTransform = affineTransform.translatedBy(x: anchorOffset.x, y: anchorOffset.y);
                
                let transformedBounds = selfBounds.applying(affineTransform);
                
                context.translateBy(x: -transformedBounds.origin.x, y: -transformedBounds.origin.y);
                context.concatenate(affineTransform);
            }
        }
    }
    
    /** @brief Updates the layer layout if needed and then draws layer content and the content of all sublayers into the provided graphics context.
     *  @param context The graphics context to draw into.
     */
    func layoutAndRender(context: CGContext)
    {
        self.layoutIfNeeded()
        self.recursivelyRenderInContext(context: context)
    }
    
    /** @brief Draws layer content and the content of all sublayers into a PDF document.
     *  @return PDF representation of the layer content.
     **/
    func dataForPDFRepresentationOfLayer () -> Data
    {
        let pdfData = Data()
        let  dataConsumer = CGDataConsumer(data: pdfData as! CFMutableData)
            
        var mediaBox = CGRect(x: 0.0, y: 0.0, width: bounds.size.width, height: bounds.size.height)
        let pdfContext = CGContext(consumer: dataConsumer!, mediaBox: &mediaBox, nil)
        
        NSUIGraphicsPushContext(pdfContext!)
        
        pdfContext?.beginPage(mediaBox: &mediaBox)
        layoutAndRender(context: pdfContext!)
        pdfContext?.endPage()
        pdfContext?.closePDF()
        
        NSUIGraphicsPopContext()
        return pdfData;
    }
    
    //MARK: - Responder Chain and User interaction
    func pointingDeviceDownEvent(event : CPTNativeEvent,atPoint interactionPoint :CGPoint) -> Bool
    {
        return false;
    }
    
    func pointingDeviceUpEvent(event : CPTNativeEvent , atPoint: CGPoint)-> Bool
    {
        return false;
    }
    
    func pointingDeviceDraggedEvent(event : CPTNativeEvent, atPoint: CGPoint)-> Bool
    {
        return false;
    }
    
    func pointingDeviceCancelledEvent(event: CPTNativeEvent ) -> Bool
    {
        return false;
    }
    
    func scrollWheelEvent(event : CPTNativeEvent, fromPoint:CGPoint, toPoint:CGPoint) -> Bool
    {
        return false
    }
    
    
    
}
