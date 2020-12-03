//
//  CPTPlot Dtat Source.swift
//  corePlot
//
//  Created by thierryH24 on 24/11/2020.
//

import Foundation

extension CPTPlot {
    
    
    // MARK: Data Source
    
    //    func numberOfRecords() -> Int {
    //        var theDataSource = dataSource as? CPTPlotDataSource
    //
    //        return theDataSource?.numberOfRecords(forPlot: self) ?? 0
    //    }
    func reloadDataInIndexRange(indexRange :NSRange)
    {
        self.dataNeedsReloading = false;
        self.reloadPlotData(indexRange: indexRange)
        
        // Data labels
        self.reloadDataLabels( indexRange: indexRange)
    }
    
    ///** @brief Insert records into the plot data cache at the given index.
    // *  @param idx The starting index of the new records.
    // *  @param numberOfRecords The number of records to insert.
    // **/
    func insertDataAtIndex(idx : Int, numberOfRecords:Int)
    {
        Class numericClass = (CPTNumericData class)
        
        let values = cachedData.map { $0.value }
        
        for  data in values {
            
            //            if ( [data is numericClass] ) {
            //                CPTMutableNumericData *numericData = (CPTMutableNumericData *)data;
            //                let sampleSize                  = numericData.sampleBytes;
            //                let length                      = sampleSize * numberOfRecords;
            //
            //                let numericData.data increaseLengthBy:length
            //
            //                int8_t *start      = [numericData mutableSamplePointer:idx];
            //                let bytesToMove = numericData.data.length - (idx + numberOfRecords) * sampleSize;
            //                if ( bytesToMove > 0 ) {
            //                    memmove(start + length, start, bytesToMove);
            //                }
            //            }
            //            else {
            //                var array = data
            //                NSNull *nullObject    = [NSNull null];
            //                NSUInteger lastIndex  = idx + numberOfRecords - 1;
            //
            //                for i in idx..<=lastIndex {
            //                    array.insertObject(nullObject atIndex:i)
            //                }
            //            }
        }
        
        let labelArray = self.labelAnnotations;
        
        if  !labelArray.isEmpty  {
            let nullObject        = [NSNull null];
            let lastIndex = idx + numberOfRecords - 1;
            for i in idx..<lastIndex + 1 {
                labelArray.insertObject(nullObject, atIndex:i)
            }
        }
        
        self.cachedDataCount += numberOfRecords;
        self.reloadData(indexRange: NSRange(location: idx, length: numberOfRecords))
    }
        
