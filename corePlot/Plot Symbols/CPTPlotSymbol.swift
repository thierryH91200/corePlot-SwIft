//
//  CPTPlotSymbol.swift
//  corePlot
//
//  Created by thierryH24 on 01/01/2021.
//

import Cocoa



class CPTPlotSymbol: NSObject {
    
    enum CPTPlotSymbolType : Int {
        case none ///< No symbol.
        case rectangle ///< Rectangle symbol.
        case ellipse ///< Elliptical symbol.
        case diamond ///< Diamond symbol.
        case triangle ///< Triangle symbol.
        case star ///< 5-point star symbol.
        case pentagon ///< Pentagon symbol.
        case hexagon ///< Hexagon symbol.
        case cross ///< X symbol.
        case plus ///< Plus symbol.
        case dash ///< Dash symbol.
        case snow ///< Snowflake symbol.
        case custom ///< Custom symbol.
    }
    
    var anchorPoint = CGPoint()
    var symbolType = CPTPlotSymbolType.none
    //    @synthesize lineStyle;
    //    @synthesize shadow;
    //    @synthesize customSymbolPath;
    var usesEvenOddClipRule = false
    //    var cachedSymbolPath : CGPath?
    //    @synthesize cachedLayer;
    var cachedScale = CGFloat(0)
    
    // MARK: - Init/Dealloc
    override init() {
        super.init()
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        size = CGSize(width: 5.0, height: 5.0)
        symbolType = CPTPlotSymbolType.none
        lineStyle = CPTLineStyle()
        fill = nil
        shadow = nil
        cachedSymbolPath = nil
        //        customSymb  dClipRule = false
        cachedLayer = nil
        cachedScale = CGFloat(0.0)
    }
    
    // MARK: - Accessors
    var _size = CGSize()
    var size : CGSize {
        get { return _size }
        set {
            if !newValue.equalTo( size) {
                _size  = newValue;
                self.cachedSymbolPath = nil
            }
        }
    }
    
    //    -(void)setSymbolType:(CPTPlotSymbolType)newType
    //    {
    //        if ( newType != symbolType ) {
    //            symbolType            = newType;
    //            self.cachedSymbolPath = nil
    //        }
    //    }
    //
    
    var  _shadow : CPTShadow?
    var  shadow : CPTShadow? {
        get { return _shadow }
        set {
            if ( newValue != _shadow ) {
                _shadow                = newValue
                self.cachedSymbolPath = nil
            }
        }
    }
    var _customSymbolPath : CGPath?
    var customSymbolPath : CGPath? {
        get { return _customSymbolPath }
        set {
            if ( _customSymbolPath != newValue ) {
                _customSymbolPath      = newValue
                self.cachedSymbolPath = nil
            }
        }
    }
    
    var _lineStyle: CPTLineStyle?
    var lineStyle: CPTLineStyle? {
        get {return _lineStyle }
        set {
            if ( newValue != _lineStyle ) {
                _lineStyle        = newValue;
                self.cachedLayer = nil
            }
        }
    }
    
    var _fill : CPTFill?
    var fill: CPTFill? {
        get { return _fill}
        set {
            if ( newValue != _fill ) {
                _fill             = newValue
                self.cachedLayer = nil
            }
        }
    }
    
    //
    //    -(void)setUsesEvenOddClipRule:(BOOL)newEvenOddClipRule
    //    {
    //        if ( newEvenOddClipRule != usesEvenOddClipRule ) {
    //            usesEvenOddClipRule = newEvenOddClipRule;
    //            self.cachedLayer    = nil
    //        }
    //    }
    

    var _cachedSymbolPath : CGPath?
    var cachedSymbolPath : CGPath? {
        get {
            if ( (_cachedSymbolPath == nil) ) {
                _cachedSymbolPath =  newSymbolPath()
            }
            return _cachedSymbolPath }
        set {
            if ( _cachedSymbolPath != newValue ) {
                _cachedSymbolPath = newValue
                self.cachedLayer = nil
            }
        }
    }
    
