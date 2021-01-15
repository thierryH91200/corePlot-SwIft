//
//  CPTPlot Data Caching.swift
//  corePlot
//
//  Created by thierryH24 on 24/11/2020.
//

import Foundation

extension CPTPlot {
    
    // MARK: - cacheNumbers
        
//    func cachedDataCount() -> Int
//    {
//        self.reloadDataIfNeeded()
//        return cachedDataCount
//    }
//
    /** @brief Copies an array of numbers to the cache.
     *  @param numbers An array of numbers to cache. Can be a CPTNumericData, NSArray, or NSData (NSData is assumed to be a c-style array of type @double).
     *  @param fieldEnum The field enumerator identifying the field.
     **/
    func cacheNumbers(numbers : [CGFloat?], fieldEnum: Int)
    {
        var cacheKey = String(fieldEnum)
        
        let coordinate   = self.coordinateForFieldIdentifier(field: fieldEnum)
        var thePlotSpace = self.plotSpace;
        
        if ( numbers != nil ) {
            
            let scaleType = thePlotSpace?.scaleTypeForCoordinate(coordinate: coordinate)
            switch ( scaleType! ) {
            case .linear:
                fallthrough
            case .log:
                fallthrough
            case .logModulus:
                let theNumbers = numbers;
                let mutableNumbers = self.numericDataForNumbers(numbers: theNumbers)
                let  sampleCount = mutableNumbers
                
                if sampleCount as! Int > 0  {
                    (self.cachedData)[cacheKey] = mutableNumbers as! [Any];
                }
                else {
                    self.cachedData.removeValue(forKey: cacheKey)
                }
                
                self.cachedDataCount = sampleCount as! Int;
                
                switch ( self.cachePrecision ) {
                case .auto:
                    self.setCachedDataType(mutableNumbers.dataType)
                    
                case .double:
                    self.setCachedDataType(self.doubleDataType())
                    
                case .decimal:
                    self.setCachedDataType(self.decimalDataType())
                }
                
            case .category:
                var samples = [String]()
                thePlotSpace?.setCategories(newCategories: samples, forCoordinate: coordinate)
                
                let sampleCount = samples.count
                if ( sampleCount > 0 ) {
                    var indices = NSMutableArray()
                    
                    for category in samples {
                        indices.addObject(thePlotSpace, indexOfCategory:category, forCoordinate: coordinate)
                    }
                    
                    let dataType = (self.cachePrecision == CPTPlotCachePrecision.decimal ? self.decimalDataType : self.doubleDataType);
                    
                    let mutableNumbers = CPTMutableNumericData ( initWithArray:indices,
                                                                 dataType:dataType,
                                                                 shape:nil)
                    
                    self.cachedData[cacheKey] = mutableNumbers;
                    self.cachedDataCount = sampleCount;
                }
                else {
                    self.cachedData.removeValue(forKey: cacheKey)
                }
                
            default:
                break;
            }
        }
        else {
            self.cachedData.removeValue(forKey: cacheKey)
            self.cachedDataCount = 0;
        }
        self.needsRelabel = true;
        self.setNeedsDisplay()
    }
    
