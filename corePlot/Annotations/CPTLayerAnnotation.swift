//
//  CPTLayerAnnotation.swift
//  corePlot
//
//  Created by thierryH24 on 09/11/2020.
//

//==============================
//  OK
//==============================

import AppKit

class CPTLayerAnnotation: CPTAnnotation {
    
    var  anchorLayer : CPTLayer?
    var  rectAnchor : CPTRectAnchor?
    var  xConstraints : CPTConstraints?
    var  yConstraints : CPTConstraints?
    
    init( newAnchorLayer: CPTLayer) {
        
        super.init()
        anchorLayer  = newAnchorLayer
        rectAnchor   = .top
        xConstraints = nil
        yConstraints = nil
        self.setConstraints()
        
        NotificationCenter.default.addObserver(
            self,
             selector:#selector(positionContentLayer),
             name: .CPTLayerBoundsDidChangeNotification,
               object:newAnchorLayer)
    }

    @objc override func positionContentLayer()   {
        let content = self.contentLayer
        
        if  content != nil  {
            let hostLayer = self.annotationHostLayer
            if  hostLayer != nil {
                let theAnchorLayer = self.anchorLayer
                let anchorLayerBounds = theAnchorLayer!.bounds;
                
                var lower = anchorLayerBounds.minX
                var upper = anchorLayerBounds.maxX
                let xPosition = self.xConstraints?.positionFor(lowerBound: lower, upperBound: upper)
                
                lower = anchorLayerBounds.minY
                upper = anchorLayerBounds.maxY
                let yPosition = self.yConstraints?.positionFor(lowerBound:lower, upperBound:upper)
                
                let referencePoint = CGPoint(x: xPosition!, y: yPosition!)
                var newPosition    = theAnchorLayer?.convert(referencePoint, to: hostLayer)
                
                let offset = self.displacement;
                newPosition?.x += offset!.x;
                newPosition?.y += offset!.y;
                
                content?.anchorPoint = self.contentAnchorPoint!;
                content?.position    = newPosition!
                content?.transform   = CATransform3DMakeRotation(self.rotation!, CGFloat(0.0), CGFloat(0.0), CGFloat(1.0));
                content?.pixelAlign()
            }
        }
    }
    
    func setConstraints()
    {
        let xConstraint : CPTConstraints?;
        let yConstraint : CPTConstraints?;
        
        switch ( self.rectAnchor ) {
        case .none:
            xConstraint = CPTConstraints(upperOffset:CGFloat(0.0))
            yConstraint = CPTConstraints(relativeOffset:CGFloat(0.5))
            break;

        case .right:
            xConstraint = CPTConstraints(upperOffset:CGFloat(0.0))
            yConstraint = CPTConstraints(relativeOffset:CGFloat(0.5))
            break;
            
        case .topRight:
            xConstraint = CPTConstraints(upperOffset: CGFloat(0.0))
            yConstraint = CPTConstraints(upperOffset: CGFloat(0.0))
            break;
            
        case .top:
            xConstraint = CPTConstraints(relativeOffset: CGFloat(0.5))
            yConstraint = CPTConstraints(upperOffset: CGFloat(0.0))
            break;
            
        case .topLeft:
            xConstraint = CPTConstraints(lowerOffset:CGFloat(0.0))
            yConstraint = CPTConstraints(upperOffset:CGFloat(0.0))
            
            break;
            
        case .left:
            xConstraint = CPTConstraints(lowerOffset:CGFloat(0.0))
            yConstraint = CPTConstraints(relativeOffset:CGFloat(0.5))
            break;
            
        case .bottomLeft:
            
            xConstraint = CPTConstraints(lowerOffset:CGFloat(0.0))
            yConstraint = CPTConstraints(lowerOffset:CGFloat(0.0))
            break;
            
        case .bottom:
            xConstraint = CPTConstraints(relativeOffset:CGFloat(0.5))
            yConstraint = CPTConstraints(lowerOffset:CGFloat(0.0))
            break;
            
        case .bottomRight:
            xConstraint = CPTConstraints(upperOffset:CGFloat(0.0))
            yConstraint = CPTConstraints(lowerOffset:CGFloat(0.0))
            break;
            
        case .center:
            xConstraint = CPTConstraints(relativeOffset:CGFloat(0.5))
            yConstraint = CPTConstraints(relativeOffset:CGFloat(0.5))
            break;
        }
        
        self.xConstraints = xConstraint;
        self.yConstraints = yConstraint;
    }
    
    
}
