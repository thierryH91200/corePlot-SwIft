//
//  CPTXYAxisSet.swift
//  corePlot
//
//  Created by thierryH24 on 14/11/2020.
//

import Cocoa

class CPTXYAxisSet: CPTAxisSet {
    var xAxis: CPTXYAxis
    var yAxis: CPTXYAxis
    
    // MARK: - Init/Dealloc

    init(frame : CGRect)
    {
        super.init(frame:frame)
            CPTXYAxis *xAxis = [[CPTXYAxis alloc] initWithFrame:newFrame];
            xAxis.coordinate    = CPTCoordinateX;
            xAxis.tickDirection = CPTSignNegative;

            let yAxis = CPTXYAxis( newFrame : newFrame)
            yAxis.coordinate    = CPTCoordinateY
            yAxis.tickDirection = CPTSignNegative

            self.axes = [xAxis, yAxis]
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



