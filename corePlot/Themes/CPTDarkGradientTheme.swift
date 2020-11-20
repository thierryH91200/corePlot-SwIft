//
//  CPTDarkGradientTheme.swift
//  corePlot
//
//  Created by thierryH24 on 11/11/2020.
//

import Cocoa

class CPTDarkGradientTheme: CPTXYTheme {
    let kCPTDarkGradientTheme = "Dark Gradients"

    
    func name() -> String {
        return kCPTDarkGradientTheme
    }
    
    func applyTheme( graph: CGFloat) {
        
        let endColor = NSUIColor(genericGray: CGFloat(0.1))
        var graphGradient = CPTGradient(beginningColor: endColor, ending: endColor)

        graphGradient = graphGradient.addColorStop(NSUIColor(genericGray: CGFloat(0.2)), atPosition: CGFloat(0.3))
        graphGradient = graphGradient.addColorStop(NSUIColor(genericGray: CGFloat(0.3)), atPosition: CGFloat(0.5))
        graphGradient = graphGradient.addColorStop(NSUIColor(genericGray: CGFloat(0.2)), atPosition: CGFloat(0.6))
        graphGradient.angle = CGFloat(90.0)
        graph.fill = CPTFill(gradient: graphGradient)
    }

}