    var _cachedLayer : CGLayer?
    var cachedLayer : CGLayer? {
        get { }
        set {
            if ( _cachedLayer != newValue ) {
                _cachedLayer = newValue
            }
            
        }
    }
    
    // MARK: - Class methods
    //
    //    /** @brief Creates and returns a new CPTPlotSymbol instance initialized with a symbol type of #CPTPlotSymbolTypeNone.
    //     *  @return A new CPTPlotSymbol instance initialized with a symbol type of #CPTPlotSymbolTypeNone.
    //     **/
    //    +(nonnull instancetype)plotSymbol
    //    {
    //        CPTPlotSymbol *symbol = [[self alloc] init];
    //
    //        symbol.symbolType = CPTPlotSymbolTypeNone;
    //
    //        return symbol;
    //    }
    //
    //    /** @brief Creates and returns a new CPTPlotSymbol instance initialized with a symbol type of #CPTPlotSymbolTypeCross.
    //     *  @return A new CPTPlotSymbol instance initialized with a symbol type of #CPTPlotSymbolTypeCross.
    //     **/
    //    +(nonnull instancetype)crossPlotSymbol
    //    {
    //        CPTPlotSymbol *symbol = [[self alloc] init];
    //
    //        symbol.symbolType = CPTPlotSymbolTypeCross;
    //
    //        return symbol;
    //    }
    //
    //    /** @brief Creates and returns a new CPTPlotSymbol instance initialized with a symbol type of #CPTPlotSymbolTypeEllipse.
    //     *  @return A new CPTPlotSymbol instance initialized with a symbol type of #CPTPlotSymbolTypeEllipse.
    //     **/
    //    +(nonnull instancetype)ellipsePlotSymbol
    //    {
    //        CPTPlotSymbol *symbol = [[self alloc] init];
    //
    //        symbol.symbolType = CPTPlotSymbolTypeEllipse;
    //
    //        return symbol;
    //    }
    //
    //    /** @brief Creates and returns a new CPTPlotSymbol instance initialized with a symbol type of #CPTPlotSymbolTypeRectangle.
    //     *  @return A new CPTPlotSymbol instance initialized with a symbol type of #CPTPlotSymbolTypeRectangle.
    //     **/
    //    +(nonnull instancetype)rectanglePlotSymbol
    //    {
    //        CPTPlotSymbol *symbol = [[self alloc] init];
    //
    //        symbol.symbolType = CPTPlotSymbolTypeRectangle;
    //
    //        return symbol;
    //    }
    //
    //    /** @brief Creates and returns a new CPTPlotSymbol instance initialized with a symbol type of #CPTPlotSymbolTypePlus.
    //     *  @return A new CPTPlotSymbol instance initialized with a symbol type of #CPTPlotSymbolTypePlus.
    //     **/
    //    +(nonnull instancetype)plusPlotSymbol
    //    {
    //        CPTPlotSymbol *symbol = [[self alloc] init];
    //
    //        symbol.symbolType = CPTPlotSymbolTypePlus;
    //
    //        return symbol;
    //    }
    //
    //    /** @brief Creates and returns a new CPTPlotSymbol instance initialized with a symbol type of #CPTPlotSymbolTypeStar.
    //     *  @return A new CPTPlotSymbol instance initialized with a symbol type of #CPTPlotSymbolTypeStar.
    //     **/
    //    +(nonnull instancetype)starPlotSymbol
    //    {
    //        CPTPlotSymbol *symbol = [[self alloc] init];
    //
    //        symbol.symbolType = CPTPlotSymbolTypeStar;
    //
    //        return symbol;
    //    }
    //
    //    /** @brief Creates and returns a new CPTPlotSymbol instance initialized with a symbol type of #CPTPlotSymbolTypeDiamond.
    //     *  @return A new CPTPlotSymbol instance initialized with a symbol type of #CPTPlotSymbolTypeDiamond.
    //     **/
    //    +(nonnull instancetype)diamondPlotSymbol
    //    {
    //        CPTPlotSymbol *symbol = [[self alloc] init];
    //
    //        symbol.symbolType = CPTPlotSymbolTypeDiamond;
    //
    //        return symbol;
    //    }
    //
    //    /** @brief Creates and returns a new CPTPlotSymbol instance initialized with a symbol type of #CPTPlotSymbolTypeTriangle.
    //     *  @return A new CPTPlotSymbol instance initialized with a symbol type of #CPTPlotSymbolTypeTriangle.
    //     **/
    //    +(nonnull instancetype)trianglePlotSymbol
    //    {
    //        CPTPlotSymbol *symbol = [[self alloc] init];
    //
    //        symbol.symbolType = CPTPlotSymbolTypeTriangle;
    //
    //        return symbol;
    //    }
    //
    //    /** @brief Creates and returns a new CPTPlotSymbol instance initialized with a symbol type of #CPTPlotSymbolTypePentagon.
    //     *  @return A new CPTPlotSymbol instance initialized with a symbol type of #CPTPlotSymbolTypePentagon.
    //     **/
    //    +(nonnull instancetype)pentagonPlotSymbol
    //    {
    //        CPTPlotSymbol *symbol = [[self alloc] init];
    //
    //        symbol.symbolType = CPTPlotSymbolTypePentagon;
    //
    //        return symbol;
    //    }
    //
    //    /** @brief Creates and returns a new CPTPlotSymbol instance initialized with a symbol type of #CPTPlotSymbolTypeHexagon.
    //     *  @return A new CPTPlotSymbol instance initialized with a symbol type of #CPTPlotSymbolTypeHexagon.
    //     **/
    //    +(nonnull instancetype)hexagonPlotSymbol
    //    {
    //        CPTPlotSymbol *symbol = [[self alloc] init];
    //
    //        symbol.symbolType = CPTPlotSymbolTypeHexagon;
    //
    //        return symbol;
    //    }
    //
    //    /** @brief Creates and returns a new CPTPlotSymbol instance initialized with a symbol type of #CPTPlotSymbolTypeDash.
    //     *  @return A new CPTPlotSymbol instance initialized with a symbol type of #CPTPlotSymbolTypeDash.
    //     **/
    //    +(nonnull instancetype)dashPlotSymbol
    //    {
    //        CPTPlotSymbol *symbol = [[self alloc] init];
    //
    //        symbol.symbolType = CPTPlotSymbolTypeDash;
    //
    //        return symbol;
    //    }
    //
    //    /** @brief Creates and returns a new CPTPlotSymbol instance initialized with a symbol type of #CPTPlotSymbolTypeSnow.
    //     *  @return A new CPTPlotSymbol instance initialized with a symbol type of #CPTPlotSymbolTypeSnow.
    //     **/
    //    +(nonnull instancetype)snowPlotSymbol
    //    {
    //        CPTPlotSymbol *symbol = [[self alloc] init];
    //
    //        symbol.symbolType = CPTPlotSymbolTypeSnow;
    //
    //        return symbol;
    //    }
    //
    //    /** @brief Creates and returns a new CPTPlotSymbol instance initialized with a symbol type of #CPTPlotSymbolTypeCustom.
    //     *  @param aPath The bounding path for the custom symbol.
    //     *  @return A new CPTPlotSymbol instance initialized with a symbol type of #CPTPlotSymbolTypeCustom.
    //     **/
    
