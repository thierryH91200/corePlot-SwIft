//
//  CPTDefinitions.swift
//  corePlot
//
//  Created by thierryH24 on 08/11/2020.
//

import AppKit

/**
 *  @brief Enumeration of numeric types
 **/
enum CPTNumericType : Int {
    case integer ///< Integer
    case float ///< Float
    case double ///< Double
}
/**
 *  @brief Enumeration of error bar types
 **/
enum CPTErrorBarType : Int {
    case custom ///< Custom error bars
    case constantRatio ///< Constant ratio error bars
    case constantValue ///< Constant value error bars
}

///  Enumeration of axis scale types
///
enum CPTScaleType : Int {
    case linear     ///< Linear axis scale
    case log        ///< Logarithmic axis scale
    case angular    ///< Angular axis scale (not implemented)
    case dateTime   ///< Date/time axis scale (not implemented)
    case category   ///< Category axis scale
    case logModulus ///< Log-modulus axis scale
}

/**
 *  @brief Enumeration of axis coordinates
 **/
enum CPTCoordinate : Int {
    case x = 0 ///< X axis
    case y = 1 ///< Y axis
    case z = 2 ///< Z axis
    case none = 3 ///< Invalid coordinate value
}

///  RGBA color for gradients
///
struct _CPTRGBAColor {
    var red: CGFloat ///< The red component (0 ≤ @par{red} ≤ 1).
    var green: CGFloat ///< The green component (0 ≤ @par{green} ≤ 1).
    var blue: CGFloat ///< The blue component (0 ≤ @par{blue} ≤ 1).
    var alpha: CGFloat ///< The alpha component (0 ≤ @par{alpha} ≤ 1).
}

typealias CPTRGBAColor = _CPTRGBAColor
/**
 *  @brief Enumeration of label positioning offset directions
 **/
enum CPTSign : Int {
    case none = 0 ///< No offset
    case positive = 1 ///< Positive offset
    case negative = -1 ///< Negative offset
}
/**
 *  @brief Locations around the edge of a rectangle.
 **/
enum CPTRectAnchor : Int {
    case bottomLeft ///< The bottom left corner
    case bottom ///< The bottom center
    case bottomRight ///< The bottom right corner
    case left ///< The left middle
    case right ///< The right middle
    case topLeft ///< The top left corner
    case top ///< The top center
    case topRight ///< The top right
    case center ///< The center of the rect
}
/**
 *  @brief Label and constraint alignment constants.
 **/
enum CPTAlignment : Int {
    case left ///< Align horizontally to the left side.
    case center ///< Align horizontally to the center.
    case right ///< Align horizontally to the right side.
    case top ///< Align vertically to the top.
    case middle ///< Align vertically to the middle.
    case bottom ///< Align vertically to the bottom.
}

typealias CPTEdgeInsets = NSEdgeInsets

let CPTStringDrawingOptions : [NSString.DrawingOptions] = [.usesLineFragmentOrigin , .usesFontLeading , .truncatesLastVisibleLine]


/**
 *  @brief An array of numbers.
 **/
typealias CPTNumberArray = [CGFloat]
typealias CPTMutableNumberArray = [NSNumber]
typealias CPTNumberSet = Set<NSNumber>
typealias CPTFloatSet = Set<CGFloat>
typealias CPTMutableNumberSet = Set<NSNumber>
typealias CPTStringArray = [String]
typealias CPTMutableStringArray = [String]
/**
 *  @brief An array of values.
 **/
typealias CPTValueArray = Array<NSValue >
typealias CPTMutableValueArray = Array<NSValue >;
typealias CPTDictionary = Dictionary< String , Any>
typealias CPTMutableDictionary = Dictionary<String , Any>
