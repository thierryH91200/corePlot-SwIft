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
    func plotSpace(space: CPTPlotSpace, proposedDisplacementVector:CGPoint)-> CGPoint
    func plotSpace(space: CPTPlotSpace, newRange: CPTPlotRange , coordinate:CPTCoordinate) -> CPTPlotRange
    
    func plotSpace(space: CPTPlotSpace, didChangePlotRangeForCoordinate coordinate: CPTCoordinate)
    func plotSpace(space: CPTPlotSpace, shouldHandlePointingDeviceDownEvent event : CPTNativeEvent,atPoint:CGPoint)-> Bool
    func plotSpace(space: CPTPlotSpace, shouldHandlePointingDeviceDraggedEvent event: CPTNativeEvent, atPoint:CGPoint)-> Bool
    func plotSpace(space: CPTPlotSpace, shouldHandlePointingDeviceCancelledEvent event:CPTNativeEvent)-> Bool
    func plotSpace(space: CPTPlotSpace, shouldHandlePointingDeviceUpEvent event: CPTNativeEvent,  atPoint:CGPoint)-> Bool
    func plotSpace(space: CPTPlotSpace, shouldHandleScrollWheelEvent event: CPTNativeEvent, fromPoint:CGPoint, toPoint:CGPoint)-> Bool
}


class CPTPlotSpace: NSObject {
    
    var categoryNames : Dictionary<Int, String >? = [:]
    weak var delegate : CPTPlotSpaceDelegate?
    var identifier : UUID?
    var allowsUserInteraction : Bool?
    var isDragging : Bool
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
    
    // MARK: - Categorical Data
    //
    //    /// @cond
    //
    //    /** @internal
    //     *  @brief Gets the ordered set of categories for the given coordinate, creating it if necessary.
    //     *  @param coordinate The axis coordinate.
    //     *  @return The ordered set of categories for the given coordinate.
    //     */
    func orderedSet(for coordinate: CPTCoordinate) -> [String] {
        var names = categoryNames
        
        if names == nil {
            names = [:]
            
            categoryNames = names
        }
        
        let cacheKey = coordinate.rawValue
        var categories = names?[cacheKey]
        
        if categories == nil {
            categories = NSMutableOrderedSet()
            names?[cacheKey] = categories
        }
        return categories!
    }
    
    
    func addCategory(_ category: String, for coordinate: CPTCoordinate) {
        
        var categories = orderedSet(for: coordinate)
        categories.append(category)
    }
    
    func removeCategory(category: String, forCoordinate coordinate:CPTCoordinate)
    {
        var categories = orderedSet(for: coordinate)
        categories.remove( category)
    }
    
    func insertCategory(category: String, forCoordinate coordinate :CPTCoordinate, atIndex idx:Int)
    {
        var categories = self.orderedSet(for:coordinate)
        categories.insert(category, atIndex:idx)
    }
    
    func setCategories(newCategories: [String],  forCoordinate coordinate:CPTCoordinate)
    {
        let names = self.categoryNames;
        
        if ( !names ) {
            names = [String]()
            
            self.categoryNames = names;
        }
        
        let cacheKey = coordinate
        
        if newCategories is Array<Any> {
            let categories = newCategories;
            
            names[cacheKey] = [NSMutableOrderedSet orderedSetWithArray:categories];
        }
        else {
            names.removeObjectForKey(cacheKey)
        }
    }
    //
    //    /**
    //     *  @brief Remove all categories for every coordinate.
    //     */
    func removeAllCategories()
    {
        self.categoryNames = [:]
    }
    //
    func categoriesForCoordinate(coordinate: CPTCoordinate)->[String]
    {
        let categories = self.orderedSet(for: coordinate)
        return categories
    }
    
    func category(for coordinate: CPTCoordinate, at idx: Int) -> String? {
        
        let categories = orderedSet(for: coordinate)
        return categories[idx]
    }
    