    func customPlotSymbol(with aPath: CGPath?) -> CPTPlotSymbol {
        let symbol = CPTPlotSymbol()
        
        symbol.symbolType = CPTPlotSymbolType.custom
        symbol.customSymbolPath = aPath
        
        return symbol
    }
    
    // MARK: - Drawing
    //
    //    /** @brief Draws the plot symbol into the given graphics context centered at the provided point using the cached symbol image.
    //     *  @param context The graphics context to draw into.
    //     *  @param center The center point of the symbol.
    //     *  @param scale The drawing scale factor. Must be greater than zero (@num{0}).
    //     *  @param alignToPixels If @YES, the symbol position is aligned with device pixels to reduce anti-aliasing artifacts.
    //     **/
    func renderInContext(context: CGContext, atPoint center: CGPoint,  scale: CGFloat, alignToPixels: Bool)
    {
        let symbolAnchor = self.anchorPoint;
        
        var theCachedLayer = self.cachedLayer;
        let theCachedScale    = self.cachedScale;
        
        if ( (theCachedLayer == nil) || (theCachedScale != scale)) {
            let layerSize = self.layerSizeForScale(scale: scale)
            
            self.anchorPoint = CGPoint(x: 0.5, y: 0.5);
            
            let newLayer = CGLayer(context, size: layerSize, auxiliaryInfo: nil);
            
            let layerContext = newLayer!.context;
            self.renderAsVectorInContext(context: layerContext!,
                                         atPoint:CGPoint(x: layerSize.width * CGFloat(0.5), y: layerSize.height * CGFloat(0.5)),
                                         scale:scale)
            
            self.cachedLayer = newLayer;
            self.cachedScale = scale;
            theCachedLayer   = self.cachedLayer;
            self.anchorPoint = symbolAnchor;
        }
        
        if (( theCachedLayer ) != nil) {
            var layerSize = theCachedLayer!.size;
            if ( scale != CGFloat(1.0)) {
                layerSize.width  /= scale;
                layerSize.height /= scale;
            }
            
            let symbolSize = self.size;
            
            var origin = CGPoint(x: center.x - layerSize.width * CGFloat(0.5) - symbolSize.width * (symbolAnchor.x - CGFloat(0.5)),
                                 y: center.y - layerSize.height * CGFloat(0.5) - symbolSize.height * (symbolAnchor.y - CGFloat(0.5)));
            
            if ( alignToPixels ) {
                if ( scale == CGFloat(1.0)) {
                    origin.x = round(origin.x);
                    origin.y = round(origin.y);
                }
                else {
                    origin.x = round(origin.x * scale) / scale;
                    origin.y = round(origin.y * scale) / scale;
                }
            }
            let rect =  CGRect(x: origin.x, y: origin.y, width: layerSize.width, height: layerSize.height)
            context.draw( theCachedLayer! , in: rect )
            //            CGContextDrawLayerInRect(context, rect, theCachedLayer);
            
        }
    }
    
