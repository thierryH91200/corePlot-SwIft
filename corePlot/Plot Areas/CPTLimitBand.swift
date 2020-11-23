//
//  CPTLimitBand.swift
//  corePlot
//
//  Created by thierryH24 on 11/11/2020.
//

import Cocoa

class CPTLimitBand: NSObject {

    
    var range: CPTPlotRange?
    var fill: CPTFill?

    // MARK: Init/Dealloc
//
    init (range:  CPTPlotRange?,  fill: CPTFill?)
    {
        super.init()
        self.range = range
        self.fill = fill
    }

    override init()
    {
        super.init()
        self.range = nil
        self.fill = nil
    }

    
}
