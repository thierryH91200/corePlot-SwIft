//
//  CPTPieChart reload.swift
//  corePlot
//
//  Created by thierryH24 on 23/12/2020.
//

import AppKit

extension CPTPieChart {
    
    func reloadSliceFillsInIndexRange(indexRange: NSRange)
    {
        var needsLegendUpdate = false
        
        if let fill = theDataSource?.sliceFillsForPieChart(self, recordIndexRange: indexRange) {

            needsLegendUpdate = true
            let fill = theDataSource?.sliceFillsForPieChart(self, recordIndexRange:indexRange)
            self.cacheArray(array: fill! as [Any],
                            forKey: NSBindingName.PieSliceFills.rawValue,
                            atRecordIndex:indexRange.location)
        }
        else if (theDataSource?.sliceFillForPieChart(self, recordIndex: indexRange) != nil) {
            needsLegendUpdate = true
            
            let nilObject = (CPTPlot nilData)
            let nilFill : CPTFill?
            var array = [Any]()
            var maxIndex = NSMaxRange(indexRange);
            
            for idx in indexRange.location..<maxIndex {
                let fill = theDataSource?.sliceFillForPieChart(self, idx:idx)
                if (( fill ) != nil) {
                    array.append(fill as Any)
                }
                else {
                    array.append(nilFill)
                }
            }
            
            self.cacheArray(array: array,
                            forKey:NSBindingName.PieSliceFills.rawValue,
                            atRecordIndex:indexRange.location)
        }
        
        // Legend
        if needsLegendUpdate == true {
            NotificationCenter.send(
                name:.CPTLegendNeedsRedrawForPlotNotification,
                object:self)
        }
        self.setNeedsDisplay()
    }
}
