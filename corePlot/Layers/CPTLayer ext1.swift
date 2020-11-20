//
//  CPTLayer ext1.swift
//  corePlot
//
//  Created by thierryH24 on 20/11/2020.
//

import Foundation


extension CPTLayer {
    
    // MARK: - Layout
    
    // Align the receiver&rsquo;s position with pixel boundaries.
    func pixelAlign()
    {
        let scale           = self.contentsScale
        let currentPosition = self.position
        
        let boundsSize = self.bounds.size;
        let frameSize  = self.frame.size
        
        var newPosition = CGPoint()
        
        if  boundsSize.equalTo(frameSize)  { // rotated 0° or 180°
            let anchor = self.anchorPoint
            
            let newAnchor = CGPoint(x: boundsSize.width * anchor.x,
                                    y: boundsSize.height * anchor.y)
            
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
                newPosition.x = round(currentPosition.x * scale) / scale
                newPosition.y = round(currentPosition.y * scale) / scale
            }
        }
        
        self.position = newPosition
    }
    
    /// @cond
    
    func setPaddingLeft(newPadding: CGFloat)
    {
        if ( newPadding != paddingLeft ) {
            paddingLeft = newPadding
            self.setNeedsLayout()
        }
    }
    
    func setPaddingRight(newPadding : CGFloat)
    {
        if ( newPadding != paddingRight ) {
            paddingRight = newPadding;
            self.setNeedsLayout()
        }
    }
    
    func setPaddingTop(newPadding: CGFloat)
    {
        if ( newPadding != paddingTop ) {
            paddingTop = newPadding;
            self.setNeedsLayout()
        }
    }
    
    func setPaddingBottom( newPadding:CGFloat)
    {
        if ( newPadding != paddingBottom ) {
            paddingBottom = newPadding
            self.setNeedsLayout()
        }
    }
    
    
/**     *  @brief Updates the layout of all sublayers. Sublayers fill the super layer&rsquo;s bounds minus any padding.
     *
     *  This is where we do our custom replacement for the Mac-only layout manager and autoresizing mask.
     *  Subclasses should override this method to provide a different layout of their own sublayers.
     **/
    override func layoutSublayers()
    {
        let selfBounds = self.bounds;
        
        var mySublayers = self.sublayers;
        
        if( mySublayers!.count > 0) {
            
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
            
            let  excludedSublayers = self.sublayersExcludedFromAutomaticLayout()
            
            Class layerClass                  = [CPTLayer class];
            for ( CALayer *subLayer in mySublayers ) {
                if ( [subLayer isKindOfClass:layerClass] && ![excludedSublayers containsObject:subLayer] ) {
                    subLayer.frame = subLayerFrame;
                }
            }
        }
    }
    func sublayersExcludedFromAutomaticLayout() -> CPTSublayerSet? {
        return nil
    }
    
    func sublayerMargin( left: inout CGFloat, top: inout CGFloat, right: inout CGFloat, bottom: inout CGFloat )
    {
        left   = self.paddingLeft;
        top    = self.paddingTop;
        right  = self.paddingRight;
        bottom = self.paddingBottom;
    }
}
