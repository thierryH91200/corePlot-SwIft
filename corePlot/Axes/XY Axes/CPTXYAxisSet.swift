//
//  CPTXYAxisSet.swift
//  corePlot
//
//  Created by thierryH24 on 14/11/2020.
//

import AppKit

class CPTXYAxisSet: CPTAxisSet {
    var xAxis: CPTXYAxis
    var yAxis: CPTXYAxis

    // MARK: - Init/Dealloc
    override init(frame: CGRect) {
        super.init(frame: frame)
        let xAxis = CPTXYAxis(layer: frame)
        xAxis.coordinate = CPTCoordinate.x
        xAxis.tickDirection = CPTSign.negative

        let yAxis = CPTXYAxis(layer: frame)
        yAxis.coordinate = CPTCoordinate.y
        yAxis.tickDirection = CPTSign.negative

        axes = [xAxis, yAxis]
    }

//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

    // MARK: - Drawing
    override func renderAsVectorInContext(context: CGContext) {
        guard self.isHidden == false else { return }

        let theLineStyle = self.borderLineStyle

        if theLineStyle != nil {
            super.renderAsVectorInContext(context: context)

            let superlayer = self.superlayer
            let borderRect = CPTUtilities.shared.CPTAlignRectToUserSpace(context: context, rect: self.convert(superlayer!.bounds, from: superlayer))
            theLineStyle?.setLineStyleInContext(context: context)

            let radius = superlayer?.cornerRadius

            if radius! > CGFloat(0.0) {
                context.beginPath()
                CPTPathExtensions.shared.CPTAddRoundedRectPath(context: context, rect: borderRect, cornerRadius: radius!)

                theLineStyle?.strokePathInContext(context: context)
            }
            else {
                theLineStyle?.strokeRect(rect: borderRect, context: context)
            }
        }
    }

    /// @endcond

    // MARK: - mark Layout

    /// @name Layout
    /// @{

    /**
     *  @brief Updates the layout of all sublayers. Sublayers (the axes) fill the plot area frame&rsquo;s bounds.
     *
     *  This is where we do our custom replacement for the Mac-only layout manager and autoresizing mask.
     *  Subclasses should override this method to provide a different layout of their own sublayers.
     **/
    override func layoutSublayers() {
        // If we have a border, the default layout will work. Otherwise, the axis set layer has zero size
        // and we need to calculate the correct size for the axis layers.
        if self.borderLineStyle != nil {
            super.layoutSublayers()
        }
        else {
            let plotAreaFrame = self.superlayer?.superlayer
            var sublayerBounds = self.convert(plotAreaFrame!.bounds, from: plotAreaFrame)
            sublayerBounds.origin = CGPoint()
            var sublayerPosition = self.convert(self.bounds.origin, to: plotAreaFrame)
            sublayerPosition = CGPoint(x: -sublayerPosition.x, y: -sublayerPosition.y)

            let subLayerFrame = CGRect(x: sublayerPosition.x,
                                       y: sublayerPosition.y,
                                       width: sublayerBounds.size.width,
                                       height: sublayerBounds.size.height)

            let excludedSublayers = self.sublayersExcludedFromAutomaticLayout()

            for subLayer in self.sublayers! {
                if excludedSublayers?.contains(subLayer) == false {
                    subLayer.frame = subLayerFrame
                }
            }
        }
    }

    // MARK: - Accessors

//    var xAxis: GCControllerAxisInput {
//        return (axis(forCoordinate: CPTCoordinateX, atIndex: 0) as? CPTXYAxis)!
//    }
//
//    var yAxis: GCControllerAxisInput {
//        return (axis(forCoordinate: CPTCoordinateY, atIndex: 0) as? CPTXYAxis)!
//    }
}
