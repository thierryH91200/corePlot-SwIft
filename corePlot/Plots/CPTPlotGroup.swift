//
//  CPTPlotGroup.swift
//  corePlot
//
//  Created by thierryH24 on 11/11/2020.
//

import Cocoa

class CPTPlotGroup: CPTLayer {

//    -(nullable instancetype)initWithCoder:(nonnull NSCoder *)coder
//    {
//        if ((self = [super initWithCoder:coder])) {
//            // support old archives
//            if ( [coder containsValueForKey:@"CPTPlotGroup.identifier"] ) {
//                self.identifier = [coder decodeObjectOfClass:[NSObject class]
//                                                      forKey:@"CPTPlotGroup.identifier"];
//            }
//        }
//        return self;
//    }
//
//    /// @endcond
//
//    #pragma mark -
//    #pragma mark NSSecureCoding Methods
//
//    /// @cond
//
//    +(BOOL)supportsSecureCoding
//    {
//        return YES;
//    }

    /// @endcond

//    #pragma mark -
//    #pragma mark Organizing Plots
//
//    /** @brief Add a plot to this plot group.
//     *  @param plot The plot.
//     **/
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

    /** @brief Remove a plot from this plot group.
     *  @param plot The plot to remove.
     **/
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
