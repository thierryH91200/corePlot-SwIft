//
//  CPTGraphHostingView.swift
//  corePlot
//
//  Created by thierryH24 on 09/11/2020.
//

import Cocoa

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
    
    
    override func makeBackingLayer() ->CALayer
    {
        return CPTLayer (alloc] initWithFrame:NSRectToCGRect(self.bounds)];
    }

//    -(void)encodeWithCoder:(nonnull NSCoder *)coder
//    {
//        [super encodeWithCoder:coder];
//
//        [coder encodeObject:self.hostedGraph forKey:@"CPTLayerHostingView.hostedGraph"];
//        [coder encodeRect:self.printRect forKey:@"CPTLayerHostingView.printRect"];
//        [coder encodeObject:self.closedHandCursor forKey:@"CPTLayerHostingView.closedHandCursor"];
//        [coder encodeObject:self.openHandCursor forKey:@"CPTLayerHostingView.openHandCursor"];
//        [coder encodeBool:self.allowPinchScaling forKey:@"CPTLayerHostingView.allowPinchScaling"];
//
//    }


    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        if ( self.hostedGraph ) {
            if ( ![NSGraphicsContext currentContextDrawingToScreen] ) {
                self.viewDidChangeBackingProperties

                let graphicsContext = NSGraphicsContext.current;

                graphicsContext!.saveGraphicsState

                let sourceRect      = NSRectToCGRect(self.frame);
                var destinationRect = NSRectToCGRect(self.printRect);
                if ( destinationRect.equalTo(CGRect())) {
                    destinationRect = sourceRect;
                }

                // scale the view isotropically so that it fits on the printed page
                let widthScale  = (sourceRect.size.width != CGFloat(0.0)) ? destinationRect.size.width / sourceRect.size.width : CGFloat(1.0);
                let heightScale = (sourceRect.size.height != CGFloat(0.0)) ? destinationRect.size.height / sourceRect.size.height : CGFloat(1.0);
                let scale       = MIN(widthScale, heightScale);

                // position the view so that its centered on the printed page
                let offset = destinationRect.origin;
                offset.x += ((destinationRect.size.width - (sourceRect.size.width * scale)) / CGFloat(2.0));
                offset.y += ((destinationRect.size.height - (sourceRect.size.height * scale)) / CGFloat(2.0));

                NSAffineTransform transform = [NSAffineTransform transform];
                transform.translateXBy:offset.x yBy:offset.y
                transform (scaleBy:scale)
                transform (concat)

                // render CPTLayers recursively into the graphics context used for printing
                // (thanks to Brad for the tip: https://stackoverflow.com/a/2791305/132867 )
                let context = graphicsContext.graphicsPort;
                [self.hostedGraph recursivelyRenderInContext:context];

                graphicsContext.restoreGraphicsState
            }
        }
    }
    
}
