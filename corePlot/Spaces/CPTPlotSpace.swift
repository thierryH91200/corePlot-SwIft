//
//  CPTPlotSpace.swift
//  corePlot
//
//  Created by thierryH24 on 14/11/2020.
//

import Cocoa

class CPTPlotSpace: NSObject {

}

protocol CPTPlotSpaceDelegate: NSObject {

//@optional

/// @name Scaling
/** @brief @optional Informs the receiver that it should uniformly scale (e.g., in response to a pinch gesture).
 *  @param space The plot space.
 *  @param interactionScale The scaling factor.
 *  @param interactionPoint The coordinates of the scaling centroid.
 *  @return @YES if the gesture should be handled by the plot space, and @NO if not.
 *  In either case, the delegate may choose to take extra actions, or handle the scaling itself.
 **/
    func plotSpace(space: CPTPlotSpace, interactionScale:CGFloat,  interactionPoint:CGPoint) -> Bool


/// @name Scrolling
/// @{

/** @brief @optional Notifies that plot space is going to scroll.
 *  @param space The plot space.
 *  @param proposedDisplacementVector The proposed amount by which the plot space will shift.
 *  @return The displacement actually applied.
 **/
func plotSpace(space:  CPTPlotSpace , proposedDisplacementVector:CGPoint)-> CGPoint
}
/// @}

/// @name Plot Range Changes
/// @{

/** @brief @optional Notifies that plot space is going to change a plot range.
 *  @param space The plot space.
 *  @param newRange The proposed new plot range.
 *  @param coordinate The coordinate of the range.
 *  @return The new plot range to be used.
 **/
func plotSpace(space: CPTPlotSpace,  newRange: CPTPlotRange , coordinate:CPTCoordinate) -> CPTPlotRange

/** @brief @optional Notifies that plot space has changed a plot range.
 *  @param space The plot space.
 *  @param coordinate The coordinate of the range.
 **/
-(void)plotSpace:(nonnull CPTPlotSpace *)space didChangePlotRangeForCoordinate:(CPTCoordinate)coordinate;

/// @}

/// @name User Interaction
/// @{

/** @brief @optional Notifies that plot space intercepted a device down event.
 *  @param space The plot space.
 *  @param event The native event.
 *  @param point The point in the host view.
 *  @return Whether the plot space should handle the event or not.
 *  In either case, the delegate may choose to take extra actions, or handle the event itself.
 **/
-(BOOL)plotSpace:(nonnull CPTPlotSpace *)space shouldHandlePointingDeviceDownEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)point;

/** @brief @optional Notifies that plot space intercepted a device dragged event.
 *  @param space The plot space.
 *  @param event The native event.
 *  @param point The point in the host view.
 *  @return Whether the plot space should handle the event or not.
 *  In either case, the delegate may choose to take extra actions, or handle the event itself.
 **/
-(BOOL)plotSpace:(nonnull CPTPlotSpace *)space shouldHandlePointingDeviceDraggedEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)point;

/** @brief @optional Notifies that plot space intercepted a device cancelled event.
 *  @param space The plot space.
 *  @param event The native event.
 *  @return Whether the plot space should handle the event or not.
 *  In either case, the delegate may choose to take extra actions, or handle the event itself.
 **/
-(BOOL)plotSpace:(nonnull CPTPlotSpace *)space shouldHandlePointingDeviceCancelledEvent:(nonnull CPTNativeEvent *)event;

/** @brief @optional Notifies that plot space intercepted a device up event.
 *  @param space The plot space.
 *  @param event The native event.
 *  @param point The point in the host view.
 *  @return Whether the plot space should handle the event or not.
 *  In either case, the delegate may choose to take extra actions, or handle the event itself.
 **/
-(BOOL)plotSpace:(nonnull CPTPlotSpace *)space shouldHandlePointingDeviceUpEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)point;

#if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
#else

/** @brief @optional Notifies that plot space intercepted a scroll wheel event.
 *  @param space The plot space.
 *  @param event The native event.
 *  @param fromPoint The The starting point in the host view.
 *  @param toPoint The The ending point in the host view.
 *  @return Whether the plot space should handle the event or not.
 *  In either case, the delegate may choose to take extra actions, or handle the event itself.
 **/
-(BOOL)plotSpace:(nonnull CPTPlotSpace *)space shouldHandleScrollWheelEvent:(nonnull CPTNativeEvent *)event fromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint;
}
