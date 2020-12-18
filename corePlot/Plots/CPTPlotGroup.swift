//
//  CPTPlotGroup.swift
//  corePlot
//
//  Created by thierryH24 on 11/11/2020.
//

//==============================
//  OK
// 18/12/20
//==============================



import AppKit

class CPTPlotGroup: CPTLayer {


// MARK: - Organizing Plots
    func addPlot(plot:  CPTPlot)
    {
        self.addSublayer(plot)
    }

    /** @brief Add a plot to this plot group at the given index.
     *  @param plot The plot.
     *  @param idx The index at which to insert the plot. This value must not be greater than the count of elements in the sublayer array.
     **/
    func insertPlot(plot: CPTPlot, atIndex:Int)
    {
        self.insertSublayer(plot, at: UInt32(atIndex))
    }

    func removePlot(plot: CPTPlot )
    {
        if self == plot.superlayer  {
            plot.removeFromSuperlayer()
        }
    }

// MARK: - Drawing
    override func display()
    {
        // nothing to draw
    }

    override func renderAsVectorInContext(context: CGContext)
    {
        // nothing to draw
        if ( /* DISABLES CODE */ (false)) {
            super.renderAsVectorInContext(context: context)
        }
    }
}