    func indexOfCategory(_ category: String, for coordinate: CPTCoordinate) -> Int {
        guard category != "" else {
            
            let categories = self.orderedSet(for:coordinate)
            return categories.indexOfObject(category)
        }
        
        let categories = orderedSet(for: coordinate)
        return categories.indexOfObject(category) ?? 0
    }
    
    
    //    pragma mark -
    //    #pragma mark Responder Chain and User interaction
    
    // https://izziswift.com/what-is-the-swift-equivalent-of-respondstoselector/
    func pointingDeviceDownEven(event: CPTNativeEvent, atPoint interactionPoint:CGPoint)-> Bool
    {
        let theDelegate = self.delegate
        
        guard let handledByDelegate = theDelegate?.plotSpace(space: self, shouldHandlePointingDeviceDownEvent: event, atPoint: interactionPoint)
        else { return false}
        return handledByDelegate;
    }
    
    //
    //    /**
    //     *  @brief Informs the receiver that the user has
    //     *  @if MacOnly released the mouse button. @endif
    //     *  @if iOSOnly lifted their finger off the screen. @endif
    //     *
    //     *
    //     *  If the receiver does not have a @link CPTPlotSpace::delegate delegate @endlink,
    //     *  this method always returns @NO. Otherwise, the
    //     *  @link CPTPlotSpaceDelegate::plotSpace:shouldHandlePointingDeviceUpEvent:atPoint: -plotSpace:shouldHandlePointingDeviceUpEvent:atPoint: @endlink
    //     *  delegate method is called. If it returns @NO, this method returns @YES
    //     *  to indicate that the event has been handled and no further processing should occur.
    //     *
    //     *  @param event The OS event.
    //     *  @param interactionPoint The coordinates of the interaction.
    //     *  @return Whether the event was handled or not.
    //     **/
    func pointingDeviceUpEvent(event:CPTNativeEvent,atPoint interactionPoint:CGPoint)-> Bool
    {
        let theDelegate = self.delegate
        
        guard let handledByDelegate = theDelegate?.plotSpace(space: self, shouldHandlePointingDeviceUpEvent: event, atPoint: interactionPoint)
        else { return false}
        return handledByDelegate;
    }
    
    //    /**
    //     *  @brief Informs the receiver that the user has moved
    //     *  @if MacOnly the mouse with the button pressed. @endif
    //     *  @if iOSOnly their finger while touching the screen. @endif
    //     *
    //     *
    //     *  If the receiver does not have a @ref delegate,
    //     *  this method always returns @NO. Otherwise, the
    //     *  @link CPTPlotSpaceDelegate::plotSpace:shouldHandlePointingDeviceDraggedEvent:atPoint: -plotSpace:shouldHandlePointingDeviceDraggedEvent:atPoint: @endlink
    //     *  delegate method is called. If it returns @NO, this method returns @YES
    //     *  to indicate that the event has been handled and no further processing should occur.
    //     *
    //     *  @param event The OS event.
    //     *  @param interactionPoint The coordinates of the interaction.
    //     *  @return Whether the event was handled or not.
    //     **/
    func pointingDeviceDraggedEvent(event: CPTNativeEvent, atPoint interactionPoint:CGPoint) -> Bool
    {
        let theDelegate = self.delegate
        
        guard let handledByDelegate = theDelegate?.plotSpace(space: self, shouldHandlePointingDeviceDraggedEvent: event, atPoint: interactionPoint)
        else { return false}
        return handledByDelegate;
        
    }
    //
    //    /**
    //     *  @brief Informs the receiver that tracking of
    //     *  @if MacOnly mouse moves @endif
    //     *  @if iOSOnly touches @endif
    //     *  has been cancelled for any reason.
    //     *
    //     *
    //     *  If the receiver does not have a @ref delegate,
    //     *  this method always returns @NO. Otherwise, the
    //     *  @link CPTPlotSpaceDelegate::plotSpace:shouldHandlePointingDeviceCancelledEvent: -plotSpace:shouldHandlePointingDeviceCancelledEvent: @endlink
    //     *  delegate method is called. If it returns @NO, this method returns @YES
    //     *  to indicate that the event has been handled and no further processing should occur.
    //     *
    //     *  @param event The OS event.
    //     *  @return Whether the event was handled or not.
    //     **/
    func pointingDeviceCancelledEvent(event : CPTNativeEvent )->Bool
    {
        let theDelegate = self.delegate
        
        guard let handledByDelegate = theDelegate?.plotSpace(space: self, shouldHandlePointingDeviceCancelledEvent: event)
        else { return false}
        return handledByDelegate;
    }
    //
    #if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
    #else
    //
    //    /**
    //     *  @brief Informs the receiver that the user has moved the scroll wheel.
    //     *
    //     *
    //     *  If the receiver does not have a @ref delegate,
    //     *  this method always returns @NO. Otherwise, the
    //     *  @link CPTPlotSpaceDelegate::plotSpace:shouldHandleScrollWheelEvent:fromPoint:toPoint: -plotSpace:shouldHandleScrollWheelEvent:fromPoint:toPoint: @endlink
    //     *  delegate method is called. If it returns @NO, this method returns @YES
    //     *  to indicate that the event has been handled and no further processing should occur.
    //     *
    //     *  @param event The OS event.
    //     *  @param fromPoint The starting coordinates of the interaction.
    //     *  @param toPoint The ending coordinates of the interaction.
    //     *  @return Whether the event was handled or not.
    //     **/
    func scrollWheelEvent(event: CPTNativeEvent, fromPoint:CGPoint, toPoint:CGPoint)-> Bool
    {
        let theDelegate = self.delegate
        
        guard let handledByDelegate = theDelegate?.plotSpace(space: self, shouldHandleScrollWheelEvent: event, fromPoint:fromPoint, toPoint:toPoint )
        else { return false}
        return handledByDelegate;
    }
    