    func layerSizeForScale( scale: CGFloat) -> CGSize {
        let symbolMargin = CGFloat(2.0)
        
        var shadowOffset = CGSize.zero
        var shadowRadius = CGFloat(0.0)
        let myShadow = shadow
        
        if let myShadow = myShadow {
            shadowOffset = myShadow.shadowOffset
            shadowRadius = myShadow.shadowBlurRadius
        }
        
        var layerSize = size
        let lineWidth = lineStyle?.lineWidth
        
        layerSize.width += (CGFloat(abs(shadowOffset.width)) + shadowRadius) * CGFloat(2.0) + lineWidth!
        layerSize.width *= scale
        layerSize.width += symbolMargin
        
        layerSize.height += (CGFloat(abs(shadowOffset.height)) + shadowRadius) * CGFloat(2.0) + lineWidth!
        layerSize.height *= scale
        layerSize.height += symbolMargin
        
        return layerSize
    }
    
    //
    //    /// @endcond
    //
    //    /** @brief Draws the plot symbol into the given graphics context centered at the provided point.
    //     *  @param context The graphics context to draw into.
    //     *  @param center The center point of the symbol.
    //     *  @param scale The drawing scale factor. Must be greater than zero (@num{0}).
    //     **/
    func renderAsVectorInContext(context: CGContext, atPoint center:CGPoint, scale:CGFloat)
    {
        let theSymbolPath = self.cachedSymbolPath;
        
        if (( theSymbolPath ) != nil) {
            let theLineStyle : CPTLineStyle?
            let theFill      : CPTFill?
            
            switch ( self.symbolType ) {
            case .rectangle:
                fallthrough
            case .ellipse:
                fallthrough
            case .diamond:
                fallthrough
            case .triangle:
                fallthrough
            case .star:
                fallthrough
            case .pentagon:
                fallthrough
            case .hexagon:
                fallthrough
            case .custom:
                theLineStyle = self.lineStyle
                theFill      = self.fill
                break;
                
            case .cross:
                fallthrough
            case .plus:
                fallthrough
            case .dash:
                fallthrough
            case .snow:
                theLineStyle = self.lineStyle;
                break;
            default:
                break;
            }
            
            if ( (theLineStyle != nil) || (theFill != nil) ) {
                let symbolAnchor = self.anchorPoint;
                let symbolSize    = self.size;
                let myShadow  = self.shadow;
                
                context.saveGState();
                context.translateBy(x: center.x + (symbolAnchor.x - CGFloat(0.5)) * symbolSize.width, y: center.y + (symbolAnchor.y - CGFloat(0.5)) * symbolSize.height);
                context.scaleBy(x: scale, y: scale);
                myShadow?.setShadowInContext(context: context)
                
                // redraw only symbol rectangle
                let halfSize = CGSize(width: symbolSize.width * CGFloat(0.5), height: symbolSize.height * CGFloat(0.5));
                let bounds   = CGRect(x: -halfSize.width, y: -halfSize.height, width: symbolSize.width, height: symbolSize.height);
                
                var symbolRect = bounds;
                
                if (( myShadow ) != nil) {
                    let shadowRadius = myShadow?.shadowBlurRadius;
                    let shadowOffset  = myShadow?.shadowOffset;
                    symbolRect = symbolRect.insetBy(dx: -(abs(shadowOffset!.width) + abs(shadowRadius!)),
                                                    dy: -(abs(shadowOffset!.height) + abs(shadowRadius!)));
                }
                if (( theLineStyle ) != nil) {
                    let lineWidth = abs(theLineStyle!.lineWidth);
                    symbolRect = symbolRect.insetBy(dx: -lineWidth, dy: -lineWidth);
                }
                
                context.clip(to: symbolRect);
                
                context.beginTransparencyLayer(auxiliaryInfo: nil);
                
                if (( theFill ) != nil) {
                    // use fillRect instead of fillPath so that images and gradients are properly centered in the symbol
                    context.saveGState();
                    if ( !theSymbolPath!.isEmpty) {
                        context.beginPath();
                        context.addPath(theSymbolPath!);
                        if ( self.usesEvenOddClipRule == true) {
                            context.clip(using: .evenOdd)
                        }
                        else {
                            context.clip();
                        }
                    }
                    theFill?.fillRect(rect: bounds, context:context)
                    context.restoreGState();
                }
                
                if (( theLineStyle ) != nil) {
                    theLineStyle?.setLineStyleInContext(context: context)
                    context.beginPath();
                    context.addPath(theSymbolPath!)
                    theLineStyle?.strokePathInContext(context: context)
                }
                
                context.endTransparencyLayer();
                context.restoreGState();
            }
        }
    }
    
