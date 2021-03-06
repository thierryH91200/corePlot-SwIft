//
//  CPTPlotSpace.swift
//  corePlot
//
//  Created by thierryH24 on 14/11/2020.
//

import AppKit

protocol CPTPlotSpaceDelegate: NSObject {
    
    func plotSpace( space: CPTPlotSpace, shouldScaleBy interactionScale : CGFloat, aboutPoint interactionPoint:CGPoint)-> Bool
    func plotSpace( space: CPTPlotSpace, willDisplaceBy proposedDisplacementVector :CGPoint)-> CGPoint
    func plotSpace( space: CPTPlotSpace, willChangePlotRangeTo newRange : CPTPlotRange, forCoordinate coordinate : CPTCoordinate) -> CPTPlotRange
    
    
    func plotSpace(space: CPTPlotSpace, interactionScale:CGFloat,  interactionPoint:CGPoint) -> Bool
    func plotSpace(space: CPTPlotSpace, proposedDisplacementVector:CGPoint)-> CGPoint
    
    //    func plotSpace(space: CPTPlotSpace, willChangePlotRangeTo newRange: CPTPlotRange,  coordinate:CPTCoordinate)-> CPTPlotRange
    
    func plotSpace(space: CPTPlotSpace, newRange: CPTPlotRange , coordinate:CPTCoordinate) -> CPTPlotRange
    
    func plotSpace(space: CPTPlotSpace, didChangePlotRangeForCoordinate coordinate: CPTCoordinate)
    func plotSpace(space: CPTPlotSpace, shouldHandlePointingDeviceDownEvent event : CPTNativeEvent,atPoint:CGPoint)-> Bool
    func plotSpace(space: CPTPlotSpace, shouldHandlePointingDeviceDraggedEvent event: CPTNativeEvent, atPoint:CGPoint)-> Bool
    func plotSpace(space: CPTPlotSpace, shouldHandlePointingDeviceCancelledEvent event:CPTNativeEvent)-> Bool
    func plotSpace(space: CPTPlotSpace, shouldHandlePointingDeviceUpEvent event: CPTNativeEvent,  atPoint:CGPoint)-> Bool
    func plotSpace(space: CPTPlotSpace, shouldHandleScrollWheelEvent event: CPTNativeEvent, fromPoint:CGPoint, toPoint:CGPoint)-> Bool
}

class CPTPlotSpace: NSObject {
    
    weak var delegate : CPTPlotSpaceDelegate?
    
    let CPTPlotSpaceCoordinateKey   = "CPTPlotSpaceCoordinateKey";
    let CPTPlotSpaceScrollingKey    = "CPTPlotSpaceScrollingKey";
    let CPTPlotSpaceDisplacementKey = "CPTPlotSpaceDisplacementKey";
    
    var categoryNames : Dictionary<Int, Set<String>>? = [:]
    var identifier : String?
    var allowsUserInteraction : Bool?
    var isDragging : Bool
    var graph : CPTGraph?
    
    override init()
    {
        super.init()
        identifier            = ""
        allowsUserInteraction = false
        isDragging            = false
        graph                 = nil
        delegate              = nil;
        categoryNames         = nil;
    }
    
    // MARK: - Categorical Data
    func orderedSetForCoordinate( coordinate: CPTCoordinate) -> NSMutableOrderedSet {
        
        //        typedef NSMutableOrderedSet<NSString *> CPTMutableCategorySet;
        
        var categoryNames: [Int :  NSMutableOrderedSet]?
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
        
        let categories = orderedSetForCoordinate(coordinate: coordinate)
        categories.insert(category, at: 0)
    }
    
    func removeCategory(category: String, forCoordinate coordinate:CPTCoordinate)
    {
        let categories = orderedSetForCoordinate(coordinate: coordinate)
        categories.remove( category)
    }
    
    func insertCategory(category: String, forCoordinate coordinate :CPTCoordinate, atIndex idx:Int)
    {
        let categories = self.orderedSetForCoordinate(coordinate:coordinate)
        categories.insert(category, at: 0)
    }
    
    func setCategories(newCategories: [String],  forCoordinate coordinate:CPTCoordinate)
    {
        var names = self.categoryNames
        
        if ( names?.isEmpty == true ) {
            names = (NSMutableDictionary() as! Dictionary<Int, Set<String>>)
            self.categoryNames = names;
        }
        
        let cacheKey = coordinate
        
        if newCategories is Array<String> {
            let categories = newCategories;
            names?[cacheKey.rawValue] = NSMutableOrderedSet(array: categories)        }
        else {
            names?.removeValue(forKey: cacheKey.rawValue)
        }
    }
    