    // MARK: - AbstractMethods
    //    -(NSUInteger)numberOfCoordinates
    //    {
    //        return 0;
    //    }
    //
    //    /// @endcond
    //
    //    /** @brief Converts a data point to plot area drawing coordinates.
    //     *  @param plotPoint An array of data point coordinates (as NSNumber values).
    //     *  @return The drawing coordinates of the data point.
    //     **/
    //    -(CGPoint)plotAreaViewPointForPlotPoint:(nonnull CPTNumberArray *cpt_unused)plotPoint
    //    {
    //        NSParameterAssert(plotPoint.count == self.numberOfCoordinates);
    //
    //        return CGPointZero;
    //    }
    //
    //    /** @brief Converts a data point to plot area drawing coordinates.
    //     *  @param plotPoint A c-style array of data point coordinates (as NSDecimal structs).
    //     *  @param count The number of coordinate values in the @par{plotPoint} array.
    //     *  @return The drawing coordinates of the data point.
    //     **/
    //    -(CGPoint)plotAreaViewPointForPlotPoint:(nonnull NSDecimal *__unused)plotPoint numberOfCoordinates:(NSUInteger cpt_unused)count
    //    {
    //        NSParameterAssert(count == self.numberOfCoordinates);
    //
    //        return CGPointZero;
    //    }
    //
    //    /** @brief Converts a data point to plot area drawing coordinates.
    //     *  @param plotPoint A c-style array of data point coordinates (as @double values).
    //     *  @param count The number of coordinate values in the @par{plotPoint} array.
    //     *  @return The drawing coordinates of the data point.
    //     **/
    //    -(CGPoint)plotAreaViewPointForDoublePrecisionPlotPoint:(nonnull double *__unused)plotPoint numberOfCoordinates:(NSUInteger cpt_unused)count
    //    {
    //        NSParameterAssert(count == self.numberOfCoordinates);
    //
    //        return CGPointZero;
    //    }
    //
    //    /** @brief Converts a point given in plot area drawing coordinates to the data coordinate space.
    //     *  @param point The drawing coordinates of the data point.
    //     *  @return An array of data point coordinates (as NSNumber values).
    //     **/
    //    -(nullable CPTNumberArray *)plotPointForPlotAreaViewPoint:(CGPoint __unused)point
    //    {
    //        return nil;
    //    }
    //
    //    /** @brief Converts a point given in plot area drawing coordinates to the data coordinate space.
    //     *  @param plotPoint A c-style array of data point coordinates (as NSDecimal structs).
    //     *  @param count The number of coordinate values in the @par{plotPoint} array.
    //     *  @param point The drawing coordinates of the data point.
    //     **/
    //    -(void)plotPoint:(nonnull NSDecimal *__unused)plotPoint numberOfCoordinates:(NSUInteger cpt_unused)count forPlotAreaViewPoint:(CGPoint __unused)point
    //    {
    //        NSParameterAssert(count == self.numberOfCoordinates);
    //    }
    //
    //    /** @brief Converts a point given in drawing coordinates to the data coordinate space.
    //     *  @param plotPoint A c-style array of data point coordinates (as @double values).
    //     *  @param count The number of coordinate values in the @par{plotPoint} array.
    //     *  @param point The drawing coordinates of the data point.
    //     **/
    //    -(void)doublePrecisionPlotPoint:(nonnull double *__unused)plotPoint numberOfCoordinates:(NSUInteger cpt_unused)count forPlotAreaViewPoint:(CGPoint __unused)point
    //    {
    //        NSParameterAssert(count == self.numberOfCoordinates);
    //    }
    //
    //    /** @brief Converts the interaction point of an OS event to plot area drawing coordinates.
    //     *  @param event The event.
    //     *  @return The drawing coordinates of the point.
    //     **/
    //    -(CGPoint)plotAreaViewPointForEvent:(nonnull CPTNativeEvent *__unused)event
    //    {
    //        return CGPointZero;
    //    }
    //
    //    /** @brief Converts the interaction point of an OS event to the data coordinate space.
    //     *  @param event The event.
    //     *  @return An array of data point coordinates (as NSNumber values).
    //     **/
    //    -(nullable CPTNumberArray *)plotPointForEvent:(nonnull CPTNativeEvent *__unused)event
    //    {
    //        return nil;
    //    }
    //
    //    /** @brief Converts the interaction point of an OS event to the data coordinate space.
    //     *  @param plotPoint A c-style array of data point coordinates (as NSDecimal structs).
    //     *  @param count The number of coordinate values in the @par{plotPoint} array.
    //     *  @param event The event.
    //     **/
    //    -(void)plotPoint:(nonnull NSDecimal *__unused)plotPoint numberOfCoordinates:(NSUInteger cpt_unused)count forEvent:(nonnull CPTNativeEvent *__unused)event
    //    {
    //        NSParameterAssert(count == self.numberOfCoordinates);
    //    }
    //
    //    /** @brief Converts the interaction point of an OS event to the data coordinate space.
    //     *  @param plotPoint A c-style array of data point coordinates (as @double values).
    //     *  @param count The number of coordinate values in the @par{plotPoint} array.
    //     *  @param event The event.
    //     **/
    //    -(void)doublePrecisionPlotPoint:(nonnull double *__unused)plotPoint numberOfCoordinates:(NSUInteger cpt_unused)count forEvent:(nonnull CPTNativeEvent *__unused)event
    //    {
    //        NSParameterAssert(count == self.numberOfCoordinates);
    //    }
    //
    //    /** @brief Sets the range of values for a given coordinate.
    //     *  @param newRange The new plot range.
    //     *  @param coordinate The axis coordinate.
    //     **/
    //    -(void)setPlotRange:(nonnull CPTPlotRange *__unused)newRange forCoordinate:(CPTCoordinate __unused)coordinate
    //    {
    //    }
    //
    //    /** @brief Gets the range of values for a given coordinate.
    //     *  @param coordinate The axis coordinate.
    //     *  @return The range of values.
    //     **/
    //    -(nullable CPTPlotRange *)plotRangeForCoordinate:(CPTCoordinate __unused)coordinate
    //    {
    //        return nil;
    //    }
    //
    //    /** @brief Sets the scale type for a given coordinate.
    //     *  @param newType The new scale type.
    //     *  @param coordinate The axis coordinate.
    //     **/
    //    -(void)setScaleType:(CPTScaleType __unused)newType forCoordinate:(CPTCoordinate __unused)coordinate
    //    {
    //    }
    //
    //    /** @brief Gets the scale type for a given coordinate.
    //     *  @param coordinate The axis coordinate.
    //     *  @return The scale type.
    //     **/
    
