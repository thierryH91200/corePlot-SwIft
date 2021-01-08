//
//  CPTPlot Dtat Source.swift
//  corePlot
//
//  Created by thierryH24 on 24/11/2020.
//

import Foundation

extension CPTPlot {
    
    
    // MARK: Data Source

    //    func reloadDataInIndexRange(indexRange :NSRange)
    //    {
    //        self.dataNeedsReloading = false;
    //        self.reloadPlotData(indexRange: indexRange)
    //
    //        // Data labels
    //        self.reloadDataLabels( indexRange: indexRange)
    //    }
    
    ///** @brief Insert records into the plot data cache at the given index.
    // *  @param idx The starting index of the new records.
    // *  @param numberOfRecords The number of records to insert.
    // **/
    @objc func insertDataAtIndex(idx : Int, numberOfRecords:Int)
    {
        Class numericClass = (CPTNumericData class)
        
        let values = cachedData.map { $0.value }
        
        for  data in values {
            
            //            if ( data is numericClass] ) {
            //                CPTMutableNumericData *numericData = (CPTMutableNumericData *)data;
            //                let sampleSize                  = numericData.sampleBytes;
            //                let length                      = sampleSize * numberOfRecords;
            //
            //                let numericData.data increaseLengthBy:length
            //
            //                int8_t *start      = numericData mutableSamplePointer:idx];
            //                let bytesToMove = numericData.data.length - (idx + numberOfRecords) * sampleSize;
            //                if ( bytesToMove > 0 ) {
            //                    memmove(start + length, start, bytesToMove);
            //                }
            //            }
            //            else {
            //                var array = data
            //                NSNull *nullObject    = NSNull null];
            //                NSUInteger lastIndex  = idx + numberOfRecords - 1;
            //
            //                for i in idx..<=lastIndex {
            //                    array.insertObject(nullObject atIndex:i)
            //                }
            //            }
        }
        
        let labelArray = self.labelAnnotations;
        
        if  labelArray.isEmpty == false  {
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
    @objc func deleteDataInIndexRange(indexRange: NSRange)
    {
        Class numericClass = [CPTNumericData class];
        
        for (  data in self.cachedData.allValues ) {
            if ( data isKindOfClass:numericClass] ) {
                let numericData = (CPTMutableNumericData *)data;
                size_t sampleSize                  = numericData.sampleBytes;
                int8_t *start                      = numericData mutableSamplePointer:indexRange.location];
                size_t length                      = sampleSize * indexRange.length;
                size_t bytesToMove                 = numericData.data.length - (indexRange.location + indexRange.length) * sampleSize;
                if ( bytesToMove > 0 ) {
                    memmove(start, start + length, bytesToMove);
                }
                
                let dataBuffer = numericData.data;
                dataBuffer.length -= length;
            }
            else  {
                data.removeObjectsInRange(indexRange)
            }
        }
        
        let labelArray = self.labelAnnotations;
        
        let maxIndex   = NSMaxRange(indexRange)
        let annotationClass = CPTAnnotation.class
        
        for  i in  indexRange.location..<maxIndex {
            let annotation = labelArray[i];
            if ( annotation is CPTAnnotation ) {
                self.removeAnnotation(annotation)
            }
        }
        labelArray.removeObjectsInRange(indexRange)
        
        self.cachedDataCount -= indexRange.length;
        self.setNeedsDisplay()
    }
    
