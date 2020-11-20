//
//  CPTXYPlotSpace.swift
//  corePlot
//
//  Created by thierryH24 on 14/11/2020.
//

import Cocoa

class CPTXYPlotSpace: CPTPlotSpace {
    
    
    var xRange: CPTPlotRange;
    var yRange: CPTPlotRange;
    var globalXRange: CPTPlotRange?
    var globalYRange: CPTPlotRange?
    var  xScaleType : CPTScaleType
    var  yScaleType : CPTScaleType
    
    var  allowsMomentum: Bool
    var  allowsMomentumX: Bool
    var  allowsMomentumY: Bool
    var momentumAnimationCurve: CPTAnimationCurve
    var bounceAnimationCurve: CPTAnimationCurve;
    var  momentumAcceleration: CGFloat
    var bounceAcceleration: CGFloat
    var minimumDisplacementToDrag: CGFloat;
    
    
    override init()
    {
        super.init()
        xRange           = [[CPTPlotRange alloc] initWithLocation:@0.0 length:@1.0];
        yRange           = [[CPTPlotRange alloc] initWithLocation:@0.0 length:@1.0];
        globalXRange     = ni;
        globalYRange     = nil
        xScaleType       = CPTScaleType.linear
        yScaleType       = CPTScaleType.linear
        lastDragPoint    = CGPointZero;
        lastDisplacement = CGPointZero;
        lastDragTime     = 0.0;
        lastDeltaTime    = 0.0;
        animations       = [[NSMutableArray alloc] init];
        
        allowsMomentumX           = false;
        allowsMomentumY           = false;
        momentumAnimationCurve    = .CUR;
        bounceAnimationCurve      = CPTAnimationCurveQuadraticOut;
        momentumAcceleration      = 2000.0;
        bounceAcceleration        = 3000.0;
        minimumDisplacementToDrag = 2.0;
    }

}
