//
//  CPTNumericDataType.swift
//  corePlot
//
//  Created by thierryH24 on 13/12/2020.
//

import Foundation

typedef NS_ENUM (NSInteger, CPTDataTypeFormat) {
    CPTUndefinedDataType = 0,        ///< Undefined
    CPTIntegerDataType,              ///< Integer
    CPTUnsignedIntegerDataType,      ///< Unsigned integer
    CPTFloatingPointDataType,        ///< Floating point
    CPTComplexFloatingPointDataType, ///< Complex floating point
    CPTDecimalDataType               ///< NSDecimal
};

/**
 *  @brief Enumeration of memory arrangements for multi-dimensional data arrays.
 *  @see See <a href="https://en.wikipedia.org/wiki/Row-major_order">Wikipedia</a> for more information.
 **/
enum CPTDataOrder: Int {
    case rowsFirst                  //< Numeric data is arranged in row-major order.
    case columnsFirst               //< Numeric data is arranged in column-major order.
};

/**
 *  @brief Structure that describes the encoding of numeric data samples.
 **/
typedef struct _CPTNumericDataType {
    CPTDataTypeFormat dataTypeFormat; ///< Data type format
    size_t            sampleBytes;    ///< Number of bytes in each sample
    CFByteOrder       byteOrder;      ///< Byte order
}
CPTNumericDataType;
