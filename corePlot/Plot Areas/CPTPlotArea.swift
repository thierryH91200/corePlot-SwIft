//
//  CPTPlotArea.swift
//  corePlot
//
//  Created by thierryH24 on 11/11/2020.
//

import Cocoa

class CPTPlotArea: CPTAnnotationHostLayer {
    /// @name Layers
    /// @{
    var minorGridLineGroup : CPTGridLineGroup
    var majorGridLineGroup: CPTGridLineGroup
    var axisSet: CPTAxisSet
    var plotGroup: CPTPlotGroup
    var axisLabelGroup : CPTAxisLabelGroup
    var axisTitleGroup: CPTAxisLabelGroup
    /// @}

    /// @name Layer Ordering
    /// @{
    var *topDownLayerOrder CPTNumberArray
    /// @}

    /// @name Decorations
    /// @{
    @property (nonatomic, readwrite, copy, nullable)  *borderLineStyle: CPTLineStyle
    @property (nonatomic, readwrite, copy, nullable)  *fill: CPTFill
    /// @}

    /// @name Dimensions
    /// @{
    @property (nonatomic, readonly)  widthDecimal: NSDecimal
    @property (nonatomic, readonly)  heightDecimal: NSDecimal

}
