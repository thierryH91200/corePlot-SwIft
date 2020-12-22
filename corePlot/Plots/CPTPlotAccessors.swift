//
//  CPTPlotDataSource.swift
//  corePlot
//
//  Created by thierryH24 on 20/11/2020.
//

import Foundation

extension CPTPlot {
    
    
    
    
    // MARK: - Accessors
    
    //    -(nullable CPTLayerArray *)dataLabels
    //    {
    //        return [self cachedArrayForKey:CPTPlotBindingDataLabels];
    //    }
    //
    //    -(void)setDataLabels:(nullable CPTLayerArray *)newDataLabels
    //    {
    //        [self cacheArray:newDataLabels forKey:CPTPlotBindingDataLabels];
    //        [self setNeedsRelabel];
    //    }
    //
    
    
    //
    func setAttributedTitle(newTitle: NSAttributedString )
    {
        if ( newTitle != attributedTitle ) {
            attributedTitle = newTitle
            
            if ( !self.inTitleUpdate == false) {
                self.inTitleUpdate = true
                self.title         = attributedTitle?.string;
                self.inTitleUpdate = false
                
                NotificationCenter.send(
                    name: .CPTLegendNeedsLayoutForPlotNotification,
                    object:self)
            }
        }
    }
    
    func setDataNeedsReloading(newDataNeedsReloading: Bool)
    {
        if ( newDataNeedsReloading != dataNeedsReloading ) {
            dataNeedsReloading = newDataNeedsReloading;
            if ( dataNeedsReloading ) {
                self.setNeedsDisplay()
            }
        }
    }
    
    func plotArea() -> CPTPlotArea?
    {
        let theGraph = self.graph
        return theGraph?.plotAreaFrame.plotArea!
    }

    func setNeedsRelabel(newNeedsRelabel: Bool)
    {
        if ( newNeedsRelabel != needsRelabel ) {
            needsRelabel = newNeedsRelabel;
            if ( needsRelabel ) {
                self.setNeedsLayout()
            }
        }
    }
    
    func setLabelTextStyle(newStyle: CPTTextStyle)
    {
        if ( newStyle != labelTextStyle ) {
            labelTextStyle = newStyle
            
            if ( labelTextStyle != nil)  {
                let newFormatter = NumberFormatter()
                newFormatter.minimumIntegerDigits  = 1
                newFormatter.maximumFractionDigits = 1
                newFormatter.minimumFractionDigits = 1
                self.labelFormatter    = newFormatter
            }
            self.needsRelabel = true
        }
    }
    
    func setLabelOffset(newOffset: CGFloat)
    {
        if ( newOffset != labelOffset ) {
            labelOffset = newOffset;
            self.repositionAllLabelAnnotations()
        }
    }
    
    func setLabel(_ newTickLabelFormatter: Formatter?) {
        if newTickLabelFormatter != labelFormatter {
            labelFormatter = newTickLabelFormatter!
            needsRelabel = true
        }
    }
    
    func setCachePrecision(_ newPrecision: CPTPlotCachePrecision) {
        if newPrecision != cachePrecision {
            cachePrecision = newPrecision
            switch newPrecision {
            case .auto:
                // don't change data already in the cache
                break
            case .double:
                setCachedDataType(doubleDataType())
            case .decimal:
                setCachedDataType(decimalDataType())
            default:
                break
            }
        }
    }
    
    func setAlignsPointsToPixels(newAlignsPointsToPixels : Bool){
        if ( newAlignsPointsToPixels != alignsPointsToPixels ) {
            alignsPointsToPixels = newAlignsPointsToPixels
            self.setNeedsDisplay()
        }
    }
    
    public override var isHidden: Bool {
        get {
            return super.isHidden
        }
        set {
            if ( newValue != self.isHidden ) {
                super.isHidden = newValue;
                if ( newValue == true ) {
                    self.setNeedsDisplay()
                }
            }
            
        }
    }
}