    func removeObject(list: [CPTPlotSpace], element: CPTPlotSpace) {
        var list = list
        list = list.filter { $0 !== element }
    }
    
    /**
     brief Remove all categories for every coordinate.
     */
    func removeAllCategories()
    {
        self.categoryNames = [:]
    }
    
    func categoriesForCoordinate( coordinate: CPTCoordinate)->NSMutableOrderedSet
    {
        let categories = self.orderedSetForCoordinate(coordinate: coordinate)
        return categories
    }
    
    func categoryForCoordinate( coordinate: CPTCoordinate, at index: Int) -> String?
    {
        let categories = orderedSetForCoordinate(coordinate: coordinate)
        return categories[index] as? String
    }
    
    func indexOfCategory( category: String, for coordinate: CPTCoordinate) -> Int {
        guard category != "" else {
            
            let categories = self.orderedSetForCoordinate(coordinate:coordinate)
            return categories.index(of: category)
        }
        
        let categories = orderedSetForCoordinate(coordinate: coordinate)
        return categories.index(of: category)
    }
    
    
    // MARK: - Responder Chain and User interaction
    // https://izziswift.com/what-is-the-swift-equivalent-of-respondstoselector/
    func pointingDeviceDownEvent(event: CPTNativeEvent, atPoint interactionPoint : CGPoint)-> Bool
    {
        weak var theDelegate = self.delegate
        
        guard let handledByDelegate = theDelegate?.plotSpace(space: self, shouldHandlePointingDeviceDownEvent: event, atPoint: interactionPoint)
        else { return false}
        return handledByDelegate;
    }
    
    
    /**
     *  @brief Informs the receiver that the user has
     *  @if MacOnly released the mouse button. @endif
     *  @if iOSOnly lifted their finger off the screen. @endif
     *
     *
     *  If the receiver does not have a @link CPTPlotSpace::delegate delegate @endlink,
     *  this method always returns @NO. Otherwise, the
     *  @link CPTPlotSpaceDelegate::plotSpace:shouldHandlePointingDeviceUpEvent:atPoint: -plotSpace:shouldHandlePointingDeviceUpEvent:atPoint: @endlink
     *  delegate method is called. If it returns @NO, this method returns @YES
     *  to indicate that the event has been handled and no further processing should occur.
     *
     *  @param event The OS event.
     *  @param interactionPoint The coordinates of the interaction.
     *  @return Whether the event was handled or not.
     **/
    func pointingDeviceUpEvent(event:CPTNativeEvent,atPoint interactionPoint:CGPoint)-> Bool
    {
        let theDelegate = self.delegate
        
        guard let handledByDelegate = theDelegate?.plotSpace(space: self, shouldHandlePointingDeviceUpEvent: event, atPoint: interactionPoint)
        else { return false}
        return handledByDelegate;
    }
    
