//
//  CPTAnnotationHostLayer.swift
//  corePlot
//
//  Created by thierryH24 on 09/11/2020.
//

//==============================
//  OK
//==============================


import AppKit

public class CPTAnnotationHostLayer: CPTLayer {
    
    typealias CPTMutableSublayerSet = Set<CALayer>
    
    var annotations = [CPTAnnotation] ()
    var CPTSublayerSet = Set<CALayer>()
    
    
    // MARK: - Init/Dealloc
    override init()
    {
        super.init()
        annotations.removeAll()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -  Annotations
    func addAnnotation(_ annotation: CPTAnnotation?) {
        if annotation != nil {
            
            if annotations.contains(annotation!) == false {
                if let theAnnotation = annotation {
                    annotations.append(theAnnotation)
                }
            }
            annotation?.annotationHostLayer = self
            annotation?.positionContentLayer()
        }
    }
    
    // Removes an annotation from the receiver.
    func removeAnnotation(_ annotation: CPTAnnotation?) {
        
        if let index = annotations.firstIndex(of: annotation!) {
            annotations.remove(at: index)
        }
    }
    
    //     Removes all annotations from the receiver.
    func removeAllAnnotations() {
        
        for annotation in annotations {
            annotation.annotationHostLayer = nil
        }
        annotations.removeAll()
    }
    
    // MARK: -  Layout
    override func sublayersExcludedFromAutomaticLayout() -> CPTSublayerSet? {
        
        if annotations.count > 0 {
            var excludedSublayers = super.sublayersExcludedFromAutomaticLayout()
            
            if excludedSublayers == nil {
                excludedSublayers = []
            }
            
            for annotation in annotations {
                guard let annotation = annotation as? CPTAnnotation else { continue }
                let content = annotation.contentLayer
                if let content = content {
                    excludedSublayers?.add(content)
                }
            }
            return excludedSublayers
            
        } else {
            return super.sublayersExcludedFromAutomaticLayout()
        }
    }
    public override func layoutSublayers()
    {
        super.layoutSublayers()
        //        self.annotations.    makeObjectsPerformSelector:@selector(positionContentLayer)
        
        for annotation in annotations {
            annotation.positionContentLayer()
        }
    }

    //    /**
    //     *  @brief Informs the receiver that the user has
    //     *  @if MacOnly pressed the mouse button. @endif
    //     *  @if iOSOnly touched the screen. @endif
    //     *
    //     */
    override func pointingDeviceDownEvent(event: CPTNativeEvent, atPoint interactionPoint: CGPoint)-> Bool
    {
        for annotation in self.annotations  {
            let content = annotation.contentLayer;
            if (( content ) != nil) {
                if ( content!.frame.contains(interactionPoint)) {
                    let  handled = content!.pointingDeviceDownEvent(event: event, atPoint:interactionPoint)
                    if  handled == true  {
                        return true
                    }
                }
            }
        }
        return super.pointingDeviceDownEvent(event: event, atPoint:interactionPoint)
    }
    
    //    /**
    //     *  @brief Informs the receiver that the user has
    //     *  @if MacOnly released the mouse button. @endif
    //     *  @if iOSOnly lifted their finger off the screen. @endif
    //     *
    //     *
    override func pointingDeviceUpEvent(event: CPTNativeEvent, atPoint interactionPoint:CGPoint ) -> Bool
    {
        for annotation in self.annotations {
            let content = annotation.contentLayer;
            if (( content ) != nil) {
                if ( content!.frame.contains(interactionPoint)) {
                    let  handled = content!.pointingDeviceUpEvent(event: event, atPoint:interactionPoint)
                    if ( handled == true) {
                        return true
                    }
                }
            }
        }
        return super.pointingDeviceUpEvent(event: event, atPoint:interactionPoint)
    }
    
    //    /**
    //     *  @brief Informs the receiver that the user has moved
    //     *  @if MacOnly the mouse with the button pressed. @endif
    //     *  @if iOSOnly their finger while touching the screen. @endif
    //     *
    //     *
    override func pointingDeviceDraggedEvent(event: CPTNativeEvent, atPoint interactionPoint:CGPoint) -> Bool
    {
        for annotation in self.annotations {
            let content = annotation.contentLayer;
            if (( content ) != nil) {
                if ( content!.frame.contains(interactionPoint)) {
                    let handled = content!.pointingDeviceDraggedEvent(event: event, atPoint:interactionPoint)
                    if ( handled ) {
                        return true;
                    }
                }
            }
        }
        return super.pointingDeviceDraggedEvent(event: event, atPoint:interactionPoint)
    }
    
    //    /**
    //     *  @brief Informs the receiver that tracking of
    //     *  @if MacOnly mouse moves @endif
    //     *  @if iOSOnly touches @endif
    //     *  has been cancelled for any reason.
    //     *
    //     *
    func pointingDeviceCancelledEvent(_ event: CPTNativeEvent) -> Bool {
        for annotation in annotations {
            let content = annotation.contentLayer
            if let content = content {
                let handled = content.pointingDeviceCancelledEvent(event: event)
                if handled {
                    return true
                }
            }
        }
        return super.pointingDeviceCancelledEvent(event: event)
    }
}
