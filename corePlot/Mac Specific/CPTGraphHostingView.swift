//
//  CPTGraphHostingView.swift
//  corePlot
//
//  Created by thierryH24 on 09/11/2020.
//

import Cocoa

//static void *CPTGraphHostingViewKVOContext = (void *)&CPTGraphHostingViewKVOContext;

class CPTGraphHostingView: NSView {
    
    var hostedGraph :  CPTGraph?
    var printRect = NSRect.zero
    var closedHandCursor = NSCursor.closedHand
    var openHandCursor = NSCursor.openHand
    var  allowPinchScaling = false
    
    var locationInWindow = NSPoint.zero
    var scrollOffset = CGPoint.zero
    

    func commonInit() {
    
        self.hostedGraph = nil
        self.printRect   = .zero

        self.closedHandCursor  = NSCursor.closedHand
        self.openHandCursor    = NSCursor.openHand
        self.allowPinchScaling = true

        self.locationInWindow = NSPoint.zero
        self.scrollOffset     = CGPoint.zero

        if CPTGraphHostingView.instancesRespond(to: #selector(getter: NSAppearanceCustomization.effectiveAppearance)) {
            addObserver(
                self,
                forKeyPath: "effectiveAppearance",
                options: [.new, .old, .initial],
                context: CPTGraphHostingViewKVOContext)
        }
        

        if ( !self.superview!.wantsLayer ) {
            self.layer = self.makeBackingLayer()
        }
        
    }
    
    override init(frame: NSRect) {
        super.init(frame: frame)
            commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func makeBackingLayer() ->CALayer
    {
        return CPTLayer(frame: self.bounds)
    }


    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        if (( self.hostedGraph ) != nil) {
            if ( !NSGraphicsContext.currentContextDrawingToScreen() ) {
                self.viewDidChangeBackingProperties()

                let graphicsContext = NSGraphicsContext.current;

                graphicsContext!.saveGraphicsState()

                let sourceRect      = NSRectToCGRect(self.frame);
                var destinationRect = NSRectToCGRect(self.printRect);
                if ( destinationRect.equalTo(CGRect())) {
                    destinationRect = sourceRect;
                }

                // scale the view isotropically so that it fits on the printed page
                let widthScale  = (sourceRect.size.width != CGFloat(0.0)) ? destinationRect.size.width / sourceRect.size.width : CGFloat(1.0);
                let heightScale = (sourceRect.size.height != CGFloat(0.0)) ? destinationRect.size.height / sourceRect.size.height : CGFloat(1.0);
                let scale       = min(widthScale, heightScale);

                // position the view so that its centered on the printed page
                var offset = destinationRect.origin;
                offset.x += ((destinationRect.size.width - (sourceRect.size.width * scale)) / CGFloat(2.0));
                offset.y += ((destinationRect.size.height - (sourceRect.size.height * scale)) / CGFloat(2.0));

                let transform = NSAffineTransform(transform)
                transform.translateXBy(offset.x, yBy:offset.y)
                transform (scaleBy:scale)
                transform (concat)

                // render CPTLayers recursively into the graphics context used for printing
                // (thanks to Brad for the tip: https://stackoverflow.com/a/2791305/132867 )
                let context = graphicsContext?.cgContext
                self.hostedGraph?.recursivelyRenderInContext(context:context!)

                graphicsContext?.restoreGraphicsState()
            }
        }
    }
    
// MARK: - Printing
//
//    /// @cond
//
//    -(BOOL)knowsPageRange:(nonnull NSRangePointer)rangePointer
//    {
//        rangePointer->location = 1;
//        rangePointer->length   = 1;
//
//        return YES;
//    }
//
//    -(NSRect)rectForPage:(NSInteger __unused)pageNumber
//    {
//        return self.printRect;
//    }
    
// MARK: -Mouse handling
//
//    /// @cond
//
//    -(BOOL)acceptsFirstMouse:(nullable NSEvent *__unused)theEvent
//    {
//        return YES;
//    }
//
//    -(void)mouseDown:(nonnull NSEvent *)theEvent
//    {
//        [super mouseDown:theEvent];
//
//        CPTGraph *theGraph = self.hostedGraph;
//        BOOL handled       = NO;
//
//        if ( theGraph ) {
//            CGPoint pointOfMouseDown   = NSPointToCGPoint([self convertPoint:theEvent.locationInWindow fromView:nil]);
//            CGPoint pointInHostedGraph = [self.layer convertPoint:pointOfMouseDown toLayer:theGraph];
//            handled = [theGraph pointingDeviceDownEvent:theEvent atPoint:pointInHostedGraph];
//        }
//
//        if ( !handled ) {
//            [self.nextResponder mouseDown:theEvent];
//        }
//    }
//
//    -(void)mouseDragged:(nonnull NSEvent *)theEvent
//    {
//        CPTGraph *theGraph = self.hostedGraph;
//        BOOL handled       = NO;
//
//        if ( theGraph ) {
//            CGPoint pointOfMouseDrag   = NSPointToCGPoint([self convertPoint:theEvent.locationInWindow fromView:nil]);
//            CGPoint pointInHostedGraph = [self.layer convertPoint:pointOfMouseDrag toLayer:theGraph];
//            handled = [theGraph pointingDeviceDraggedEvent:theEvent atPoint:pointInHostedGraph];
//        }
//
//        if ( !handled ) {
//            [self.nextResponder mouseDragged:theEvent];
//        }
//    }
//
//    -(void)mouseUp:(nonnull NSEvent *)theEvent
//    {
//        CPTGraph *theGraph = self.hostedGraph;
//        BOOL handled       = NO;
//
//        if ( theGraph ) {
//            CGPoint pointOfMouseUp     = NSPointToCGPoint([self convertPoint:theEvent.locationInWindow fromView:nil]);
//            CGPoint pointInHostedGraph = [self.layer convertPoint:pointOfMouseUp toLayer:theGraph];
//            handled = [theGraph pointingDeviceUpEvent:theEvent atPoint:pointInHostedGraph];
//        }
//
//        if ( !handled ) {
//            [self.nextResponder mouseUp:theEvent];
//        }
//    }


