//
//  CPTPlot.swift
//  corePlot
//
//  Created by thierryH24 on 11/11/2020.
//

import AppKit



@objc public protocol CPTPlotDataSource: NSObjectProtocol {
    
    func numberOfRecordsForPlot(plot:  CPTPlot) -> Int
    func numbersForPlot( plot : CPTPlot, fieldEnum :Int, indexRange : NSRange) -> [Int]
    func numberForPlot(plot: CPTPlot, field:Int, recordIndex:Int) -> Double
    func doubleForPlot(plot: CPTPlot, fieldEnum:Int,  idx: Int) ->Double
    func dataForPlot(plot: CPTPlot,  fieldEnum: Int, indexRange:NSRange ) -> CPTNumericData
    
    @objc optional func dataForPlot(plot : CPTPlot , indexRange:NSRange)-> [CPTNumericData]
    @objc optional func dataLabelForPlot(plot: CPTPlot, recordIndex:Int )-> CPTLayer
}


@objc public protocol CPTPlotDelegate: CPTLayerDelegate {
    
    func plot(plot: CPTPlot, dataLabelWasSelectedAtRecordIndex:Int)
    func plot(plot: CPTPlot, dataLabelWasSelectedAtRecordIndex:Int,  event: CPTNativeEvent )
    func plot(plot: CPTPlot, dataLabelTouchDownAtRecordIndex:Int)
    func plot(plot: CPTPlot, dataLabelTouchDownAtRecordIndex:Int, event: CPTNativeEvent )
    func plot(plot: CPTPlot, dataLabelTouchUpAtRecordIndex: Int)
    func plot(plot: CPTPlot, dataLabelTouchUpAtRecordIndex: Int,  event: CPTNativeEvent )
    
    func didFinishDrawing(plot: CPTPlot )
}

public class CPTPlot: CPTAnnotationHostLayer {
    
//    let CPTPlotBindingDataLabels = "dataLabels"
    
    public weak var dataSource : CPTPlotDataSource?
    public var delegatePlot: CPTPlotDelegate?
    
    var title : String?
    var attributedTitle : NSAttributedString?
    var plotSpace : CPTPlotSpace?
    var adjustLabelAnchors = false
    
    var showLabels = false
    var labelOffset = CGFloat (0)
    
    var labelRotation = CGFloat(0)
    var labelField : CPTTextStyle?
    var labelTextStyle: CPTTextStyle?
    var labelFormatter = Formatter()
    var labelShadow : CPTShadow?
    
    var dataNeedsReloading = false
//    var cachedData :  Dictionary<String, Any> = [:]
    var cachedData = NSMutableDictionary()
    
    var needsRelabel = false
    var labelIndexRange = NSRange()
    var alignsPointsToPixels = true
    
    var labelAnnotations = [CPTAnnotation]()
    //    var dataLabels = [CPTLayer]()
    var drawLegendSwatchDecoration = false
    
    var pointingDeviceDownLabelIndex = 0 ;
    var cachedDataCount = 0
    var inTitleUpdate = false ;
    
    var cachePrecision = CPTPlotCachePrecision.auto
    
    var fieldIdentifiers = [Int]()
    
    enum CPTPlotCachePrecision: Int {
        case auto
        case double
        case decimal
    }
    
    override init()
    {
        super.init()
        CPTPlot.exposeBinding(.CPTPlotBindingDataLabels)
    }

