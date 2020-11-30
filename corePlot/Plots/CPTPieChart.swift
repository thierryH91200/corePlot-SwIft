//
//  CPTPieChart.swift
//  corePlot
//
//  Created by thierryH24 on 14/11/2020.
//

import AppKit





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
    var labelRotationRelativeToRadius = false
    
//    +(void)initialize
//    {
//        if ( self == [CPTPieChart class] ) {
//            [self exposeBinding:CPTPieChartBindingPieSliceWidthValues];
//            [self exposeBinding:CPTPieChartBindingPieSliceFills];
//            [self exposeBinding:CPTPieChartBindingPieSliceRadialOffsets];
//        }
//    }
//
//    #endif
//
//    /// @endcond
//
//    /// @name Initialization
//    /// @{
//
//    /** @brief Initializes a newly allocated CPTPieChart object with the provided frame rectangle.
//     *
//     *  This is the designated initializer. The initialized layer will have the following properties:
//     *  - @ref pieRadius = @num{40%} of the minimum of the width and height of the frame rectangle
//     *  - @ref pieInnerRadius = @num{0.0}
//     *  - @ref startAngle = @num{π/2}
//     *  - @ref endAngle = @NAN
//     *  - @ref sliceDirection = #CPTPieDirectionClockwise
//     *  - @ref centerAnchor = (@num{0.5}, @num{0.5})
//     *  - @ref borderLineStyle = @nil
//     *  - @ref overlayFill = @nil
//     *  - @ref labelRotationRelativeToRadius = @NO
//     *  - @ref labelOffset = @num{10.0}
//     *  - @ref labelField = #CPTPieChartFieldSliceWidth
//     *
//     *  @param newFrame The frame rectangle.
//     *  @return The initialized CPTPieChart object.
//     **/
//    -(nonnull instancetype)initWithFrame:(CGRect)newFrame
//    {
//        if ((self = [super initWithFrame:newFrame])) {
//            pieRadius                     = CPTFloat(0.8) * (MIN(newFrame.size.width, newFrame.size.height) / CPTFloat(2.0));
//            pieInnerRadius                = CPTFloat(0.0);
//            startAngle                    = CPTFloat(M_PI_2); // pi/2
//            endAngle                      = CPTNAN;
//            sliceDirection                = CPTPieDirectionClockwise;
//            centerAnchor                  = CPTPointMake(0.5, 0.5);
//            borderLineStyle               = nil;
//            overlayFill                   = nil;
//            labelRotationRelativeToRadius = NO;
//            pointingDeviceDownIndex       = NSNotFound;
//
//            self.labelOffset = CPTFloat(10.0);
//            self.labelField  = CPTPieChartFieldSliceWidth;
//        }
//        return self;
//    }
//
//    /// @}
//
//    /// @cond
//
//    -(nonnull instancetype)initWithLayer:(nonnull id)layer
//    {
//        if ((self = [super initWithLayer:layer])) {
//            CPTPieChart *theLayer = (CPTPieChart *)layer;
//
//            pieRadius                     = theLayer->pieRadius;
//            pieInnerRadius                = theLayer->pieInnerRadius;
//            startAngle                    = theLayer->startAngle;
//            endAngle                      = theLayer->endAngle;
//            sliceDirection                = theLayer->sliceDirection;
//            centerAnchor                  = theLayer->centerAnchor;
//            borderLineStyle               = theLayer->borderLineStyle;
//            overlayFill                   = theLayer->overlayFill;
//            labelRotationRelativeToRadius = theLayer->labelRotationRelativeToRadius;
//            pointingDeviceDownIndex       = NSNotFound;
//        }
//        return self;
//    }

    
}


