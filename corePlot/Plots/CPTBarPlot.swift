//
//  CPTBarPlot.swift
//  corePlot
//
//  Created by thierryH24 on 11/11/2020.
//

import Cocoa

class CPTBarPlot: CPTPlot {
    
    
    // MARK: Appearance
    var barWidthsAreInViewCoordinates = true
    var barWidth = CGFloat(0.0)
    var barOffset : CGFloat
    var  barCornerRadius : CGFloat
    var  barBaseCornerRadius : CGFloat
    var   barsAreHorizontal : Bool
    var baseValue : CGFloat
    var barBasesVary : Bool
    var plotRange : CPTPlotRange

    // MARK: Drawing
    var  lineStyle : CPTLineStyle
    var  fill : CPTFill
//
    
    override init() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }



     func tubularBarPlot(with color: CPTColor, horizontalBars horizontal: Bool) -> Self {

        let barPlot = init()
        let barLineStyle = CPTMutableLineStyle()

        barLineStyle.lineWidth = CPTFloat(1.0)
        barLineStyle.lineColor = CPTColor.black()

        barPlot?.lineStyle = barLineStyle
        barPlot?.barsAreHorizontal = horizontal
        barPlot?.barWidth = NSNumber(value: 0.8)
        barPlot?.barCornerRadius = CPTFloat(2.0)

        let fillGradient = CPTGradient(beginningColor: color, endingColor: CPTColor.black())

        fillGradient.angle = CPTFloat(horizontal ? -90.0 : 0.0)
        barPlot?.fill = CPTFill(gradient: fillGradient)

        barPlot?.barWidthsAreInViewCoordinates = false

        return barPlot
    }

    class func initialize() {
        if self == CPTBarPlot.self {
            self.exposeBinding(CPTBarPlotBindingBarLocations)
            self.exposeBinding(CPTBarPlotBindingBarTips)
            self.exposeBinding(CPTBarPlotBindingBarBases)
            self.exposeBinding(CPTBarPlotBindingBarFills)
            self.exposeBinding(CPTBarPlotBindingBarLineStyles)
            self.exposeBinding(CPTBarPlotBindingBarWidths)
        }
    }
}
