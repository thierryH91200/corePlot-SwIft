//
//  CPTBorderedLayer.swift
//  corePlot
//
//  Created by thierryH24 on 09/11/2020.
//

import AppKit

public class CPTBorderedLayer: CPTAnnotationHostLayer {
    
    var text = ""
    var textStyle = CPTTextStyle()
    var attributedText =  NSAttributedString()
    var maximumSize = CGSize()
    
    var borderLineStyle: CPTLineStyle?
    var  fill : CPTFill?
    var inLayout = false
    
    var _needsDisplayOnBoundsChange  = false
    
    init (frame :CGRect)
    {
        borderLineStyle = nil
        fill            = nil
        inLayout        = false
        
        self.needsDisplayOnBoundsChange = true
    }
    
    init( layer : CPTLayer)
    {
        let theLayer = CPTBorderedLayer(layer: layer)
        
        borderLineStyle = theLayer.borderLineStyle
        fill            = theLayer.fill
        inLayout        = theLayer.inLayout
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func renderAsVectorInContext(context:  CGContext)
    {
        guard self.isHidden == true || self.masksToBorder == true else { return }
        
        super.renderAsVectorInContext(context: context)
        self.renderBorderedLayerAsVectorInContext(context: context)
    }
    
    func renderBorderedLayerAsVectorInContext(context : CGContext)
    {
        if ( (self.backgroundColor == nil) || self.useFastRendering == false ) {
            let theFill = self.fill
            
            if (( theFill ) != nil) {
                let useMask = self.masksToBounds;
                self.masksToBounds = true
                
                context.beginPath();
                context.addPath(self.maskingPath()!)
                theFill?.fillPathInContext(context: context)
                self.masksToBounds = useMask;
            }
        }
        
        let theLineStyle = self.borderLineStyle;
        
        if  (theLineStyle != nil)  {
            let inset      = theLineStyle!.lineWidth * CGFloat(0.5);
            let layerBounds = self.bounds.insetBy(dx: inset, dy: inset);
            
            theLineStyle!.setLineStyleInContext(context: context)
            
            let radius = self.cornerRadius;
            
            if ( radius > CGFloat(0.0)) {
                context.beginPath();
                CPTAddRoundedRectPath(context, layerBounds, radius);
                theLineStyle?.strokePathInContext(context: context)
            }
            else {
                theLineStyle?.strokeRect(rect: layerBounds, context:context)
            }
        }
    }
    
    
}
