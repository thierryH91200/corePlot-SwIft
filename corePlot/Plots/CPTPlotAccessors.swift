//
//  CPTPlotDataSource.swift
//  corePlot
//
//  Created by thierryH24 on 20/11/2020.
//

import Foundation

extension CPTPlot {
    
    
    // MARK:  Accessors
    
    
//    #pragma mark -
//    #pragma mark Accessors
//
//    /// @cond
//
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
//    -(void)setTitle:(nullable NSString *)newTitle
//    {
//        if ( newTitle != title ) {
//            title = [newTitle copy];
//
//            if ( !self.inTitleUpdate ) {
//                self.inTitleUpdate   = YES;
//                self.attributedTitle = nil;
//                self.inTitleUpdate   = NO;
//
//                [[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsLayoutForPlotNotification object:self];
//            }
//        }
//    }
//
//    -(void)setAttributedTitle:(nullable NSAttributedString *)newTitle
//    {
//        if ( newTitle != attributedTitle ) {
//            attributedTitle = [newTitle copy];
//
//            if ( !self.inTitleUpdate ) {
//                self.inTitleUpdate = YES;
//                self.title         = attributedTitle.string;
//                self.inTitleUpdate = NO;
//
//                [[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsLayoutForPlotNotification object:self];
//            }
//        }
//    }
//
//    -(void)setDataSource:(nullable id<CPTPlotDataSource>)newSource
//    {
//        if ( newSource != dataSource ) {
//            dataSource = newSource;
//            [self setDataNeedsReloading];
//        }
//    }
//
//    -(void)setDataNeedsReloading:(BOOL)newDataNeedsReloading
//    {
//        if ( newDataNeedsReloading != dataNeedsReloading ) {
//            dataNeedsReloading = newDataNeedsReloading;
//            if ( dataNeedsReloading ) {
//                [self setNeedsDisplay];
//            }
//        }
//    }
//
//    -(nullable CPTPlotArea *)plotArea
//    {
//        CPTGraph *theGraph = self.graph;
//
//        return theGraph.plotAreaFrame.plotArea;
//    }
//
//    -(void)setNeedsRelabel:(BOOL)newNeedsRelabel
//    {
//        if ( newNeedsRelabel != needsRelabel ) {
//            needsRelabel = newNeedsRelabel;
//            if ( needsRelabel ) {
//                [self setNeedsLayout];
//            }
//        }
//    }
//
//    -(void)setShowLabels:(BOOL)newShowLabels
//    {
//        if ( newShowLabels != showLabels ) {
//            showLabels = newShowLabels;
//            if ( showLabels ) {
//                [self setNeedsLayout];
//            }
//            [self setNeedsRelabel];
//        }
//    }
//
//    -(void)setLabelTextStyle:(nullable CPTTextStyle *)newStyle
//    {
//        if ( newStyle != labelTextStyle ) {
//            labelTextStyle = [newStyle copy];
//
//            if ( labelTextStyle && !self.labelFormatter ) {
//                NSNumberFormatter *newFormatter = [[NSNumberFormatter alloc] init];
//                newFormatter.minimumIntegerDigits  = 1;
//                newFormatter.maximumFractionDigits = 1;
//                newFormatter.minimumFractionDigits = 1;
//                self.labelFormatter                = newFormatter;
//            }
//
//            self.needsRelabel = YES;
//        }
//    }
//
//    -(void)setLabelOffset:(CGFloat)newOffset
//    {
//        if ( newOffset != labelOffset ) {
//            labelOffset = newOffset;
//            [self repositionAllLabelAnnotations];
//        }
//    }
//
//    -(void)setLabelRotation:(CGFloat)newRotation
//    {
//        if ( newRotation != labelRotation ) {
//            labelRotation = newRotation;
//
//            Class annotationClass = [CPTAnnotation class];
//            for ( CPTPlotSpaceAnnotation *label in self.labelAnnotations ) {
//                if ( [label isKindOfClass:annotationClass] ) {
//                    label.rotation = labelRotation;
//                    [self updateContentAnchorForLabel:label];
//                }
//            }
//        }
//    }
//
//    -(void)setLabelFormatter:(nullable NSFormatter *)newTickLabelFormatter
//    {
//        if ( newTickLabelFormatter != labelFormatter ) {
//            labelFormatter    = newTickLabelFormatter;
//            self.needsRelabel = YES;
//        }
//    }
//
//    -(void)setLabelShadow:(nullable CPTShadow *)newLabelShadow
//    {
//        if ( newLabelShadow != labelShadow ) {
//            labelShadow = newLabelShadow;
//
//            Class annotationClass = [CPTAnnotation class];
//            for ( CPTAnnotation *label in self.labelAnnotations ) {
//                if ( [label isKindOfClass:annotationClass] ) {
//                    label.contentLayer.shadow = labelShadow;
//                }
//            }
//        }
//    }
//
//    -(void)setCachePrecision:(CPTPlotCachePrecision)newPrecision
//    {
//        if ( newPrecision != cachePrecision ) {
//            cachePrecision = newPrecision;
//            switch ( cachePrecision ) {
//                case CPTPlotCachePrecisionAuto:
//                    // don't change data already in the cache
//                    break;
//
//                case CPTPlotCachePrecisionDouble:
//                    [self setCachedDataType:self.doubleDataType];
//                    break;
//
//                case CPTPlotCachePrecisionDecimal:
//                    [self setCachedDataType:self.decimalDataType];
//                    break;
//            }
//        }
//    }
//
//    -(void)setAlignsPointsToPixels:(BOOL)newAlignsPointsToPixels
//    {
//        if ( newAlignsPointsToPixels != alignsPointsToPixels ) {
//            alignsPointsToPixels = newAlignsPointsToPixels;
//            [self setNeedsDisplay];
//        }
//    }
//
//    -(void)setHidden:(BOOL)newHidden
//    {
//        if ( newHidden != self.hidden ) {
//            super.hidden = newHidden;
//            [self setNeedsRelabel];
//        }
//    }
//
//    /// @endcond
}
