//
//  CPTPieChart.swift
//  corePlot
//
//  Created by thierryH24 on 14/11/2020.
//

import Cocoa


//@objc
//public protocol CPTPieChartDataSource : CPTPlotDataSource
//{
//ChartViewDelegate
//@protocol CPTPieChartDataSource<CPTPlotDataSource>
//
//-(nullable CPTFillArray *)sliceFillsForPieChart:(nonnull CPTPieChart *)pieChart recordIndexRange:(NSRange)indexRange;
//
///** @brief @optional Gets a fill for the given pie chart slice.
// *  This method will not be called if
// *  @link CPTPieChartDataSource::sliceFillsForPieChart:recordIndexRange: -sliceFillsForPieChart:recordIndexRange: @endlink
// *  is also implemented in the datasource.
// *  @param pieChart The pie chart.
// *  @param idx The data index of interest.
// *  @return The pie slice fill for the slice with the given index. If the datasource returns @nil, the default fill is used.
// *  If the data source returns an NSNull object, no fill is drawn.
// **/
//-(nullable CPTFill *)sliceFillForPieChart:(nonnull CPTPieChart *)pieChart recordIndex:(NSUInteger)idx;
//
///// @}
//
///// @name Slice Layout
///// @{
//
///** @brief @optional Gets a range of slice offsets for the given pie chart.
// *  @param pieChart The pie chart.
// *  @param indexRange The range of the data indexes of interest.
// *  @return An array of radial offsets.
// **/
//-(nullable CPTNumberArray *)radialOffsetsForPieChart:(nonnull CPTPieChart *)pieChart recordIndexRange:(NSRange)indexRange;
//
///** @brief @optional Offsets the slice radially from the center point. Can be used to @quote{explode} the chart.
// *  This method will not be called if
// *  @link CPTPieChartDataSource::radialOffsetsForPieChart:recordIndexRange: -radialOffsetsForPieChart:recordIndexRange: @endlink
// *  is also implemented in the datasource.
// *  @param pieChart The pie chart.
// *  @param idx The data index of interest.
// *  @return The radial offset in view coordinates. Zero is no offset.
// **/
//-(CGFloat)radialOffsetForPieChart:(nonnull CPTPieChart *)pieChart recordIndex:(NSUInteger)idx;





protocol CPTPieChartDataSource {

    func sliceFillsForPieChart( pieChart: CPTPieChart, recordIndexRange:NSRange) -> CPTFillArray
    func sliceFillForPieChart(pieChart: CPTPieChart, idx : Int) -> CPTFill
    func radialOffsetsForPieChart(pieChart:  CPTPieChart, indexRange:NSRange) -> CPTNumberArray
    func radialOffsetForPieChart( pieChart: CPTPieChart, idx:Int) -> CGFloat
    func legendTitleForPieChart(pieChart:  CPTPieChart, idx: Int)-> String
    func attributedLegendTitleForPieChart(pieChart:  CPTPieChart, idx :Int)-> NSAttributedString
}


class CPTPieChart: CPTPlot {

}


