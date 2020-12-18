//
//  CPTNumericDataType.swift
//  corePlot
//
//  Created by thierryH24 on 13/12/2020.
//

import Foundation

enum CPTDataTypeFormat : Int {
    case undefined = 0 ///< Undefined
    case integer ///< Integer
    case unsignedInteger ///< Unsigned integer
    case floatingPoint ///< Floating point
    case complexFloatingPoint ///< Complex floating point
    case decimal ///< NSDecimal
}
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
struct _CPTNumericDataType {
var dataTypeFormat: CPTDataTypeFormat ///< Data type format
var sampleBytes: size_t ///< Number of bytes in each sample
var byteOrder: CFByteOrder ///< Byte order
}

typealias CPTNumericDataType = _CPTNumericDataType
