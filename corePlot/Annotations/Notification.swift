//
//  Notification.swift
//  corePlot
//
//  Created by thierryH24 on 20/11/2020.
//


import AppKit


public extension Notification.Name {
    
    
    // MARK: Legend
    static let CPTLegendNeedsRedrawForPlotNotification  =  Notification.Name( "CPTLegendNeedsRedrawForPlotNotification")
    static let CPTLegendNeedsLayoutForPlotNotification  =  Notification.Name( "CPTLegendNeedsLayoutForPlotNotification")
    static let CPTLegendNeedsReloadEntriesForPlotNotification =  Notification.Name( "CPTLegendNeedsReloadEntriesForPlotNotification")

    static let CPTPlotSpaceCoordinateMappingDidChangeNotification =  Notification.Name( "CPTPlotSpaceCoordinateMappingDidChangeNotification")

    static let CPTLayerBoundsDidChangeNotification     = Notification.Name( "CPTLayerBoundsDidChangeNotification")
    static let CoordinateMappingDidChangeNotification  = Notification.Name( "CoordinateMappingDidChangeNotification")
    static let boundsDidChange  = Notification.Name( "boundsDidChange")
    
    static let CPTGraphNeedsRedrawNotification  = Notification.Name( "CPTGraphNeedsRedrawNotification")
    static let CPTGraphDidAddPlotSpaceNotification  = Notification.Name( "CPTGraphDidAddPlotSpaceNotification")
    static let CPTGraphDidRemovePlotSpaceNotification  = Notification.Name( "CPTGraphDidRemovePlotSpaceNotification")
    static let CPTGraphPlotSpaceNotificationKey  = Notification.Name( "CPTGraphPlotSpaceNotificationKey")
    
    static let updateBalance             = Notification.Name( "updateBalance")
    static let updateAccount             = Notification.Name( "updateAccount")

    static let selectionDidChangeTable   = NSTableView.selectionDidChangeNotification
    static let selectionDidChangeOutLine = NSOutlineView.selectionDidChangeNotification
}

extension NotificationCenter {
    
    // Send(Post) Notification
    static func send( name: Notification.Name , object :Any? = nil, userInfo : [AnyHashable : Any]? = nil ) {
        self.default.post(
            name: name,
            object: object,
            userInfo : userInfo
        )
    }
    
    // Receive(addObserver) Notification
    static func receive(instance: Any, name: Notification.Name, selector: Selector, object :Any? = nil) {
        self.default.addObserver(
            instance,
            selector: selector,
            name: name,
            object: object
        )
    }
    
    // Remove(removeObserver) Notification
    static func remove( instance: Any, name: Notification.Name, object :Any? = nil  ) {
        self.default.removeObserver(
            instance,
            name: name,
            object: object
        )
    }
}

public extension NSBindingName {
    
    // MARK: CPTPlot

    static let CPTPlotBindingDataLabels  =  NSBindingName( "dataLabels")
    
    // MARK: CPTBar
    static let CPTBarPlotBindingBarLocations  = NSBindingName("barLocations" ) ///< Bar locations.
    static let CPTBarPlotBindingBarTips       = NSBindingName("barTips"  )     ///< Bar tips.
    static let CPTBarPlotBindingBarBases      = NSBindingName("barBases")      ///< Bar bases.
    static let CPTBarPlotBindingBarFills      = NSBindingName("barFills" )    ///< Bar fills.
    static let CPTBarPlotBindingBarLineStyles = NSBindingName("barLineStyles") ///< Bar line styles.
    static let CPTBarPlotBindingBarWidths     = NSBindingName("barWidths" )    ///< Bar widths.
    
    // MARK: CPTPie
    static let PieSliceWidthValues   = NSBindingName("sliceWidths")        ///< Pie slice widths.
    static let PieSliceFills         = NSBindingName("sliceFills")       ///< Pie slice interior fills.
    static let PieSliceRadialOffsets = NSBindingName("sliceRadialOffsets") ///< Pie slice radial offsets.
}


//const String.DrawingOptions CPTStringDrawingOptions = NSStringDrawingUsesLineFragmentOrigin |
//                                                       NSStringDrawingUsesFontLeading |
//                                                       NSStringDrawingTruncatesLastVisibleLine;

