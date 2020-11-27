//
//  CPTImage.swift
//  corePlot
//
//  Created by thierryH24 on 07/11/2020.
//

import Cocoa

class CPTImage: NSObject {
    
    enum CPTSlice : Int {
        case topLeft = 0 ///< Top left corner
        case top ///< Top middle
        case topRight ///< Top right corner
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
    var tiled = false
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
        tiled                 = false
        tileAnchoredToContext = true;
        edgeInsets            = NSEdgeInsetsZero
    }
    
    convenience init( anImage: CGImage)
    {
        self.init(anImage: anImage, newScale:CGFloat(1.0))
    }
    
    override init()
    {
        //        self.init(anImage: nil)
    }
    
    // MARK: - Factory Methods
    
    init(name:String)
    {
         [self imageWithNativeImage:[CPTNativeImage imageNamed:name]];
    }
    
    /** @brief Initializes a CPTImage instance with the provided platform-native image.
     *
     *  @param anImage The platform-native image.
     *  @return A new CPTImage instance initialized with the provided image.
     **/
    func imageWithNativeImage(anImage:  CPTNativeImage)
    {
    return [[self alloc] initWithNativeImage:anImage];
    }
    
    /** @brief Initializes a CPTImage instance with the contents of a file.
     *
     *  @param path The full or partial path to the image file.
     *  @return A new CPTImage instance initialized from the file at the given path.
     **/
    +(nonnull instancetype)imageWithContentsOfFile:(nonnull NSString *)path
    {
    return [[self alloc] initWithContentsOfFile:path];
    }
    
    /** @brief Creates and returns a new CPTImage instance initialized with the provided @ref CGImageRef.
     *  @param anImage The image to wrap.
     *  @param newScale The image scale.
     *  @return A new CPTImage instance initialized with the provided @ref CGImageRef.
     **/
    +(nonnull instancetype)imageWithCGImage:(nullable CGImageRef)anImage scale:(CGFloat)newScale
    {
    return [[self alloc] initWithCGImage:anImage scale:newScale];
    }
    
    /** @brief Creates and returns a new CPTImage instance initialized with the provided @ref CGImageRef and scale @num{1.0}.
     *  @param anImage The image to wrap.
     *  @return A new CPTImage instance initialized with the provided @ref CGImageRef.
     **/
    +(nonnull instancetype)imageWithCGImage:(nullable CGImageRef)anImage
    {
    return [self imageWithCGImage:anImage scale:CPTFloat(1.0)];
    }
    
    /** @brief Creates and returns a new CPTImage instance initialized with the contents of a PNG file.
     *
     *  On systems that support hi-dpi or @quote{Retina} displays, this method will look for a
     *  double-resolution image with the given name followed by @quote{@2x}. If the @quote{@2x} image
     *  is not available, the named image file will be loaded.
     *
     *  @param path The file system path of the file.
     *  @return A new CPTImage instance initialized with the contents of the PNG file.
     **/
    +(nonnull instancetype)imageForPNGFile:(nonnull NSString *)path
    {
    return [[self alloc] initForPNGFile:path];
    }
    
    #pragma mark -
    #pragma mark Image comparison
    
    /// @name Comparison
    /// @{
    
