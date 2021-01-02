//
//  CPTPlotSpace.swift
//  corePlot
//
//  Created by thierryH24 on 14/11/2020.
//

import AppKit

protocol CPTPlotSpaceDelegate: NSObject {
    
    
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
    
    let CPTPlotSpaceCoordinateKey   = "CPTPlotSpaceCoordinateKey";
    let CPTPlotSpaceScrollingKey    = "CPTPlotSpaceScrollingKey";
    let CPTPlotSpaceDisplacementKey = "CPTPlotSpaceDisplacementKey";
    
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
        categories.insert(category, at:idx)
    }
    
    func setCategories(newCategories: [String],  forCoordinate coordinate:CPTCoordinate)
    {
        let names = self.categoryNames;
        
        if ( (names == nil) ) {
            names = [String]()
            
            self.categoryNames = names;
        }
        
        let cacheKey = coordinate
        
        if newCategories is [String] {
            let categories = newCategories;
            
            names[cacheKey] = orderedSetWithArray(categories)
        }
        else {
            names.removeObjectForKey(cacheKey)
        }
    }
    
    func removeObject(list: [CPTPlotSpace], element: CPTPlotSpace) {
        var list = list
        list = list.filter { $0 !== element }
    }
    
    //    /**
    // brief Remove all categories for every coordinate.
    //     */
    func removeAllCategories()
    {
        self.categoryNames = [:]
    }
    
    func categoriesForCoordinate(coordinate: CPTCoordinate)->[String]
    {
        let categories = self.orderedSet(for: coordinate)
        return categories
    }
    
    func category(for coordinate: CPTCoordinate, at index: Int) -> String?
    {
        let categories = orderedSet(for: coordinate)
        return categories[index]
    }
    
    func indexOfCategory(_ category: String, for coordinate: CPTCoordinate) -> Int {
        guard category != "" else {
            
            let categories = self.orderedSet(for:coordinate)
            return categories.indexOfObject(category)
        }
        
        let categories = orderedSet(for: coordinate)
        return categories.indexOfObject(category) ?? 0
    }
    
    
    // MARK: - Responder Chain and User interaction
    // https://izziswift.com/what-is-the-swift-equivalent-of-respondstoselector/
    func pointingDeviceDownEvent(event: CPTNativeEvent, atPoint interactionPoint : CGPoint)-> Bool
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
    
    func pointingDeviceDraggedEvent(event: CPTNativeEvent, atPoint interactionPoint:CGPoint) -> Bool
    {
        let theDelegate = self.delegate
        
        guard let handledByDelegate = theDelegate?.plotSpace(space: self, shouldHandlePointingDeviceDraggedEvent: event, atPoint: interactionPoint)
        else { return false}
        return handledByDelegate;
        
    }
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
    #endif
    
    
    func scrollWheelEvent(event: CPTNativeEvent, fromPoint:CGPoint, toPoint:CGPoint)-> Bool
    {
        let theDelegate = self.delegate
        
        guard let handledByDelegate = theDelegate?.plotSpace(space: self, shouldHandleScrollWheelEvent: event, fromPoint:fromPoint, toPoint:toPoint )
        else { return false}
        return handledByDelegate;
    }
    
    // MARK: - AbstractMethods
    func numberOfCoordinates()->Int
    {
        return 0
    }
    func plotAreaViewPointForPlotPoint(plotPoint:  CPTNumberArray)->CGPoint
    {
        return CGPoint()
    }
    //
    //    /** @brief Converts a data point to plot area drawing coordinates.
    //     *  @param plotPoint A c-style array of data point coordinates (as NSDecimal structs).
    //     *  @param count The number of coordinate values in the @par{plotPoint} array.
    //     *  @return The drawing coordinates of the data point.
    //     **/
    func plotAreaViewPointForPlotPoint(plotPoint: [CGFloat], numberOfCoordinates count :Int)->CGPoint
    {
        return CGPoint()
    }
    //
    //    /** @brief Converts a data point to plot area drawing coordinates.
    //     *  @param plotPoint A c-style array of data point coordinates (as @double values).
    //     *  @param count The number of coordinate values in the @par{plotPoint} array.
    //     *  @return The drawing coordinates of the data point.
    //     **/
    func plotAreaViewPointForDoublePrecisionPlotPoint(plotPoint: Double, numberOfCoordinates count:Int)-> CGPoint
        {
            return CGPoint()
        }

    func plotPointForPlotAreaViewPoint(point: CGPoint ) -> CPTNumberArray?
    {
        return nil
    }
    //
    //    /** @brief Converts a point given in plot area drawing coordinates to the data coordinate space.
    //     *  @param plotPoint A c-style array of data point coordinates (as NSDecimal structs).
    //     *  @param count The number of coordinate values in the @par{plotPoint} array.
    //     *  @param point The drawing coordinates of the data point.
    //     **/
    func plotPoint(plotPoint: [CGFloat],  numberOfCoordinates count :Int , forPlotAreaViewPoint point: CGPoint)
    {
        assert(count == self.numberOfCoordinates())
    }
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
    func  setPlotRange(newRange:  CPTPlotRange, forCoordinate coordinate :CPTCoordinate)
    {
    }
    
    //
    //    /** @brief Gets the range of values for a given coordinate.
    //     *  @param coordinate The axis coordinate.
    //     *  @return The range of values.
    //     **/
    func plotRangeForCoordinate(coordinate: CPTCoordinate )->CPTPlotRange?
    {
        return nil
    }
    
    //    /** @brief Sets the scale type for a given coordinate.
    //     *  @param newType The new scale type.
    //     *  @param coordinate The axis coordinate.
    //     **/
    func setScaleType(_ newType: CPTScaleType, for coordinate: CPTCoordinate) {
    }
    
    
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
    func scaleToFitPlots(plots: [CPTPlot] )
    {
    }
    
    
    //    /** @brief Scales the plot range for the given coordinate so that the plots just fit in the visible space.
    //     *  @param plots An array of the plots that have to fit in the visible area.
    //     *  @param coordinate The axis coordinate.
    //     **/
    func scaleToFitPlots( plots: [CPTPlot]?, for coordinate: CPTCoordinate) {
        guard plots?.count != 0 else { return }
        
        // Determine union of ranges
        var unionRange: CPTMutablePlotRange? = nil
        
        if let plots = plots {
            for plot in plots {
//                guard let plot = plot as? CPTPlot else { continue }
                
                let currentRange = plot.plotRange(for: coordinate)
                if unionRange == nil {
                    unionRange = currentRange
                }
                unionRange?.union(currentRange)
            }
        }
        
        // Set range
        if let unionRange = unionRange {
            if unionRange.lengthDecimal == CGFloat(0) {
                unionRange.union(plotRange(for: coordinate))
            }
            setPlotRange(newRange: unionRange, forCoordinate: coordinate)
        }
    }
    
    
    /** @brief Scales the plot ranges so that the plots just fit in the visible space.
     *  @param plots An array of the plots that have to fit in the visible area.
     **/
    func scaleToFitEntirePlots(plots: [CPTPlot])
    {
    }
    
    /** @brief Scales the plot range for the given coordinate so that the plots just fit in the visible space.
     *  @param plots An array of the plots that have to fit in the visible area.
     *  @param coordinate The axis coordinate.
     **/
    func scaleToFitEntirePlots(plots: [CPTPlot], forCoordinate coordinate: CPTCoordinate)
    {
        if ( plots.count == 0 ) {
            return;
        }
        
        // Determine union of ranges
        var unionRange : CPTMutablePlotRange?
        
        for plot in plots {
            let currentRange = plot.plotRangeForCoordinate(coord: coordinate)
            if ( (unionRange == nil) ) {
                unionRange = currentRange
            }
            unionRange?.unionPlotRange(other: currentRange)
        }
        
        // Set range
        if (( unionRange ) != nil) {
            if unionRange?.lengthDecimal == CGFloat(0) {
                unionRange.unionPlotRange(self, plotRangeForCoordinate(coordinate))
            }
            self.setPlotRange(newRange: unionRange, forCoordinate:coordinate)
        }
    }
    
    /** @brief Zooms the plot space equally in each dimension.
     *  @param interactionScale The scaling factor. One (@num{1}) gives no scaling.
     *  @param interactionPoint The plot area view point about which the scaling occurs.
     **/
    func scale(by interactionScale: CGFloat, aboutPoint interactionPoint: CGPoint)
    {
    }
    
    
    
    
}
