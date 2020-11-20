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
    var tickLocation = 0
    
    
    
    typealias CPTAxisLabelSet = Set<CPTAxisLabel>

    convenience init(text newText: String?, textStyle newStyle: CPTTextStyle?) {
        let newLayer = CPTTextLayer(text: newText, style: newStyle)

        self.init(contentLayer: newLayer)
    }}