    /** @brief Returns a boolean value that indicates whether the received is equal to the given object.
     *  Images are equal if they have the same @ref scale, @ref tiled, @ref tileAnchoredToContext, image size, color space, bit depth, and image data.
     *  @param object The object to be compared with the receiver.
     *  @return @YES if @par{object} is equal to the receiver, @NO otherwise.
     **/
    -(BOOL)isEqual:(nullable id)object
    {
    if ( self == object ) {return true }
    
    else if ( [object isKindOfClass:[self class]] ) {
    CPTImage *otherImage = (CPTImage *)object;
    
    BOOL equalImages = (self.scale == otherImage.scale) &&
    (self.tiled == otherImage.tiled) &&
    (self.tileAnchoredToContext == otherImage.tileAnchoredToContext) &&
    CPTEdgeInsetsEqualToEdgeInsets(self.edgeInsets, otherImage.edgeInsets);
    
    CGImageRef selfCGImage  = self.image;
    CGImageRef otherCGImage = otherImage.image;
    
    CGColorSpaceRef selfColorSpace  = CGImageGetColorSpace(selfCGImage);
    CGColorSpaceRef otherColorSpace = CGImageGetColorSpace(otherCGImage);
    
    if ( equalImages ) {
    equalImages = (CGImageGetWidth(selfCGImage) == CGImageGetWidth(otherCGImage));
    }
    
    if ( equalImages ) {
    equalImages = (CGImageGetHeight(selfCGImage) == CGImageGetHeight(otherCGImage));
    }
    
    if ( equalImages ) {
    equalImages = (CGImageGetBitsPerComponent(selfCGImage) == CGImageGetBitsPerComponent(otherCGImage));
    }
    
    if ( equalImages ) {
    equalImages = (CGImageGetBitsPerPixel(selfCGImage) == CGImageGetBitsPerPixel(otherCGImage));
    }
    
    if ( equalImages ) {
    equalImages = (CGImageGetBytesPerRow(selfCGImage) == CGImageGetBytesPerRow(otherCGImage));
    }
    
    if ( equalImages ) {
    equalImages = (CGImageGetBitmapInfo(selfCGImage) == CGImageGetBitmapInfo(otherCGImage));
    }
    
    if ( equalImages ) {
    equalImages = (CGImageGetShouldInterpolate(selfCGImage) == CGImageGetShouldInterpolate(otherCGImage));
    }
    
    if ( equalImages ) {
    equalImages = (CGImageGetRenderingIntent(selfCGImage) == CGImageGetRenderingIntent(otherCGImage));
    }
    
    // decode array
    if ( equalImages ) {
    const CGFloat *selfDecodeArray  = CGImageGetDecode(selfCGImage);
    const CGFloat *otherDecodeArray = CGImageGetDecode(otherCGImage);
    
    if ( selfDecodeArray && otherDecodeArray ) {
    size_t numberOfComponentsSelf  = CGColorSpaceGetNumberOfComponents(selfColorSpace) * 2;
    size_t numberOfComponentsOther = CGColorSpaceGetNumberOfComponents(otherColorSpace) * 2;
    
    if ( numberOfComponentsSelf == numberOfComponentsOther ) {
    for ( size_t i = 0; i < numberOfComponentsSelf; i++ ) {
    if ( selfDecodeArray[i] != otherDecodeArray[i] ) {
    equalImages = NO;
    break;
    }
    }
    }
    else {
    equalImages = NO;
    }
    }
    else if ((selfDecodeArray && !otherDecodeArray) || (!selfDecodeArray && otherDecodeArray)) {
    equalImages = NO;
    }
    }
    
    // color space
    if ( equalImages ) {
    equalImages = (CGColorSpaceGetModel(selfColorSpace) == CGColorSpaceGetModel(otherColorSpace)) &&
    (CGColorSpaceGetNumberOfComponents(selfColorSpace) == CGColorSpaceGetNumberOfComponents(otherColorSpace));
    }
    
    // data provider
    if ( equalImages ) {
    CGDataProviderRef selfProvider  = CGImageGetDataProvider(selfCGImage);
    CFDataRef selfProviderData      = CGDataProviderCopyData(selfProvider);
    CGDataProviderRef otherProvider = CGImageGetDataProvider(otherCGImage);
    CFDataRef otherProviderData     = CGDataProviderCopyData(otherProvider);
    
    if ( selfProviderData && otherProviderData ) {
    equalImages = [(__bridge NSData *) selfProviderData isEqualToData:(__bridge NSData *)otherProviderData];
    }
    else {
    equalImages = (selfProviderData == otherProviderData);
    }
    
    if ( selfProviderData ) {
    CFRelease(selfProviderData);
    }
    if ( otherProviderData ) {
    CFRelease(otherProviderData);
    }
    }
    
    return equalImages;
    }
    else {
    return NO;
    }
    }
    
    /// @}
    
    /// @cond
    
    -(NSUInteger)hash
    {
    // Equal objects must hash the same.
    CGImageRef selfCGImage = self.image;
    
    return (CGImageGetWidth(selfCGImage) * CGImageGetHeight(selfCGImage)) +
    CGImageGetBitsPerComponent(selfCGImage) +
    CGImageGetBitsPerPixel(selfCGImage) +
    CGImageGetBytesPerRow(selfCGImage) +
    CGImageGetBitmapInfo(selfCGImage) +
    CGImageGetShouldInterpolate(selfCGImage) +
    (NSUInteger)(CGImageGetRenderingIntent(selfCGImage) * self.scale);
    }
    
    /// @endcond
    
    #pragma mark -
    #pragma mark Opacity
    
    /// @cond
    
    var isOpaque
    {
    return false;
    }
    
    /// @endcond
    
    #pragma mark -
    #pragma mark Accessors
    
    /// @cond
    
    -(void)setImage:(nullable CGImageRef)newImage
    {
    if ( newImage != image ) {
    CGImageRetain(newImage);
    CGImageRelease(image);
    image = newImage;
    }
    }
    
