//
//  CPTPlot Responder.swift
//  corePlot
//
//  Created by thierryH24 on 24/11/2020.
//

import Foundation


extension CPTPlot {


//#pragma mark -
//#pragma mark Responder Chain and User interaction
//
///// @name User Interaction
///// @{
//
///**
// *  @brief Informs the receiver that the user has
// *  @if MacOnly pressed the mouse button. @endif
// *  @if iOSOnly started touching the screen. @endif
// *
// *
// *  If this plot has a delegate that responds to the
// *  @link CPTPlotDelegate::plot:dataLabelTouchDownAtRecordIndex: -plot:dataLabelTouchDownAtRecordIndex: @endlink or
// *  @link CPTPlotDelegate::plot:dataLabelTouchDownAtRecordIndex:withEvent: -plot:dataLabelTouchDownAtRecordIndex:withEvent: @endlink
// *  methods, the data labels are searched to find the index of the one containing the @par{interactionPoint}.
// *  The delegate method will be called and this method returns @YES if the @par{interactionPoint} is within a label.
// *  This method returns @NO if the @par{interactionPoint} is too far away from all of the data labels.
// *
// *  @param event The OS event.
// *  @param interactionPoint The coordinates of the interaction.
// *  @return Whether the event was handled or not.
// **/
    override func pointingDeviceDownEvent(event: CPTNativeEvent, atPoint interactionPoint:CGPoint)-> Bool
    {
        self.pointingDeviceDownLabelIndex = NSNotFound;
        let theGraph = self.graph
        
        if  (theGraph == nil) || self.isHidden == true {
            return false
        }
        
        let theDelegate = self.delegate as? CPTPlotDelegate
        
//        if ( theDelegate.plot(:dataLabelTouchDownAtRecordIndex:) ||
//             theDelegate respondsToSelector:@selector(plot:dataLabelTouchDownAtRecordIndex:withEvent:) ||
//             theDelegate respondsToSelector:@selector(plot:dataLabelWasSelectedAtRecordIndex:) ||
//             theDelegate respondsToSelector:@selector(plot:dataLabelWasSelectedAtRecordIndex:withEvent:) ) {
            // Inform delegate if a label was hit
            
            let labelArray = self.labelAnnotations;
            let labelCount                 = labelArray.count;
            let annotationClass            = [CPTAnnotation]()
            
            for  idx in 0..<labelCount {
                let annotation = labelArray[idx];
//                if annotation is Array<CPTAnnotation> {
                    
                let labelLayer = annotation.contentLayer;
                if ( (labelLayer != nil) && !labelLayer!.isHidden ) {
                    let labelPoint = theGraph?.convert(interactionPoint, to:labelLayer)
                        
                    if  labelLayer!.bounds.contains( labelPoint!) == true{
                            self.pointingDeviceDownLabelIndex = idx;
                            var handled = false
                            
                        if theDelegate.plot:dataLabelTouchDownAtRecordIndex:) ) {
                                handled = true
                                theDelegate?.plot(plot:self, dataLabelTouchDownAtRecordIndex:idx)
                            }
                            
                            if theDelegate.plot(plot:self, dataLabelTouchDownAtRecordIndex:idx, withEvent:event) {
                                handled = true
                                theDelegate!.plot(plot: self, dataLabelTouchDownAtRecordIndex:idx, event:event)
                            }
                            
                            if ( handled ) {
                                return true
                            }
                        }
                    }
//                }
            }
        }
        
        return super.pointingDeviceDownEvent(event: event, atPoint:interactionPoint);
    }
    
    
    
