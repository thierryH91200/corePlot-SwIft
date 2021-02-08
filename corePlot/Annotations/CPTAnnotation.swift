//
//  CPTAnnotation.swift
//  corePlot
//
//  Created by thierryH24 on 09/11/2020.
//

//==============================
//  OK
// 16/12/20
//==============================

import AppKit

class CPTAnnotation: NSObject {
    override init() {
        annotationHostLayer = nil
        contentLayer = nil
        displacement = .zero
        contentAnchorPoint = CGPoint(x: 0.5, y: 0.5)
        rotation = CGFloat(0.0)
    }
    
    var _contentLayer: CPTLayer?
    var contentLayer: CPTLayer? {
        get {
            return _contentLayer
        }
        set {
            if newValue != _contentLayer {
                _contentLayer!.removeFromSuperlayer()
                _contentLayer = newValue
                if newValue != nil {
                    let layer = newValue
                    
                    let hostLayer = annotationHostLayer
                    hostLayer!.addSublayer(layer!)
                }
            }
        }
    }
    
    var _annotationHostLayer: CPTAnnotationHostLayer?
    var annotationHostLayer: CPTAnnotationHostLayer? {
        get {
            return _annotationHostLayer
        }
        set {
            if newValue != _annotationHostLayer {
                let myContent = contentLayer
                
                myContent!.removeFromSuperlayer()
                _annotationHostLayer = newValue
                if myContent != nil {
                    newValue!.addSublayer(myContent!)
                }
            }
        }
    }
    
    var _displacement: CGPoint?
    var displacement: CGPoint? {
        get {
            return _displacement
        }
        set {
            if _displacement!.equalTo(newValue!) == false {
                _displacement = newValue!
                contentLayer?.superlayer!.setNeedsLayout()
            }
        }
    }

    var _contentAnchorPoint: CGPoint?
    var contentAnchorPoint: CGPoint? {
        get {
            return _contentAnchorPoint
        }
        set {
            if _contentAnchorPoint!.equalTo(newValue!) == false {
                _contentAnchorPoint = newValue!
                contentLayer?.superlayer!.setNeedsLayout()
            }
        }
    }
    
    var _rotation: CGFloat?
    var rotation: CGFloat? {
        get {
            return _rotation
        }
        set {
            if _rotation != rotation! {
                _rotation = newValue!
                contentLayer?.superlayer!.setNeedsLayout()
            }
        }
    }
    
    // MARK: Layout
    func positionContentLayer() {
        // Do nothing--implementation provided by subclasses
    }
}