    // MARK: - mark Private methods
    //
    //
    //    /** @internal
    //     *  @brief Creates and returns a drawing path for the current symbol type.
    //     *  @return A path describing the outline of the current symbol type.
    //     **/
    func newSymbolPath()-> CGPath
    {
        var dx = CGFloat(0)
        var dy = CGFloat(0)
        let symbolSize = self.size;
        let halfSize   = CGSize(width: symbolSize.width * CGFloat(0.5), height: symbolSize.height * CGFloat(0.5));
        
        let symbolPath = CGMutablePath();
        
        switch ( self.symbolType ) {
        case .none:
            // empty path
            break;
            
        case .rectangle:
            let rect = CGRect(x: -halfSize.width, y: -halfSize.height, width: symbolSize.width, height: symbolSize.height)
            symbolPath.addRect(rect)
            break;
            
        case .ellipse:
            let rect = CGRect(x: -halfSize.width, y: -halfSize.height, width: symbolSize.width, height: symbolSize.height)
            symbolPath.addEllipse(in: rect)
            break;
            
        case .cross:
            symbolPath.move(to: CGPoint( x: -halfSize.width, y: halfSize.height))
            symbolPath.addLine(to: CGPoint( x: halfSize.width, y: -halfSize.height))
            
            symbolPath.move(to: CGPoint( x: halfSize.width, y: halfSize.height))
            symbolPath.addLine(to: CGPoint( x: -halfSize.width, y: -halfSize.height))
            break;
            
        case .plus:
            //                CGPathMoveToPoint(symbolPath, nil,CGFloat(0.0), halfSize.height);
            //                CGPathAddLineToPoint(symbolPath, nil, CGFloat(0.0), -halfSize.height);
            //                CGPathMoveToPoint(symbolPath, nil, -halfSize.width, CGFloat(0.0));
            //                CGPathAddLineToPoint(symbolPath, nil, halfSize.width, CGFloat(0.0));
            break;
            
        case .pentagon:
            //                CGPathMoveToPoint(symbolPath, nil, CGFloat(0.0), halfSize.height);
            //                CGPathAddLineToPoint(symbolPath, nil, halfSize.width * CGFloat(0.95105651630), halfSize.height * CGFloat(0.30901699437));
            //                CGPathAddLineToPoint(symbolPath, nil, halfSize.width * CGFloat(0.58778525229), -halfSize.height * CGFloat(0.80901699437));
            //                CGPathAddLineToPoint(symbolPath, nil, -halfSize.width * CGFloat(0.58778525229), -halfSize.height * CGFloat(0.80901699437));
            //                CGPathAddLineToPoint(symbolPath, nil, -halfSize.width * CGFloat(0.95105651630), halfSize.height * CGFloat(0.30901699437));
            symbolPath.closeSubpath();
            break;
            
        case .star:
            //                CGPathMoveToPoint(symbolPath, nil, CGFloat(0.0), halfSize.height);
            //                CGPathAddLineToPoint(symbolPath, nil, halfSize.width * CGFloat(0.22451398829), halfSize.height * CGFloat(0.30901699437));
            //                CGPathAddLineToPoint(symbolPath, nil, halfSize.width * CGFloat(0.95105651630), halfSize.height * CGFloat(0.30901699437));
            //                CGPathAddLineToPoint(symbolPath, nil, halfSize.width * CGFloat(0.36327126400), -halfSize.height * CGFloat(0.11803398875));
            //                CGPathAddLineToPoint(symbolPath, nil, halfSize.width * CGFloat(0.58778525229), -halfSize.height * CGFloat(0.80901699437));
            //                CGPathAddLineToPoint(symbolPath, nil, CGFloat(0.0), -halfSize.height * CGFloat(0.38196601125));
            //                CGPathAddLineToPoint(symbolPath, nil, -halfSize.width * CGFloat(0.58778525229), -halfSize.height * CGFloat(0.80901699437));
            //                CGPathAddLineToPoint(symbolPath, nil, -halfSize.width * CGFloat(0.36327126400), -halfSize.height * CGFloat(0.11803398875));
            //                CGPathAddLineToPoint(symbolPath, nil, -halfSize.width * CGFloat(0.95105651630), halfSize.height * CGFloat(0.30901699437));
            //                CGPathAddLineToPoint(symbolPath, nil, -halfSize.width * CGFloat(0.22451398829), halfSize.height * CGFloat(0.30901699437));
            symbolPath.closeSubpath();
            break;
            
        case .diamond:
            //                CGPathMoveToPoint(symbolPath, nil, CGFloat(0.0), halfSize.height);
            //                CGPathAddLineToPoint(symbolPath, nil, halfSize.width, CGFloat(0.0));
            //                CGPathAddLineToPoint(symbolPath, nil, CGFloat(0.0), -halfSize.height);
            //                CGPathAddLineToPoint(symbolPath, nil, -halfSize.width, CGFloat(0.0));
            symbolPath.closeSubpath();
            break;
            
        case .triangle:
            dx = halfSize.width * CGFloat(0.86602540378); // sqrt(3.0) / 2.0;
            dy = halfSize.height / CGFloat(2.0);
            
            //                CGPathMoveToPoint(symbolPath, nil, CGFloat(0.0), halfSize.height);
            //                CGPathAddLineToPoint(symbolPath, nil, dx, -dy);
            //                CGPathAddLineToPoint(symbolPath, nil, -dx, -dy);
            symbolPath.closeSubpath();
            break;
            
        case .dash:
            symbolPath.move   (to: CGPoint( x: halfSize.width, y: CGFloat(0.0)))
            symbolPath.addLine(to: CGPoint( x: -halfSize.width, y: CGFloat(0.0)))
            break;
            
        case .hexagon:
            dx = halfSize.width * CGFloat(0.86602540378); // sqrt(3.0) / 2.0;
            dy = halfSize.height / CGFloat(2.0);
            
            symbolPath.move   (to: CGPoint( x:  CGFloat(0.0), y: halfSize.height))
            symbolPath.addLine(to: CGPoint( x: dx, y: dy))
            symbolPath.addLine(to: CGPoint( x: dx, y: -dy))
            symbolPath.addLine(to: CGPoint( x: CGFloat(0.0), y: -halfSize.height))
            symbolPath.addLine(to: CGPoint( x: -dx, y: -dy))
            symbolPath.addLine(to: CGPoint( x: -dx, y: dy))
            symbolPath.closeSubpath();
            break;
            
        case .snow:
            dx = halfSize.width * CGFloat(0.86602540378); // sqrt(3.0) / 2.0;
            dy = halfSize.height / CGFloat(2.0);
            let point = CGPoint(x: CGFloat(0.0), y: halfSize.height)
            symbolPath.move(to: point)
            symbolPath.addLine(to: CGPoint( x: CGFloat(0.0), y: -halfSize.height))
            
            symbolPath.move   (to: CGPoint( x: dx, y: -dy))
            symbolPath.addLine(to: CGPoint( x: -dx, y: dy))
            
            symbolPath.move   (to: CGPoint( x: -dx, y: -dy))
            symbolPath.addLine(to: CGPoint( x: dx, y: dy))
            
            
        case .custom:
            let customPath = self.customSymbolPath;
            if (( customPath ) != nil) {
                let oldBounds = customPath!.boundingBox;
                let dx1      = symbolSize.width / oldBounds.size.width;
                let dy1      = symbolSize.height / oldBounds.size.height;
                
                //                    var scaleTransform = CGAffineTransformScale(CGAffineTransformIdentity, dx1, dy1);
                //                    scaleTransform = scaleTransform.concatenating(CGAffineTransformMakeTranslation(-halfSize.width, -halfSize.height));
                //                    CGPathAddPath(symbolPath, &scaleTransform, customPath);
            }
            
            break;
        }
        return symbolPath;
    }
    //
    //    /// @endcond
    
    
    // MARK: - Debugging
    //
    //    /// @cond
    //
    //    -(nullable id)debugQuickLookObject
    //    {
    //        const CGFloat screenScale = 1.0;
    //
    //        CGSize layerSize = [self layerSizeForScale:screenScale];
    //
    //        CGRect rect = CGRectMake(0.0, 0.0, layerSize.width, layerSize.height);
    //
    //        return CPTQuickLookImage(rect, ^(CGContextRef context, CGFloat scale, CGRect bounds) {
    //            CGPoint symbolAnchor = self.anchorPoint;
    //
    //            self.anchorPoint = CPTPointMake(0.5, 0.5);
    //
    //            [self renderAsVectorInContext:context atPoint:CGPoint(CGRectGetMidX(bounds), CGRectGetMidY(bounds)) scale:scale];
    //
    //            self.anchorPoint = symbolAnchor;
    //        });
    //    }
    //
    //    /// @endcond
    //
    //    @end
    
    
}
