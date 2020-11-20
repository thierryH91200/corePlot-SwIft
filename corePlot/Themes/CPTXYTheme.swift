//
//  CPTXYTheme.swift
//  corePlot
//
//  Created by thierryH24 on 09/11/2020.
//

import Cocoa

class CPTXYTheme: CPTTheme {

    override init()
    {
        self.graphClass = CPTXYGraph.class
    }

    
    func newGraph()
    {
    var graph : CPTXYGraph?

        if ( self.graphClass ) {
            graph = [[self.graphClass((CGRectMake(0.0, 0.0, 200.0, 200.0))
        }
        else {
            graph = CPTXYGraph(CGRectMake(0.0, 0.0, 200.0, 200.0)
        }
        graph.paddingLeft   = CPTFloat(60.0);
        graph.paddingTop    = CPTFloat(60.0);
        graph.paddingRight  = CPTFloat(60.0);
        graph.paddingBottom = CPTFloat(60.0);

        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;

        plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(-1.0) length:@1.0];
        plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(-1.0) length:@1.0];

        [self applyThemeToGraph:graph];

        return graph;
    }
}
