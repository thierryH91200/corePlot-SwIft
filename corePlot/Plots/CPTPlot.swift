//
//  CPTPlot.swift
//  corePlot
//
//  Created by thierryH24 on 11/11/2020.
//

import AppKit

public class CPTPlot: CPTAnnotationHostLayer {
    
    var dataSource : CPTPlotDataSource?
    var title : String?
    var attributedTitle = NSAttributedString(string: "")
    var plotSpace : CPTPlotSpace?
    var adjustLabelAnchors = false
    
    var showLabels = false
    var  labelOffset = CGFloat (0)
    
    var labelRotation = CGFloat(0)
    var labelField : CPTTextStyle?
    var labelTextStyle: CPTTextStyle?
    var labelFormatter = Formatter()
    var labelShadow : CPTShadow?
    
    var dataNeedsReloading = false
    var cachedData = [ Dictionary<String, Any>]()
    
    var needsRelabel = false
    var labelIndexRange = NSRange()
    var alignsPointsToPixels = true
    
    var labelAnnotations = [CPTAnnotation]()
    var dataLabels = [CPTLayer]()
    var drawLegendSwatchDecoration = false
    
    var pointingDeviceDownLabelIndex = 0 ;
    var cachedDataCount = 0
    var inTitleUpdate = false ;
    
    var numberOfRecords = 0
    var cachePrecision = CPTPlotCachePrecision.auto
    
    var fieldIdentifiers = [CGFloat]()
    
    
    enum CPTPlotCachePrecision: Int {
        case auto
        case double
        case decimal
    }
    
