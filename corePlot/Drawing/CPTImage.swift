////
////  CPTImage.swift
////  corePlot
////
////  Created by thierryH24 on 07/11/2020.
////
//
import AppKit

class CPTImage: NSObject {
    
    enum CPTSlice : Int {
        case topLeft = 0    //< Top left corner
        case top            //< Top middle
        case topRight   //< Top right corner
        case left ///< Left middle
        case middle ///< Middle
        case right ///< Right middle
        case bottomLeft ///< Bottom left corner
        case bottom ///< Bottom middle
        case bottomRight ///< Bottom right corner
    }
    
    struct _CPTImageSlices {
        var  slice = [CGImage?] ()       ///< The image slices used to render a stretchable image.
    }
    typealias CPTImageSlices = _CPTImageSlices
    
    var nativeImage: CPTNativeImage?
    var image: CGImage?
    var scale: CGFloat = 0.0
    var isTiled = false
    var edgeInsets: NSEdgeInsets?
    var tileAnchoredToContext = false
    var opaque = false
    let slices: CPTImageSlices
    
    var  lastDrawnScale = CGFloat(0.0)
    
    
    // MARK: - Init/Dealloc
    init(path : String)
    {
        //        self.initWithNativeImage([[CPTNativeImage alloc] initWithContentsOfFile:path]];
    }
    
    init( anImage: CGImage, newScale: CGFloat )
    {
        guard newScale > CGFloat(0.0) else {return };
        
        super.init()
        
        nativeImage           = nil;
        image                 = anImage;
        scale                 = newScale;
        lastDrawnScale        = newScale;
        isTiled                 = false
        tileAnchoredToContext = true;
        edgeInsets            = NSEdgeInsetsZero
    }
    
    //    convenience init( anImage: CGImage)
    //    {
    //        self.init(anImage: anImage, newScale:CGFloat(1.0))
    //    }
    //
    //    override init()
    //    {
    //        //        self.init(anImage: nil)
    //    }
    //
    //    // MARK: - Factory Methods
    //    init(name:String)
    //    {
    //        self.imageWithNativeImage:[CPTNativeImage imageNamed:name]];
    //    }
    //
    //    /** @brief Initializes a CPTImage instance with the provided platform-native image.
    //     *
    //     *  @param anImage The platform-native image.
    //     *  @return A new CPTImage instance initialized with the provided image.
    //     **/
    //    func imageWithNativeImage(anImage:  CPTNativeImage)
    //    {
    //    return [[self alloc] initWithNativeImage:anImage];
    //    }
    //
    //    /** @brief Initializes a CPTImage instance with the contents of a file.
    //     *
    //     *  @param path The full or partial path to the image file.
    //     *  @return A new CPTImage instance initialized from the file at the given path.
    //     **/
    //    +(nonnull instancetype)imageWithContentsOfFile:(nonnull NSString *)path
    //    {
    //    return [[self alloc] initWithContentsOfFile:path];
    //    }
    //
    //    /** @brief Creates and returns a new CPTImage instance initialized with the provided @ref CGImageRef.
    //     *  @param anImage The image to wrap.
    //     *  @param newScale The image scale.
    //     *  @return A new CPTImage instance initialized with the provided @ref CGImageRef.
    //     **/
    //    +(nonnull instancetype)imageWithCGImage:(nullable CGImageRef)anImage scale:(CGFloat)newScale
    //    {
    //    return [[self alloc] initWithCGImage:anImage scale:newScale];
    //    }
    //
    //    /** @brief Creates and returns a new CPTImage instance initialized with the provided @ref CGImageRef and scale @num{1.0}.
    //     *  @param anImage The image to wrap.
    //     *  @return A new CPTImage instance initialized with the provided @ref CGImageRef.
    //     **/
    //    +(nonnull instancetype)imageWithCGImage:(nullable CGImageRef)anImage
    //    {
    //    returnself.imageWithCGImage:anImage scale:CGFloat(1.0)];
    //    }
    //
    //    /** @brief Creates and returns a new CPTImage instance initialized with the contents of a PNG file.
    //     *
    //     *  On systems that support hi-dpi or @quote{Retina} displays, this method will look for a
    //     *  double-resolution image with the given name followed by @quote{@2x}. If the @quote{@2x} image
    //     *  is not available, the named image file will be loaded.
    //     *
    //     *  @param path The file system path of the file.
    //     *  @return A new CPTImage instance initialized with the contents of the PNG file.
    //     **/
    //    +(nonnull instancetype)imageForPNGFile:(nonnull NSString *)path
    //    {
    //    return [[self alloc] initForPNGFile:path];
    //    }
    //
    // MARK: Image comparison
    func isEqual(object: Any) -> Bool
    {
        
        let otherImage = object as? CPTImage
        
        
        let selfCGImage  = self.image
        let otherCGImage = otherImage?.image;
        
        return selfCGImage == otherCGImage
        
    }
    