    // MARK: -Trackpad handling
//    -(void)magnifyWithEvent:(nonnull NSEvent *)event
//    {
//        CPTGraph *theGraph = self.hostedGraph;
//        BOOL handled       = NO;
//
//        if ( theGraph && self.allowPinchScaling ) {
//            CGPoint pointOfMagnification = NSPointToCGPoint([self convertPoint:event.locationInWindow fromView:nil]);
//            CGPoint pointInHostedGraph   = [self.layer convertPoint:pointOfMagnification toLayer:theGraph];
//            CGPoint pointInPlotArea      = [theGraph convertPoint:pointInHostedGraph toLayer:theGraph.plotAreaFrame.plotArea];
//
//            CGFloat scale = event.magnification + CPTFloat(1.0);
//
//            for ( CPTPlotSpace *space in theGraph.allPlotSpaces ) {
//                if ( space.allowsUserInteraction ) {
//                    [space scaleBy:scale aboutPoint:pointInPlotArea];
//                    handled = YES;
//                }
//            }
//        }
//
//        if ( !handled ) {
//            [self.nextResponder magnifyWithEvent:event];
//        }
//    }
//
//    -(void)scrollWheel:(nonnull NSEvent *)theEvent
//    {
//        CPTGraph *theGraph = self.hostedGraph;
//        BOOL handled       = NO;
//
//        if ( theGraph ) {
//            switch ( theEvent.phase ) {
//                case NSEventPhaseBegan: // Trackpad with no momentum scrolling. Fingers moved on trackpad.
//                {
//                    self.locationInWindow = theEvent.locationInWindow;
//                    self.scrollOffset     = CGPointZero;
//
//                    CGPoint pointOfMouseDown   = NSPointToCGPoint([self convertPoint:self.locationInWindow fromView:nil]);
//                    CGPoint pointInHostedGraph = [self.layer convertPoint:pointOfMouseDown toLayer:theGraph];
//                    handled = [theGraph pointingDeviceDownEvent:theEvent atPoint:pointInHostedGraph];
//                }
//                // Fall through
//
//                case NSEventPhaseChanged:
//                {
//                    CGPoint offset = self.scrollOffset;
//                    offset.x         += theEvent.scrollingDeltaX;
//                    offset.y         -= theEvent.scrollingDeltaY;
//                    self.scrollOffset = offset;
//
//                    NSPoint scrolledPointOfMouse = self.locationInWindow;
//                    scrolledPointOfMouse.x += offset.x;
//                    scrolledPointOfMouse.y += offset.y;
//
//                    CGPoint pointOfMouseDrag   = NSPointToCGPoint([self convertPoint:scrolledPointOfMouse fromView:nil]);
//                    CGPoint pointInHostedGraph = [self.layer convertPoint:pointOfMouseDrag toLayer:theGraph];
//                    handled = handled || [theGraph pointingDeviceDraggedEvent:theEvent atPoint:pointInHostedGraph];
//                }
//                break;
//
//                case NSEventPhaseEnded:
//                {
//                    CGPoint offset = self.scrollOffset;
//
//                    NSPoint scrolledPointOfMouse = self.locationInWindow;
//                    scrolledPointOfMouse.x += offset.x;
//                    scrolledPointOfMouse.y += offset.y;
//
//                    CGPoint pointOfMouseUp     = NSPointToCGPoint([self convertPoint:scrolledPointOfMouse fromView:nil]);
//                    CGPoint pointInHostedGraph = [self.layer convertPoint:pointOfMouseUp toLayer:theGraph];
//                    handled = [theGraph pointingDeviceUpEvent:theEvent atPoint:pointInHostedGraph];
//                }
//                break;
//
//                case NSEventPhaseNone:
//                    if ( theEvent.momentumPhase == NSEventPhaseNone ) {
//                        // Mouse wheel
//                        CGPoint startLocation      = theEvent.locationInWindow;
//                        CGPoint pointOfMouse       = NSPointToCGPoint([self convertPoint:startLocation fromView:nil]);
//                        CGPoint pointInHostedGraph = [self.layer convertPoint:pointOfMouse toLayer:theGraph];
//
//                        CGPoint scrolledLocationInWindow = startLocation;
//                        if ( theEvent.hasPreciseScrollingDeltas ) {
//                            scrolledLocationInWindow.x += theEvent.scrollingDeltaX;
//                            scrolledLocationInWindow.y -= theEvent.scrollingDeltaY;
//                        }
//                        else {
//                            scrolledLocationInWindow.x += theEvent.scrollingDeltaX * CPTFloat(10.0);
//                            scrolledLocationInWindow.y -= theEvent.scrollingDeltaY * CPTFloat(10.0);
//                        }
//                        CGPoint scrolledPointOfMouse       = NSPointToCGPoint([self convertPoint:scrolledLocationInWindow fromView:nil]);
//                        CGPoint scrolledPointInHostedGraph = [self.layer convertPoint:scrolledPointOfMouse toLayer:theGraph];
//
//                        handled = [theGraph scrollWheelEvent:theEvent fromPoint:pointInHostedGraph toPoint:scrolledPointInHostedGraph];
//                    }
//                    break;
//
//                default:
//                    break;
//            }
//        }
//
//        if ( !handled ) {
//            [self.nextResponder scrollWheel:theEvent];
//        }
//    }
//
//    /// @endcond
//
//    #pragma mark -
//    #pragma mark HiDPI display support
//
//    /// @cond
//
//    -(void)viewDidChangeBackingProperties
//    {
//        [super viewDidChangeBackingProperties];
//
//        NSWindow *myWindow = self.window;
//
//        if ( myWindow ) {
//            self.layer.contentsScale = myWindow.backingScaleFactor;
//        }
//        else {
//            self.layer.contentsScale = CPTFloat(1.0);
//        }
//    }
//
//
//
}
