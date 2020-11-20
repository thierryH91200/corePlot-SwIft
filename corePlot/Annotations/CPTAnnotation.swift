//
//  CPTAnnotation.swift
//  corePlot
//
//  Created by thierryH24 on 09/11/2020.
//

//==============================
//  OK
//==============================


import AppKit

class CPTAnnotation: NSObject {
    
//    var contentLayer:  CPTLayer?
    var annotationHostLayer : CPTAnnotationHostLayer?
    var contentAnchorPoint : CGPoint = .zero
    var displacement : CGPoint = .zero
    var rotation = CGFloat(0)
    
    override init()
    {
        annotationHostLayer = nil;
        contentLayer        = nil;
        displacement        = .zero;
        contentAnchorPoint  = CGPoint(x: 0.5, y: 0.5);
        rotation            = CGFloat(0.0);
    }
    var _contentLayer:  CPTLayer?
    var contentLayer:  CPTLayer? {
        get { return  _contentLayer }
     set {
        if newValue != _contentLayer {
            _contentLayer!.removeFromSuperlayer()
            _contentLayer = newValue
            if let newLayer = newValue {
                
                let hostLayer = annotationHostLayer
                hostLayer?.addSublayer(newLayer)
            }
        }
    }
    }
    func setAnnotationHostLayer(_ newLayer: CPTAnnotationHostLayer?) {
        if newLayer != annotationHostLayer {
            let myContent = contentLayer
            
            myContent?.removeFromSuperlayer()
            annotationHostLayer = newLayer
            if let myContent = myContent {
                newLayer?.addSublayer(myContent)
            }
        }
    }
    
    func setDisplacement(_ newDisplacement : CGPoint)
    {
        if newDisplacement.equalTo(displacement) {
            displacement = newDisplacement
            self.contentLayer?.superlayer?.needsLayout()
        }
    }
    
    func setContentAnchorPoint( newAnchorPoint: CGPoint)
    {
        if !newAnchorPoint.equalTo( contentAnchorPoint) {
            contentAnchorPoint = newAnchorPoint;
            self.contentLayer?.superlayer?.needsLayout()
        }
    }
    
    func setRotation(newRotation : CGFloat)
    {
        if ( newRotation != rotation ) {
            rotation = newRotation;
            self.contentLayer?.superlayer?.needsLayout()
            
        }
    }
    
    func positionContentLayer()
    {
    }
}
