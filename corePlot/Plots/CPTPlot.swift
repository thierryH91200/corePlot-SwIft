//
//  CPTPlot.swift
//  corePlot
//
//  Created by thierryH24 on 11/11/2020.
//

import AppKit

@objc public protocol CPTPlotDataSource: NSObjectProtocol {
    
    func numberOfRecordsForPlot ( plot:  CPTPlot) -> Int
    func numbersForPlot         ( plot : CPTPlot, fieldEnum :Int, indexRange : NSRange) -> [Int]
    func numberForPlot          ( plot: CPTPlot, field:Int, index: Int) -> Double
    func doubleForPlot          ( plot: CPTPlot, fieldEnum:Int,  index: Int) ->Double
    
    func dataForPlot            ( plot: CPTPlot, fieldEnum: Int, indexRange:NSRange ) -> CGFloat
    @objc optional func dataForPlot(plot : CPTPlot , indexRange:NSRange)-> [CGFloat]
    @objc optional func dataLabelForPlot(plot: CPTPlot, index:Int )-> CPTLayer
    @objc optional func dataLabelsForPlot(plot: CPTPlot,  indexRange: NSRange)-> [CPTLayer]
}

@objc public protocol CPTPlotDelegate {
    
    func plot(plot: CPTPlot, dataLabelWasSelectedAtRecordIndex:Int)
    func plot(plot: CPTPlot, dataLabelWasSelectedAtRecordIndex:Int,  event: CPTNativeEvent )
    func plot(plot: CPTPlot, dataLabelTouchDownAtRecordIndex:Int)
    func plot(plot: CPTPlot, dataLabelTouchDownAtRecordIndex:Int, event: CPTNativeEvent )
    func plot(plot: CPTPlot, dataLabelTouchUpAtRecordIndex: Int)
    func plot(plot: CPTPlot, dataLabelTouchUpAtRecordIndex: Int,  event: CPTNativeEvent )
    
    func didFinishDrawing(plot: CPTPlot )
}

public class CPTPlot: CPTAnnotationHostLayer {
    
    var cachedData: [String : [Any]] = [:]
        
    open weak var dataSource  : CPTPlotDataSource?
    @objc open weak var delegatePlot: CPTPlotDelegate?
    
    var _title : String?
    var title : String? {
        get { return _title}        
        set {
            if ( newValue != _title ) {
                _title = newValue
                
                if self.inTitleUpdate == false {
                    self.attributedTitle = nil;
                    
                    NotificationCenter.send(
                        name: .CPTLegendNeedsLayoutForPlotNotification,
                        object:self)
                }
            }
        }
    }
    
    
    var plotArea : CPTPlotArea? {
        get {
            let theGraph = self.graph
            return theGraph?.plotAreaFrame.plotArea! }
        set { }
    }

    var attributedTitle : NSAttributedString?
    var plotSpace : CPTPlotSpace?
    var adjustLabelAnchors = false
    
    var labelOffset = CGFloat (0)
    
    var labelField : Int
    var labelTextStyle: CPTTextStyle?
    var labelFormatter : Formatter?
    
    var dataNeedsReloading = false
    
    var needsRelabel = false
    var labelIndexRange = NSRange()
    var alignsPointsToPixels = true
    
    var labelAnnotations = [CPTAnnotation]()
    //    var dataLabels = [CPTLayer]()
    var drawLegendSwatchDecoration = false
    
    var pointingDeviceDownLabelIndex = 0
    var cachedDataCount = 0
    var inTitleUpdate = false
    
    var cachePrecision = CPTPlotCachePrecision.auto
    
    var fieldIdentifiers = [Int]()
    
    var _labelRotation = CGFloat(0)
    var labelRotation : CGFloat {
        get { return _labelRotation  }
        set {
            if ( newValue != _labelRotation ) {
                _labelRotation = newValue
                
                for  label in self.labelAnnotations  {
                    label.rotation = labelRotation;
                    self.updateContentAnchorForLabel(label: label as! CPTPlotSpaceAnnotation)
                }
            }
        }
    }

    var _labelShadow : CPTShadow?
    var labelShadow : CPTShadow? {
        get { return _labelShadow!}
        set {
            if ( newValue != _labelShadow ) {
                _labelShadow = newValue;
    
                for label in self.labelAnnotations  {
                    label.contentLayer?.shadow = labelShadow
                }
            }
        }
    }

    var _showLabels = false
    var showLabels : Bool {
        get {return _showLabels}
        set {
            if ( newValue != _showLabels ) {
                _showLabels = newValue;
                if  _showLabels == true {
                    self.setNeedsLayout()
                }
                //                self.needsRelabel()
            }
        }
    }
    

    
    enum _CPTPlotCachePrecision: Int {
        case auto
        case double
        case decimal
    }
    typealias CPTPlotCachePrecision = _CPTPlotCachePrecision

    
    override init()
    {
        super.init()
        CPTPlot.exposeBinding(.PlotDataLabels)
    }

