//
//  CPTPlot.swift
//  corePlot
//
//  Created by thierryH24 on 11/11/2020.
//

import Cocoa

protocol CPTPlotDataSource {


func numberOfRecordsForPlot(plot:  CPTPlot) -> Int

    /// @name Data Values
    /// @{

    /** @brief @required The number of data points for the plot.
     *  @param plot The plot.
     *  @return The number of data points for the plot.
     **/

    func numbersForPlot( plot : CPTPlot, fieldEnum :Int, recordIndexRange:(NSRange)indexRange -> [Int]

/** @brief @optional Gets a plot data value for the given plot and field.
 *  Implement one and only one of the optional methods in this section.
 *
 *  For fields where the @link CPTPlot::plotSpace plotSpace @endlink scale type is #CPTScaleTypeCategory,
 *  this method should return an NSString containing the category name. Otherwise, it should return an
 *  NSNumber holding the data value. For any scale type, return @nil or an instance of NSNull to indicate
 *  missing values.
 *
 *  @param plot The plot.
 *  @param fieldEnum The field index.
 *  @param idx The data index of interest.
 *  @return A data point.
 **/
func numberForPlot(nonnull CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx;

/** @brief @optional Gets a range of plot data for the given plot and field.
 *  Implement one and only one of the optional methods in this section.
 *  @param plot The plot.
 *  @param fieldEnum The field index.
 *  @param indexRange The range of the data indexes of interest.
 *  @return A retained C array of data points.
 **/
-(nullable double *)doublesForPlot:(nonnull CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange NS_RETURNS_INNER_POINTER;

/** @brief @optional Gets a plot data value for the given plot and field.
 *  Implement one and only one of the optional methods in this section.
 *  @param plot The plot.
 *  @param fieldEnum The field index.
 *  @param idx The data index of interest.
 *  @return A data point.
 **/
-(double)doubleForPlot:(nonnull CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx;

/** @brief @optional Gets a range of plot data for the given plot and field.
 *  Implement one and only one of the optional methods in this section.
 *  @param plot The plot.
 *  @param fieldEnum The field index.
 *  @param indexRange The range of the data indexes of interest.
 *  @return A one-dimensional array of data points.
 **/
-(nullable CPTNumericData *)dataForPlot:(nonnull CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange;

/** @brief @optional Gets a range of plot data for all fields of the given plot simultaneously.
 *  Implement one and only one of the optional methods in this section.
 *
 *  The data returned from this method should be a two-dimensional array. It can be arranged
 *  in row- or column-major order although column-major will load faster, especially for large arrays.
 *  The array should have the same number of rows as the length of @par{indexRange}.
 *  The number of columns should be equal to the number of plot fields required by the plot.
 *  The column index (zero-based) corresponds with the field index.
 *  The data type will be converted to match the @link CPTPlot::cachePrecision cachePrecision @endlink if needed.
 *
 *  @param plot The plot.
 *  @param indexRange The range of the data indexes of interest.
 *  @return A two-dimensional array of data points.
 **/
-(nullable CPTNumericData *)dataForPlot:(nonnull CPTPlot *)plot recordIndexRange:(NSRange)indexRange;

/// @}

/// @name Data Labels
/// @{

/** @brief @optional Gets a range of data labels for the given plot.
 *  @param plot The plot.
 *  @param indexRange The range of the data indexes of interest.
 *  @return An array of data labels.
 **/
-(nullable CPTLayerArray *)dataLabelsForPlot:(nonnull CPTPlot *)plot recordIndexRange:(NSRange)indexRange;

/** @brief @optional Gets a data label for the given plot.
 *  This method will not be called if
 *  @link CPTPlotDataSource::dataLabelsForPlot:recordIndexRange: -dataLabelsForPlot:recordIndexRange: @endlink
 *  is also implemented in the datasource.
 *  @param plot The plot.
 *  @param idx The data index of interest.
 *  @return The data label for the point with the given index.
 *  If you return @nil, the default data label will be used. If you return an instance of NSNull,
 *  no label will be shown for the index in question.
 **/
-(nullable CPTLayer *)dataLabelForPlot:(nonnull CPTPlot *)plot recordIndex:(NSUInteger)idx;

/// @}

@end


class CPTPlot: CPTAnnotationHostLayer {

}
