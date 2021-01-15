//
//  CPTXYTheme.swift
//  corePlot
//
//  Created by thierryH24 on 09/11/2020.
//

import AppKit

class CPTXYTheme: CPTTheme {
    
    override init()
    {
        super.init()
        self.graphClass = CPTXYGraph()
    }

    func newGraph()-> CPTXYGraph
    
    {
        var graph : CPTXYGraph?
        
        if  self.graphClass  != nil {
            graph = CPTXYGraph(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 200.0))
        }
        else {
            graph = CPTXYGraph(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 200.0))
        }
        graph?.paddingLeft   = CGFloat(60.0);
        graph?.paddingTop    = CGFloat(60.0);
        graph?.paddingRight  = CGFloat(60.0);
        graph?.paddingBottom = CGFloat(60.0);
        
        let plotSpace = graph?.defaultPlotSpace as? CPTXYPlotSpace
        
        plotSpace?.xRange = CPTPlotRange(location:-1.0, length:1.0)
        plotSpace?.yRange = CPTPlotRange(location:-1.0, length:1.0)
        
        self.applyThemeToGraph(graph: graph!)
        
        return graph!
    }
}