    init(frame: CGRect)
    {
        super.init()
        cachedData.removeAll()
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
        labelOffset          = CGFloat(0.0);
        labelRotation        = CGFloat(0.0);
        labelField           = nil
        labelTextStyle       = nil;
        labelFormatter       = Formatter()
        labelShadow          = nil;
        labelIndexRange      = NSRange(location: 0, length: 0);
        labelAnnotations.removeAll()
        alignsPointsToPixels = true;
        inTitleUpdate        = false;
        
        pointingDeviceDownLabelIndex = NSNotFound;
        drawLegendSwatchDecoration   = true
        
        self.masksToBounds              = true
        self.needsDisplayOnBoundsChange = true
    }
    
    
    init(layer: Any)
    {
        super.init()
        let theLayer = CPTPlot(layer: layer)
        
        cachedData           = theLayer.cachedData;
        cachedDataCount      = theLayer.cachedDataCount;
        cachePrecision       = theLayer.cachePrecision;
        dataSource           = theLayer.dataSource;
        title                = theLayer.title;
        attributedTitle      = theLayer.attributedTitle;
        plotSpace            = theLayer.plotSpace;
        dataNeedsReloading   = theLayer.dataNeedsReloading;
        needsRelabel         = theLayer.needsRelabel;
        adjustLabelAnchors   = theLayer.adjustLabelAnchors;
        showLabels           = theLayer.showLabels;
        labelOffset          = theLayer.labelOffset;
        labelRotation        = theLayer.labelRotation;
        labelField           = theLayer.labelField;
        labelTextStyle       = theLayer.labelTextStyle;
        labelFormatter       = theLayer.labelFormatter;
        labelShadow          = theLayer.labelShadow;
        labelIndexRange      = theLayer.labelIndexRange;
        labelAnnotations     = theLayer.labelAnnotations;
        alignsPointsToPixels = theLayer.alignsPointsToPixels;
        inTitleUpdate        = theLayer.inTitleUpdate;
        
        drawLegendSwatchDecoration   = theLayer.drawLegendSwatchDecoration;
        pointingDeviceDownLabelIndex = NSNotFound;
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Bindings
    // MARK: - Drawing
    override func drawInContext(context: CGContext)
    {
        self.reloadDataIfNeeded()
        super.draw(in: context)
        
        let  theDelegate = self.delegatePlot
        
        //        if ( [theDelegate respondsToSelector:@selector(didFinishDrawing:)] ) {
        theDelegate?.didFinishDrawing(plot: self)
        //        }
    }
    
    // MARK: - Animation
    func needsDisplayForKey(forKey key: String )-> Bool
    {
        var keys        = Set<String>()
        
        keys.insert("labelOffset")
        keys.insert("labelRotation")
        
        if keys.contains(key ) {
            return true;
        }
        else {
            return CPTBorderedLayer.needsDisplay(forKey: key)
        }
    }
    
    // MARK: - Layout
    public override func layoutSublayers()
    {
        self.relabel()
        super.layoutSublayers()
    }
    
    
    // MARK:Fields
    func numberOfFields() -> Int
    {
        return 0
    }
    
    /** @brief The field identifiers that correspond to a particular coordinate.
     *  @param coord The coordinate for which the corresponding field identifiers are desired.
     *  @return Array of NSNumber objects for the field identifiers.
     **/
    func fieldIdentifiersForCoordinate( coord: CPTCoordinate ) ->[CGFloat]
    {
    return []
    }
    
    /** @brief The coordinate value that corresponds to a particular field identifier.
     *  @param field The field identifier for which the corresponding coordinate is desired.
     *  @return The coordinate that corresponds to a particular field identifier or #CPTCoordinateNone if there is no matching coordinate.
     */
    func coordinateForFieldIdentifier(field: Int)-> CPTCoordinate
    {
        return .none
    }
    
    // MARK: - Data Labels
    func positionLabelAnnotation(label:  CPTPlotSpaceAnnotation, forIndex: Int)
    {
    // do nothing--implementation provided by subclasses
    }
    
    // MARK: - User Interaction
    
    /**
     *  @brief Determines the index of the data element that is under the given point.
     *  @param point The coordinates of the interaction.
     *  @return The index of the data point that is under the given point or @ref NSNotFound if none was found.
     */
    func dataIndexFromInteractionPoint(point : CGPoint)->Int
    {
        return NSNotFound;
    }
    
    // MARK: - Data Source
    var          _numberOfRecords = 0
    var numberOfRecords: Int{
        get {
            let number = self.dataSource?.numberOfRecordsForPlot(plot: self)
            return number!
        }
        set {
            _numberOfRecords = newValue
        }
    }
    
    
    //  @brief Marks the receiver as needing the data source reloaded before the content is next drawn.
    func setDataNeedsReloading()
    {
        self.dataNeedsReloading = true;
    }
    
    /**
     *  @brief Reload all plot data, labels, and plot-specific information from the data source immediately.
     **/
    func reloadData()
    {
        self.cachedData.removeAll()
        self.cachedDataCount = 0;
        self.reloadData( indexRange: NSRange(location: 0, length: self.numberOfRecords))
    }
    
    /**
     *  @brief Reload plot data from the data source only if the data cache is out of date.
     **/
    func reloadDataIfNeeded()
    {
        if  self.dataNeedsReloading  {
            self.reloadData()
        }
    }
    
    /** @brief Reload plot data, labels, and plot-specific information in the given index range from the data source immediately.
     *  @param indexRange The index range to load.
     **/
    func reloadData( indexRange: NSRange) {
        
        dataNeedsReloading = false
        reloadPlotData(indexRange: indexRange)
        reloadDataLabels(indexRange: indexRange)
    }
}