    override init(frame: CGRect)
    {
        super.init()
        cachedData  = [:]
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
        labelField           = 0
        labelTextStyle       = nil;
        labelFormatter       = Formatter()
        labelShadow          = nil
        labelIndexRange      = NSRange(location: 0, length: 0);
        labelAnnotations.removeAll()
        alignsPointsToPixels = true;
        inTitleUpdate        = false;
        
        pointingDeviceDownLabelIndex = NSNotFound;
        drawLegendSwatchDecoration   = true
        
        self.masksToBounds              = true
        self.needsDisplayOnBoundsChange = true
    }
    
    
    override init(layer: Any)
    {
        super.init(layer: layer)
        
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
    
//    +(nonnull id)nilData
//    {
//        static id nilObject              = nil;
//        static dispatch_once_t onceToken = 0;
//
//        dispatch_once(&onceToken, ^{
//            nilObject = [[NSObject alloc] init];
//        });
//
//        return nilObject;
//    }

//    static let nilDataNilObject = { () -> <#Result#> in
//        var nilObject = NSObject()
//        return nilObject
//    }()
//
//    class func nilData() -> Any {
//
//        // `dispatch_once()` call was converted to a static variable initializer
//
//        return nilDataNilObject
//    }
    
    func plotRangeForCoordinate(coord: CPTCoordinate)-> CPTPlotRange?
    {
        let fields = self.fieldIdentifiersForCoordinate(coord: coord)
        guard ( fields.count != 0 ) else { return nil }
        
        var unionRange : CPTMutablePlotRange?
        
        for field in fields  {
            let currentRange = self.plotRangeForField(fieldEnum: Int(field))
            if ( (unionRange == nil) ) {
                unionRange = currentRange as? CPTMutablePlotRange
            }
            else {
                unionRange?.unionPlotRange(other: self.plotRangeForField(fieldEnum: Int(field)))
            }
        }
        return unionRange;
    }

    
    func reloadDataInIndexRange(indexRange :NSRange)
    {
        self.dataNeedsReloading = false;
        self.reloadPlotData(indexRange: indexRange)
        
        // Data labels
        self.reloadDataLabels( indexRange: indexRange)
    }

    
    // MARK: - Bindings
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
    var _numberOfRecords = 0
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
    
    // MARK: - Legends
    func numberOfLegendEntries()->Int
    {
        return 1
    }
    
    ///** @brief The title text of a legend entry.
    // *  @param idx The index of the desired title.
    // *  @return The title of the legend entry at the requested index.
    // **/
    func titleForLegendEntryAtIndex(idx: Int) ->String
    {
        var legendTitle = self.title
        
        if ( legendTitle != "" ) {
            let  myIdentifier = self.identifier;
            
            if myIdentifier is String {
                legendTitle = myIdentifier as? String
            }
        }
        return legendTitle!;
    }
    
    func attributedTitleForLegendEntryAtIndex(idx: Int )-> NSAttributedString
    {
        var legendAttributedTitle = self.attributedTitle
        
        if ( legendAttributedTitle == nil ) {
            let  myIdentifier = self.identifier
            
            if myIdentifier is NSAttributedString {
                legendAttributedTitle = myIdentifier as? NSAttributedString
            }
        }
        return legendAttributedTitle!
    }
    
    ///** @brief Draws the legend swatch of a legend entry.
    // *  Subclasses should call @super to draw the background fill and border.
    // *  @param legend The legend being drawn.
    // *  @param idx The index of the desired swatch.
    // *  @param rect The bounding rectangle where the swatch should be drawn.
    // *  @param context The graphics context to draw into.
    // **/
    func drawSwatchForLegend(legend: CPTLegend, atIndex idx:Int , inRect rect: CGRect, context: CGContext)
    {
        weak var theDelegate = self.delegate as? CPTLegendDelegate
        
        var theFill : CPTFill?
        //        let defaultHandler = {}
        
        if let method = theDelegate?.legend?( legend: legend, fillForSwatchAtIndex: idx, forPlot: self) {
            theFill =   method
        }
        
        if ( theFill == nil ) {
            theFill = legend.swatchFill
        }
        
        var theLineStyle : CPTLineStyle?
        
        if let method =  theDelegate?.legend!(legend: legend , lineStyleForSwatchAtIndex: idx, forPlot: self)  {
            theLineStyle = method
        }
        if ( theLineStyle == nil ) {
            theLineStyle = legend.swatchBorderLineStyle
        }
        
        if ( theFill != nil || theLineStyle != nil ) {
            let radius = legend.swatchCornerRadius
            
            if theFill  != nil {
                context.beginPath();
                CPTPathExtensions.shared.CPTAddRoundedRectPath(
                    context: context,
                    rect: CPTUtilities.shared.CPTAlignIntegralRectToUserSpace(context: context, rect: rect),
                    cornerRadius: radius);
                theFill?.fillPathInContext(context: context)
            }
            
            if ( theLineStyle != nil) {
                theLineStyle?.setLineStyleInContext(context: context)
                context.beginPath()
                CPTPathExtensions.shared.CPTAddRoundedRectPath(context: context, rect: CPTUtilities.shared.CPTAlignBorderedRectToUserSpace(context: context, rect: rect, borderLineStyle: theLineStyle!), cornerRadius: radius);
                theLineStyle?.strokePathInContext(context: context)
            }
        }
    }
}
