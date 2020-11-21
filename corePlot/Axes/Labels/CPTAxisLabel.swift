//
//  CPTAxisLabel.swift
//  corePlot
//
//  Created by thierryH24 on 16/11/2020.
//

import Cocoa

class CPTAxisLabel: NSObject {
    
    
    var contentLayer: CPTLayer
    var offset: CGFloat = 0.0
    var rotation: CGFloat = 0.0
    var alignment: CPTAlignment?
    var tickLocation = CGFloat(0)
    
    
    
    typealias CPTAxisLabelSet = Set<CPTAxisLabel>
    
    convenience init( newText: String?, newStyle: CPTTextStyle?) {
        
        let newLayer = CPTTextLayer(text: newText, style: newStyle)
        
        self.init(layer: newLayer)
    }
    
    init(layer: CPTLayer)
    {
        super.init()
        contentLayer = layer;
        offset       = CGFloat(20.0);
        rotation     = CGFloat(0.0);
        alignment    = .center
        tickLocation = 0.0;
    }
    
}