    -(void)setNativeImage:(nullable CPTNativeImage *)newImage
    {
    if ( newImage != nativeImage ) {
    nativeImage = [newImage copy];
    
    self.image = NULL;
    }
    }
    
    -(nullable CPTNativeImage *)nativeImage
    {
    if ( !nativeImage ) {
    CGImageRef imageRef = self.image;
    
    #if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
    CGFloat theScale = self.scale;
    
    if ( imageRef && (theScale > CPTFloat(0.0))) {
    nativeImage = [UIImage imageWithCGImage:imageRef
    scale:theScale
    orientation:UIImageOrientationUp];
    }
    #else
    if ( [NSImage instancesRespondToSelector:@selector(initWithCGImage:size:)] ) {
    nativeImage = [[NSImage alloc] initWithCGImage:imageRef size:NSZeroSize];
    }
    else {
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    
    NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
    pixelsWide:(NSInteger)imageSize.width
    pixelsHigh:(NSInteger)imageSize.height
    bitsPerSample:8
    samplesPerPixel:4
    hasAlpha:YES
    isPlanar:NO
    colorSpaceName:NSCalibratedRGBColorSpace
    bytesPerRow:(NSInteger)imageSize.width * 4
    bitsPerPixel:32];
    
    NSGraphicsContext *bitmapContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:imageRep];
    CGContextRef context             = (CGContextRef)bitmapContext.graphicsPort;
    
    CGContextDrawImage(context, CPTRectMake(0.0, 0.0, imageSize.width, imageSize.height), imageRef);
    
    nativeImage = [[NSImage alloc] initWithSize:NSSizeFromCGSize(imageSize)];
    [nativeImage addRepresentation:imageRep];
    }
    #endif
    }
    
    return nativeImage;
    }
    
    -(void)setScale:(CGFloat)newScale
    {
    NSParameterAssert(newScale > CPTFloat(0.0));
    
    if ( newScale != scale ) {
    scale = newScale;
    }
    }
    
    func setEdgeInsets(newEdgeInsets : CPTEdgeInsets)
    {
        
        if NSEdgeInsetsEqual(NSEdgeInsetsEqual,newEdgeInsets) == false {
            edgeInsets = newEdgeInsets;
        }
    
    var imageSlices = CPTImageSlices
    
    for ( NSUInteger i = 0; i < 9; i++ ) {
    imageSlices.slice[i] = NULL;
    }
    
    self.slices = imageSlices;
    }
    }
    
func setSlices(newSlices: CPTImageSlices)
{
    for ( i in 0..<9) {
        CGImageRelease(slices.slice[i]);
        
        CGImageRef slice = CGImageRetain(newSlices.slice[i]);
        if ( slice ) {
            slices.slice[i] = slice;
        }
    }
}
    
    /// @endcond
    
    #pragma mark -
    #pragma mark Drawing
    
    /// @cond
    
