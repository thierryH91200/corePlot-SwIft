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
    
//    @synthesize anchorPoint;
//    @synthesize size;
//    @synthesize symbolType;
//    @synthesize lineStyle;
//    @synthesize fill;
//    @synthesize shadow;
//    @synthesize customSymbolPath;
//    @synthesize usesEvenOddClipRule;
//    @synthesize cachedSymbolPath;
//    @synthesize cachedLayer;
//    @synthesize cachedScale;

    // MARK: - Init/Dealloc
//    override init() {
//        super.init()
//        anchorPoint = CPTPoint(0.5, 0.5)
//        size = CPTSizeMake(5.0, 5.0)
//        symbolType = CPTPlotSymbolType.none
//        lineStyle = CPTLineStyle()
//        fill = nil
//        shadow = nil
//        cachedSymbolPath = nil
//        customSymbolPath = nil
//        usesEvenOddClipRule = false
//        cachedLayer = nil
//        cachedScale = CGFloat(0.0)
//    }

    
    

    // MARK: - Accessors
    var _size = CGSize()
    var size : CGSize {
        get { return _size }
        set {
            if !newValue.equalTo( size) {
                _size                  = newValue;
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
//    -(void)setShadow:(nullable CPTShadow *)newShadow
//    {
//        if ( newShadow != shadow ) {
//            shadow                = [newShadow copy];
//            self.cachedSymbolPath = nil
//        }
//    }
//
//    -(void)setCustomSymbolPath:(nullable CGPathRef)newPath
//    {
//        if ( customSymbolPath != newPath ) {
//            CGPathRelease(customSymbolPath);
//            customSymbolPath      = CGPathRetain(newPath);
//            self.cachedSymbolPath = nil
//        }
//    }
//
//    -(void)setLineStyle:(nullable CPTLineStyle *)newLineStyle
//    {
//        if ( newLineStyle != lineStyle ) {
//            lineStyle        = newLineStyle;
//            self.cachedLayer = nil
//        }
//    }
//
//    -(void)setFill:(nullable CPTFill *)newFill
//    {
//        if ( newFill != fill ) {
//            fill             = newFill;
//            self.cachedLayer = nil
//        }
//    }
//
//    -(void)setUsesEvenOddClipRule:(BOOL)newEvenOddClipRule
//    {
//        if ( newEvenOddClipRule != usesEvenOddClipRule ) {
//            usesEvenOddClipRule = newEvenOddClipRule;
//            self.cachedLayer    = nil
//        }
//    }
//
//    -
    var cachedSymbolPath : CGPath?
    var _cachedSymbolPath : CGPath? {
        get {
            if ( (_cachedSymbolPath == nil) ) {
                _cachedSymbolPath = self.newSymbolPath
            }
            return cachedSymbolPath }
        set {
            if ( _cachedSymbolPath != newValue ) {
                self.cachedLayer = nil
            }
        }
    }

//
//    -(void)setCachedLayer:(nullable CGLayerRef)newLayer
//    {
//        if ( cachedLayer != newLayer ) {
//            CGLayerRelease(cachedLayer);
//            cachedLayer = CGLayerRetain(newLayer);
//        }
//    }
//
//    /// @endcond
//
    
    
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
//    +(nonnull instancetype)customPlotSymbolWithPath:(nullable CGPathRef)aPath
//    {
//        CPTPlotSymbol *symbol = [[self alloc] init];
//
//        symbol.symbolType       = CPTPlotSymbolTypeCustom;
//        symbol.customSymbolPath = aPath;
//
//        return symbol;
//    }
//

    
    // MARK: - Drawing
//
//    /** @brief Draws the plot symbol into the given graphics context centered at the provided point using the cached symbol image.
//     *  @param context The graphics context to draw into.
//     *  @param center The center point of the symbol.
//     *  @param scale The drawing scale factor. Must be greater than zero (@num{0}).
//     *  @param alignToPixels If @YES, the symbol position is aligned with device pixels to reduce anti-aliasing artifacts.
//     **/
//    -(void)renderInContext:(nonnull CGContextRef)context atPoint:(CGPoint)center scale:(CGFloat)scale alignToPixels:(BOOL)alignToPixels
//    {
//        CGPoint symbolAnchor = self.anchorPoint;
//
//        CGLayerRef theCachedLayer = self.cachedLayer;
//        CGFloat theCachedScale    = self.cachedScale;
//
//        if ( !theCachedLayer || (theCachedScale != scale)) {
//            CGSize layerSize = [self layerSizeForScale:scale];
//
//            self.anchorPoint = CPTPointMake(0.5, 0.5);
//
//            CGLayerRef newLayer = CGLayerCreateWithContext(context, layerSize, NULL);
//
//            CGContextRef layerContext = CGLayerGetContext(newLayer);
//            [self renderAsVectorInContext:layerContext
//                                  atPoint:CPTPointMake(layerSize.width * CGFloat(0.5), layerSize.height * CGFloat(0.5))
//                                    scale:scale];
//
//            self.cachedLayer = newLayer;
//            CGLayerRelease(newLayer);
//            self.cachedScale = scale;
//            theCachedLayer   = self.cachedLayer;
//            self.anchorPoint = symbolAnchor;
//        }
//
//        if ( theCachedLayer ) {
//            CGSize layerSize = CGLayerGetSize(theCachedLayer);
//            if ( scale != CGFloat(1.0)) {
//                layerSize.width  /= scale;
//                layerSize.height /= scale;
//            }
//
//            CGSize symbolSize = self.size;
//
//            CGPoint origin = CPTPointMake(center.x - layerSize.width * CGFloat(0.5) - symbolSize.width * (symbolAnchor.x - CGFloat(0.5)),
//                                          center.y - layerSize.height * CGFloat(0.5) - symbolSize.height * (symbolAnchor.y - CGFloat(0.5)));
//
//            if ( alignToPixels ) {
//                if ( scale == CGFloat(1.0)) {
//                    origin.x = round(origin.x);
//                    origin.y = round(origin.y);
//                }
//                else {
//                    origin.x = round(origin.x * scale) / scale;
//                    origin.y = round(origin.y * scale) / scale;
//                }
//            }
//
//            CGContextDrawLayerInRect(context, CGRect(origin.x, origin.y, layerSize.width, layerSize.height), theCachedLayer);
//        }
//    }
//
//    /// @cond
//
//    -(CGSize)layerSizeForScale:(CGFloat)scale
//    {
//        const CGFloat symbolMargin = CGFloat(2.0);
//
//        CGSize shadowOffset  = CGSizeZero;
//        CGFloat shadowRadius = CGFloat(0.0);
//        CPTShadow *myShadow  = self.shadow;
//
//        if ( myShadow ) {
//            shadowOffset = myShadow.shadowOffset;
//            shadowRadius = myShadow.shadowBlurRadius;
//        }
//
//        CGSize layerSize  = self.size;
//        CGFloat lineWidth = self.lineStyle.lineWidth;
//
//        layerSize.width += (ABS(shadowOffset.width) + shadowRadius) * CGFloat(2.0) + lineWidth;
//        layerSize.width *= scale;
//        layerSize.width += symbolMargin;
//
//        layerSize.height += (ABS(shadowOffset.height) + shadowRadius) * CGFloat(2.0) + lineWidth;
//        layerSize.height *= scale;
//        layerSize.height += symbolMargin;
//
//        return layerSize;
//    }
//
//    /// @endcond
//
//    /** @brief Draws the plot symbol into the given graphics context centered at the provided point.
//     *  @param context The graphics context to draw into.
//     *  @param center The center point of the symbol.
//     *  @param scale The drawing scale factor. Must be greater than zero (@num{0}).
//     **/
//    -(void)renderAsVectorInContext:(nonnull CGContextRef)context atPoint:(CGPoint)center scale:(CGFloat)scale
//    {
//        CGPathRef theSymbolPath = self.cachedSymbolPath;
//
//        if ( theSymbolPath ) {
//            CPTLineStyle *theLineStyle = nil;
//            CPTFill *theFill           = nil;
//
//            switch ( self.symbolType ) {
//                case CPTPlotSymbolTypeRectangle:
//                case CPTPlotSymbolTypeEllipse:
//                case CPTPlotSymbolTypeDiamond:
//                case CPTPlotSymbolTypeTriangle:
//                case CPTPlotSymbolTypeStar:
//                case CPTPlotSymbolTypePentagon:
//                case CPTPlotSymbolTypeHexagon:
//                case CPTPlotSymbolTypeCustom:
//                    theLineStyle = self.lineStyle;
//                    theFill      = self.fill;
//                    break;
//
//                case CPTPlotSymbolTypeCross:
//                case CPTPlotSymbolTypePlus:
//                case CPTPlotSymbolTypeDash:
//                case CPTPlotSymbolTypeSnow:
//                    theLineStyle = self.lineStyle;
//                    break;
//
//                default:
//                    break;
//            }
//
//            if ( theLineStyle || theFill ) {
//                CGPoint symbolAnchor = self.anchorPoint;
//                CGSize symbolSize    = self.size;
//                CPTShadow *myShadow  = self.shadow;
//
//                CGContextSaveGState(context);
//                CGContextTranslateCTM(context, center.x + (symbolAnchor.x - CGFloat(0.5)) * symbolSize.width, center.y + (symbolAnchor.y - CGFloat(0.5)) * symbolSize.height);
//                CGContextScaleCTM(context, scale, scale);
//                [myShadow setShadowInContext:context];
//
//                // redraw only symbol rectangle
//                CGSize halfSize = CPTSizeMake(symbolSize.width * CGFloat(0.5), symbolSize.height * CGFloat(0.5));
//                CGRect bounds   = CGRect(-halfSize.width, -halfSize.height, symbolSize.width, symbolSize.height);
//
//                CGRect symbolRect = bounds;
//
//                if ( myShadow ) {
//                    CGFloat shadowRadius = myShadow.shadowBlurRadius;
//                    CGSize shadowOffset  = myShadow.shadowOffset;
//                    symbolRect = CGRectInset(symbolRect, -(ABS(shadowOffset.width) + ABS(shadowRadius)), -(ABS(shadowOffset.height) + ABS(shadowRadius)));
//                }
//                if ( theLineStyle ) {
//                    CGFloat lineWidth = ABS(theLineStyle.lineWidth);
//                    symbolRect = CGRectInset(symbolRect, -lineWidth, -lineWidth);
//                }
//
//                CGContextClipToRect(context, symbolRect);
//
//                CGContextBeginTransparencyLayer(context, NULL);
//
//                if ( theFill ) {
//                    // use fillRect instead of fillPath so that images and gradients are properly centered in the symbol
//                    CGContextSaveGState(context);
//                    if ( !CGPathIsEmpty(theSymbolPath)) {
//                        CGContextBeginPath(context);
//                        CGContextAddPath(context, theSymbolPath);
//                        if ( self.usesEvenOddClipRule ) {
//                            CGContextEOClip(context);
//                        }
//                        else {
//                            CGContextClip(context);
//                        }
//                    }
//                    [theFill fillRect:bounds inContext:context];
//                    CGContextRestoreGState(context);
//                }
//
//                if ( theLineStyle ) {
//                    [theLineStyle setLineStyleInContext:context];
//                    CGContextBeginPath(context);
//                    CGContextAddPath(context, theSymbolPath);
//                    [theLineStyle strokePathInContext:context];
//                }
//
//                CGContextEndTransparencyLayer(context);
//                CGContextRestoreGState(context);
//            }
//        }
//    }
//
    // MARK: - mark Private methods
//
//    /// @cond
//
//    /** @internal
//     *  @brief Creates and returns a drawing path for the current symbol type.
//     *  @return A path describing the outline of the current symbol type.
//     **/
//    -(nonnull CGPathRef)newSymbolPath
//    {
//        CGFloat dx, dy;
//        CGSize symbolSize = self.size;
//        CGSize halfSize   = CPTSizeMake(symbolSize.width * CGFloat(0.5), symbolSize.height * CGFloat(0.5));
//
//        CGMutablePathRef symbolPath = CGPathCreateMutable();
//
//        switch ( self.symbolType ) {
//            case CPTPlotSymbolTypeNone:
//                // empty path
//                break;
//
//            case CPTPlotSymbolTypeRectangle:
//                CGPathAddRect(symbolPath, nil, CGRect(-halfSize.width, -halfSize.height, symbolSize.width, symbolSize.height));
//                break;
//
//            case CPTPlotSymbolTypeEllipse:
//                CGPathAddEllipseInRect(symbolPath, nil, CGRect(-halfSize.width, -halfSize.height, symbolSize.width, symbolSize.height));
//                break;
//
//            case CPTPlotSymbolTypeCross:
//                CGPathMoveToPoint(symbolPath, nil, -halfSize.width, halfSize.height);
//                CGPathAddLineToPoint(symbolPath, nil,halfSize.width, -halfSize.height);
//                CGPathMoveToPoint(symbolPath, nil, halfSize.width, halfSize.height);
//                CGPathAddLineToPoint(symbolPath, nil,-halfSize.width, -halfSize.height);
//                break;
//
//            case CPTPlotSymbolTypePlus:
//                CGPathMoveToPoint(symbolPath, nil,CGFloat(0.0), halfSize.height);
//                CGPathAddLineToPoint(symbolPath, nil, CGFloat(0.0), -halfSize.height);
//                CGPathMoveToPoint(symbolPath, nil, -halfSize.width, CGFloat(0.0));
//                CGPathAddLineToPoint(symbolPath, nil, halfSize.width, CGFloat(0.0));
//                break;
//
//            case CPTPlotSymbolTypePentagon:
//                CGPathMoveToPoint(symbolPath, nil, CGFloat(0.0), halfSize.height);
//                CGPathAddLineToPoint(symbolPath, nil, halfSize.width * CGFloat(0.95105651630), halfSize.height * CGFloat(0.30901699437));
//                CGPathAddLineToPoint(symbolPath, nil, halfSize.width * CGFloat(0.58778525229), -halfSize.height * CGFloat(0.80901699437));
//                CGPathAddLineToPoint(symbolPath, nil, -halfSize.width * CGFloat(0.58778525229), -halfSize.height * CGFloat(0.80901699437));
//                CGPathAddLineToPoint(symbolPath, nil, -halfSize.width * CGFloat(0.95105651630), halfSize.height * CGFloat(0.30901699437));
//                CGPathCloseSubpath(symbolPath);
//                break;
//
//            case CPTPlotSymbolTypeStar:
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
//                CGPathCloseSubpath(symbolPath);
//                break;
//
//            case CPTPlotSymbolTypeDiamond:
//                CGPathMoveToPoint(symbolPath, nil, CGFloat(0.0), halfSize.height);
//                CGPathAddLineToPoint(symbolPath, nil, halfSize.width, CGFloat(0.0));
//                CGPathAddLineToPoint(symbolPath, nil, CGFloat(0.0), -halfSize.height);
//                CGPathAddLineToPoint(symbolPath, nil, -halfSize.width, CGFloat(0.0));
//                CGPathCloseSubpath(symbolPath);
//                break;
//
//            case CPTPlotSymbolTypeTriangle:
//                dx = halfSize.width * CGFloat(0.86602540378); // sqrt(3.0) / 2.0;
//                dy = halfSize.height / CGFloat(2.0);
//
//                CGPathMoveToPoint(symbolPath, nil, CGFloat(0.0), halfSize.height);
//                CGPathAddLineToPoint(symbolPath, nil, dx, -dy);
//                CGPathAddLineToPoint(symbolPath, nil, -dx, -dy);
//                CGPathCloseSubpath(symbolPath);
//                break;
//
//            case CPTPlotSymbolTypeDash:
//                CGPathMoveToPoint(symbolPath, nil, halfSize.width, CGFloat(0.0));
//                CGPathAddLineToPoint(symbolPath, nil, -halfSize.width, CGFloat(0.0));
//                break;
//
//            case CPTPlotSymbolTypeHexagon:
//                dx = halfSize.width * CGFloat(0.86602540378); // sqrt(3.0) / 2.0;
//                dy = halfSize.height / CGFloat(2.0);
//
//                CGPathMoveToPoint(symbolPath, nil, CGFloat(0.0), halfSize.height);
//                CGPathAddLineToPoint(symbolPath, nil, dx, dy);
//                CGPathAddLineToPoint(symbolPath, nil, dx, -dy);
//                CGPathAddLineToPoint(symbolPath, nil, CGFloat(0.0), -halfSize.height);
//                CGPathAddLineToPoint(symbolPath, nil, -dx, -dy);
//                CGPathAddLineToPoint(symbolPath, nil, -dx, dy);
//                CGPathCloseSubpath(symbolPath);
//                break;
//
//            case CPTPlotSymbolTypeSnow:
//                dx = halfSize.width * CGFloat(0.86602540378); // sqrt(3.0) / 2.0;
//                dy = halfSize.height / CGFloat(2.0);
//
//                CGPathMoveToPoint(symbolPath, nil, CGFloat(0.0), halfSize.height);
//                CGPathAddLineToPoint(symbolPath, nil, CGFloat(0.0), -halfSize.height);
//                CGPathMoveToPoint(symbolPath, nil, dx, -dy);
//                CGPathAddLineToPoint(symbolPath, nil, -dx, dy);
//                CGPathMoveToPoint(symbolPath, nil, -dx, -dy);
//                CGPathAddLineToPoint(symbolPath, nil, dx, dy);
//                break;
//
//            case CPTPlotSymbolTypeCustom:
//            {
//                CGPathRef customPath = self.customSymbolPath;
//                if ( customPath ) {
//                    CGRect oldBounds = CGPathGetBoundingBox(customPath);
//                    CGFloat dx1      = symbolSize.width / oldBounds.size.width;
//                    CGFloat dy1      = symbolSize.height / oldBounds.size.height;
//
//                    CGAffineTransform scaleTransform = CGAffineTransformScale(CGAffineTransformIdentity, dx1, dy1);
//                    scaleTransform = CGAffineTransformConcat(scaleTransform,
//                                                             CGAffineTransformMakeTranslation(-halfSize.width, -halfSize.height));
//                    CGPathAddPath(symbolPath, &scaleTransform, customPath);
//                }
//            }
//            break;
//        }
//
//        return symbolPath;
//    }
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