    init(frame: CGRect)
    {
        super.init()
        cachedData           = [Dictionary<String, Any>]()
        cachedDataCount      = 0;
        cachePrecision       = .auto
        dataSource           = nil;
        title                = nil;
        attributedTitle      = NSAttributedString(string: "")
        plotSpace            = nil
        dataNeedsReloading   = false;
        needsRelabel         = true;
        adjustLabelAnchors   = true;
        showLabels           = true;
        labelOffset          = CGFloat(0.0);
        labelRotation        = CGFloat(0.0);
        labelField           = nil
        labelTextStyle       = nil;
        labelFormatter       = Formatter()
        labelShadow          = nil;
        labelIndexRange      = NSRange(location: 0, length: 0);
        labelAnnotations.removeAll()
        alignsPointsToPixels = true;
        inTitleUpdate        = false;
        
        pointingDeviceDownLabelIndex = NSNotFound;
        drawLegendSwatchDecoration   = true
        
        self.masksToBounds              = true
        self.needsDisplayOnBoundsChange = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK : Drawing
    override func drawInContext(context: CGContext)
    {
        self.reloadDataIfNeeded()
        super.draw(in: context)
        
        let theDelegate = self.delegate
        
        if ( [theDelegate respondsToSelector:@selector(didFinishDrawing:)] ) {
            theDelegate.didFinishDrawing(self)
        }
    }
    
    // MARK: Animation
    func needsDisplayForKey(aKey: String )-> Bool
    {
        var keys        = Set<String>()
        
        
        keys.insert("labelOffset")
        keys.insert("labelRotation")
        
        if keys.contains(aKey ) {
            return true;
        }
        else {
            return CPTBorderedLayer.needsDisplay(forKey: aKey)
        }
    }
    
    // MARK: Layout
    public override func layoutSublayers()
    {
        self.relabel()
        super.layoutSublayers()
    }
    
    
    // MARK: Data Source
    func numberOfRecords() -> Int
    {
        let theDataSource = self.dataSource
        return (theDataSource?.numberOfRecordsForPlot(plot: self))!
    }
    
    /**
     *  @brief Marks the receiver as needing the data source reloaded before the content is next drawn.
     **/
    func setDataNeedsReloading()
    {
        self.dataNeedsReloading = true;
    }
    
    /**
     *  @brief Reload all plot data, labels, and plot-specific information from the data source immediately.
     **/
    func reloadData()
    {
        self.cachedData.removeAll()
        self.cachedDataCount = 0;
        
        self.reloadDataInIndexRange(NSRange(location: 0, length: self.numberOfRecords))
    }
    
    /**
     *  @brief Reload plot data from the data source only if the data cache is out of date.
     **/
    func reloadDataIfNeeded()
    {
        if  self.dataNeedsReloading  {
            self.reloadData
        }
    }
    
    /** @brief Reload plot data, labels, and plot-specific information in the given index range from the data source immediately.
     *  @param indexRange The index range to load.
     **/
    //    func reloadData(inIndexRange indexRange: NSRange) {
    //        assert(NSMaxRange(indexRange) <= numberOfRecords, "Invalid parameter not satisfying: NSMaxRange(indexRange) <= numberOfRecords")
    //
    //        dataNeedsReloading = false
    //
    //        reloadPlotData(inIndexRange: indexRange)
    //
    //        // Data labels
    //        reloadDataLabels(inIndexRange: indexRange)
    //    }
    //
    //
    //    /** @brief Insert records into the plot data cache at the given index.
    //     *  @param idx The starting index of the new records.
    //     *  @param numberOfRecords The number of records to insert.
    //     **/
    //    -(void)insertDataAtIndex:(NSUInteger)idx numberOfRecords:(NSUInteger)numberOfRecords
    //    {
    //        NSParameterAssert(idx <= self.cachedDataCount);
    //        Class numericClass = [CPTNumericData class];
    //
    //        for ( id data in self.cachedData.allValues ) {
    //            if ( [data isKindOfClass:numericClass] ) {
    //                CPTMutableNumericData *numericData = (CPTMutableNumericData *)data;
    //                size_t sampleSize                  = numericData.sampleBytes;
    //                size_t length                      = sampleSize * numberOfRecords;
    //
    //                [(NSMutableData *) numericData.data increaseLengthBy:length];
    //
    //                int8_t *start      = [numericData mutableSamplePointer:idx];
    //                size_t bytesToMove = numericData.data.length - (idx + numberOfRecords) * sampleSize;
    //                if ( bytesToMove > 0 ) {
    //                    memmove(start + length, start, bytesToMove);
    //                }
    //            }
    //            else {
    //                NSMutableArray *array = (NSMutableArray *)data;
    //                NSNull *nullObject    = [NSNull null];
    //                NSUInteger lastIndex  = idx + numberOfRecords - 1;
    //                for ( NSUInteger i = idx; i <= lastIndex; i++ ) {
    //                    [array insertObject:nullObject atIndex:i];
    //                }
    //            }
    //        }
    //
    //        let labelArray = self.labelAnnotations;
    //
    //        if ( labelArray ) {
    //            id nullObject        = [NSNull null];
    //            NSUInteger lastIndex = idx + numberOfRecords - 1;
    //            for ( NSUInteger i = idx; i <= lastIndex; i++ ) {
    //                [labelArray insertObject:nullObject atIndex:i];
    //            }
    //        }
    //
    //        self.cachedDataCount += numberOfRecords;
    //        [self reloadDataInIndexRange:NSMakeRange(idx, numberOfRecords)];
    //    }
    //
    //    /** @brief Delete records in the given index range from the plot data cache.
    //     *  @param indexRange The index range of the data records to remove.
    //     **/
    //    func deleteDataInIndexRange(indexRange :NSRange)
    //    {
    //        NSParameterAssert(NSMaxRange(indexRange) <= self.cachedDataCount);
    //        Class numericClass = [CPTNumericData class];
    //
    //        for ( id data in self.cachedData.allValues ) {
    //            if ( [data isKindOfClass:numericClass] ) {
    //                CPTMutableNumericData *numericData = (CPTMutableNumericData *)data;
    //                size_t sampleSize                  = numericData.sampleBytes;
    //                int8_t *start                      = [numericData mutableSamplePointer:indexRange.location];
    //                size_t length                      = sampleSize * indexRange.length;
    //                size_t bytesToMove                 = numericData.data.length - (indexRange.location + indexRange.length) * sampleSize;
    //                if ( bytesToMove > 0 ) {
    //                    memmove(start, start + length, bytesToMove);
    //                }
    //
    //                NSMutableData *dataBuffer = (NSMutableData *)numericData.data;
    //                dataBuffer.length -= length;
    //            }
    //            else {
    //                [(NSMutableArray *) data removeObjectsInRange:indexRange];
    //            }
    //        }
    //
    //        CPTMutableAnnotationArray *labelArray = self.labelAnnotations;
    //
    //        let maxIndex   = NSMaxRange(indexRange);
    //
    //        for   i in indexRange.location..<maxIndex {
    //            let annotation = labelArray[i];
    //            if ( annotation is CPTAnnotation) {
    //                self removeAnnotation(annotation)
    //            }
    //        }
    //        [labelArray removeObjectsInRange:indexRange];
    //
    //        self.cachedDataCount -= indexRange.length;
    //        self.setNeedsDisplay()
    //    }
    //
    //    /**
    //     *  @brief Reload all plot data from the data source immediately.
    //     **/
    //    func reloadPlotData()
    //    {
    //        NSMutableDictionary<NSNumber *, id> *dataCache = self.cachedData;
    //
    //        for fieldID in self.fieldIdentifiers {
    //            dataCache.removeObjectForKey:fieldID
    //        }
    //
    //        self.reloadPlotData(NSRange(0, self.cachedDataCount)
    //    }
    //
    //    /** @brief Reload plot data in the given index range from the data source immediately.
    //     *  @param indexRange The index range to load.
    //     **/
    //    func reloadPlotData(indexRange: NSRange )
    //    {
    //        // do nothing--implementation provided by subclasses
    //    }
    //
    //    /**
    //     *  @brief Reload all data labels from the data source immediately.
    //     **/
    //    func reloadDataLabels()
    //    {
    //        self.cachedData removeObjectForKey:CPTPlotBindingDataLabels
    //
    //        self.reloadDataLabels(NSRange(0, self.cachedDataCount))
    //    }
    //
    //    /** @brief Reload data labels in the given index range from the data source immediately.
    //     *  @param indexRange The index range to load.
    //     **/
    //    func reloadDataLabels(indexRange: NSRange)
    //    {
    //        id<CPTPlotDataSource> theDataSource = (id<CPTPlotDataSource>)self.dataSource;
    //
    //        if ( [theDataSource respondsToSelector:@selector(dataLabelsForPlot:recordIndexRange:)] ) {
    //            [self cacheArray:[theDataSource dataLabelsForPlot:self recordIndexRange:indexRange]
    //                      forKey:CPTPlotBindingDataLabels
    //               atRecordIndex:indexRange.location];
    //        }
    //        else if ( [theDataSource respondsToSelector:@selector(dataLabelForPlot:recordIndex:)] ) {
    //            id nilObject                = [CPTPlot nilData];
    //            CPTMutableLayerArray *array = [[NSMutableArray alloc] initWithCapacity:indexRange.length];
    //            NSUInteger maxIndex         = NSMaxRange(indexRange);
    //
    //            for ( NSUInteger idx = indexRange.location; idx < maxIndex; idx++ ) {
    //                CPTLayer *labelLayer = [theDataSource dataLabelForPlot:self recordIndex:idx];
    //                if ( labelLayer ) {
    //                    [array addObject:labelLayer];
    //                }
    //                else {
    //                    [array addObject:nilObject];
    //                }
    //            }
    //
    //            [self cacheArray:array
    //                      forKey:CPTPlotBindingDataLabels
    //               atRecordIndex:indexRange.location];
    //        }
    //
    //        [self relabelIndexRange:indexRange];
    //    }
    //
    //    /**
    //     *  @brief A unique marker object used in collections to indicate that the datasource returned @nil.
    //     **/
    //
    //    +(nonnull id)nilData
    //    {
    //        static id nilObject              = nil;
    //        static dispatch_once_t onceToken = 0;
    //
    //        dispatch_once(&onceToken, ^{
    //            nilObject = [[NSObject alloc] init];
    //        });
    //
    //        return nilObject;
    //    }
    //
    //    /** @brief Gets a range of plot data for the given plot and field.
    //     *  @param fieldEnum The field index.
    //     *  @param indexRange The range of the data indexes of interest.
    //     *  @return An array of data points.
    //     **/
    //    -(nullable id)numbersFromDataSourceForField:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange
    //    {
    //        id numbers; // can be CPTNumericData, NSArray, or NSData
    //
    //        id<CPTPlotDataSource> theDataSource = self.dataSource;
    //
    //        if ( theDataSource ) {
    //            if ( [theDataSource respondsToSelector:@selector(dataForPlot:field:recordIndexRange:)] ) {
    //                numbers = [theDataSource dataForPlot:self field:fieldEnum recordIndexRange:indexRange];
    //            }
    //            else if ( [theDataSource respondsToSelector:@selector(doublesForPlot:field:recordIndexRange:)] ) {
    //                numbers = [NSMutableData dataWithLength:sizeof(double) * indexRange.length];
    //                double *fieldValues  = [numbers mutableBytes];
    //                double *doubleValues = [theDataSource doublesForPlot:self field:fieldEnum recordIndexRange:indexRange];
    //                memcpy(fieldValues, doubleValues, sizeof(double) * indexRange.length);
    //            }
    //            else if ( [theDataSource respondsToSelector:@selector(numbersForPlot:field:recordIndexRange:)] ) {
    //                NSArray *numberArray = [theDataSource numbersForPlot:self field:fieldEnum recordIndexRange:indexRange];
    //                if ( numberArray ) {
    //                    numbers = [NSArray arrayWithArray:numberArray];
    //                }
    //                else {
    //                    numbers = nil;
    //                }
    //            }
    //            else if ( [theDataSource respondsToSelector:@selector(doubleForPlot:field:recordIndex:)] ) {
    //                NSUInteger recordIndex;
    //                NSMutableData *fieldData = [NSMutableData dataWithLength:sizeof(double) * indexRange.length];
    //                double *fieldValues      = fieldData.mutableBytes;
    //                for ( recordIndex = indexRange.location; recordIndex < indexRange.location + indexRange.length; ++recordIndex ) {
    //                    double number = [theDataSource doubleForPlot:self field:fieldEnum recordIndex:recordIndex];
    //                    *fieldValues++ = number;
    //                }
    //                numbers = fieldData;
    //            }
    //            else {
    //                BOOL respondsToSingleValueSelector = [theDataSource respondsToSelector:@selector(numberForPlot:field:recordIndex:)];
    //                NSNull *nullObject                 = [NSNull null];
    //                NSUInteger recordIndex;
    //                NSMutableArray *fieldValues = [NSMutableArray arrayWithCapacity:indexRange.length];
    //                for ( recordIndex = indexRange.location; recordIndex < indexRange.location + indexRange.length; recordIndex++ ) {
    //                    if ( respondsToSingleValueSelector ) {
    //                        id number = [theDataSource numberForPlot:self field:fieldEnum recordIndex:recordIndex];
    //                        if ( number ) {
    //                            [fieldValues addObject:number];
    //                        }
    //                        else {
    //                            [fieldValues addObject:nullObject];
    //                        }
    //                    }
    //                    else {
    //                        [fieldValues addObject:[NSDecimalNumber zero]];
    //                    }
    //                }
    //                numbers = fieldValues;
    //            }
    //        }
    //        else {
    //            numbers = @[];
    //        }
    //
    //        return numbers;
    //    }
    //
    //    /** @brief Gets a range of plot data for the given plot.
    //     *  @param indexRange The range of the data indexes of interest.
    //     *  @return Returns @YES if the datasource implements the
    //     *  @link CPTPlotDataSource::dataForPlot:recordIndexRange: -dataForPlot:recordIndexRange: @endlink
    //     *  method and it returns valid data.
    //     **/
    //    -(BOOL)loadNumbersForAllFieldsFromDataSourceInRecordIndexRange:(NSRange)indexRange
    //    {
    //        BOOL hasData = NO;
    //
    //        id<CPTPlotDataSource> theDataSource = self.dataSource;
    //
    //        if ( [theDataSource respondsToSelector:@selector(dataForPlot:recordIndexRange:)] ) {
    //            CPTNumericData *data = [theDataSource dataForPlot:self recordIndexRange:indexRange];
    //
    //            if ( [data isKindOfClass:[CPTNumericData class]] ) {
    //                const NSUInteger sampleCount = data.numberOfSamples;
    //                CPTNumericDataType dataType  = data.dataType;
    //
    //                if ((sampleCount > 0) && (data.numberOfDimensions == 2)) {
    //                    CPTNumberArray *theShape    = data.shape;
    //                    const NSUInteger rowCount   = theShape[0].unsignedIntegerValue;
    //                    const NSUInteger fieldCount = theShape[1].unsignedIntegerValue;
    //
    //                    if ( fieldCount > 0 ) {
    //                        // convert data type if needed
    //                        switch ( self.cachePrecision ) {
    //                            case CPTPlotCachePrecisionAuto:
    //                                if ( self.doublePrecisionCache ) {
    //                                    if ( !CPTDataTypeEqualToDataType(dataType, self.doubleDataType)) {
    //                                        CPTMutableNumericData *mutableData = [data mutableCopy];
    //                                        mutableData.dataType = self.doubleDataType;
    //                                        data                 = mutableData;
    //                                    }
    //                                }
    //                                else {
    //                                    if ( !CPTDataTypeEqualToDataType(dataType, self.decimalDataType)) {
    //                                        CPTMutableNumericData *mutableData = [data mutableCopy];
    //                                        mutableData.dataType = self.decimalDataType;
    //                                        data                 = mutableData;
    //                                    }
    //                                }
    //                                break;
    //
    //                            case CPTPlotCachePrecisionDecimal:
    //                                if ( !CPTDataTypeEqualToDataType(dataType, self.decimalDataType)) {
    //                                    CPTMutableNumericData *mutableData = [data mutableCopy];
    //                                    mutableData.dataType = self.decimalDataType;
    //                                    data                 = mutableData;
    //                                }
    //                                break;
    //
    //                            case CPTPlotCachePrecisionDouble:
    //                                if ( !CPTDataTypeEqualToDataType(dataType, self.doubleDataType)) {
    //                                    CPTMutableNumericData *mutableData = [data mutableCopy];
    //                                    mutableData.dataType = self.doubleDataType;
    //                                    data                 = mutableData;
    //                                }
    //                                break;
    //                        }
    //
    //                        // add the data to the cache
    //                        const NSUInteger bufferLength = rowCount * dataType.sampleBytes;
    //
    //                        switch ( data.dataOrder ) {
    //                            case CPTDataOrderRowsFirst:
    //                            {
    //                                const void *sourceEnd = (const int8_t *)(data.bytes) + data.length;
    //
    //                                for ( NSUInteger fieldNum = 0; fieldNum < fieldCount; fieldNum++ ) {
    //                                    NSMutableData *tempData = [[NSMutableData alloc] initWithLength:bufferLength];
    //
    //                                    if ( CPTDataTypeEqualToDataType(dataType, self.doubleDataType)) {
    //                                        const double *sourceData = [data samplePointerAtIndex:0, fieldNum];
    //                                        double *destData         = tempData.mutableBytes;
    //
    //                                        while ( sourceData < (const double *)sourceEnd ) {
    //                                            *destData++ = *sourceData;
    //                                            sourceData += fieldCount;
    //                                        }
    //                                    }
    //                                    else {
    //                                        const NSDecimal *sourceData = [data samplePointerAtIndex:0, fieldNum];
    //                                        NSDecimal *destData         = tempData.mutableBytes;
    //
    //                                        while ( sourceData < (const NSDecimal *)sourceEnd ) {
    //                                            *destData++ = *sourceData;
    //                                            sourceData += fieldCount;
    //                                        }
    //                                    }
    //
    //                                    CPTMutableNumericData *tempNumericData = [[CPTMutableNumericData alloc] initWithData:tempData
    //                                                                                                                dataType:dataType
    //                                                                                                                   shape:nil];
    //
    //                                    [self cacheNumbers:tempNumericData forField:fieldNum atRecordIndex:indexRange.location];
    //                                }
    //                                hasData = YES;
    //                            }
    //                            break;
    //
    //                            case CPTDataOrderColumnsFirst:
    //                                for ( NSUInteger fieldNum = 0; fieldNum < fieldCount; fieldNum++ ) {
    //                                    const void *samples = [data samplePointerAtIndex:0, fieldNum];
    //                                    NSData *tempData    = [[NSData alloc] initWithBytes:samples
    //                                                                                 length:bufferLength];
    //
    //                                    CPTMutableNumericData *tempNumericData = [[CPTMutableNumericData alloc] initWithData:tempData
    //                                                                                                                dataType:dataType
    //                                                                                                                   shape:nil];
    //
    //                                    [self cacheNumbers:tempNumericData forField:fieldNum atRecordIndex:indexRange.location];
    //                                }
    //                                hasData = YES;
    //                                break;
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //
    //        return hasData;
    //    }
}
    
    
    
    
    
    
@objc public protocol CPTPlotDataSource {
    
