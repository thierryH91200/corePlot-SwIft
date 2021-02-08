//
//  PieChartController.swift
//  corePlot
//
//  Created by thierryH24 on 14/11/2020.
//

import AppKit

class PieChartController: NSViewController  {
    
    private var pieGraph : CPTXYGraph? = nil
    let dataForChart = [20.0, 30.0, 60.0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        // Create graph from theme
        
        //        let kCPTDarkGradientTheme = "Dark Gradients"
        
        let newGraph = CPTXYGraph(frame: CGRect())
        newGraph.applyTheme(theme: CPTTheme(named: CPTThemeName.CPTDarkGradientTheme.rawValue))
        
        let hostingView = self.view as! CPTGraphHostingView
        hostingView.hostedGraph = newGraph
        
        // Paddings
        newGraph.paddingLeft   = 20.0
        newGraph.paddingRight  = 20.0
        newGraph.paddingTop    = 20.0
        newGraph.paddingBottom = 20.0
        
        newGraph.axisSet = nil
        
        let whiteText = CPTTextStyle()
        whiteText.color = NSColor.white
        
        newGraph.titleTextStyle = whiteText
        newGraph.title          = "Graph Title"
        
        // Add pie chart
        let piePlot = CPTPieChart(frame: .zero)
        piePlot.dataSource      = self
        piePlot.pieRadius       = 131.0
        piePlot.identifier      = "Pie Chart 1"
        piePlot.startAngle      = CGFloat.pi/4
        piePlot.sliceDirection  = .counterClockwise
        piePlot.centerAnchor    = CGPoint(x: 0.5, y: 0.38)
        piePlot.borderLineStyle = CPTLineStyle()
        piePlot.delegate        = self
        newGraph.addPlot(plot: piePlot)
        
        self.pieGraph = newGraph
    }
}

// MARK: - Plot Data Source Methods
extension PieChartController: CPTPieChartDataSource  {
    
    func numberOfRecordsForPlot(plot: CPTPlot) -> UInt
    {
        return UInt(self.dataForChart.count)
    }
    
    func numberForPlot(plot: CPTPlot, field: UInt, recordIndex: UInt) -> Any?
    {
        guard recordIndex <= self.dataForChart.count else { return nil  }
        
        switch CPTPieChartField(rawValue: Int(field))! {
        case .sliceWidth:
            return self.dataForChart[Int(recordIndex)]
            
        default:
            return Int(recordIndex)
        }
    }
    
    func dataLabelForPlot(plot: CPTPlot, index: UInt) -> CPTLayer?
    {
        let label = CPTTextLayer(newText:"\(index)")
        
        if let textStyle = label.textStyle?.mutableCopy() as? CPTMutableTextStyle {
            textStyle.color = NSUIColor.lightGray
            label.textStyle = textStyle
        }
        return label
    }
    
    func radialOffsetForPieChart(piePlot: CPTPieChart, recordIndex: UInt) -> CGFloat
    {
        var offset: CGFloat = 0.0
        if ( recordIndex == 0 ) {
            offset = piePlot.pieRadius / 8.0
        }
        return offset
    }
}

// MARK: - Delegate Methods
extension PieChartController: CPTPieChartDelegate  {
    
    func pieChart(plot: CPTPieChart, sliceWasSelectedAtRecordIndex idx: Int)
    {
        self.pieGraph?.title = "Selected index: \(idx)"
    }
}