    //
    ///** @brief Copies an array of numbers to replace a part of the cache.
    // *  @param numbers An array of numbers to cache. Can be a CPTNumericData, NSArray, or NSData (NSData is assumed to be a c-style array of type @double).
    // *  @param fieldEnum The field enumerator identifying the field.
    // *  @param idx The index of the first data point to replace.
    // **/
    func cacheNumbers(numbers : Any?, forField fieldEnum: Int, atRecordIndexidx :Int)
    {
//        if (( numbers ) != nil) {
//            let cacheKey     = fieldEnum
//            let sampleCount = 0;
//
//            let coordinate   = self.coordinateForFieldIdentifier(field: fieldEnum)
//            let thePlotSpace = self.plotSpace;
//
//            let mutableNumbers = nil;
//
//            switch ( thePlotSpace?.scaleTypeForCoordinate(coordinate: coordinate)) {
//            case .linear:
//                fallthrough
//            case .log:
//                    fallthrough
//            case .logModulus:
//                    let theNumbers = numbers;
//                mutableNumbers = self.numericDataForNumbers(theNumbers)
//
//                    sampleCount = mutableNumbers.numberOfSamples;
//                    if ( sampleCount > 0 ) {
//                        // Ensure the new data is the same type as the cache
//                        switch ( self.cachePrecision ) {
//                        case .auto:
//                            self.setCachedDataType(mutableNumbers.dataType)
//                                break;
//
//                        case .double:
//                                let newType = self.doubleDataType;
//                                [self setCachedDataType:newType];
//                                mutableNumbers.dataType = newType;
//
//                            case CPTPlotCachePrecisionDecimal:
//                                CPTNumericDataType newType = self.decimalDataType;
//                                [self setCachedDataType:newType];
//                                mutableNumbers.dataType = newType;
//                break;
//
//                        case .category:
//                    let samples = numbers as! [String]
//                    if ( [samples isKindOfClass:[NSArray class]] ) {
//                        sampleCount = samples.count;
//                        if ( sampleCount > 0 ) {
//                            var indices = [CGFloat]()
//
//                            for  category in samples {
//                                [thePlotSpace addCategory:category forCoordinate:coordinate];
//                                [indices addObject:@([thePlotSpace indexOfCategory:category forCoordinate:coordinate])];
//                            }
//
//                            CPTNumericDataType dataType = self.cachePrecision == CPTPlotCachePrecisionDecimal ? self.decimalDataType : self.doubleDataType
//
//                            mutableNumbers = [[CPTMutableNumericData alloc] initWithArray:indices
//                                                                                 dataType:dataType
//                                                                                    shape:nil];
//                        }
//                    }
//
//                default:
//                    self.cachedData.removeObjectForKey(cacheKey)
//                    break;
//            }
//
//            if ( mutableNumbers && (sampleCount > 0)) {
//                // Ensure the data cache exists and is the right size
//                let cachedNumbers = self.cachedData[cacheKey]
//                if ( !cachedNumbers ) {
//                    cachedNumbers = [CPTMutableNumericData numericDataWithData:[NSData data]
//                                                                      dataType:mutableNumbers.dataType
//                                                                         shape:nil];
//                    (self.cachedData)[cacheKey] = cachedNumbers;
//                }
//                let theDataSource = self.dataSource
//                let numberOfRecords          = theDataSource?.numberOfRecordsForPlot(plot: self)
//                cachedNumbers.shape = numberOfRecords
//
//                // Update the cache
//                self.cachedDataCount = numberOfRecords!;
//
//                NSUInteger startByte = idx * cachedNumbers.sampleBytes;
//                void *cachePtr       = (int8_t *)(cachedNumbers.mutableBytes) + startByte;
//                size_t numberOfBytes = MIN(mutableNumbers.data.length, cachedNumbers.data.length - startByte);
//                memcpy(cachePtr, mutableNumbers.bytes, numberOfBytes);
//
//                self.relabelIndexRange(NSRange(idx, sampleCount)
//            }
//
//                self.setNeedsDisplay()
//        }
    }


    func numericDataForNumbers(numbers:Any?) -> Any?
    {
//        let mutableNumbers : CPTMutableNumericData? = nil
//        var loadedDataType : CPTNumericDataType?
//
//        if numbers is CPTNumericData  {
//            mutableNumbers = numbers
//            // ensure the numeric data is in a supported format; default to double if not already NSDecimal
//            if ( mutableNumbers.dataType !=  self.decimalDataType && mutableNumbers.dataType != self.doubleDataType {
//                    mutableNumbers.dataType = self.doubleDataType;
//            }
//        }
//        else if numbers is Data {
//            loadedDataType = self.doubleDataType();
//            mutableNumbers = CPTMutableNumericData(  initWithData:numbers dataType:loadedDataType shape:nil];
//        }
//        else if let numbers = numbers as? [Any] {
//            if numbers.count == 0  {
//                loadedDataType = self.doubleDataType
//            }
//            else if ( [((NSArray<NSNumber *> *)numbers)[0] is [NSDecimalNumber class]] ) {
//                loadedDataType = self.decimalDataType;
//            }
//            else {
//                loadedDataType = self.doubleDataType();
//            }
//
//            mutableNumbers = [[CPTMutableNumericData alloc] initWithArray:numbers dataType:loadedDataType shape:nil];
//        }
//        else {
//            print("NSException raise:CPTException format:@Unsupported number array format")
//        }
//        return mutableNumbers;
        return nil
    }
    
    
    func doublePrecisionCache()-> Bool
    {
        var result = false;
        
        switch ( self.cachePrecision ) {
        case .auto:
            var dataCache = self.cachedData
            //                Class numberClass                                            = [NSNumber class];
            for key in dataCache.keys {
                if ( key is String ) {
                    result = dataCache[key].dataType == self.doubleDataType
                    break
                }
            }
            
        case .double:
            result = true
            
        default:
            // not double precision
            break;
        }
        return result;
    }
    