    func numberOfRecordsForPlot(plot:  CPTPlot) -> Int
    func numbersForPlot( plot : CPTPlot, fieldEnum :Int, indexRange : NSRange) -> [Int]
    func numberForPlot(plot: CPTPlot, field:Int, recordIndex:Int) -> Double
    func doubleForPlot(plot: CPTPlot, fieldEnum:Int,  idx: Int) ->Double
    func dataForPlot(plot: CPTPlot,  fieldEnum: Int, indexRange:NSRange ) -> CPTNumericData
    
    @objc optional func dataForPlot(plot : CPTPlot , indexRange:NSRange)-> [CPTNumericData]
    @objc optional func dataLabelForPlot(plot: CPTPlot, recordIndex:Int )-> CPTLayer
}


@objc protocol CPTPlotDelegate: CPTLayerDelegate {
    
    func plot(plot: CPTPlot, dataLabelWasSelectedAtRecordIndex:Int)
    func plot(plot: CPTPlot, dataLabelWasSelectedAtRecordIndex:Int,  event: CPTNativeEvent )
    func plot(plot: CPTPlot, dataLabelTouchDownAtRecordIndex:Int)
    func plot(plot: CPTPlot, dataLabelTouchDownAtRecordIndex:Int, event: CPTNativeEvent )
    func plot(plot: CPTPlot, dataLabelTouchUpAtRecordIndex: Int)
    func plot(plot: CPTPlot, dataLabelTouchUpAtRecordIndex: Int,  event: CPTNativeEvent )
    
}

