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
    
    var annotations = [CPTAnnotation] ()
    
    
    // MARK: - Init/Dealloc
    override init()
    {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -  Accessors
    
    
//    -(void)addAnnotation:(nullable CPTAnnotation *)annotation
//    {
//        if ( annotation ) {
//            CPTAnnotation *theAnnotation = annotation;
//
//            CPTMutableAnnotationArray *annotationArray = self.mutableAnnotations;
//            if ( ![annotationArray containsObject:theAnnotation] ) {
//                [annotationArray addObject:theAnnotation];
//            }
//            theAnnotation.annotationHostLayer = self;
//            [theAnnotation positionContentLayer];
//        }
//    }
//
//    /**
//     *  @brief Removes an annotation from the receiver.
//     **/
//    -(void)removeAnnotation:(nullable CPTAnnotation *)annotation
//    {
//        if ( annotation ) {
//            CPTAnnotation *theAnnotation = annotation;
//
//            if ( [self.mutableAnnotations containsObject:theAnnotation] ) {
//                theAnnotation.annotationHostLayer = nil;
//                [self.mutableAnnotations removeObject:theAnnotation];
//            }
//            else {
//                CPTAnnotationHostLayer *hostLayer = theAnnotation.annotationHostLayer;
//                [NSException raise:CPTException format:@"Tried to remove CPTAnnotation from %@. Host layer was %@.", self, hostLayer];
//            }
//        }
//    }
//
//    /**
//     *  @brief Removes all annotations from the receiver.
//     **/
//    -(void)removeAllAnnotations
//    {
//        CPTMutableAnnotationArray *allAnnotations = self.mutableAnnotations;
//
//        for ( CPTAnnotation *annotation in allAnnotations ) {
//            annotation.annotationHostLayer = nil;
//        }
//        [allAnnotations removeAllObjects];
//    }
//
//    #pragma mark -
//    #pragma mark Layout
//
//    /// @cond
//
//    -(nullable CPTSublayerSet *)sublayersExcludedFromAutomaticLayout
//    {
//        CPTMutableAnnotationArray *annotations = self.mutableAnnotations;
//
//        if ( annotations.count > 0 ) {
//            CPTMutableSublayerSet *excludedSublayers = [super.sublayersExcludedFromAutomaticLayout mutableCopy];
//
//            if ( !excludedSublayers ) {
//                excludedSublayers = [NSMutableSet set];
//            }
//
//            for ( CPTAnnotation *annotation in annotations ) {
//                CALayer *content = annotation.contentLayer;
//                if ( content ) {
//                    [excludedSublayers addObject:content];
//                }
//            }
//
//            return excludedSublayers;
//        }
//        else {
//            return super.sublayersExcludedFromAutomaticLayout;
//        }
//    }
//
//    -(void)layoutSublayers
//    {
//        [super layoutSublayers];
//        [self.mutableAnnotations makeObjectsPerformSelector:@selector(positionContentLayer)];
//    }
//
//    /// @endcond
//
//    #pragma mark -
//    #pragma mark Event Handling
//
//    /// @name User Interaction
//    /// @{
//
//    /**
//     *  @brief Informs the receiver that the user has
//     *  @if MacOnly pressed the mouse button. @endif
//     *  @if iOSOnly touched the screen. @endif
//     *
//     *
//     *  The event is passed in turn to each annotation layer that contains the interaction point.
//     *  If any layer handles the event, subsequent layers are not notified and
//     *  this method immediately returns @YES.
//     *
//     *  @param event The OS event.
//     *  @param interactionPoint The coordinates of the interaction.
//     *  @return Whether the event was handled or not.
//     **/
//    -(BOOL)pointingDeviceDownEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
//    {
//        for ( CPTAnnotation *annotation in self.annotations ) {
//            CPTLayer *content = annotation.contentLayer;
//            if ( content ) {
//                if ( CGRectContainsPoint(content.frame, interactionPoint)) {
//                    BOOL handled = [content pointingDeviceDownEvent:event atPoint:interactionPoint];
//                    if ( handled ) {
//                        return YES;
//                    }
//                }
//            }
//        }
//
//        return [super pointingDeviceDownEvent:event atPoint:interactionPoint];
//    }
//
//    /**
//     *  @brief Informs the receiver that the user has
//     *  @if MacOnly released the mouse button. @endif
//     *  @if iOSOnly lifted their finger off the screen. @endif
//     *
//     *
//     *  The event is passed in turn to each annotation layer that contains the interaction point.
//     *  If any layer handles the event, subsequent layers are not notified and
//     *  this method immediately returns @YES.
//     *
//     *  @param event The OS event.
//     *  @param interactionPoint The coordinates of the interaction.
//     *  @return Whether the event was handled or not.
//     **/
//    -(BOOL)pointingDeviceUpEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
//    {
//        for ( CPTAnnotation *annotation in self.annotations ) {
//            CPTLayer *content = annotation.contentLayer;
//            if ( content ) {
//                if ( CGRectContainsPoint(content.frame, interactionPoint)) {
//                    BOOL handled = [content pointingDeviceUpEvent:event atPoint:interactionPoint];
//                    if ( handled ) {
//                        return YES;
//                    }
//                }
//            }
//        }
//
//        return [super pointingDeviceUpEvent:event atPoint:interactionPoint];
//    }
//
//    /**
//     *  @brief Informs the receiver that the user has moved
//     *  @if MacOnly the mouse with the button pressed. @endif
//     *  @if iOSOnly their finger while touching the screen. @endif
//     *
//     *
//     *  The event is passed in turn to each annotation layer that contains the interaction point.
//     *  If any layer handles the event, subsequent layers are not notified and
//     *  this method immediately returns @YES.
//     *
//     *  @param event The OS event.
//     *  @param interactionPoint The coordinates of the interaction.
//     *  @return Whether the event was handled or not.
//     **/
//    -(BOOL)pointingDeviceDraggedEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
//    {
//        for ( CPTAnnotation *annotation in self.annotations ) {
//            CPTLayer *content = annotation.contentLayer;
//            if ( content ) {
//                if ( CGRectContainsPoint(content.frame, interactionPoint)) {
//                    BOOL handled = [content pointingDeviceDraggedEvent:event atPoint:interactionPoint];
//                    if ( handled ) {
//                        return YES;
//                    }
//                }
//            }
//        }
//
//        return [super pointingDeviceDraggedEvent:event atPoint:interactionPoint];
//    }
//
//    /**
//     *  @brief Informs the receiver that tracking of
//     *  @if MacOnly mouse moves @endif
//     *  @if iOSOnly touches @endif
//     *  has been cancelled for any reason.
//     *
//     *
//     *  The event is passed in turn to each annotation layer.
//     *  If any layer handles the event, subsequent layers are not notified and
//     *  this method immediately returns @YES.
//     *
//     *  @param event The OS event.
//     *  @return Whether the event was handled or not.
//     **/
//    -(BOOL)pointingDeviceCancelledEvent:(nonnull CPTNativeEvent *)event
//    {
//        for ( CPTAnnotation *annotation in self.annotations ) {
//            CPTLayer *content = annotation.contentLayer;
//            if ( content ) {
//                BOOL handled = [content pointingDeviceCancelledEvent:event];
//                if ( handled ) {
//                    return YES;
//                }
//            }
//        }
//
//        return [super pointingDeviceCancelledEvent:event];
//    }
//
    
    
    
}
