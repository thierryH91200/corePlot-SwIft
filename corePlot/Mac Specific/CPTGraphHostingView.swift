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
                let scale     = min(widthScale, heightScale);

                // position the view so that its centered on the printed page
                var offset = destinationRect.origin;
                offset.x += ((destinationRect.size.width - (sourceRect.size.width * scale)) / CGFloat(2.0));
                offset.y += ((destinationRect.size.height - (sourceRect.size.height * scale)) / CGFloat(2.0));

                let transform = NSAffineTransform()
                transform.translateX(by: offset.x, yBy:offset.y)
                transform.scale(by: scale)
                transform.concat()

                // render CPTLayers recursively into the graphics context used for printing
                // (thanks to Brad for the tip: https://stackoverflow.com/a/2791305/132867 )
                let context = graphicsContext?.cgContext
                self.hostedGraph?.recursivelyRenderInContext(context:context!)

                graphicsContext?.restoreGraphicsState()
            }
        }
    }
    
// MARK: - Printing
    override func knowsPageRange(_ range: NSRangePointer) -> Bool {
        var rangeOut = NSRange(location: 0, length: 0)

        // Pages are 1-based. That is, the first page is 1.
        rangeOut.location = 1
        rangeOut.length = 1 // Number of pages

        // Return the newly constructed range, rangeOut, via the range pointer
        range.pointee = rangeOut // Cannot assign to property: 'range' is a 'let' constant

        return true
    }
    
    override func rectForPage(_ pageNumber: Int) -> NSRect {
        guard let pi = NSPrintOperation.current?.printInfo else{return CGRect.zero}

        let paperSize = pi.paperSize // Calculate the page dimensions in points
        // Convert dimensions to the scaled view

        let dict = pi.dictionary()
        let pageScale = dict[NSPrintInfo.AttributeKey.scalingFactor] as! CGFloat

        let topMargin = pi.topMargin
        let  leftMargin = pi.leftMargin
        let bottomMargin = pi.bottomMargin
        let rightMargin = pi.rightMargin
        let pageHeight = (paperSize.height - topMargin - bottomMargin) / pageScale
        let pageWidth = (paperSize.width - leftMargin - rightMargin) / pageScale
        let bounds = self.bounds
        let actualPageRect = NSRect(x: NSMinX(bounds), y:  NSMinY(bounds), width: pageWidth * pageScale, height: pageHeight * pageScale)

        return actualPageRect
    }
    
