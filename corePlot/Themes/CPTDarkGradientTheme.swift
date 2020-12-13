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
        let  gradient = [CPTGradient gradientWithBeginningColor:[CPTColor colorWithGenericGray:CGFloat(0.1)] endingColor:[CPTColor colorWithGenericGray:CGFloat(0.3)]];

        gradient.angle     = CGFloat(90.0)
        plotAreaFrame.fill = CPTFill(fillWithGradient:gradient)

        let borderLineStyle = CPTMutableLineStyle(lineStyle)

        borderLineStyle.lineColor = CPTColor.colorWithGenericGray:CGFloat(0.2)];
        borderLineStyle.lineWidth = CGFloat(4.0);

        plotAreaFrame.borderLineStyle = borderLineStyle;
        plotAreaFrame.cornerRadius    = CGFloat(10.0);
    }
//
//    -(void)applyThemeToAxisSet:(nonnull CPTAxisSet *)axisSet
//    {
//        CPTMutableLineStyle *majorLineStyle = [CPTMutableLineStyle lineStyle];
//
//        majorLineStyle.lineCap   = kCGLineCapSquare;
//        majorLineStyle.lineColor = [CPTColor colorWithGenericGray:CGFloat(0.5)];
//        majorLineStyle.lineWidth = CGFloat(2.0);
//
//        CPTMutableLineStyle *minorLineStyle = [CPTMutableLineStyle lineStyle];
//
//        minorLineStyle.lineCap   = kCGLineCapSquare;
//        minorLineStyle.lineColor = [CPTColor darkGrayColor];
//        minorLineStyle.lineWidth = CGFloat(1.0);
//
//        CPTMutableTextStyle *whiteTextStyle = [[CPTMutableTextStyle alloc] init];
//
//        whiteTextStyle.color    = [CPTColor whiteColor];
//        whiteTextStyle.fontSize = CGFloat(14.0);
//
//        CPTMutableTextStyle *whiteMinorTickTextStyle = [[CPTMutableTextStyle alloc] init];
//
//        whiteMinorTickTextStyle.color    = [CPTColor whiteColor];
//        whiteMinorTickTextStyle.fontSize = CGFloat(12.0);
//
//        for ( CPTXYAxis *axis in axisSet.axes ) {
//            axis.labelingPolicy          = CPTAxisLabelingPolicyFixedInterval;
//            axis.majorIntervalLength     = @0.5;
//            axis.orthogonalPosition      = @0.0;
//            axis.tickDirection           = CPTSignNone;
//            axis.minorTicksPerInterval   = 4;
//            axis.majorTickLineStyle      = majorLineStyle;
//            axis.minorTickLineStyle      = minorLineStyle;
//            axis.axisLineStyle           = majorLineStyle;
//            axis.majorTickLength         = CGFloat(7.0);
//            axis.minorTickLength         = CGFloat(5.0);
//            axis.labelTextStyle          = whiteTextStyle;
//            axis.minorTickLabelTextStyle = whiteMinorTickTextStyle;
//            axis.titleTextStyle          = whiteTextStyle;
//        }
//    }
//


}
