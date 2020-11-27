//
//  Notification.swift
//  corePlot
//
//  Created by thierryH24 on 20/11/2020.
//


import AppKit


public extension Notification.Name {
    
    static let CPTLayerBoundsDidChangeNotification           = Notification.Name( "CPTLayerBoundsDidChangeNotification")
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
//    static let selectionDidChangeComboBox = NSComboBox.selectionDidChangeNotification
}

extension NotificationCenter {
    
    // Send(Post) Notification
    static func send(_ key: Notification.Name) {
        self.default.post(
            name: key,
            object: nil
        )
    }
    
    // Receive(addObserver) Notification
    static func receive(instance: Any, name: Notification.Name, selector: Selector) {
        self.default.addObserver(
            instance,
            selector: selector,
            name: name,
            object: nil
        )
    }
    
    // Remove(removeObserver) Notification
    static func remove( instance: Any, name: Notification.Name  ) {
        self.default.removeObserver(
            instance,
            name: name,
            object: nil
        )
    }
}