    //    /// @}
    //
    //    /// @cond
    //
    //    -(NSUInteger)hash
    //    {
    //    // Equal objects must hash the same.
    //    CGImageRef selfCGImage = self.image;
    //
    //    return (CGImageGetWidth(selfCGImage) * CGImageGetHeight(selfCGImage)) +
    //    CGImageGetBitsPerComponent(selfCGImage) +
    //    CGImageGetBitsPerPixel(selfCGImage) +
    //    CGImageGetBytesPerRow(selfCGImage) +
    //    CGImageGetBitmapInfo(selfCGImage) +
    //    CGImageGetShouldInterpolate(selfCGImage) +
    //    (NSUInteger)(CGImageGetRenderingIntent(selfCGImage) * self.scale);
    //    }
    //
    //    /// @endcond
    //
    //
    //    // MARK: Opacity
    //    var isOpaque: Bool
    //    {
    //        get { return false}
    //    }
    //
    //
    //    // MARK: Accessors
    //
    //    /// @cond
    //
    //    -(void)setImage:(nullable CGImageRef)newImage
    //    {
    //    if ( newImage != image ) {
    //    CGImageRetain(newImage);
    //    CGImageRelease(image);
    //    image = newImage;
    //    }
    //    }
    //
    //    -(void)setNativeImage:(nullable CPTNativeImage *)newImage
    //    {
    //    if ( newImage != nativeImage ) {
    //    nativeImage = [newImage copy];
    //
    //    self.image = NULL;
    //    }
    //    }
    //
    //    -(nullable CPTNativeImage *)nativeImage
    //    {
    //    if ( !nativeImage ) {
    //    CGImageRef imageRef = self.image;
    //
    //    #if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
    //    CGFloat theScale = self.scale;
    //
    //    if ( imageRef && (theScale > CGFloat(0.0))) {
    //    nativeImage = [UIImage imageWithCGImage:imageRef
    //    scale:theScale
    //    orientation:UIImageOrientationUp];
    //    }
    //    #else
    //    if ( [NSImage instancesRespondToSelector:@selector(initWithCGImage:size:)] ) {
    //    nativeImage = [[NSImage alloc] initWithCGImage:imageRef size:NSZeroSize];
    //    }
    //    else {
    //    CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    //
    //    NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
    //    pixelsWide:(NSInteger)imageSize.width
    //    pixelsHigh:(NSInteger)imageSize.height
    //    bitsPerSample:8
    //    samplesPerPixel:4
    //    hasAlpha:true
    //    isPlanar:NO
    //    colorSpaceName:NSCalibratedRGBColorSpace
    //    bytesPerRow:(NSInteger)imageSize.width * 4
    //    bitsPerPixel:32];
    //
    //    NSGraphicsContext *bitmapContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:imageRep];
    //    CGContextRef context             = (CGContextRef)bitmapContext.graphicsPort;
    //
    //    CGContextDrawImage(context, CPTRectMake(0.0, 0.0, imageSize.width, imageSize.height), imageRef);
    //
    //    nativeImage = [[NSImage alloc] initWithSize:NSSizeFromCGSize(imageSize)];
    //    [nativeImage addRepresentation:imageRep];
    //    }
    //    #endif
    //    }
    //
    //    return nativeImage;
    //    }
    //
    //    -(void)setScale:(CGFloat)newScale
    //    {
    //    NSParameterAssert(newScale > CGFloat(0.0));
    //
    //    if ( newScale != scale ) {
    //    scale = newScale;
    //    }
    //    }
    //
    //    func setEdgeInsets(newEdgeInsets : CPTEdgeInsets)
    //    {
    //
    //        if NSEdgeInsetsEqual(NSEdgeInsetsEqual,newEdgeInsets) == false {
    //            edgeInsets = newEdgeInsets;
    //        }
    //
    //    var imageSlices = CPTImageSlices
    //
    //        for i in 0..<9 {
    //    imageSlices.slice[i] = NULL;
    //    }
    //
    //    self.slices = imageSlices;
    //    }
    //    }
    //
    //func setSlices(newSlices: CPTImageSlices)
    //{
    //    for ( i in 0..<9) {
    //        CGImageRelease(slices.slice[i]);
    //
    //        CGImageRef slice = CGImageRetain(newSlices.slice[i]);
    //        if ( slice ) {
    //            slices.slice[i] = slice;
    //        }
    //    }
    //}
    //
    //    /// @endcond
    //
    
    
    //  MARK: Drawing
    
    
    func drawImage(theImage: CGImage, inContext context: CGContext, rect: CGRect, scaleRatio: CGFloat)
    {
        if ( theImage && (rect.width > CGFloat(0.0)) && (rect.height > CGFloat(0.0))) {
            let imageScale = self.scale;
            
            context.saveGState();
            
            if ( self.isTiled ) {
                context.clip(to: rect);
                if ( !self.tileAnchoredToContext ) {
                    context.translateBy(x: rect.origin.x, y: rect.origin.y);
                }
                context.scaleBy(x: scaleRatio, y: scaleRatio);
                
                let imageBounds = CGRect(x: 0.0, y: 0.0, width: CGFloat(theImage.width) / imageScale, height: CGFloat(theImage.height) / imageScale)
                
                CGContextDrawTiledImage(context, imageBounds, theImage);
            }
            else {
                context.scaleBy(x: scaleRatio, y: scaleRatio);
                context.draw(theImage, in: rect)
                
            }
            
            context.restoreGState();
        }
    }
    ////
    ////    /// @endcond
    ////
    ////    /** @brief Draws the image into the given graphics context.
    ////     *
    ////     *  If the tiled property is @true, the image is repeatedly drawn to fill the clipping region, otherwise the image is
    ////     *  scaled to fit in @par{rect}.
    ////     *
    ////     *  @param rect The rectangle to draw into.
    ////     *  @param context The graphics context to draw into.
    ////     **/
    
    
    func drawInRect(rect: CGRect, inContext context: CGContext)
    {
        var theImage = self.image;
        
        // compute drawing scale
        let lastScale    = self.lastDrawnScale;
        var contextScale = CGFloat(1.0)
        
        if ( rect.size.height != CGFloat(0.0)) {
            let deviceRect = context.convertToDeviceSpace(rect)
            contextScale = deviceRect.size.height / rect.size.height;
        }
        
        // generate a Core Graphics image if needed
        if ( (theImage == nil) || (contextScale != lastScale)) {
            let theNativeImage = self.nativeImage;
            
            if (( theNativeImage ) != nil) {
                #if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
                theImage   = theNativeImage.CGImage;
                self.scale = theNativeImage.scale;
                #else
                let imageSize   = theNativeImage!.size;
                var drawingRect = NSRect(x: 0.0, y: 0.0, width: imageSize.width, height: imageSize.height);
                
                theImage = theNativeImage!.CGImageForProposedRect(&drawingRect,
                                                                  context:  NSGraphicsContext.graphicsContextWithGraphicsPort(context, flipped:false),
                                                                  hints:nil)
                self.scale = contextScale;
                #endif
                self.image = theImage;
            }
        }
        
        guard ( theImage == nil)  else {return }
        
        // draw the image
        let imageScale = self.scale;
        let scaleRatio = contextScale / imageScale;
        
        let insets = self.edgeInsets;
        
        if CPTUtilities.shared.CPTEdgeInsetsEqualToEdgeInsets(insets1: insets!, insets2: NSEdgeInsets()) {
            self.drawImage(theImage: theImage!, inContext:context, rect:rect, scaleRatio:scaleRatio)
        }
        else {
            var imageSlices = self.slices;
            var hasSlices             = false
            
            for  i in   0..<9 {
                if (( imageSlices.slice[i] ) != nil) {
                    hasSlices = true;
                    break;
                }
            }
            
            // create new slices if needed
            if ( hasSlices == false || (contextScale != lastScale)) {
                self.makeImageSlices()
                imageSlices = self.slices
            }
            
            let capTop    = (insets?.top)!
            let capLeft   = (insets?.left)!
            let capBottom = (insets?.bottom)!
            let capRight  = (insets?.right)!;
            
            let centerSize = CGSize(width: rect.size.width - capLeft - capRight,
                                    height: rect.size.height - capTop - capBottom);
            
            // top row
            self.drawImage(theImage: imageSlices.slice[CPTSlice.topLeft.rawValue]!,
                           inContext:context,
                           rect:CGRect(x: 0.0, y: rect.size.height - capTop, width: capLeft, height: capTop),
                           scaleRatio:scaleRatio)
            
            self.drawImage(theImage: imageSlices.slice[CPTSlice.top.rawValue]!,
                           inContext:context,
                           rect:CGRect(x: capLeft, y: rect.size.height - capTop, width: centerSize.width, height: capTop),
                           scaleRatio:scaleRatio)
            
            self.drawImage(theImage: imageSlices.slice[CPTSlice.topRight.rawValue]!,
                           inContext:context,
                           rect:CGRect(x: rect.size.width - capRight, y: rect.size.height - capTop, width: capRight, height: capTop),
                           scaleRatio:scaleRatio)
            
            // middle row
            
            self.drawImage(theImage: imageSlices.slice[CPTSlice.left.rawValue]!,
                           inContext:context,
                           rect:CGRect(x: 0.0, y: capBottom, width: capLeft, height: centerSize.height),
                           scaleRatio:scaleRatio)
            
            self.drawImage(theImage: imageSlices.slice[CPTSlice.middle.rawValue]!,
                           inContext:context,
                           rect:CGRect(x: capLeft, y: capBottom, width: centerSize.width, height: centerSize.height),
                           scaleRatio:scaleRatio)
            
            self.drawImage(theImage: imageSlices.slice[CPTSlice.right.rawValue]!,
                           inContext:context,
                           rect:CGRect(x: rect.size.width - capRight, y: capBottom, width: capRight, height: centerSize.height),
                           scaleRatio:scaleRatio)
            
            // bottom row
            self.drawImage(theImage: imageSlices.slice[CPTSlice.bottomLeft.rawValue]!,
                           inContext:context,
                           rect:CGRect(x: 0.0, y: 0.0, width: capLeft, height: capBottom),
                           scaleRatio:scaleRatio)
            
            self.drawImage(theImage: imageSlices.slice[CPTSlice.bottom.rawValue]!,
                           inContext:context,
                           rect:CGRect(x: capLeft, y: 0.0, width: centerSize.width, height: capBottom),
                           scaleRatio:scaleRatio)
            
            self.drawImage(theImage: imageSlices.slice[CPTSlice.bottomRight.rawValue]!,
                           inContext:context,
                           rect:CGRect(x: rect.size.width - capRight, y: 0.0, width: capRight, height: capBottom),
                           scaleRatio:scaleRatio)
        }
        
        self.lastDrawnScale = contextScale;
    }
    
}