//
///**
// *  @brief Informs the receiver that the user has
// *  @if MacOnly pressed the mouse button. @endif
// *  @if iOSOnly ended touching the screen. @endif
// *
// *
// *  If this plot has a delegate that responds to the
// *  @link CPTPlotDelegate::plot:dataLabelTouchUpAtRecordIndex: -plot:dataLabelTouchUpAtRecordIndex: @endlink or
// *  @link CPTPlotDelegate::plot:dataLabelTouchUpAtRecordIndex:withEvent: -plot:dataLabelTouchUpAtRecordIndex:withEvent: @endlink
// *  methods, the data labels are searched to find the index of the one containing the @par{interactionPoint}.
// *  The delegatfloadNumbersForAllFieldsFromDataSourceInRecordIndexRangeffe method will be called and this method returns @YES if the @par{interactionPoint} is within a label.
// *  This method returns @NO if the @par{interactionPoint} is too far away from all of the data labels.
// *
// *  If the data label being released is the same as the one that was pressed (see
// *  @link CPTPlot::pointingDeviceDownEvent:atPoint: -pointingDeviceDownEvent:atPoint: @endlink), if the delegate responds to the
// *  @link CPTPlotDelegate::plot:dataLabelWasSelectedAtRecordIndex: -plot:dataLabelWasSelectedAtRecordIndex: @endlink and/or
// *  @link CPTPlotDelegate::plot:dataLabelWasSelectedAtRecordIndex:withEvent: -plot:dataLabelWasSelectedAtRecordIndex:withEvent: @endlink
// *  methods, these will be called.
// *
// *  @param event The OS event.
// *  @param interactionPoint The coordinates of the interaction.
// *  @return Whether the event was handled or not.
// **/
//-(BOOL)pointingDeviceUpEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
//{
//    NSUInteger selectedDownIndex = self.pointingDeviceDownLabelIndex;
//
//    self.pointingDeviceDownLabelIndex = NSNotFound;
//
//    CPTGraph *theGraph = self.graph;
//
//    if ( !theGraph || self.hidden ) {
//        return false
//    }
//
//    id<CPTPlotDelegate> theDelegate = (id<CPTPlotDelegate>)self.delegate;
//
//    if ( [theDelegate respondsToSelector:@selector(plot:dataLabelTouchUpAtRecordIndex:)] ||
//         [theDelegate respondsToSelector:@selector(plot:dataLabelTouchUpAtRecordIndex:withEvent:)] ||
//         [theDelegate respondsToSelector:@selector(plot:dataLabelWasSelectedAtRecordIndex:)] ||
//         [theDelegate respondsToSelector:@selector(plot:dataLabelWasSelectedAtRecordIndex:withEvent:)] ) {
//        // Inform delegate if a label was hit
//        CPTMutableAnnotationArray *labelArray = self.labelAnnotations;
//        NSUInteger labelCount                 = labelArray.count;
//        Class annotationClass                 = [CPTAnnotation class];
//
//        for ( NSUInteger idx = 0; idx < labelCount; idx++ ) {
//            CPTPlotSpaceAnnotation *annotation = labelArray[idx];
//            if ( [annotation isKindOfClass:annotationClass] ) {
//                CPTLayer *labelLayer = annotation.contentLayer;
//                if ( labelLayer && !labelLayer.hidden ) {
//                    CGPoint labelPoint = [theGraph convertPoint:interactionPoint toLayer:labelLayer];
//
//                    if ( CGRectContainsPoint(labelLayer.bounds, labelPoint)) {
//                        BOOL handled = false
//
//                        if ( [theDelegate respondsToSelector:@selector(plot:dataLabelTouchUpAtRecordIndex:)] ) {
//                            handled = true
//                            [theDelegate plot:self dataLabelTouchUpAtRecordIndex:idx];
//                        }
//
//                        if ( [theDelegate respondsToSelector:@selector(plot:dataLabelTouchUpAtRecordIndex:withEvent:)] ) {
//                            handled = true
//                            [theDelegate plot:self dataLabelTouchUpAtRecordIndex:idx withEvent:event];
//                        }
//
//                        if ( idx == selectedDownIndex ) {
//                            if ( [theDelegate respondsToSelector:@selector(plot:dataLabelWasSelectedAtRecordIndex:)] ) {
//                                handled = true
//                                [theDelegate plot:self dataLabelWasSelectedAtRecordIndex:idx];
//                            }
//
//                            if ( [theDelegate respondsToSelector:@selector(plot:dataLabelWasSelectedAtRecordIndex:withEvent:)] ) {
//                                handled = true
//                                [theDelegate plot:self dataLabelWasSelectedAtRecordIndex:idx withEvent:event];
//                            }
//                        }
//
//                        if ( handled ) {
//                            return true
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    return [super pointingDeviceUpEvent:event atPoint:interactionPoint];
//}
}
