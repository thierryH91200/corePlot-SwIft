//
//  CPTMutableLineStyle.swift
//  corePlot
//
//  Created by thierryH24 on 12/11/2020.
//

import Cocoa

class CPTMutableLineStyle: CPTLineStyle {

    
    var  lineCap =  CGLineCap.butt
    var  lineJoin : CGLineJoin?
    var limiterLimit: CGFloat = 0.0
    var lineWidth: CGFloat = 0.0
    var dashPattern: CPTNumberArray = []
    var patternPhase: CGFloat = 0.0
    var lineColor: CPTColor
    var lineFill: CPTFill?
    var lineGradient: CPTGradient?
    


}