//    -(void)makeImageSlices
//    {
//    CGImageRef theImage = self.image;
//    
//    CGFloat width  = CGImageGetWidth(theImage);
//    CGFloat height = CGImageGetHeight(theImage);
//    
//    CGFloat imageScale   = self.scale;
//    CPTEdgeInsets insets = self.edgeInsets;
//    
//    CGFloat capTop    = insets.top * imageScale;
//    CGFloat capLeft   = insets.left * imageScale;
//    CGFloat capBottom = insets.bottom * imageScale;
//    CGFloat capRight  = insets.right * imageScale;
//    
//    CGSize centerSize = CGSizeMake(width - capLeft - capRight,
//    height - capTop - capBottom);
//    
//    CPTImageSlices imageSlices = {};
//    
//    for ( NSUInteger i = 0; i < 9; i++ ) {
//    imageSlices.slice[i] = NULL;
//    }
//    
//    // top row
//    if ( capTop > CPTFloat(0.0)) {
//    if ( capLeft > CPTFloat(0.0)) {
//    CGImageRef sliceImage = CGImageCreateWithImageInRect(theImage, CPTRectMake(0.0, 0.0, capLeft, capTop));
//    imageSlices.slice[CPTSliceTopLeft] = sliceImage;
//    }
//    
//    if ( centerSize.width > CPTFloat(0.0)) {
//    CGImageRef sliceImage = CGImageCreateWithImageInRect(theImage, CPTRectMake(capLeft, 0.0, centerSize.width, capTop));
//    imageSlices.slice[CPTSliceTop] = sliceImage;
//    }
//    
//    if ( capRight > CPTFloat(0.0)) {
//    CGImageRef sliceImage = CGImageCreateWithImageInRect(theImage, CPTRectMake(width - capRight, 0.0, capRight, capTop));
//    imageSlices.slice[CPTSliceTopRight] = sliceImage;
//    }
//    }
//    
//    // middle row
//    if ( centerSize.height > CPTFloat(0.0)) {
//    if ( capLeft > CPTFloat(0.0)) {
//    CGImageRef sliceImage = CGImageCreateWithImageInRect(theImage, CPTRectMake(0.0, capTop, capLeft, centerSize.height));
//    imageSlices.slice[CPTSliceLeft] = sliceImage;
//    }
//    
//    if ( centerSize.width > CPTFloat(0.0)) {
//    CGImageRef sliceImage = CGImageCreateWithImageInRect(theImage, CPTRectMake(capLeft, capTop, centerSize.width, centerSize.height));
//    imageSlices.slice[CPTSliceMiddle] = sliceImage;
//    }
//    
//    if ( capRight > CPTFloat(0.0)) {
//    CGImageRef sliceImage = CGImageCreateWithImageInRect(theImage, CPTRectMake(width - capRight, capTop, capRight, centerSize.height));
//    imageSlices.slice[CPTSliceRight] = sliceImage;
//    }
//    }
//    
//    // bottom row
//    if ( capBottom > CPTFloat(0.0)) {
//    if ( capLeft > CPTFloat(0.0)) {
//    CGImageRef sliceImage = CGImageCreateWithImageInRect(theImage, CPTRectMake(0.0, height - capBottom, capLeft, capBottom));
//    imageSlices.slice[CPTSliceBottomLeft] = sliceImage;
//    }
//    
//    if ( centerSize.width > CPTFloat(0.0)) {
//    CGImageRef sliceImage = CGImageCreateWithImageInRect(theImage, CPTRectMake(capLeft, height - capBottom, centerSize.width, capBottom));
//    imageSlices.slice[CPTSliceBottom] = sliceImage;
//    }
//    
//    if ( capRight > CPTFloat(0.0)) {
//    CGImageRef sliceImage = CGImageCreateWithImageInRect(theImage, CPTRectMake(width - capRight, height - capBottom, capRight, capBottom));
//    imageSlices.slice[CPTSliceBottomRight] = sliceImage;
//    }
//    }
//    
//    self.slices = imageSlices;
//    for ( NSUInteger i = 0; i < 9; i++ ) {
//    CGImageRelease(imageSlices.slice[i]);
//    }
//    }
//    
//    -(void)drawImage:(nonnull CGImageRef)theImage inContext:(nonnull CGContextRef)context rect:(CGRect)rect scaleRatio:(CGFloat)scaleRatio
//    {
//    if ( theImage && (rect.size.width > CPTFloat(0.0)) && (rect.size.height > CPTFloat(0.0))) {
//    CGFloat imageScale = self.scale;
//    
//    CGContextSaveGState(context);
//    
//    if ( self.isTiled ) {
//    CGContextClipToRect(context, rect);
//    if ( !self.tileAnchoredToContext ) {
//    CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
//    }
//    CGContextScaleCTM(context, scaleRatio, scaleRatio);
//    
//    CGRect imageBounds = CPTRectMake(0.0, 0.0, CGImageGetWidth(theImage) / imageScale, CGImageGetHeight(theImage) / imageScale);
//    
//    CGContextDrawTiledImage(context, imageBounds, theImage);
//    }
//    else {
//    CGContextScaleCTM(context, scaleRatio, scaleRatio);
//    CGContextDrawImage(context, rect, theImage);
//    }
//    
//    CGContextRestoreGState(context);
//    }
//    }
//    
//    /// @endcond
//    
//    /** @brief Draws the image into the given graphics context.
//     *
//     *  If the tiled property is @YES, the image is repeatedly drawn to fill the clipping region, otherwise the image is
//     *  scaled to fit in @par{rect}.
//     *
//     *  @param rect The rectangle to draw into.
//     *  @param context The graphics context to draw into.
//     **/
//    -(void)drawInRect:(CGRect)rect inContext:(nonnull CGContextRef)context
//    {
//    CGImageRef theImage = self.image;
//    
//    // compute drawing scale
//    CGFloat lastScale    = self.lastDrawnScale;
//    CGFloat contextScale = CPTFloat(1.0);
//    
//    if ( rect.size.height != CPTFloat(0.0)) {
//    CGRect deviceRect = CGContextConvertRectToDeviceSpace(context, rect);
//    contextScale = deviceRect.size.height / rect.size.height;
//    }
//    
//    // generate a Core Graphics image if needed
//    if ( !theImage || (contextScale != lastScale)) {
//    CPTNativeImage *theNativeImage = self.nativeImage;
//    
//    if ( theNativeImage ) {
//    #if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
//    theImage   = theNativeImage.CGImage;
//    self.scale = theNativeImage.scale;
//    #else
//    NSSize imageSize   = theNativeImage.size;
//    NSRect drawingRect = NSMakeRect(0.0, 0.0, imageSize.width, imageSize.height);
//    
//    theImage = [theNativeImage CGImageForProposedRect:&drawingRect
//    context:[NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO]
//    hints:nil];
//    self.scale = contextScale;
//    #endif
//    self.image = theImage;
//    }
//    }
//    
//    if ( !theImage ) {
//    return;
//    }
//    
//    // draw the image
//    CGFloat imageScale = self.scale;
//    CGFloat scaleRatio = contextScale / imageScale;
//    
//    CPTEdgeInsets insets = self.edgeInsets;
//    
//    if ( CPTEdgeInsetsEqualToEdgeInsets(insets, CPTEdgeInsetsZero)) {
//    [self drawImage:theImage inContext:context rect:rect scaleRatio:scaleRatio];
//    }
//    else {
//    CPTImageSlices imageSlices = self.slices;
//    BOOL hasSlices             = NO;
//    
//    for  i in   0..<9 {
//    if ( imageSlices.slice[i] ) {
//    hasSlices = YES;
//    break;
//    }
//    }
//    
//    // create new slices if needed
//    if ( !hasSlices || (contextScale != lastScale)) {
//    [self makeImageSlices];
//    imageSlices = self.slices;
//    }
//    
//    CGFloat capTop    = insets.top;
//    CGFloat capLeft   = insets.left;
//    CGFloat capBottom = insets.bottom;
//    CGFloat capRight  = insets.right;
//    
//    CGSize centerSize = CGSizeMake(rect.size.width - capLeft - capRight,
//    rect.size.height - capTop - capBottom);
//    
//    // top row
//    [self drawImage:imageSlices.slice[CPTSliceTopLeft]
//    inContext:context
//    rect:CPTRectMake(0.0, rect.size.height - capTop, capLeft, capTop)
//    scaleRatio:scaleRatio];
//    [self drawImage:imageSlices.slice[CPTSliceTop]
//    inContext:context
//    rect:CPTRectMake(capLeft, rect.size.height - capTop, centerSize.width, capTop)
//    scaleRatio:scaleRatio];
//    [self drawImage:imageSlices.slice[CPTSliceTopRight]
//    inContext:context
//    rect:CPTRectMake(rect.size.width - capRight, rect.size.height - capTop, capRight, capTop)
//    scaleRatio:scaleRatio];
//    
//    // middle row
//    [self drawImage:imageSlices.slice[CPTSliceLeft]
//    inContext:context
//    rect:CPTRectMake(0.0, capBottom, capLeft, centerSize.height)
//    scaleRatio:scaleRatio];
//    [self drawImage:imageSlices.slice[CPTSliceMiddle]
//    inContext:context
//    rect:CPTRectMake(capLeft, capBottom, centerSize.width, centerSize.height)
//    scaleRatio:scaleRatio];
//    [self drawImage:imageSlices.slice[CPTSliceRight]
//    inContext:context
//    rect:CPTRectMake(rect.size.width - capRight, capBottom, capRight, centerSize.height)
//    scaleRatio:scaleRatio];
//    
//    // bottom row
//    [self drawImage:imageSlices.slice[CPTSliceBottomLeft]
//    inContext:context
//    rect:CPTRectMake(0.0, 0.0, capLeft, capBottom)
//    scaleRatio:scaleRatio];
//    [self drawImage:imageSlices.slice[CPTSliceBottom]
//    inContext:context
//    rect:CPTRectMake(capLeft, 0.0, centerSize.width, capBottom)
//    scaleRatio:scaleRatio];
//    [self drawImage:imageSlices.slice[CPTSliceBottomRight]
//    inContext:context
//    rect:CPTRectMake(rect.size.width - capRight, 0.0, capRight, capBottom)
//    scaleRatio:scaleRatio];
//    }
//    
//    self.lastDrawnScale = contextScale;
//    }
//    
//    #pragma mark -
//    #pragma mark Debugging
//    
//    /// @cond
//    
//    -(nullable id)debugQuickLookObject
//    {
//    return self.nativeImage;
//    }
//    
//    /// @endcond
//    
//    @end
//    
}