        //
        ///** @brief Delete records in the given index rang@objc e from the plot data cache.
        // *  @param indexRange The index range of the data records to remove.
        // **/
//        func deleteDataInIndexRange(indexRange: NSRange)
//        {
//        Class numericClass = [CPTNumericData class];
//
//        for (  data in self.cachedData.allValues ) {
//        if ( [data isKindOfClass:numericClass] ) {
//        CPTMutableNumericData *numericData = (CPTMutableNumericData *)data;
//        size_t sampleSize                  = numericData.sampleBytes;
//        int8_t *start                      = [numericData mutableSamplePointer:indexRange.location];
//        size_t length                      = sampleSize * indexRange.length;
//        size_t bytesToMove                 = numericData.data.length - (indexRange.location + indexRange.length) * sampleSize;
//        if ( bytesToMove > 0 ) {
//        memmove(start, start + length, bytesToMove);
//        }
//
//        NSMutableData *dataBuffer = (NSMutableData *)numericData.data;
//        dataBuffer.length -= length;
//        }
//        else {
//        [(NSMutableArray *) data removeObjectsInRange:indexRange];
//        }
//        }
//
//        CPTMutableAnnotationArray *labelArray = self.labelAnnotations;
//
//        let maxIndex   = NSMaxRange(indexRange)
//        Class annotationClass = [CPTAnnotation class];
//
//        for ( NSUInteger i = indexRange.location; i < maxIndex; i++ ) {
//        CPTAnnotation *annotation = labelArray[i];
//        if ( [annotation isKindOfClass:annotationClass] ) {
//        [self removeAnnotation:annotation];
//        }
//        }
//        [labelArray removeObjectsInRange:indexRange];
//
//        self.cachedDataCount -= indexRange.length;
//        [self setNeedsDisplay];
//        }
//
//        // *  @brief Reload all plot data from the data source immediately.
//        func reloadPlotData()
//        {
//        var dataCache = cachedData
//        for fieldID in fieldIdentifiers {
//        dataCache.removeValue(forKey: String(fieldID))
//        }
//        reloadPlotData(indexRange: NSRange(location: 0, length: cachedDataCount))
//        }
        //
        ///** @brief Reload plot data in the given index range from the data source immediately.
        // *  @param indexRange The index range to load.
        // **/
    @objc func reloadPlotData(indexRange: NSRange )
    {
        // do nothing--implementation provided by subclasses
    }
        //
        // *  @brief Reload all data labels from the data source immediately.
    func reloadDataLabels()
    {
        self.cachedData.removeValue (forKey: .CPTPlotBindingDataLabels)
        self.reloadDataLabels( indexRange: NSRange(location: 0, length: self.cachedDataCount))
    }
    
        
        //
    ///** @brief Reload data labels in the given index range from the data source immediately.
    // *  @param indexRange The index range to load.
    // **/
    func reloadDataLabels( indexRange: NSRange) {
        
        
        let theDataSource = self.dataSource as? CPTBarPlotDataSource
        
        if theDataSource?.responds(to: #selector(CPTPlotDataSource.dataLabels(forPlot:recordIndexRange:)@objc )) ?? false {
            cacheArray(
                theDataSource?.dataLabels(forPlot: self, recordIndexRange: indexRange),
                forKey: CPTPlotBindingDataLabels,
                atRecord: indexRange.location)
        } else if theDataSource?.responds(to: #selector(CPTPlotDataSource.dataLabel(forPlot:recordIndex:))) ?? false {
            let nilObject = CPTPlot.nilData()
            let array = [AnyHashable](repeating: 0, count: indexRange.length) as? CPTMutableLayerArray
            
            
            let maxIndex = NSMaxRange(indexRange)
            
            for idx in indexRange.location..<maxIndex {
                let labelLayer = theDataSource?.dataLabel(forPlot: self, record: idx)
                if let labelLayer = labelLayer {
                    array?.add(labelLayer)
                } else {
                    if let nilObject = nilObject as? MDLObject {
                        array?.add(nilObject)
                    }
                }
            }
            
            cacheArray( array, forKey: CPTPlotBindingDataLabels, atRecord: indexRange.location)
        }
        
        relabel(indexRange)
    }


///**
// *  @brief A unique marker object used in collections to indicate that the datasource returned @nil.
// **/
//+(nonnull id)nilData
//{
//    static id nilObject              = nil;
//    static dispatch_once_t onceToken = 0;
//
//    dispatch_once(&onceToken, ^{
//        nilObject = [[NSObject alloc] init];
//    });
//
//    return nilObject;
//}
//
///** @brief Gets a range of plot data for the given plot and field.
// *  @param fieldEnum The field index.
// *  @param indexRange The range of the data indexes of interest.
// *  @return An array of data points.
// **/
//-(nullable id)numbersFromDataSourceForField:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange
//{
//    id numbers; // can be CPTNumericData, NSArray, or NSData
//
//    id<CPTPlotDataSource> theDataSource = self.dataSource;
//
//    if ( theDataSource ) {
//        if ( [theDataSource respondsToSelector:@selector(dataForPlot:field:recordIndexRange:)] ) {
//            numbers = [theDataSource dataForPlot:self field:fieldEnum recordIndexRange:indexRange];
//        }
//        else if ( [theDataSource respondsToSelector:@selector(doublesForPlot:field:recordIndexRange:)] ) {
//            numbers = [NSMutableData dataWithLength:sizeof(double) * indexRange.length];
//            double *fieldValues  = [numbers mutableBytes];
//            double *doubleValues = [theDataSource doublesForPlot:self field:fieldEnum recordIndexRange:indexRange];
//            memcpy(fieldValues, doubleValues, sizeof(double) * indexRange.length);
//        }
//        else if ( [theDataSource respondsToSelector:@selector(numbersForPlot:field:recordIndexRange:)] ) {
//            NSArray *numberArray = [theDataSource numbersForPlot:self field:fieldEnum recordIndexRange:indexRange];
//            if ( numberArray ) {
//                numbers = [NSArray arrayWithArray:numberArray];
//            }
//            else {
//                numbers = nil;
//            }
//        }
//        else if ( [theDataSource respondsToSelector:@selector(doubleForPlot:field:recordIndex:)] ) {
//            NSUInteger recordIndex;
//            NSMutableData *fieldData = [NSMutableData dataWithLength:sizeof(double) * indexRange.length];
//            double *fieldValues      = fieldData.mutableBytes;
//            for ( recordIndex = indexRange.location; recordIndex < indexRange.location + indexRange.length; ++recordIndex ) {
//                double number = [theDataSource doubleForPlot:self field:fieldEnum recordIndex:recordIndex];
//                *fieldValues++ = number;
//            }
//            numbers = fieldData;
//        }
//        else {
//            BOOL respondsToSingleValueSelector = [theDataSource respondsToSelector:@selector(numberForPlot:field:recordIndex:)];
//            NSNull *nullObject                 = [NSNull null];
//            NSUInteger recordIndex;
//            NSMutableArray *fieldValues = [NSMutableArray arrayWithCapacity:indexRange.length];
//            for ( recordIndex = indexRange.location; recordIndex < indexRange.location + indexRange.length; recordIndex++ ) {
//                if ( respondsToSingleValueSelector ) {
//                    id number = [theDataSource numberForPlot:self field:fieldEnum recordIndex:recordIndex];
//                    if ( number ) {
//                        [fieldValues addObject:number];
//                    }
//                    else {
//                        [fieldValues addObject:nullObject];
//                    }
//                }
//                else {
//                    [fieldValues addObject:[NSDecimalNumber zero]];
//                }
//            }
//            numbers = fieldValues;
//        }
//    }
//    else {
//        numbers = @[];
//    }
//
//    return numbers;
//}
//
///** @brief Gets a range of plot data for the given plot.
// *  @param indexRange The range of the data indexes of interest.
// *  @return Returns @YES if the datasource implements the
// *  @link CPTPlotDataSource::dataForPlot:recordIndexRange: -dataForPlot:recordIndexRange: @endlink
// *  method and it returns valid data.
// **/
//-(BOOL)loadNumbersForAllFieldsFromDataSourceInRecordIndexRange:(NSRange)indexRange
//{
//    BOOL hasData = NO;
//
//    id<CPTPlotDataSource> theDataSource = self.dataSource;
//
//    if ( [theDataSource respondsToSelector:@selector(dataForPlot:recordIndexRange:)] ) {
//        CPTNumericData *data = [theDataSource dataForPlot:self recordIndexRange:indexRange];
//
//        if ( [data isKindOfClass:[CPTNumericData class]] ) {
//            const NSUInteger sampleCount = data.numberOfSamples;
//            CPTNumericDataType dataType  = data.dataType;
//
//            if ((sampleCount > 0) && (data.numberOfDimensions == 2)) {
//                CPTNumberArray *theShape    = data.shape;
//                const NSUInteger rowCount   = theShape[0].unsignedIntegerValue;
//                const NSUInteger fieldCount = theShape[1].unsignedIntegerValue;
//
//                if ( fieldCount > 0 ) {
//                    // convert data type if needed
//                    switch ( self.cachePrecision ) {
//                        case CPTPlotCachePrecisionAuto:
//                            if ( self.doublePrecisionCache ) {
//                                if ( !CPTDataTypeEqualToDataType(dataType, self.doubleDataType)) {
//                                    CPTMutableNumericData *mutableData = [data mutableCopy];
//                                    mutableData.dataType = self.doubleDataType;
//                                    data                 = mutableData;
//                                }
//                            }
//                            else {
//                                if ( !CPTDataTypeEqualToDataType(dataType, self.decimalDataType)) {
//                                    CPTMutableNumericData *mutableData = [data mutableCopy];
//                                    mutableData.dataType = self.decimalDataType;
//                                    data                 = mutableData;
//                                }
//                            }
//                            break;
//
//                        case CPTPlotCachePrecisionDecimal:
//                            if ( !CPTDataTypeEqualToDataType(dataType, self.decimalDataType)) {
//                                CPTMutableNumericData *mutableData = [data mutableCopy];
//                                mutableData.dataType = self.decimalDataType;
//                                data                 = mutableData;
//                            }
//                            break;
//
//                        case CPTPlotCachePrecisionDouble:
//                            if ( !CPTDataTypeEqualToDataType(dataType, self.doubleDataType)) {
//                                CPTMutableNumericData *mutableData = [data mutableCopy];
//                                mutableData.dataType = self.doubleDataType;
//                                data                 = mutableData;
//                            }
//                            break;
//                    }
//
//                    // add the data to the cache
//                    const NSUInteger bufferLength = rowCount * dataType.sampleBytes;
//
//                    switch ( data.dataOrder ) {
//                        case CPTDataOrderRowsFirst:
//                        {
//                            const void *sourceEnd = (const int8_t *)(data.bytes) + data.length;
//
//                            for ( NSUInteger fieldNum = 0; fieldNum < fieldCount; fieldNum++ ) {
//                                NSMutableData *tempData = [[NSMutableData alloc] initWithLength:bufferLength];
//
//                                if ( CPTDataTypeEqualToDataType(dataType, self.doubleDataType)) {
//                                    const double *sourceData = [data samplePointerAtIndex:0, fieldNum];
//                                    double *destData         = tempData.mutableBytes;
//
//                                    while ( sourceData < (const double *)sourceEnd ) {
//                                        *destData++ = *sourceData;
//                                        sourceData += fieldCount;
//                                    }
//                                }
//                                else {
//                                    const NSDecimal *sourceData = [data samplePointerAtIndex:0, fieldNum];
//                                    NSDecimal *destData         = tempData.mutableBytes;
//
//                                    while ( sourceData < (const NSDecimal *)sourceEnd ) {
//                                        *destData++ = *sourceData;
//                                        sourceData += fieldCount;
//                                    }
//                                }
//
//                                CPTMutableNumericData *tempNumericData = [[CPTMutableNumericData alloc] initWithData:tempData
//                                                                                                            dataType:dataType
//                                                                                                               shape:nil];
//
//                                [self cacheNumbers:tempNumericData forField:fieldNum atRecordIndex:indexRange.location];
//                            }
//                            hasData = YES;
//                        }
//                        break;
//
//                        case CPTDataOrderColumnsFirst:
//                            for ( NSUInteger fieldNum = 0; fieldNum < fieldCount; fieldNum++ ) {
//                                const void *samples = [data samplePointerAtIndex:0, fieldNum];
//                                NSData *tempData    = [[NSData alloc] initWithBytes:samples
//                                                                             length:bufferLength];
//
//                                CPTMutableNumericData *tempNumericData = [[CPTMutableNumericData alloc] initWithData:tempData
//                                                                                                            dataType:dataType
//                                                                                                               shape:nil];
//
//                                [self cacheNumbers:tempNumericData forField:fieldNum atRecordIndex:indexRange.location];
//                            }
//                            hasData = YES;
//                            break;
//                    }
//                }
//            }
//        }
//    }
//
//    return hasData;
//}
//}
}