    /** @brief Retrieves an array of numbers from the cache.
     *  @param fieldEnum The field enumerator identifying the field.
     *  @return The array of cached numbers.
     **/
    func cachedNumbersForField(fieldEnum: Int) -> [Any]
    {
        return self.cachedData[String(fieldEnum)]!
    }
    
    func cachedDoubleForField(fieldEnum: Int, recordIndex idx:Int)-> Double
    {
        let numbers = self.cachedNumbersForField(fieldEnum: fieldEnum)

//        if ( numbers ) {
//            switch ( numbers.dataTypeFormat ) {
//                case CPTFloatingPointDataType:
//                {
//                    ltdoubleNumber = (const double *)[numbers samplePointer:idx];
//                    if ( doubleNumber ) {
//                        return *doubleNumber;
//                    }
//                }
//                break;
//
//                case CPTDecimalDataType:
//                {
//                    const NSDecimal *decimalNumber = (const NSDecimal *)[numbers samplePointer:idx];
//                    if ( decimalNumber ) {
//                        return CPTDecimalDoubleValue(*decimalNumber);
//                    }
//                }
//                break;
//
//                default:
//                    print("NSException raise:CPTException format:@Unsupported data type format")
//                    break;
//            }
//        }
        return 0.0
    }

    
    /** @brief Retrieves a single number from the cache.
     *  @param fieldEnum The field enumerator identifying the field.
     *  @param idx The index of the desired data value.
     *  @return The cached number or @NAN if no data is cached for the requested field.
     **/
    func cachedDecimalForField(fieldEnum: Int, recordIndex idx: Int) -> [CGFloat?]
    {
        let numbers = self.cachedNumbersForField(fieldEnum: fieldEnum) as! [CGFloat]
        
        if ( numbers.isEmpty == false  ) {
            return numbers
        }
        return [nil]
    }
    
    //setDataLabels
    func setCachedDataType(_ newDataType: CPTNumericDataType) {
        let numberClass = NSNumber.self
        
        var dataDictionary = cachedData
        
        for key in dataDictionary.keys {
//            if key is numberClass {
            var numericData = dataDictionary[key]
                numericData = newDataType
//            }
        }
    }

    func doubleDataType() ->CPTNumericDataType
    {
        static CPTNumericDataType dataType;
        static dispatch_once_t onceToken = 0;
    
        dispatch_once(&onceToken, ^{
            dataType = CPTDataTypeFormat(//


        enum CPTDataTypeFormat, sizeof(double), CFByteOrderGetCurrent());
        });
    
        return dataType;
    }

    func decimalDataType() -> CPTNumericDataType
    {
        let  dataType: CPTNumericDataType
        dataType = CPTDataType(CPTDecimalDataType, sizeof(NSDecimal), CFByteOrderGetCurrent());
        return dataType;
    }
    
    
    /** @brief Retrieves an array of values from the cache.
     *  @param key The key identifying the field.
     *  @return The array of cached values.
     **/
    func cachedArrayForKey(key: String)-> [Any?]
    {
        return self.cachedData[key]!
    }
}


// https://stackoverflow.com/questions/28190631/creating-an-extension-to-filter-nils-from-an-array-in-swift
extension Array {
    static func filterNils(_ array: [Element?]) -> [Element] {
        return array.filter { $0 != nil }.map { $0! }
    }
}


