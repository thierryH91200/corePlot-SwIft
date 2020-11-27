//
//  CPTLimitBand.swift
//  corePlot
//
//  Created by thierryH24 on 11/11/2020.
//

import AppKit

class CPTLimitBand: NSObject {
    
    
    var range: CPTPlotRange?
    var fill: CPTFill?
    
    // MARK: Init/Dealloc
    init (range:  CPTPlotRange?,  fill: CPTFill?)
    {
        super.init()
        self.range = range
        self.fill = fill
    }
    
    init ( newRange: CPTPlotRange, newFill:  CPTFill)
    {
        super.init()
        range = newRange;
        fill  = newFill;
    }
    
    
    override init()
    {
        super.init()
        self.range = nil
        self.fill = nil
    }
}
