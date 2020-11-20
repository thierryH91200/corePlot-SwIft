//
//  CPTXYGraph.swift
//  corePlot
//
//  Created by thierryH24 on 11/11/2020.
//

import AppKit

class CPTXYGraph: CPTGraph {
    
    var xScaleType : CPTScaleType?
    var yScaleType : CPTScaleType?
    
    // MARK: Init/Dealloc
    init(frame : CGRect, newXScaleType: CPTScaleType, newYScaleType: CPTScaleType)
    {
        super.init(frame: frame)
        xScaleType = newXScaleType
        yScaleType = newYScaleType
    }
    
    init( newFrame : CGRect)
    {
        super.init(frame : frame)
        xScaleType = CPTScaleType.linear
        yScaleType = CPTScaleType.linear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Factory Methods
    func newPlotSpace()-> CPTPlotSpace
    {
        let space = CPTXYPlotSpace()

        space.xScaleType = self.xScaleType!
        space.yScaleType = self.yScaleType!
        return space;
    }

    func newAxisSet() -> CPTAxisSet
    {
        let newAxisSet = CPTXYAxisSet( frame: self.bounds)

        newAxisSet.xAxis.plotSpace = self.defaultPlotSpace;
        newAxisSet.yAxis.plotSpace = self.defaultPlotSpace;
        return newAxisSet;
    }
}
