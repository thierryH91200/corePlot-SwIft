//
//  PieChartController.swift
//  corePlot
//
//  Created by thierryH24 on 14/11/2020.
//

import AppKit

class PieChartController: NSViewController {
    
    private var pieGraph : CPTXYGraph? = nil
    let dataForChart = [20.0, 30.0, 60.0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        // Create graph from theme
        
        let kCPTDarkGradientTheme = "Dark Gradients"

        let newGraph = CPTXYGraph(frame: CGRect())
        newGraph.applyTheme(theme: CPTTheme(named: .darkGradientTheme))
        
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
        let piePlot = CPTPieChart(frame: CGRect)
        piePlot.dataSource      = self
        piePlot.pieRadius       = 131.0
        piePlot.identifier      = "Pie Chart 1"
        piePlot.startAngle      = CGFloat(M_PI_4)
        piePlot.sliceDirection  = .counterClockwise
        piePlot.centerAnchor    = CGPoint(x: 0.5, y: 0.38)
        piePlot.borderLineStyle = CPTLineStyle()
        piePlot.delegate        = self
        newGraph.addPlot(piePlot)
        
        self.pieGraph = newGraph
    }
    
    // MARK: - Plot Data Source Methods
    func numberOfRecordsForPlot(plot: CPTPlot) -> UInt
    {
        return UInt(self.dataForChart.count)
    }
    
    func numberForPlot(plot: CPTPlot, field: UInt, recordIndex: UInt) -> Int?
    {
        if Int(recordIndex) > self.dataForChart.count {
            return nil
        }
        else {
            switch CPTPieChartField(rawValue: Int(field))! {
            case .SliceWidth:
                return (self.dataForChart)[Int(recordIndex)] as Int
                
            default:
                return recordIndex
            }
        }
    }
    
    func dataLabelForPlot(plot: CPTPlot, recordIndex: UInt) -> CPTLayer?
    {
        let label = CPTTextLayer(text:"\(recordIndex)", style: <#CPTTextStyle?#>)
        
        if let textStyle = label.textStyle?.mutableCopy() as? CPTMutableTextStyle {
            textStyle.color = CPTColor.lightGray
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
    
    // MARK: - Delegate Methods
    
    func pieChart(plot: CPTPlot, sliceWasSelectedAtRecordIndex recordIndex: UInt)
    {
        self.pieGraph?.title = "Selected index: \(recordIndex)"
    }
}