// MARK: -Mouse handling
    func acceptsFirstMouse(theEvent: NSEvent )-> Bool
    {
        return true
    }

    override func mouseDown(with theEvent: NSEvent) {
        super.mouseDown(with: theEvent)
        
        let theGraph = hostedGraph
        var handled = false
        
        if let theGraph = theGraph {
            let pointOfMouseDown = NSPointToCGPoint(convert(theEvent.locationInWindow, from: nil))
            let pointInHostedGraph = layer?.convert(pointOfMouseDown, to: theGraph)
            handled = theGraph.pointingDeviceDownEvent(event: theEvent, interactionPoint: pointInHostedGraph!)
        }
        
        if handled == false {
            nextResponder?.mouseDown(with: theEvent)
        }
    }
    
    override func mouseDragged(with theEvent: NSEvent )
    {
        let theGraph = self.hostedGraph;
        var handled       = false;
        
        if let theGraph =  theGraph {
            let pointOfMouseDrag   = NSPointToCGPoint(self.convert(theEvent.locationInWindow, from:nil))
            let  pointInHostedGraph = self.layer?.convert(pointOfMouseDrag, to: theGraph)
            handled = theGraph.pointingDeviceDraggedEvent(event: theEvent, atPoint:pointInHostedGraph!)
        }
        
        if ( !handled == false) {
            self.nextResponder?.mouseDragged(with: theEvent)
        }
    }

    override func mouseUp(with theEvent: NSEvent )
    {
        let theGraph = self.hostedGraph
        var handled       = false;

        if let theGraph =  theGraph {
            let pointOfMouseUp     = NSPointToCGPoint( self.convert(theEvent.locationInWindow, from:nil))
            let pointInHostedGraph = self.layer?.convert(pointOfMouseUp, to: theGraph)
            handled = theGraph.pointingDeviceUpEvent(event: theEvent, atPoint:pointInHostedGraph!)
        }

        if ( handled == false ) {
            self.nextResponder?.mouseUp(with: theEvent)
        }
    }


    // MARK: -Trackpad handling
    override func magnify(with event: NSEvent )
    {
        let theGraph = self.hostedGraph
        var handled       = false;

        if let theGraph = theGraph , self.allowPinchScaling == true {
            let pointOfMagnification = NSPointToCGPoint(self.convert(event.locationInWindow, from:nil))
            let pointInHostedGraph   = self.layer?.convert(pointOfMagnification, to: theGraph)
            let pointInPlotArea      = theGraph.convert(pointInHostedGraph!, to:theGraph.plotAreaFrame.plotArea)

            let scale = event.magnification + CGFloat(1.0)

            for space in theGraph.allPlotSpaces() {
                if space.allowsUserInteraction! {
                    space.scale(by: scale, aboutPoint:pointInPlotArea)
                    handled = true
                }
            }
        }

        if handled == false {
            self.nextResponder?.magnify(with: event)
        }
    }

    override func scrollWheel(with theEvent: NSEvent )
    {
        let theGraph = self.hostedGraph
        var handled       = false;
        
        if let theGraph =  theGraph {
            switch ( theEvent.phase ) {
            case .began: // Trackpad with no momentum scrolling. Fingers moved on trackpad.
                self.locationInWindow = theEvent.locationInWindow;
                self.scrollOffset     = CGPoint()
                
                let pointOfMouseDown   = NSPointToCGPoint( self.convert(self.locationInWindow, from:nil))
                let pointInHostedGraph = self.layer?.convert(pointOfMouseDown, to:theGraph)
                handled = theGraph.pointingDeviceDownEvent(event: theEvent, atPoint:pointInHostedGraph!)
            
            case .changed:
                var offset = self.scrollOffset;
                offset.x         += theEvent.scrollingDeltaX;
                offset.y         -= theEvent.scrollingDeltaY;
                self.scrollOffset = offset;
                
                var scrolledPointOfMouse = self.locationInWindow;
                scrolledPointOfMouse.x += offset.x;
                scrolledPointOfMouse.y += offset.y;
                
                let pointOfMouseDrag   = NSPointToCGPoint(self.convert(scrolledPointOfMouse, from:nil))
                let pointInHostedGraph = self.layer?.convert(pointOfMouseDrag, to:theGraph)
                handled = handled || theGraph.pointingDeviceDraggedEvent(event: theEvent, atPoint:pointInHostedGraph!)
                
            case .ended:
                var offset = self.scrollOffset;
                
                var scrolledPointOfMouse = self.locationInWindow;
                scrolledPointOfMouse.x += offset.x;
                scrolledPointOfMouse.y += offset.y;
                
                let pointOfMouseUp     = NSPointToCGPoint( self.convert(scrolledPointOfMouse, from:nil))
                let pointInHostedGraph = self.layer?.convert(pointOfMouseUp, to:theGraph)
                handled = theGraph.pointingDeviceUpEvent(event: theEvent, atPoint:pointInHostedGraph!)
                
            case [] :
                if ( theEvent.momentumPhase == [] ) {
                    // Mouse wheel
                    let startLocation      = theEvent.locationInWindow
                    let pointOfMouse       = NSPointToCGPoint(self.convert(startLocation, from:nil))
                    let pointInHostedGraph = self.layer?.convert(pointOfMouse, to: theGraph)
                    
                    var scrolledLocationInWindow = startLocation;
                    if ( theEvent.hasPreciseScrollingDeltas ) {
                        scrolledLocationInWindow.x += theEvent.scrollingDeltaX;
                        scrolledLocationInWindow.y -= theEvent.scrollingDeltaY;
                    }
                    else {
                        scrolledLocationInWindow.x += theEvent.scrollingDeltaX * CGFloat(10.0);
                        scrolledLocationInWindow.y -= theEvent.scrollingDeltaY * CGFloat(10.0);
                    }
                    let scrolledPointOfMouse       = NSPointToCGPoint(self.convert(scrolledLocationInWindow, from:nil))
                    let scrolledPointInHostedGraph = self.layer?.convert(scrolledPointOfMouse, to:theGraph)
                    
                    handled = theGraph.scrollWheelEvent( theEvent, fromPoint:pointInHostedGraph!, toPoint:scrolledPointInHostedGraph!)
                }
                
            default:
                break;
            }
        }
        
        if ( !handled ) {
            self.nextResponder?.scrollWheel(with: theEvent)
        }
    }
    

    // MARK: - HiDPI display support
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