    func pointingDeviceDraggedEvent(event: CPTNativeEvent, atPoint interactionPoint:CGPoint) -> Bool
    {
        weak var theDelegate = self.delegate
        
        guard let handledByDelegate = theDelegate?.plotSpace(space: self, shouldHandlePointingDeviceDraggedEvent: event, atPoint: interactionPoint)
        else { return false}
        return handledByDelegate;
        
    }
    func pointingDeviceCancelledEvent(event : CPTNativeEvent )->Bool
    {
        weak var theDelegate = self.delegate
        
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
    
    /** @brief Converts a data point to plot area drawing coordinates.
     *  @param plotPoint A c-style array of data point coordinates (as NSDecimal structs).
     *  @param count The number of coordinate values in the @par{plotPoint} array.
     *  @return The drawing coordinates of the data point.
     **/
    func plotAreaViewPointForPlotPoint(plotPoint: [CGFloat], numberOfCoordinates count :Int)->CGPoint
    {
        return CGPoint()
    }
    
    /** @brief Converts a data point to plot area drawing coordinates.
     *  @param plotPoint A c-style array of data point coordinates (as @double values).
     *  @param count The number of coordinate values in the @par{plotPoint} array.
     *  @return The drawing coordinates of the data point.
     **/
    func plotAreaViewPointForDoublePrecisionPlotPoint(plotPoint: [Double], numberOfCoordinates count:Int)-> CGPoint
    {
        return CGPoint()
    }
    
    func plotPointForPlotAreaViewPoint(point: CGPoint ) -> CPTNumberArray?
    {
        return nil
    }
    
    /** @brief Converts a point given in plot area drawing coordinates to the data coordinate space.
     *  @param plotPoint A c-style array of data point coordinates (as NSDecimal structs).
     *  @param count The number of coordinate values in the @par{plotPoint} array.
     *  @param point The drawing coordinates of the data point.
     **/
    func plotPoint(plotPoint: [CGFloat],  numberOfCoordinates count :Int , forPlotAreaViewPoint point: CGPoint)
    {
        assert(count == self.numberOfCoordinates())
    }
    
    /** @brief Converts a point given in drawing coordinates to the data coordinate space.
     *  @param plotPoint A c-style array of data point coordinates (as @double values).
     *  @param count The number of coordinate values in the @par{plotPoint} array.
     *  @param point The drawing coordinates of the data point.
     **/
    func doublePrecisionPlotPoint(_ plotPoint: Double, numberOfCoordinates count: Int, forPlotAreaViewPoint point: CGPoint) {
        assert(count == count, "Invalid parameter not satisfying: count == numberOfCoordinates")
    }
    
    /** @brief Converts the interaction point of an OS event to plot area drawing coordinates.
     *  @param event The event.
     *  @return The drawing coordinates of the point.
     **/
    func plotAreaViewPointForEvent(event: CPTNativeEvent) -> CGPoint
    {
        return CGPoint()
    }
    
    /** @brief Converts the interaction point of an OS event to the data coordinate space.
     *  @param event The event.
     *  @return An array of data point coordinates (as NSNumber values).
     **/
    func plotPointForEvent(event: CPTNativeEvent)-> CPTNumberArray?
    {
        return nil;
    }
    
    /** @brief Converts the interaction point of an OS event to the data coordinate space.
     *  @param plotPoint A c-style array of data point coordinates (as NSDecimal structs).
     *  @param count The number of coordinate values in the @par{plotPoint} array.
     *  @param event The event.
     **/
    func plotPoint(plotPoint: CGFloat, numberOfCoordinates count: Int, forEvent event: CPTNativeEvent)
    {
        //    NSParameterAssert(count == self.numberOfCoordinates);
        
    }
    
    /** @brief Converts the interaction point of an OS event to the data coordinate space.
     *  @param plotPoint A c-style array of data point coordinates (as @double values).
     *  @param count The number of coordinate values in the @par{plotPoint} array.
     *  @param event The event.
     **/
    func doublePrecisionPlotPoint(plotPoint: Double, numberOfCoordinates count: Int, forEvent event: CPTNativeEvent)
    {
        //        assert(count == numberOfCoordinates, "Invalid parameter not satisfying: count == numberOfCoordinates")
        
    }
    
    /** @brief Sets the range of values for a given coordinate.
     *  @param newRange The new plot range.
     *  @param coordinate The axis coordinate.
     **/
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
    func scaleToFitPlots( plots: [CPTPlot]?, forCoordinate coordinate: CPTCoordinate) {
        
        guard plots?.count != 0 else { return }
        
        // Determine union of ranges
        var unionRange : CPTMutablePlotRange?
        
        //        if let plots = plots {
        for plot in plots! {
            //                guard let plot = plot as? CPTPlot else { continue }
            
            let currentRange = plot.plotRangeForCoordinate(coord: coordinate)
            if unionRange == nil {
                unionRange = currentRange as? CPTMutablePlotRange
            }
            unionRange?.unionPlotRange(other: currentRange)
        }
        //        }
        
        // Set range
        if let unionRange = unionRange {
            if unionRange.lengthDecimal == CGFloat(0) {
                unionRange.unionPlotRange(other: plotRangeForCoordinate( coordinate: coordinate))
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
        guard plots.isEmpty  == false else { return }
        // Determine union of ranges
        var unionRange : CPTMutablePlotRange?
        
        for plot in plots {
            let currentRange = plot.plotRangeForCoordinate(coord: coordinate)
            if ( (unionRange == nil) ) {
                unionRange = currentRange as? CPTMutablePlotRange
            }
            unionRange?.unionPlotRange(other: currentRange)
        }
        
        // Set range
        if (( unionRange ) != nil) {
            if unionRange?.lengthDecimal == CGFloat(0) {
                unionRange?.unionPlotRange(other: self.plotRangeForCoordinate(coordinate: coordinate))
            }
            self.setPlotRange(newRange: unionRange!, forCoordinate:coordinate)
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
