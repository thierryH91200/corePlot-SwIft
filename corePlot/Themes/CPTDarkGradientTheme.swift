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
    
    override func applyThemeToPlotArea(plotAreaFrame: CPTPlotAreaFrame )
    {
        let  gradient = gradientWithBeginningColor([CPTColor colorWithGenericGray:CGFloat(0.1)] endingColor:[CPTColor colorWithGenericGray:CGFloat(0.3)]];

        gradient.angle     = CGFloat(90.0)
        plotAreaFrame.fill = CPTFill(fillWithGradient:gradient)

        let borderLineStyle = CPTLineStyle()

        borderLineStyle.lineColor = CPTColor.colorWithGenericGray(CGFloat(0.2))
        borderLineStyle.lineWidth = CGFloat(4.0);

        plotAreaFrame.borderLineStyle = borderLineStyle;
        plotAreaFrame.cornerRadius    = CGFloat(10.0);
    }
//
    override func applyThemeToAxisSet(axisSet: CPTAxisSet )
    {
        let majorLineStyle = CPTLineStyle()
        
        majorLineStyle.lineCap   = CGLineCap.square
        majorLineStyle.lineColor = [CPTColor colorWithGenericGray:CGFloat(0.5)];
        majorLineStyle.lineWidth = CGFloat(2.0)
        
        let minorLineStyle = CPTLineStyle()
        
        minorLineStyle.lineCap   = CGLineCap.square;
        minorLineStyle.lineColor = NSColor.darkGray
        minorLineStyle.lineWidth = CGFloat(1.0);
        
        let whiteTextStyle = CPTTextStyle()
        
        whiteTextStyle.color    = NSColor.white
        whiteTextStyle.fontSize = CGFloat(14.0);
        
        let whiteMinorTickTextStyle = CPTTextStyle()
        
        whiteMinorTickTextStyle.color    = NSColor.white
        whiteMinorTickTextStyle.fontSize = CGFloat(12.0);
        
        for  axis in axisSet.axes {
            axis.labelingPolicy          = labelingPolicyFixedInterval;
            axis.majorIntervalLength     = 0.5
            axis.orthogonalPosition      = 0.0
            axis.tickDirection           = CPTSign.none
            axis.minorTicksPerInterval   = 4;
            axis.majorTickLineStyle      = majorLineStyle
            axis.minorTickLineStyle      = minorLineStyle
            axis.axisLineStyle           = majorLineStyle
            axis.majorTickLength         = CGFloat(7.0)
            axis.minorTickLength         = CGFloat(5.0)
            axis.labelTextStyle          = whiteTextStyle
            axis.minorTickLabelTextStyle = whiteMinorTickTextStyle;
            axis.titleTextStyle          = whiteTextStyle;
        }
    }
    
}
