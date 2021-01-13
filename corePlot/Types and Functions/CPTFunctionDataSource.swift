//
//  CPTFunctionDataSource.swift
//  corePlot
//
//  Created by thierryH24 on 04/12/2020.
//

import AppKit

class CPTFunctionDataSource: NSObject <CPTPlotDataSource> {

//    typedef double (*CPTDataSourceFunction)(double);
//    static void *CPTFunctionDataSourceKVOContext = (void *)&CPTFunctionDataSourceKVOContext;


    
    var  dataSourceFunction: CPTDataSourceFunction
    var dataSourceBlock : CPTDataSourceBlock?
    var dataPlot : CPTPlot?
    var dataRange:  CPTPlotRange?

    var cachedStep = 0.0
    var cachedCount = 0
    var dataCount = 0;
    var cachedPlotRange : CPTMutablePlotRange

    
    
// MARK: - Init/Dealloc
//
//    /** @brief Creates and returns a new CPTFunctionDataSource instance initialized with the provided function and plot.
//     *  @param plot The plot that will display the function values.
//     *  @param function The function used to generate plot data.
//     *  @return A new CPTFunctionDataSource instance initialized with the provided function and plot.
//     **/
//    +(nonnull instancetype)dataSourceForPlot:(nonnull CPTPlot *)plot withFunction:(nonnull CPTDataSourceFunction)function
//    {
//        return [[self alloc] initForPlot:plot withFunction:function];
//    }
//
//    /** @brief Creates and returns a new CPTFunctionDataSource instance initialized with the provided block and plot.
//     *  @param plot The plot that will display the function values.
//     *  @param block The Objective-C block used to generate plot data.
//     *  @return A new CPTFunctionDataSource instance initialized with the provided block and plot.
//     **/
//    +(nonnull instancetype)dataSourceForPlot:(nonnull CPTPlot *)plot withBlock:(nonnull CPTDataSourceBlock)block
//    {
//        return [[self alloc] initForPlot:plot withBlock:block];
//    }
//
//    /** @brief Initializes a newly allocated CPTFunctionDataSource object with the provided function and plot.
//     *  @param plot The plot that will display the function values.
//     *  @param function The function used to generate plot data.
//     *  @return The initialized CPTFunctionDataSource object.
//     **/
    init(plot: CPTPlot , withFunction function: CPTDataSourceFunction)
    {
        self.init(plot:plot)
        dataSourceFunction = function
        plot.dataSource = self
    }
    
//
//    /** @brief Initializes a newly allocated CPTFunctionDataSource object with the provided block and plot.
//     *  @param plot The plot that will display the function values.
//     *  @param block The Objective-C block used to generate plot data.
//     *  @return The initialized CPTFunctionDataSource object.
//     **/
//    -(nonnull instancetype)initForPlot:(nonnull CPTPlot *)plot withBlock:(nonnull CPTDataSourceBlock)block
//    {
//
//        if ((self = [self initForPlot:plot])) {
//            dataSourceBlock = block;
//
//            plot.dataSource = self;
//        }
//        return self;
//    }
    init(plot: CPTPlot )
    {
        super.init()
            dataPlot           = plot;
            dataSourceFunction = NULL;
            dataSourceBlock    = nil;
            resolution         = CGFloat(1.0);
            cachedStep         = 0.0;
            dataCount          = 0;
            cachedCount        = 0;
            cachedPlotRange    = nil;
            dataRange          = nil;
            
            plot.cachePrecision = CPTPlotCachePrecisionDouble;
            
        NotificationCenter.receive(
            instance: self,
            name:.CPTLayerBoundsDidChangeNotification,
            selector:#selector(plotBoundsChanged),
            object:plot)
        
        plot.addObserver(
            self,
             forKeyPath:  "plotSpace",
            options: NSKeyValueObservingOptions.new | NSKeyValueObservingOptions.old | NSKeyValueObservingOptions.initial,
             context:CPTFunctionDataSourceKVOContext)
        
    }



    // function and plot are required; this will fail the assertions in -initForPlot:withFunction:
    convenience init() {
        NSException.raise(CPTException, format: "%@ must be initialized with a function or a block.", NSStringFromClass(type(of: self).self))
        self.init(for: CPTScatterPlot.layer(), withFunction: sin)
    }
    
    
// MARK: - Accessors
    var _resolution = CGFloat(0)
    var resolution : CGFloat {
        get { return _resolution   }
        set {
            if ( newValue != _resolution ) {
                _resolution = newValue;
                self.cachedCount     = 0
                self.cachedPlotRange = nil;
                
                self.plotBoundsChanged()
            }
        }
    }