    func scaleTypeForCoordinate(coordinate: CPTCoordinate ) ->CPTScaleType
    {
        return CPTScaleType.linear;
    }
    
    //
    //    /** @brief Scales the plot ranges so that the plots just fit in the visible space.
    //     *  @param plots An array of the plots that have to fit in the visible area.
    //     **/
    //    -(void)scaleToFitPlots:(nullable CPTPlotArray *__unused)plots
    //    {
    //    }
    //
    //    /** @brief Scales the plot range for the given coordinate so that the plots just fit in the visible space.
    //     *  @param plots An array of the plots that have to fit in the visible area.
    //     *  @param coordinate The axis coordinate.
    //     **/
    func scale(toFitPlots plots: CPTPlotArray?, for coordinate: CPTCoordinate) {
        if plots?.count == 0 {
            return
        }
        
        // Determine union of ranges
        var unionRange: CPTMutablePlotRange? = nil
        
        if let plots = plots {
            for plot in plots {
                guard let plot = plot as? CPTPlot else {
                    continue
                }
                let currentRange = plot.plotRange(for: coordinate)
                if unionRange == nil {
                    unionRange = currentRange
                }
                unionRange?.union(currentRange)
            }
        }
        
        // Set range
        if let unionRange = unionRange {
            if CPTDecimalEquals(unionRange.lengthDecimal, CPTDecimalFromInteger(0)) {
                unionRange.union(plotRange(for: coordinate))
            }
            setPlotRange(unionRange, for: coordinate)
        }
    }

