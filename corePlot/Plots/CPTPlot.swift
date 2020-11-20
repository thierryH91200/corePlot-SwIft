//
//  CPTPlot.swift
//  corePlot
//
//  Created by thierryH24 on 11/11/2020.
//

import Cocoa

class CPTPlot: CPTAnnotationHostLayer {
    
    var dataSource : CPTPlotDataSource?
    var title : String?
    var attributedTitle = NSAttributedString()
    vat plotSpace : CPTPlotSpace?
    var adjustLabelAnchors = false
    
    var dataNeedsReloading = false
    var  cachedData = [ Dictionary<String, Any>]()
    
    var needsRelabel = false
    var  labelIndexRange = NSRange()
    var labelAnnotations = [CPTAnnotation]()
    var dataLabels = [CPTLayer]()
    
    var pointingDeviceDownLabelIndex = 0 ;
    var cachedDataCount = 0
    var inTitleUpdate = false ;
    
    var numberOfRecords = 0
    
    var cachePrecision = CPTPlotCachePrecision.auto

    
    enum CPTPlotCachePrecision: Int {
        case auto
        case double
        case decimal
    }
    
    
    
    init(frame: CGRect)
    {
        super.init()
        cachedData           = [Dictionary<String, Any>]()
        cachedDataCount      = 0;
        cachePrecision       = .auto
        dataSource           = nil;
        title                = nil;
        attributedTitle      = nil
        plotSpace            = nil
        dataNeedsReloading   = false;
        needsRelabel         = true;
        adjustLabelAnchors   = true;
        showLabels           = true;
        labelOffset          = CPTFloat(0.0);
        labelRotation        = CPTFloat(0.0);
        labelField           = 0;
        labelTextStyle       = nil;
        labelFormatter       = nil;
        labelShadow          = nil;
        labelIndexRange      = NSRange(0, 0);
        labelAnnotations     = nil;
        alignsPointsToPixels = true;
        inTitleUpdate        = false;
        
        pointingDeviceDownLabelIndex = NSNotFound;
        drawLegendSwatchDecoration   = YES;
        
        self.masksToBounds              = YES;
        self.needsDisplayOnBoundsChange = YES;
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}




@objc protocol CPTPlotDataSource {

func numberOfRecordsForPlot(plot:  CPTPlot) -> Int

    /// @name Data Values
    /// @{

    /** @brief @required The number of data points for the plot.
     *  @param plot The plot.
     *  @return The number of data points for the plot.
     **/

    func numbersForPlot( plot : CPTPlot, fieldEnum :Int, indexRange : NSRange) -> [Int]

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
    func numberForPlot(plot: CPTPlot, field:Int, recordIndex:Int) -> Double

/** @brief @optional Gets a range of plot data for the given plot and field.
 *  Implement one and only one of the optional methods in this section.
 *  @param plot The plot.
 *  @param fieldEnum The field index.
 *  @param indexRange The range of the data indexes of interest.
 *  @return A retained C array of data points.
 **/
    func doublesForPlot(plot: CPTPlot, fieldEnum:Int, indexRange:NSRange) -> [Double]

/** @brief @optional Gets a plot data value for the given plot and field.
 *  Implement one and only one of the optional methods in this section.
 *  @param plot The plot.
 *  @param fieldEnum The field index.
 *  @param idx The data index of interest.
 *  @return A data point.
 **/
    func doubleForPlot(plot: CPTPlot, fieldEnum:Int,  idx: Int) ->Double

/** @brief @optional Gets a range of plot data for the given plot and field.
 *  Implement one and only one of the optional methods in this section.
 *  @param plot The plot.
 *  @param fieldEnum The field index.
 *  @param indexRange The range of the data indexes of interest.
 *  @return A one-dimensional array of data points.
 **/
    func dataForPlot(plot: CPTPlot,  fieldEnum: Int, indexRange:NSRange ) -> CPTNumericData

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
    @objc optional func dataForPlot(plot : CPTPlot , indexRange:NSRange)-> [CPTNumericData]

/// @}

/// @name Data Labels
/// @{

/** @brief @optional Gets a range of data labels for the given plot.
 *  @param plot The plot.
 *  @param indexRange The range of the data indexes of interest.
 *  @return An array of data labels.
 **/
    @objc optional func dataLabelsForPlot(plot:  CPTPlot,  indexRange:NSRange)-> [CPTLayer]

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
    @objc optional func dataLabelForPlot(plot: CPTPlot, recordIndex:Int )-> CPTLayer

}


protocol CPTPlotDelegate: CPTLayerDelegate {

@optional

/// @name Point Selection
/// @{

/** @brief @optional Informs the delegate that a data label
 *  @if MacOnly was both pressed and released. @endif
 *  @if iOSOnly received both the touch down and up events. @endif
 *  @param plot The plot.
 *  @param idx The index of the
 *  @if MacOnly clicked data label. @endif
 *  @if iOSOnly touched data label. @endif
 **/
-(void)plot:(nonnull CPTPlot *)plot dataLabelWasSelectedAtRecordIndex:(NSUInteger)idx;

/** @brief @optional Informs the delegate that a data label
 *  @if MacOnly was both pressed and released. @endif
 *  @if iOSOnly received both the touch down and up events. @endif
 *  @param plot The plot.
 *  @param idx The index of the
 *  @if MacOnly clicked data label. @endif
 *  @if iOSOnly touched data label. @endif
 *  @param event The event that triggered the selection.
 **/
-(void)plot:(nonnull CPTPlot *)plot dataLabelWasSelectedAtRecordIndex:(NSUInteger)idx withEvent:(nonnull CPTNativeEvent *)event;

/** @brief @optional Informs the delegate that a data label
 *  @if MacOnly was pressed. @endif
 *  @if iOSOnly touch started. @endif
 *  @param plot The plot.
 *  @param idx The index of the
 *  @if MacOnly clicked data label. @endif
 *  @if iOSOnly touched data label. @endif
 **/
-(void)plot:(nonnull CPTPlot *)plot dataLabelTouchDownAtRecordIndex:(NSUInteger)idx;

/** @brief @optional Informs the delegate that a data label
 *  @if MacOnly was pressed. @endif
 *  @if iOSOnly touch started. @endif
 *  @param plot The plot.
 *  @param idx The index of the
 *  @if MacOnly clicked data label. @endif
 *  @if iOSOnly touched data label. @endif
 *  @param event The event that triggered the selection.
 **/
-(void)plot:(nonnull CPTPlot *)plot dataLabelTouchDownAtRecordIndex:(NSUInteger)idx withEvent:(nonnull CPTNativeEvent *)event;

/** @brief @optional Informs the delegate that a data label
 *  @if MacOnly was released. @endif
 *  @if iOSOnly touch ended. @endif
 *  @param plot The plot.
 *  @param idx The index of the
 *  @if MacOnly clicked data label. @endif
 *  @if iOSOnly touched data label. @endif
 **/
-(void)plot:(nonnull CPTPlot *)plot dataLabelTouchUpAtRecordIndex:(NSUInteger)idx;

/** @brief @optional Informs the delegate that a data label
 *  @if MacOnly was released. @endif
 *  @if iOSOnly touch ended. @endif
 *  @param plot The plot.
 *  @param idx The index of the
 *  @if MacOnly clicked data label. @endif
 *  @if iOSOnly touched data label. @endif
 *  @param event The event that triggered the selection.
 **/
-(void)plot:(nonnull CPTPlot *)plot dataLabelTouchUpAtRecordIndex:(NSUInteger)idx withEvent:(nonnull CPTNativeEvent *)event;

/// @}
}
