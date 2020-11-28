//
//  CPTPieChart.swift
//  corePlot
//
//  Created by thierryH24 on 14/11/2020.
//

import Cocoa





protocol CPTPieChartDataSource {

    func sliceFillsForPieChart( pieChart: CPTPieChart, recordIndexRange:NSRange) -> CPTFillArray
    func sliceFillForPieChart(pieChart: CPTPieChart, idx : Int) -> CPTFill
    func radialOffsetsForPieChart(pieChart:  CPTPieChart, indexRange:NSRange) -> CPTNumberArray
    func radialOffsetForPieChart( pieChart: CPTPieChart, idx:Int) -> CGFloat
    func legendTitleForPieChart(pieChart:  CPTPieChart, idx: Int)-> String
    func attributedLegendTitleForPieChart(pieChart:  CPTPieChart, idx :Int)-> NSAttributedString
}


class CPTPieChart: CPTPlot {
    
    enum CPTPieDirection : Int {
        case clockwise     ///< Pie slices are drawn in a clockwise direction.
        case counterClockwise ///< Pie slices are drawn in a counter-clockwise direction.
    };

    
    /// @name Appearance
    /// @{
    var  pieRadius: CGFloat
    var  pieInnerRadius : CGFloat
    var startAngle: CGFloat
    var endAngle: CGFloat
    var  sliceDirection =  CPTPieDirection.clockwise
    var  centerAnchor: CGPoint
    /// @}

    /// @name Drawing
    /// @{
    var borderLineStyle : CPTLineStyle
    var overlayFill: CPTFill
    /// @}

    /// @name Data Labels
    /// @{
    @property (nonatomic, readwrite, assign) BOOL labelRotationRelativeToRadius;


}