    //
    //    /** @brief Scales the plot ranges so that the plots just fit in the visible space.
    //     *  @param plots An array of the plots that have to fit in the visible area.
    //     **/
    //    -(void)scaleToFitEntirePlots:(nullable CPTPlotArray *__unused)plots
    //    {
    //    }
    //
    //    /** @brief Scales the plot range for the given coordinate so that the plots just fit in the visible space.
    //     *  @param plots An array of the plots that have to fit in the visible area.
    //     *  @param coordinate The axis coordinate.
    //     **/
    //    -(void)scaleToFitEntirePlots:(nullable CPTPlotArray *)plots forCoordinate:(CPTCoordinate)coordinate
    //    {
    //        if ( plots.count == 0 ) {
    //            return;
    //        }
    //
    //        // Determine union of ranges
    //        CPTMutablePlotRange *unionRange = nil;
    //
    //        for ( CPTPlot *plot in plots ) {
    //            CPTPlotRange *currentRange = [plot plotRangeForCoordinate:coordinate];
    //            if ( !unionRange ) {
    //                unionRange = [currentRange mutableCopy];
    //            }
    //            [unionRange unionPlotRange:currentRange];
    //        }
    //
    //        // Set range
    //        if ( unionRange ) {
    //            if ( CPTDecimalEquals(unionRange.lengthDecimal, CPTDecimalFromInteger(0))) {
    //                [unionRange unionPlotRange:[self plotRangeForCoordinate:coordinate]];
    //            }
    //            [self setPlotRange:unionRange forCoordinate:coordinate];
    //        }
    //    }
    //
    //    /** @brief Zooms the plot space equally in each dimension.
    //     *  @param interactionScale The scaling factor. One (@num{1}) gives no scaling.
    //     *  @param interactionPoint The plot area view point about which the scaling occurs.
    //     **/
    //    -(void)scaleBy:(CGFloat __unused)interactionScale aboutPoint:(CGPoint __unused)interactionPoint
    //    {
    //    }
    //
    
}

