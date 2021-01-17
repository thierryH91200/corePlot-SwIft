//
//  CPTGraph.swift
//  corePlot
//
//  Created by thierryH24 on 09/11/2020.
//

import AppKit


public class CPTGraph: CPTBorderedLayer {
    
    // MARK: Title
    
    var hostingView : CPTGraphHostingView?
    var plots = [CPTPlot]()
    
    // MARK: - Axis Set
    var axisSet : CPTAxisSet? {
        get { return self.plotAreaFrame?.axisSet! }
        set { self.plotAreaFrame?.axisSet = newValue   }
    }

    var title = ""
    var attributedTitle = NSAttributedString()
    var titleTextStyle : CPTTextStyle?
    var titleDisplacement : CGPoint?
    var titlePlotAreaFrameAnchor : CPTRectAnchor?
    
    //    @property (nonatomic, readwrite, strong, nonnull) CPTMutablePlotArray *plots;

    var plotSpaces = [CPTPlotSpace]()
    var titleAnnotation: CPTLayerAnnotation?
    var legendAnnotation: CPTLayerAnnotation?
    var inTitleUpdate = false

    
    // MARK: Layers
//    var axisSet : CPTAxisSet
    var newAxisSet : CPTAxisSet?
    var plotAreaFrame : CPTPlotAreaFrame?
//    var defaultPlotSpace : CPTPlotSpace
    var newPlotSpace : CPTPlotSpace?
    var topDownLayerOrder : [CPTGraphLayerType]
    
    // MARK: Legend
    var legend : CPTLegend?
    var legendAnchor : CPTRectAnchor?
    var legendDisplacement: CGPoint;
    
    // MARK: - Accessors
    func setPaddingLeft(newPadding: CGFloat)
    {
        if newPadding != self.paddingLeft  {
            super.paddingLeft = newPadding
            for theAxes in self.axisSet!.axes{
                theAxes.setNeedsDisplay()
            }
        }
    }
    
    func setPaddingRight(newPadding:CGFloat)
    {
        if ( newPadding != self.paddingRight ) {
            super.paddingRight = newPadding;
            for theAxes in self.axisSet!.axes{
                theAxes.setNeedsDisplay()
            }
        }
    }
    
     func setPaddingTop(newPadding:CGFloat)
    {
        if ( newPadding != self.paddingTop ) {
            super.paddingTop = newPadding
            for theAxes in self.axisSet!.axes{
                theAxes.setNeedsDisplay()
            }
        }
    }
    
    func setPaddingBottom(newPadding: CGFloat)
    {
        if ( newPadding != self.paddingBottom ) {
            super.paddingBottom = newPadding
            for theAxes in self.axisSet!.axes{
                theAxes.setNeedsDisplay()
            }
        }
    }

    
    override init(frame : CGRect) {
        super.init(frame: frame)
        hostingView = nil
        plots.removeAll()
        
        // Margins
        paddingLeft = CGFloat(20.0)
        paddingTop = CGFloat(20.0)
        paddingRight = CGFloat(20.0)
        paddingBottom = CGFloat(20.0)
        
        // Plot area
        let newArea = CPTPlotAreaFrame(newFrame: bounds)
        plotAreaFrame = newArea
        
        // Plot spaces
        plotSpaces = [CPTPlotSpace]()
        let newPlotSpace = self.newPlotSpace
        plotSpaces.append(newPlotSpace!)
        
        // Axis set
//        let newAxisSet = self.newAxisSet
        
        // Title
        title = ""
        attributedTitle = NSAttributedString()
        titlePlotAreaFrameAnchor = .top
        titleTextStyle = CPTTextStyle()
        titleDisplacement = CGPoint.zero
        titleAnnotation = nil
        
        // Legend
        legend = nil
        legendAnnotation = nil
        legendAnchor = .bottom
        legendDisplacement = CGPoint.zero
        
        inTitleUpdate = false
        
        needsDisplayOnBoundsChange = true
    }
    
    override init(layer : Any)
    {
        super.init(layer : layer)
        let theLayer = CPTGraph(layer: layer)
        
        hostingView              = theLayer.hostingView;
        plotAreaFrame            = theLayer.plotAreaFrame;
        plots                    = theLayer.plots;
        plotSpaces               = theLayer.plotSpaces;
        title                    = theLayer.title;
        attributedTitle          = theLayer.attributedTitle;
        titlePlotAreaFrameAnchor = theLayer.titlePlotAreaFrameAnchor;
        titleTextStyle           = theLayer.titleTextStyle;
        titleDisplacement        = theLayer.titleDisplacement;
        titleAnnotation          = theLayer.titleAnnotation;
        legend                   = theLayer.legend;
        legendAnnotation         = theLayer.legendAnnotation;
        legendAnchor             = theLayer.legendAnchor;
        legendDisplacement       = theLayer.legendDisplacement;
        inTitleUpdate            = theLayer.inTitleUpdate;
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