    func setDataRange(newRange: CPTPlotRange )
    {
        if ( newRange != dataRange ) {
            dataRange = newRange;

            if dataRange.containsRange(self.cachedPlotRange ) == false {
                self.cachedCount     = 0;
                self.cachedPlotRange = nil;

                self.plotBoundsChanged()
            }
        }
    }

// MARK: - Notifications
    
    /** @internal
     *  @brief Reloads the plot with more closely spaced data points when needed.
     **/
    @objc func plotBoundsChanged()
    {
        let plot = self.dataPlot;
        
        if (( plot ) != nil) {
            let plotSpace = plot?.plotSpace
            
            if (( plotSpace ) != nil) {
                let width = plot?.bounds.size.width
                if ( width! > CGFloat(0.0)) {
                    let count = Int(lrint(ceil(Double(CGFloat(width!) / self.resolution))) + 1)
                    
                    if ( count > self.cachedCount ) {
                        self.dataCount   = count;
                        self.cachedCount = count;
                        self.cachedStep = Double(plotSpace.xRange.length / count);
                        plot?.reloadData()
                    }
                }
                else {
                    self.dataCount   = 0;
                    self.cachedCount = 0;
                    self.cachedStep  = 0.0;
                }
            }
        }
    }

    /** @internal
     *  @brief Adds new data points as needed while scrolling.
     **/
//    -(void)plotSpaceChanged
//    {
//        CPTPlot *plot = self.dataPlot;
//
//        CPTXYPlotSpace *plotSpace      = (CPTXYPlotSpace *)plot.plotSpace;
//        CPTMutablePlotRange *plotRange = [plotSpace.xRange mutableCopy];
//
//        [plotRange intersectionPlotRange:self.dataRange];
//
//        CPTMutablePlotRange *cachedRange = self.cachedPlotRange;
//
//        double step = self.cachedStep;
//
//        if ( [cachedRange containsRange:plotRange] ) {
//            // no new data needed
//        }
//        else if ( ![cachedRange intersectsRange:plotRange] || (step == 0.0)) {
//            self.cachedCount     = 0;
//            self.cachedPlotRange = plotRange;
//
//            [self plotBoundsChanged];
//        }
//        else {
//            if ( step > 0.0 ) {
//                double minLimit = plotRange.minLimitDouble;
//                if ( ![cachedRange containsDouble:minLimit] ) {
//                    NSUInteger numPoints = (NSUInteger)lrint((ceil((cachedRange.minLimitDouble - minLimit) / step)));
//
//                    NSDecimal offset = CPTDecimalFromDouble(step * numPoints);
//                    cachedRange.locationDecimal = CPTDecimalSubtract(cachedRange.locationDecimal, offset);
//                    cachedRange.lengthDecimal   = CPTDecimalAdd(cachedRange.lengthDecimal, offset);
//
//                    self.dataCount += numPoints;
//
//                    [plot insertDataAtIndex:0 numberOfRecords:numPoints];
//                }
//
//                double maxLimit = plotRange.maxLimitDouble;
//                if ( ![cachedRange containsDouble:maxLimit] ) {
//                    NSUInteger numPoints = (NSUInteger)lrint(ceil((maxLimit - cachedRange.maxLimitDouble) / step));
//
//                    NSDecimal offset = CPTDecimalFromDouble(step * numPoints);
//                    cachedRange.lengthDecimal = CPTDecimalAdd(cachedRange.lengthDecimal, offset);
//
//                    self.dataCount += numPoints;
//
//                    [plot insertDataAtIndex:plot.cachedDataCount numberOfRecords:numPoints];
//                }
//            }
//            else {
//                double maxLimit = plotRange.maxLimitDouble;
//                if ( ![cachedRange containsDouble:maxLimit] ) {
//                    NSUInteger numPoints = (NSUInteger)lrint(ceil((cachedRange.maxLimitDouble - maxLimit) / step));
//
//                    NSDecimal offset = CPTDecimalFromDouble(step * numPoints);
//                    cachedRange.locationDecimal = CPTDecimalSubtract(cachedRange.locationDecimal, offset);
//                    cachedRange.lengthDecimal   = CPTDecimalAdd(cachedRange.lengthDecimal, offset);
//
//                    self.dataCount += numPoints;
//
//                    [plot insertDataAtIndex:0 numberOfRecords:numPoints];
//                }
//
//                double minLimit = plotRange.minLimitDouble;
//                if ( ![cachedRange containsDouble:minLimit] ) {
//                    NSUInteger numPoints = (NSUInteger)lrint(ceil((minLimit - cachedRange.minLimitDouble) / step));
//
//                    NSDecimal offset = CPTDecimalFromDouble(step * numPoints);
//                    cachedRange.lengthDecimal = CPTDecimalAdd(cachedRange.lengthDecimal, offset);
//
//                    self.dataCount += numPoints;
//
//                    [plot insertDataAtIndex:plot.cachedDataCount numberOfRecords:numPoints];
//                }
//            }
//        }
//    }

    
    // MARK: - KVO Methods

//    func observeValueForKeyPath(keyPath: String, ofObject object: Any, change:(NSDictionary<NSString *, CPTPlotSpace *> *)change context:(nullable void *)
//                                
//    func hello()
//    {
//        if ((context == CPTFunctionDataSourceKVOContext) && [keyPath isEqualToString:@"plotSpace"] && [object isEqual:self.dataPlot] ) {
//            let oldSpace = change[NSKeyValueChangeOldKey];
//            let newSpace = change[NSKeyValueChangeNewKey];
//
//            if ( oldSpace ) {
//                NotificationCenter.defaultCenter.remove(
//                                Observer:self,
//                                name: .CPTPlotSpaceCoordinateMappingDidChangeNotification,
//                                object:oldSpace)
//            }
//
//            if ( newSpace ) {
//                NotificationCenter.defaultCenter.receive(
//                                self
//                                selector:#selector(plotSpaceChanged),
//                                name:.CPTPlotSpaceCoordinateMappingDidChangeNotification,
//                                object:newSpace)
//            }
//
//            self.cachedPlotRange = nil
//                self.plotSpaceChanged()
//        }
//        else {
//            super.observeValueForKeyPath(keyPath, ofObject:object, change:change, context:context)
//        }
//    }
//    // MARK: - CPTScatterPlotDataSource Methods
//func numberOfRecordsForPlot(plot: CPTPlot )-> Int
//{
//    var count = 0;
//    
//    if plot.isEqual(self.dataPlot ) {
//        count = self.dataCount
//    }
//    return count;
//}
//
//    -(nullable CPTNumericData *)dataForPlot:(nonnull CPTPlot *)plot recordIndexRange:(NSRange)indexRange
//    {
//        CPTNumericData *numericData = nil;
//
//        if ( [plot isEqual:self.dataPlot] ) {
//            NSUInteger count = self.dataCount;
//
//            if ( count > 0 ) {
//                CPTPlotRange *xRange = self.cachedPlotRange;
//
//                if ( !xRange ) {
//                    [self plotSpaceChanged];
//                    xRange = self.cachedPlotRange;
//                }
//
//                NSMutableData *data = [[NSMutableData alloc] initWithLength:indexRange.length * 2 * sizeof(double)];
//
//                double *xBytes = data.mutableBytes;
//                double *yBytes = data.mutableBytes + (indexRange.length * sizeof(double));
//
//                double location = xRange.locationDouble;
//                double length   = xRange.lengthDouble;
//                double denom    = (double)(count - ((count > 1) ? 1 : 0));
//
//                NSUInteger lastIndex = NSMaxRange(indexRange);
//
//                CPTDataSourceFunction function = self.dataSourceFunction;
//
//                if ( function ) {
//                    for ( NSUInteger i = indexRange.location; i < lastIndex; i++ ) {
//                        double x = location + ((double)i / denom) * length;
//
//                        *xBytes++ = x;
//                        *yBytes++ = function(x);
//                    }
//                }
//                else {
//                    CPTDataSourceBlock functionBlock = self.dataSourceBlock;
//
//                    if ( functionBlock ) {
//                        for ( NSUInteger i = indexRange.location; i < lastIndex; i++ ) {
//                            double x = location + ((double)i / denom) * length;
//
//                            *xBytes++ = x;
//                            *yBytes++ = functionBlock(x);
//                        }
//                    }
//                }
//
//                numericData = [CPTNumericData numericDataWithData:data
//                                                         dataType:CPTDataType(CPTFloatingPointDataType, sizeof(double), CFByteOrderGetCurrent())
//                                                            shape:@[@(indexRange.length), @2]
//                                                        dataOrder:CPTDataOrderColumnsFirst];
//            }
//        }
//
//        return numericData;
//    }

}
