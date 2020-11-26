//
//  CPTPlotSpace.swift
//  corePlot
//
//  Created by thierryH24 on 14/11/2020.
//

import Cocoa

class CPTPlotSpace: NSObject {
    
    var categoryNames : Dictionary<Int, String >? = [:]
    var delegate : CPTPlotSpaceDelegate?
    var identifier : Any?
    var allowsUserInteraction : Bool?
    var isDragging : Bool?
    var graph : CPTGraph?
    
    override init()
    {
        super.init()
        identifier            = nil;
        allowsUserInteraction = false
        isDragging            = false
        graph                 = nil
        delegate              = nil;
        categoryNames         = nil;
    }
//    #pragma mark Categorical Data
//
//    /// @cond
//
//    /** @internal
//     *  @brief Gets the ordered set of categories for the given coordinate, creating it if necessary.
//     *  @param coordinate The axis coordinate.
//     *  @return The ordered set of categories for the given coordinate.
//     */
    func orderedSetForCoordinate(coordinate: CPTCoordinate) ->Set< String > //CPTMutableCategorySet
    {
        NSMutableDictionary<NSNumber *, CPTMutableCategorySet *> *names = self.categoryNames;

        if ( !names ) {
            names = [[NSMutableDictionary alloc] init];

            self.categoryNames = names;
        }

        NSNumber *cacheKey = @(coordinate);

        let *categories = names[cacheKey];

        if ( !categories ) {
            categories = Set< Any >

            names[cacheKey] = categories;
        }

        return categories;
    }
//
//    /// @endcond
//
//    /**
//     *  @brief Add a new category name for the given coordinate.
//     *
//     *  Category names must be unique for each coordinate. Adding the same name more than once has no effect.
//     *
//     *  @param category The category name.
//     *  @param coordinate The axis coordinate.
//     */
//    -(void)addCategory:(nonnull NSString *)category forCoordinate:(CPTCoordinate)coordinate
//    {
//        NSParameterAssert(category);
//
//        CPTMutableCategorySet *categories = [self orderedSetForCoordinate:coordinate];
//
//        [categories addObject:category];
//    }
//
//    /**
//     *  @brief Removes the named category for the given coordinate.
//     *  @param category The category name.
//     *  @param coordinate The axis coordinate.
//     */
//    -(void)removeCategory:(nonnull NSString *)category forCoordinate:(CPTCoordinate)coordinate
//    {
//        NSParameterAssert(category);
//
//        CPTMutableCategorySet *categories = [self orderedSetForCoordinate:coordinate];
//
//        [categories removeObject:category];
//    }
//
//    /**
//     *  @brief Add a new category name for the given coordinate at the given index in the list of category names.
//     *
//     *  Category names must be unique for each coordinate. Adding the same name more than once has no effect.
//     *
//     *  @param category The category name.
//     *  @param coordinate The axis coordinate.
//     *  @param idx The index in the list of category names.
//     */
//    -(void)insertCategory:(nonnull NSString *)category forCoordinate:(CPTCoordinate)coordinate atIndex:(NSUInteger)idx
//    {
//        NSParameterAssert(category);
//
//        CPTMutableCategorySet *categories = [self orderedSetForCoordinate:coordinate];
//
//        NSParameterAssert(idx <= categories.count);
//
//        [categories insertObject:category atIndex:idx];
//    }
//
//    /**
//     *  @brief Replace all category names for the given coordinate with the names in the supplied array.
//     *  @param newCategories An array of category names.
//     *  @param coordinate The axis coordinate.
//     */
//    -(void)setCategories:(nullable CPTStringArray *)newCategories forCoordinate:(CPTCoordinate)coordinate
//    {
//        NSMutableDictionary<NSNumber *, CPTMutableCategorySet *> *names = self.categoryNames;
//
//        if ( !names ) {
//            names = [[NSMutableDictionary alloc] init];
//
//            self.categoryNames = names;
//        }
//
//        NSNumber *cacheKey = @(coordinate);
//
//        if ( [newCategories isKindOfClass:[NSArray class]] ) {
//            CPTStringArray *categories = newCategories;
//
//            names[cacheKey] = [NSMutableOrderedSet orderedSetWithArray:categories];
//        }
//        else {
//            [names removeObjectForKey:cacheKey];
//        }
//    }
//
//    /**
//     *  @brief Remove all categories for every coordinate.
//     */
    func removeAllCategories()
    {
        self.categoryNames = [:]
    }
//
//    /**
//     *  @brief Returns a list of all category names for the given coordinate.
//     *  @param coordinate The axis coordinate.
//     *  @return An array of category names.
//     */
    func categoriesForCoordinate(coordinate: CPTCoordinate)->[String]
    {
        let categories = self.orderedSetForCoordinate(coordinate: coordinate)

        return categories
    }
//
//    /**
//     *  @brief Returns the category name for the given coordinate at the given index in the list of category names.
//     *  @param coordinate The axis coordinate.
//     *  @param idx The index in the list of category names.
//     *  @return The category name.
//     */
//    -(nullable NSString *)categoryForCoordinate:(CPTCoordinate)coordinate atIndex:(NSUInteger)idx
//    {
//        CPTMutableCategorySet *categories = [self orderedSetForCoordinate:coordinate];
//
//        NSParameterAssert(idx < categories.count);
//
//        return categories[idx];
//    }
//
//    /**
//     *  @brief Returns the index of the given category name in the list of category names for the given coordinate.
//     *  @param category The category name.
//     *  @param coordinate The axis coordinate.
//     *  @return The category index.
//     */
//    -(NSUInteger)indexOfCategory:(nonnull NSString *)category forCoordinate:(CPTCoordinate)coordinate
//    {
//        NSParameterAssert(category);
//
//        CPTMutableCategorySet *categories = [self orderedSetForCoordinate:coordinate];
//
//        return [categories indexOfObject:category];
//    }

    
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