    // *  @brief Reload all plot data from the data source immediately.
    func reloadPlotData()
    {
        var dataCache = cachedData
        for fieldID in fieldIdentifiers {
            dataCache.removeValue(forKey: String(fieldID))
        }
        reloadPlotDataInIndexRange(indexRange: NSRange(location: 0, length: cachedDataCount))
    }
    //
    ///** @brief Reload plot data in the given index range from the data source immediately.
    // *  @param indexRange The index range to load.
    // **/
    @objc func reloadPlotDataInIndexRange(indexRange: NSRange )
    {
        // do nothing--implementation provided by subclasses
    }
    //
    // *  @brief Reload all data labels from the data source immediately.
    func reloadDataLabels()
    {
        self.cachedData.removeValue (forKey: NSBindingName.PlotDataLabels.rawValue)
        self.reloadDataLabels( indexRange: NSRange(location: 0, length: self.cachedDataCount))
    }
    
    
    //
    ///** @brief Reload data labels in the given index range from the data source immediately.
    // *  @param indexRange The index range to load.
    // **/
    func reloadDataLabels( indexRange: NSRange) {
        
        
        let theDataSource = self.dataSource as? CPTBarPlotDataSource
        
        if ((theDataSource?.responds(to: #selector(theDataSource.dataLabels(forPlot:recordIndexRange:) ))) != nil)  {
            cacheArray(
                array: (theDataSource?.dataLabels(forPlot: self, recordIndexRange: indexRange))!,
                forKey: NSBindingName.dataLabels,
                atRecordIndex: indexRange.location)
        } else if theDataSource?.responds(to: #selector(CPTPlotDataSource.dataLabel(forPlot:recordIndex:)))  {
            let nilObject = CPTPlot.nilData()
            let array = [CPTLayer]()
            
            
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
            
            cacheArray( array, forKey: .CPTPlotBindingDataLabels, atRecord: indexRange.location)
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
    //        nilObject = NSObject alloc] init];
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
    func numbersFromDataSourceForField(fieldEnum : Int, recordIndexRange indexRange:NSRange)->Any?
    {
        let  numbers : Any // can be CPTNumericData, Array, or Data
        
        weak var theDataSource = self.dataSource as? CPTPlotDtaSource
        
        if theDataSource.dataForPlot(plot: field: recordIndexRange:) {
            numbers = theDataSource.dataForPlot(self, field:fieldEnum, recordIndexRange:indexRange)
        }
        else if theDataSource?.doublesForPlot(plot: field: recordIndexRange:) {
            numbers = NSMutableData dataWithLength:sizeof(double) * indexRange.length];
            var fieldValues  = numbers
            var doubleValues = theDataSource.doublesForPlot(self field:fieldEnum recordIndexRange:indexRange)
            //                memcpy(fieldValues, doubleValues, MemoryLayout<Double>.size * indexRange.length)
            fieldValues = [Double](repeating: doubleValues, count: indexRange.length )
            
        }
        else if theDataSource?.numbersForPlot(plot: field: recordIndexRange:) {
            let numberArray = theDataSource.numbersForPlot(self, field:fieldEnum, recordIndexRange:indexRange)
            
            if ( numberArray ) {
                numbers = NSArray arrayWithArray:numberArray;
            }
            else {
                
                numbers = nil
            }
            
        }
        else if ( theDataSource respondsToSelector:@selector(doubleForPlot:field:recordIndex:)] ) {
            var recordIndex = 0
            NSMutableData *fieldData = NSMutableData dataWithLength:sizeof(double) * indexRange.length];
            double *fieldValues      = fieldData.mutableBytes;
            for ( recordIndex = indexRange.location; recordIndex < indexRange.location + indexRange.length; ++recordIndex ) {
                double number = theDataSource doubleForPlot:self field:fieldEnum recordIndex:recordIndex];
                *fieldValues++ = number;
            }
            numbers = fieldData;
        }
        else {
            if theDataSource?.numberForPlot(plot: field: recordIndex:) {
                
                let nullObject                 = NSNull null;
                let recordIndex = 0
                let fieldValues = NSMutableArray arrayWithCapacity:indexRange.length];
                for recordIndex in indexRange.location..<(indexRange.location + indexRange.length) {
                    if ( respondsToSingleValueSelector ) {
                        let number = theDataSource.numberForPlot:self field:fieldEnum recordIndex:recordIndex];
                        if ( number ) {
                            fieldValues.addObject(number)
                        }
                        else {
                            fieldValues.addObject(nullObject)
                        }
                    }
                    else {
                        fieldValues.addObject(NSDecimalNumber zero)
                    }
                }
                numbers = fieldValues
            }
        }
        
        return numbers;
    }
    //
    ///** @brief Gets a range of plot data for the given plot.
    // *  @param indexRange The range of the data indexes of interest.
    // *  @return Returns @YES if the datasource implements the
    // *  @link CPTPlotDataSource::dataForPlot:recordIndexRange: -dataForPlot:recordIndexRange: @endlink
    // *  method and it returns valid data.
    // **/
    func loadNumbersForAllFieldsFromDataSourceInRecordIndexRange(indexRange: NSRange) -> Bool
    {
        var hasData = false;
        let theDataSource = self.dataSource
        
        if ( theDataSource.respondsToSelector(to: #selector(dataForPlot:recordIndexRange:) ) {
            let data = theDataSource.dataForPlot(self, recordIndexRange:indexRange)
            
            if data is CPTNumericData  {
                let sampleCount = data.numberOfSamples;
                let dataType  = data.dataType;
                
                if ((sampleCount > 0) && (data.numberOfDimensions == 2)) {
                    let theShape    = data.shape;
                    let rowCount   = theShape[0]
                    let fieldCount = theShape[1]
                    
                    if ( fieldCount > 0 ) {
                        // convert data type if needed
                        switch ( self.cachePrecision ) {
                        case .auto:
                            if ( self.doublePrecisionCache ) {
                                if ( !CPTDataTypeEqualToDataType(dataType, self.doubleDataType)) {
                                    let mutableData = data
                                    mutableData.dataType = self.doubleDataType;
                                    data                 = mutableData;
                                }
                            }
                            else {
                                if ( !CPTDataTypeEqualToDataType(dataType, self.decimalDataType)) {
                                    let mutableData = data
                                    mutableData.dataType = self.decimalDataType;
                                    data                 = mutableData;
                                }
                            }
                            break;
                            
                        case .decimal:
                            if ( !CPTDataTypeEqualToDataType(dataType, self.decimalDataType)) {
                                let mutableData = data
                                mutableData.dataType = self.decimalDataType;
                                data                 = mutableData;
                            }
                            break;
                            
                        case .double:
                            if ( !CPTDataTypeEqualToDataType(dataType, self.doubleDataType)) {
                                let mutableData = data
                                mutableData.dataType = self.doubleDataType;
                                data                 = mutableData;
                            }
                            break;
                        }
                        
                        // add the data to the cache
                        let bufferLength = rowCount * dataType.sampleBytes;
                        
                        switch ( data.dataOrder ) {
                        case .rowsFirst:
                            let sourceEnd = (const int8_t *)(data.bytes) + data.length;
                            
                            for fieldNum in 0..<fieldCount {
                                let tempData = NSMutableData alloc] initWithLength:bufferLength];
                                
                                if ( CPTDataTypeEqualToDataType(dataType, self.doubleDataType)) {
                                    const double *sourceData = data samplePointerAtIndex:0, fieldNum];
                                    double *destData         = tempData.mutableBytes;
                                    
                                    while ( sourceData < sourceEnd ) {
                                        destData = sourceData
                                        destData += 1
                                        sourceData += fieldCount
                                    }
                                }
                                else {
                                    const NSDecimal *sourceData = data samplePointerAtIndex:0, fieldNum];
                                    NSDecimal *destData         = tempData.mutableBytes;
                                    
                                    while sourceData < sourceEnd {
                                        *destData++ = *sourceData;
                                        sourceData += fieldCount;
                                    }
                                }
                                
                                CPTMutableNumericData *tempNumericData = CPTMutableNumericData alloc] initWithData:tempData
                                dataType:dataType
                                shape:nil];
                                
                                self.cacheNumbers(tempNumericData, forField:fieldNum, atRecordIndex:indexRange.location)
                            }
                            hasData = true;
                            break;
                            
                        case .columnsFirst:
                            for  fieldNum in 0..<fieldCount {
                                let samples = data.samplePointerAtIndex(0, fieldNum)
                                let tempData    = NSData alloc] initWithBytes:samples
                                                       length:bufferLength];
                                
                                CPTMutableNumericData *tempNumericData = CPTMutableNumericData ( initWithData:tempData
                                dataType:dataType,
                                shape:nil)
                                
                                self cacheNumbers:tempNumericData forField:fieldNum atRecordIndex:indexRange.location];
                            }
                            hasData = true
                        }
                    }
                }
            }
        }
        return hasData;
    }
}

