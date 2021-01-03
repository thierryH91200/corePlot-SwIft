//
//  CPTBorderLayer.swift
//  corePlot
//
//  Created by thierryH24 on 19/11/2020.
//

import AppKit

class CPTBorderLayer: CPTLayer {
    
    var maskedLayer : CPTBorderedLayer?
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        maskedLayer = nil;
        
        self.needsDisplayOnBoundsChange = true;
    }
    
    override init( layer: Any)
    {
        super.init(layer:layer)
        let theLayer = CPTBorderLayer( layer: layer)
        maskedLayer = theLayer.maskedLayer
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Drawing
    override func renderAsVectorInContext(context:  CGContext)
    {
        guard self.isHidden == false else { return }
    
        let theMaskedLayer = self.maskedLayer
    
        if (( theMaskedLayer ) != nil) {
            super.renderAsVectorInContext(context: context)
            theMaskedLayer?.renderBorderedLayerAsVectorInContext(context: context)
        }
    }
    
    // MARK: - Layout
    override func layoutSublayers()
    {
        super.layoutSublayers()
    
        let theMaskedLayer = self.maskedLayer;
        if (( theMaskedLayer ) != nil) {
            var newBounds = self.bounds;
    
            // undo the shadow margin so the masked layer is always the same size
            if (( self.shadow ) != nil) {
                let sizeOffset = self.shadowMargin
    
                newBounds.origin.x    -= sizeOffset.width
                newBounds.origin.y    -= sizeOffset.height
                newBounds.size.width  += sizeOffset.width * CGFloat(2.0)
                newBounds.size.height += sizeOffset.height * CGFloat(2.0)
            }
    
            theMaskedLayer?.frame    = newBounds
        }
    }
    
    override func sublayersExcludedFromAutomaticLayout() -> CPTSublayerSet
    {
        var excludedLayer = self.maskedLayer;
    
        if (( excludedLayer ) != nil) {
            var excludedSublayers = super.sublayersExcludedFromAutomaticLayout()
            if ( (excludedSublayers == nil) ) {
                excludedSublayers = NSMutableSet() as? CPTLayer.CPTSublayerSet
            }
            excludedSublayers!.insert(excludedLayer!)
            return excludedSublayers!
        }
        else {
            return super.sublayersExcludedFromAutomaticLayout
        }
    }
    
    //MARK: - Accessors
    //-(void)setMaskedLayer:(nullable CPTBorderedLayer *)newLayer
    //{
    //    if ( newLayer != maskedLayer ) {
    //        maskedLayer = newLayer;
    //        [self setNeedsDisplay];
    //    }
    //}
    //
    //-(void)setBounds:(CGRect)newBounds
    //{
    //    if ( !CGRectEqualToRect(newBounds, self.bounds)) {
    //        super.bounds = newBounds;
    //        [self setNeedsLayout];
    //    }



    
}


