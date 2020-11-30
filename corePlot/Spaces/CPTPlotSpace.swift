//
//  CPTPlotSpace.swift
//  corePlot
//
//  Created by thierryH24 on 14/11/2020.
//

import Cocoa


protocol CPTPlotSpaceDelegate: NSObject {

//@optional

    func plotSpace(space: CPTPlotSpace, interactionScale:CGFloat,  interactionPoint:CGPoint) -> Bool
    func plotSpace(space:  CPTPlotSpace , proposedDisplacementVector:CGPoint)-> CGPoint
    func plotSpace(space: CPTPlotSpace,  newRange: CPTPlotRange , coordinate:CPTCoordinate) -> CPTPlotRange
    
    func plotSpace(space: CPTPlotSpace, didChangePlotRangeForCoordinate coordinate: CPTCoordinate)
    func plotSpace(space: CPTPlotSpace, shouldHandlePointingDeviceDownEvent event : CPTNativeEvent,atPoint:CGPoint)-> Bool
    func plotSpace(space: CPTPlotSpace, shouldHandlePointingDeviceDraggedEvent event: CPTNativeEvent, atPoint:CGPoint)-> Bool
    func plotSpace(space: CPTPlotSpace, shouldHandlePointingDeviceCancelledEvent event:CPTNativeEvent)-> Bool
    func plotSpace(space: CPTPlotSpace, shouldHandlePointingDeviceUpEvent event: CPTNativeEvent,  atPoint:CGPoint)-> Bool
    func plotSpace(space: CPTPlotSpace, shouldHandleScrollWheelEvent event: CPTNativeEvent, fromPoint:CGPoint, toPoint:CGPoint)-> Bool
}


class CPTPlotSpace: NSObject {
    
    var categoryNames : Dictionary<Int, String >? = [:]
    var delegate : CPTPlotSpaceDelegate?
    var identifier : UUID?
    var allowsUserInteraction : Bool?
    var isDragging : Bool?
    var graph : CPTGraph?
    
    override init()
    {
        super.init()
        identifier            = UUID();
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
    func orderedSet(for coordinate: CPTCoordinate) -> CPTMutableCategorySet {
        var names = categoryNames

        if names == nil {
            names = [:]

            categoryNames = names
        }

        let cacheKey = NSNumber(value: coordinate)

        var categories = names[cacheKey]

        if categories == nil {
            categories = NSMutableOrderedSet()

            names[cacheKey] = categories
        }

        return categories
    }
    
    
    func addCategory(_ category: String, for coordinate: CPTCoordinate) {

        let categories = orderedSetForCoordinate(coordinate: coordinate)
        categories.add(category)
    }
    
    
    
    func removeCategory(category: String, forCoordinate coordinate:CPTCoordinate)
    {
        var categories = orderedSetForCoordinate(coordinate: coordinate)
        categories.remove(category)
    }
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
    func category(for coordinate: CPTCoordinate, at idx: Int) -> String? {
        
        let categories = orderedSet(for: coordinate)
        assert(idx < (categories?.count ?? 0), "Invalid parameter not satisfying: idx < (categories?.count ?? 0)")
        return categories?[idx] as? String
    }
    
    
    
    func indexOfCategory(_ category: String, for coordinate: CPTCoordinate) -> Int {
        guard category != "" else {
            
            
            CPTMutableCategorySet *categories = [self orderedSetForCoordinate:coordinate];

            return [categories indexOfObject:category];

        }
        
        let categories = orderedSet(for: coordinate)
        return categories?.indexOfObject(category) ?? 0
    }
}

