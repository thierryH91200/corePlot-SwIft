//
//  CPTPlot Data Caching.swift
//  corePlot
//
//  Created by thierryH24 on 24/11/2020.
//

import Foundation

extension CPTPlot {

// MARK: -//-(NSUInteger)
    
// func   cachedDataCount()
//{
//    self.reloadDataIfNeeded()
//    return cachedDataCount
//}

///** @brief Copies an array of numbers to the cache.
// *  @param numbers An array of numbers to cache. Can be a CPTNumericData, NSArray, or NSData (NSData is assumed to be a c-style array of type @double).
// *  @param fieldEnum The field enumerator identifying the field.
// **/

    
    func cacheNumbers(numbers : Any, fieldEnum:Int)
{
    var cacheKey = fieldEnum

        let coordinate   = self.coordinateForFieldIdentifier(fieldEnum)
    var thePlotSpace = self.plotSpace;

    if ( numbers ) {
        switch ( thePlotSpace.scaleTypeForCoordinate(coordinate ) {
        case :
            case CPTScaleTypeLog:
            case CPTScaleTypeLogModulus:
            {
                id theNumbers                         = numbers;
                CPTMutableNumericData *mutableNumbers = [self numericDataForNumbers:theNumbers];

                NSUInteger sampleCount = mutableNumbers.numberOfSamples;
                if ( sampleCount > 0 ) {
                    (self.cachedData)[cacheKey] = mutableNumbers;
                }
                else {
                    [self.cachedData removeObjectForKey:cacheKey];
                }

                self.cachedDataCount = sampleCount;

                switch ( self.cachePrecision ) {
                    case CPTPlotCachePrecisionAuto:
                        [self setCachedDataType:mutableNumbers.dataType];
                        break;

                    case CPTPlotCachePrecisionDouble:
                        [self setCachedDataType:self.doubleDataType];
                        break;

                    case CPTPlotCachePrecisionDecimal:
                        [self setCachedDataType:self.decimalDataType];
                        break;
                }
            }
            break;

            case CPTScaleTypeCategory:
            {
                CPTStringArray *samples = (CPTStringArray *)numbers;
                if ( [samples isKindOfClass:[NSArray class]] ) {
                    [thePlotSpace setCategories:samples forCoordinate:coordinate];

                    NSUInteger sampleCount = samples.count;
                    if ( sampleCount > 0 ) {
                        CPTMutableNumberArray *indices = [[NSMutableArray alloc] initWithCapacity:sampleCount];

                        for category in samples  {
                            [indices addObject:@([thePlotSpace indexOfCategory:category forCoordinate:coordinate])];
                        }

                        CPTNumericDataType dataType = (self.cachePrecision == CPTPlotCachePrecisionDecimal ? self.decimalDataType : self.doubleDataType);

                        CPTMutableNumericData *mutableNumbers = [[CPTMutableNumericData alloc] initWithArray:indices
                                                                                                    dataType:dataType
                                                                                                       shape:nil];

                        (self.cachedData)[cacheKey] = mutableNumbers;

                        self.cachedDataCount = sampleCount;
                    }
                    else {
                        [self.cachedData removeObjectForKey:cacheKey];
                    }
                }
                else {
                    [self.cachedData removeObjectForKey:cacheKey];
                }
            }
            break;

            default:
                break;
        }
    }
    else {
        [self.cachedData removeObjectForKey:cacheKey];
        self.cachedDataCount = 0;
    }
    self.needsRelabel = YES;
    [self setNeedsDisplay];
}
//
///** @brief Copies an array of numbers to replace a part of the cache.
// *  @param numbers An array of numbers to cache. Can be a CPTNumericData, NSArray, or NSData (NSData is assumed to be a c-style array of type @double).
// *  @param fieldEnum The field enumerator identifying the field.
// *  @param idx The index of the first data point to replace.
// **/
//-(void)cacheNumbers:(nullable id)numbers forField:(NSUInteger)fieldEnum atRecordIndex:(NSUInteger)idx
//{
//    if ( numbers ) {
//        NSNumber *cacheKey     = @(fieldEnum);
//        NSUInteger sampleCount = 0;
//
//        CPTCoordinate coordinate   = [self coordinateForFieldIdentifier:fieldEnum];
//        CPTPlotSpace *thePlotSpace = self.plotSpace;
//
//        CPTMutableNumericData *mutableNumbers = nil;
//
//        switch ( [thePlotSpace scaleTypeForCoordinate:coordinate] ) {
//            case CPTScaleTypeLinear:
//            case CPTScaleTypeLog:
//            case CPTScaleTypeLogModulus:
//            {
//                id theNumbers = numbers;
//                mutableNumbers = [self numericDataForNumbers:theNumbers];
//
//                sampleCount = mutableNumbers.numberOfSamples;
//                if ( sampleCount > 0 ) {
//                    // Ensure the new data is the same type as the cache
//                    switch ( self.cachePrecision ) {
//                        case CPTPlotCachePrecisionAuto:
//                            [self setCachedDataType:mutableNumbers.dataType];
//                            break;
//
//                        case CPTPlotCachePrecisionDouble:
//                        {
//                            CPTNumericDataType newType = self.doubleDataType;
//                            [self setCachedDataType:newType];
//                            mutableNumbers.dataType = newType;
//                        }
//                        break;
//
//                        case CPTPlotCachePrecisionDecimal:
//                        {
//                            CPTNumericDataType newType = self.decimalDataType;
//                            [self setCachedDataType:newType];
//                            mutableNumbers.dataType = newType;
//                        }
//                        break;
//                    }
//                }
//            }
//            break;
//
//            case CPTScaleTypeCategory:
//            {
//                CPTStringArray *samples = (CPTStringArray *)numbers;
//                if ( [samples isKindOfClass:[NSArray class]] ) {
//                    sampleCount = samples.count;
//                    if ( sampleCount > 0 ) {
//                        CPTMutableNumberArray *indices = [[NSMutableArray alloc] initWithCapacity:sampleCount];
//
//                        for ( NSString *category in samples ) {
//                            [thePlotSpace addCategory:category forCoordinate:coordinate];
//                            [indices addObject:@([thePlotSpace indexOfCategory:category forCoordinate:coordinate])];
//                        }
//
//                        CPTNumericDataType dataType = (self.cachePrecision == CPTPlotCachePrecisionDecimal ? self.decimalDataType : self.doubleDataType);
//
//                        mutableNumbers = [[CPTMutableNumericData alloc] initWithArray:indices
//                                                                             dataType:dataType
//                                                                                shape:nil];
//                    }
//                }
//            }
//            break;
//
//            default:
//                [self.cachedData removeObjectForKey:cacheKey];
//                break;
//        }
//
//        if ( mutableNumbers && (sampleCount > 0)) {
//            // Ensure the data cache exists and is the right size
//            CPTMutableNumericData *cachedNumbers = (self.cachedData)[cacheKey];
//            if ( !cachedNumbers ) {
//                cachedNumbers = [CPTMutableNumericData numericDataWithData:[NSData data]
//                                                                  dataType:mutableNumbers.dataType
//                                                                     shape:nil];
//                (self.cachedData)[cacheKey] = cachedNumbers;
//            }
//            id<CPTPlotDataSource> theDataSource = self.dataSource;
//            NSUInteger numberOfRecords          = [theDataSource numberOfRecordsForPlot:self];
//            cachedNumbers.shape = @[@(numberOfRecords)];
//
//            // Update the cache
//            self.cachedDataCount = numberOfRecords;
//
//            NSUInteger startByte = idx * cachedNumbers.sampleBytes;
//            void *cachePtr       = (int8_t *)(cachedNumbers.mutableBytes) + startByte;
//            size_t numberOfBytes = MIN(mutableNumbers.data.length, cachedNumbers.data.length - startByte);
//            memcpy(cachePtr, mutableNumbers.bytes, numberOfBytes);
//
//            [self relabelIndexRange:NSMakeRange(idx, sampleCount)];
//        }
//
//        [self setNeedsDisplay];
//    }
//}
//
///// @cond
//
//-(nonnull CPTMutableNumericData *)numericDataForNumbers:(nonnull id)numbers
//{
//    CPTMutableNumericData *mutableNumbers = nil;
//    CPTNumericDataType loadedDataType;
//
//    if ( [numbers isKindOfClass:[CPTNumericData class]] ) {
//        mutableNumbers = [numbers mutableCopy];
//        // ensure the numeric data is in a supported format; default to double if not already NSDecimal
//        if ( !CPTDataTypeEqualToDataType(mutableNumbers.dataType, self.decimalDataType) &&
//             !CPTDataTypeEqualToDataType(mutableNumbers.dataType, self.doubleDataType)) {
//            mutableNumbers.dataType = self.doubleDataType;
//        }
//    }
//    else if ( [numbers isKindOfClass:[NSData class]] ) {
//        loadedDataType = self.doubleDataType;
//        mutableNumbers = [[CPTMutableNumericData alloc] initWithData:numbers dataType:loadedDataType shape:nil];
//    }
//    else if ( [numbers isKindOfClass:[NSArray class]] ) {
//        if (((CPTNumberArray *)numbers).count == 0 ) {
//            loadedDataType = self.doubleDataType;
//        }
//        else if ( [((NSArray<NSNumber *> *)numbers)[0] isKindOfClass:[NSDecimalNumber class]] ) {
//            loadedDataType = self.decimalDataType;
//        }
//        else {
//            loadedDataType = self.doubleDataType;
//        }
//
//        mutableNumbers = [[CPTMutableNumericData alloc] initWithArray:numbers dataType:loadedDataType shape:nil];
//    }
//    else {
//        [NSException raise:CPTException format:@"Unsupported number array format"];
//    }
//
//    return mutableNumbers;
//}
//
///// @endcond
//
//-(BOOL)doublePrecisionCache
//{
//    BOOL result = NO;
//
//    switch ( self.cachePrecision ) {
//        case CPTPlotCachePrecisionAuto:
//        {
//            NSMutableDictionary<NSString *, CPTNumericData *> *dataCache = self.cachedData;
//            Class numberClass                                            = [NSNumber class];
//            for ( id key in dataCache.allKeys ) {
//                if ( [key isKindOfClass:numberClass] ) {
//                    result = CPTDataTypeEqualToDataType(((CPTMutableNumericData *)dataCache[key]).dataType, self.doubleDataType);
//                    break;
//                }
//            }
//        }
//        break;
//
//        case CPTPlotCachePrecisionDouble:
//            result = YES;
//            break;
//
//        default:
//            // not double precision
//            break;
//    }
//    return result;
//}
//
///** @brief Retrieves an array of numbers from the cache.
// *  @param fieldEnum The field enumerator identifying the field.
// *  @return The array of cached numbers.
// **/
//-(nullable CPTMutableNumericData *)cachedNumbersForField:(NSUInteger)fieldEnum
//{
//    return (self.cachedData)[@(fieldEnum)];
//}
//
///** @brief Retrieves a single number from the cache.
// *  @param fieldEnum The field enumerator identifying the field.
// *  @param idx The index of the desired data value.
// *  @return The cached number.
// **/
//-(nullable NSNumber *)cachedNumberForField:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
//{
//    CPTMutableNumericData *numbers = [self cachedNumbersForField:fieldEnum];
//
//    return [numbers sampleValue:idx];
//}
//
///** @brief Retrieves a single number from the cache.
// *  @param fieldEnum The field enumerator identifying the field.
// *  @param idx The index of the desired data value.
// *  @return The cached number or @NAN if no data is cached for the requested field.
// **/
//-(double)cachedDoubleForField:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
//{
//    CPTMutableNumericData *numbers = [self cachedNumbersForField:fieldEnum];
//
//    if ( numbers ) {
//        switch ( numbers.dataTypeFormat ) {
//            case CPTFloatingPointDataType:
//            {
//                const double *doubleNumber = (const double *)[numbers samplePointer:idx];
//                if ( doubleNumber ) {
//                    return *doubleNumber;
//                }
//            }
//            break;
//
//            case CPTDecimalDataType:
//            {
//                const NSDecimal *decimalNumber = (const NSDecimal *)[numbers samplePointer:idx];
//                if ( decimalNumber ) {
//                    return CPTDecimalDoubleValue(*decimalNumber);
//                }
//            }
//            break;
//
//            default:
//                [NSException raise:CPTException format:@"Unsupported data type format"];
//                break;
//        }
//    }
//    return (double)NAN;
//}
//
///** @brief Retrieves a single number from the cache.
// *  @param fieldEnum The field enumerator identifying the field.
// *  @param idx The index of the desired data value.
// *  @return The cached number or @NAN if no data is cached for the requested field.
// **/
//-(NSDecimal)cachedDecimalForField:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
//{
//    CPTMutableNumericData *numbers = [self cachedNumbersForField:fieldEnum];
//
//    if ( numbers ) {
//        switch ( numbers.dataTypeFormat ) {
//            case CPTFloatingPointDataType:
//            {
//                const double *doubleNumber = (const double *)[numbers samplePointer:idx];
//                if ( doubleNumber ) {
//                    return CPTDecimalFromDouble(*doubleNumber);
//                }
//            }
//            break;
//
//            case CPTDecimalDataType:
//            {
//                const NSDecimal *decimalNumber = (const NSDecimal *)[numbers samplePointer:idx];
//                if ( decimalNumber ) {
//                    return *decimalNumber;
//                }
//            }
//            break;
//
//            default:
//                [NSException raise:CPTException format:@"Unsupported data type format"];
//                break;
//        }
//    }
//    return CPTDecimalNaN();
//}setDataLabels
//
///// @cond
//
//-(void)setCachedDataType:(CPTNumericDataType)newDataType
//{
//    Class numberClass = [NSNumber class];
//
//    NSMutableDictionary<NSString *, CPTMutableNumericData *> *dataDictionary = self.cachedData;
//
//    for ( id key in dataDictionary.allKeys ) {
//        if ( [key isKindOfClass:numberClass] ) {
//            CPTMutableNumericData *numericData = dataDictionary[key];
//            numericData.dataType = newDataType;
//        }
//    }
//}
//
///// @endcond
//
//-(CPTNumericDataType)doubleDataType
//{
//    static CPTNumericDataType dataType;
//    static dispatch_once_t onceToken = 0;
//
//    dispatch_once(&onceToken, ^{
//        dataType = CPTDataType(CPTFloatingPointDataType, sizeof(double), CFByteOrderGetCurrent());
//    });
//
//    return dataType;
//}
//
//-(CPTNumericDataType)decimalDataType
//{
//    static CPTNumericDataType dataType;
//    static dispatch_once_t onceToken = 0;
//
//    dispatch_once(&onceToken, ^{
//        dataType = CPTDataType(CPTDecimalDataType, sizeof(NSDecimal), CFByteOrderGetCurrent());
//    });
//
//    return dataType;
//}
//
///** @brief Retrieves an array of values from the cache.
// *  @param key The key identifying the field.
// *  @return The array of cached values.
// **/
//-(nullable NSArray *)cachedArrayForKey:(nonnull NSString *)key
//{
//    return (self.cachedData)[key];
//}
//
///** @brief Retrieves a single value from the cache.
// *  @param key The key identifying the field.
// *  @param idx The index of the desired data value.
// *  @return The cached value or @nil if no data is cached for the requested key.
// **/
//-(nullable id)cachedValueForKey:(nonnull NSString *)key recordIndex:(NSUInteger)idx
//{
//    return [self cachedArrayForKey:key][idx];
//}
//
///** @brief Copies an array of arbitrary values to the cache.
// *  @param array An array of arbitrary values to cache.
// *  @param key The key identifying the field.
// **/
    func cacheArray(_ array: [String], forKey key: String) {
        let sampleCount = array.count
        if sampleCount > 0 {
            cachedData[key] = array
        } else {
            cachedData.removeValue(forKey:  key)
        }
        cachedDataCount = sampleCount
    }

//
///** @brief Copies an array of arbitrary values to replace a part of the cache.
// *  @param array An array of arbitrary values to cache.
// *  @param key The key identifying the field.
// *  @param idx The index of the first data point to replace.
// **/
//-(void)cacheArray:(nullable NSArray *)array forKey:(nonnull NSString *)key atRecordIndex:(NSUInteger)idx
//{
//    NSUInteger sampleCount = array.count;
//
//    if ( sampleCount > 0 ) {
//        // Ensure the data cache exists and is the right size
//        id<CPTPlotDataSource> theDataSource = self.dataSource;
//        NSUInteger numberOfRecords          = [theDataSource numberOfRecordsForPlot:self];
//        NSMutableArray *cachedValues        = (self.cachedData)[key];
//        if ( !cachedValues ) {
//            cachedValues = [NSMutableArray arrayWithCapacity:numberOfRecords];
//            NSNull *nullObject = [NSNull null];
//            for ( NSUInteger i = 0; i < numberOfRecords; i++ ) {
//                [cachedValues addObject:nullObject];
//            }
//            (self.cachedData)[key] = cachedValues;
//        }
//
//        // Update the cache
//        self.cachedDataCount = numberOfRecords;
//
//        NSArray *dataArray = array;
//        [cachedValues replaceObjectsInRange:NSMakeRange(idx, sampleCount) withObjectsFromArray:dataArray];
//    }
}



