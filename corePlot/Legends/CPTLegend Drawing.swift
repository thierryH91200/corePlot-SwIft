//
//  CPTLegend Drawing.swift
//  corePlot
//
//  Created by thierryH24 on 09/12/2020.
//

import Foundation


extension CPTLegend {

    override func renderAsVectorInContext(context: CGContext)
    {
        guard self.isHidden == false else { return }

        super.renderAsVectorInContext(context: context)

//        if ( self.legendEntries.count == 0 ) {
//            return;
//        }

//        BOOL isHorizontalLayout;
//
//        switch ( self.swatchLayout ) {
//            case CPTLegendSwatchLayoutLeft:
//            case CPTLegendSwatchLayoutRight:
//                isHorizontalLayout = YES;
//                break;
//
//            case CPTLegendSwatchLayoutTop:
//            case CPTLegendSwatchLayoutBottom:
//                isHorizontalLayout = NO;
//                break;
//        }
//
//        // calculate column positions
//        CPTNumberArray *computedColumnWidths = self.columnWidthsThatFit;
//        NSUInteger columnCount               = computedColumnWidths.count;
//        CGFloat *actualColumnWidths          = calloc(columnCount, sizeof(CGFloat));
//        CGFloat *columnPositions             = calloc(columnCount, sizeof(CGFloat));
//
//        columnPositions[0] = self.paddingLeft;
//        CGFloat theOffset       = self.titleOffset;
//        CGSize theSwatchSize    = self.swatchSize;
//        CGFloat theColumnMargin = self.columnMargin;
//
//        CGFloat padLeft   = self.entryPaddingLeft;
//        CGFloat padTop    = self.entryPaddingTop;
//        CGFloat padRight  = self.entryPaddingRight;
//        CGFloat padBottom = self.entryPaddingBottom;
//
//        for ( NSUInteger col = 0; col < columnCount; col++ ) {
//            NSNumber *colWidth = computedColumnWidths[col];
//            CGFloat width      = [colWidth cgFloatValue];
//            actualColumnWidths[col] = width;
//            if ( col < columnCount - 1 ) {
//                columnPositions[col + 1] = columnPositions[col] + padLeft + width + padRight + (isHorizontalLayout ? theOffset + theSwatchSize.width : CPTFloat(0.0)) + theColumnMargin;
//            }
//        }
//
//        // calculate row positions
//        CPTNumberArray *computedRowHeights = self.rowHeightsThatFit;
//        NSUInteger rowCount                = computedRowHeights.count;
//        CGFloat *actualRowHeights          = calloc(rowCount, sizeof(CGFloat));
//        CGFloat *rowPositions              = calloc(rowCount, sizeof(CGFloat));
//
//        rowPositions[rowCount - 1] = self.paddingBottom;
//        CGFloat theRowMargin  = self.rowMargin;
//        CGFloat lastRowHeight = 0.0;
//
//        for ( NSUInteger rw = 0; rw < rowCount; rw++ ) {
//            NSUInteger row      = rowCount - rw - 1;
//            NSNumber *rowHeight = computedRowHeights[row];
//            CGFloat height      = [rowHeight cgFloatValue];
//            actualRowHeights[row] = height;
//            if ( row < rowCount - 1 ) {
//                rowPositions[row] = rowPositions[row + 1] + padBottom + lastRowHeight + padTop + (isHorizontalLayout ? CPTFloat(0.0) : theOffset + theSwatchSize.height) + theRowMargin;
//            }
//            lastRowHeight = height;
//        }
//
//        // draw legend entries
//        NSUInteger desiredRowCount    = self.numberOfRows;
//        NSUInteger desiredColumnCount = self.numberOfColumns;
//
//        CPTFill *theEntryFill           = self.entryFill;
//        CPTLineStyle *theEntryLineStyle = self.entryBorderLineStyle;
//        CGFloat entryRadius             = self.entryCornerRadius;
//
//        id<CPTLegendDelegate> theDelegate = (id<CPTLegendDelegate>)self.delegate;
//        BOOL delegateCanDraw              = [theDelegate respondsToSelector:@selector(legend:shouldDrawSwatchAtIndex:forPlot:inRect:inContext:)];
//        BOOL delegateProvidesFills        = [theDelegate respondsToSelector:@selector(legend:fillForEntryAtIndex:forPlot:)];
//        BOOL delegateProvidesLines        = [theDelegate respondsToSelector:@selector(legend:lineStyleForEntryAtIndex:forPlot:)];
//
//        for ( CPTLegendEntry *legendEntry in self.legendEntries ) {
//            NSUInteger row = legendEntry.row;
//            NSUInteger col = legendEntry.column;
//
//            if (((desiredRowCount == 0) || (row < desiredRowCount)) &&
//                ((desiredColumnCount == 0) || (col < desiredColumnCount))) {
//                NSUInteger entryIndex = legendEntry.index;
//                CPTPlot *entryPlot    = legendEntry.plot;
//
//                CGFloat left        = columnPositions[col];
//                CGFloat rowPosition = rowPositions[row];
//
//                CGRect entryRect;
//
//                if ( isHorizontalLayout ) {
//                    entryRect = CPTRectMake(left,
//                                            rowPosition,
//                                            padLeft + theSwatchSize.width + theOffset + actualColumnWidths[col] + CPTFloat(1.0) + padRight,
//                                            padBottom + actualRowHeights[row] + padTop);
//                }
//                else {
//                    entryRect = CPTRectMake(left,
//                                            rowPosition,
//                                            padLeft + MAX(theSwatchSize.width, actualColumnWidths[col]) + CPTFloat(1.0) + padRight,
//                                            padBottom + theSwatchSize.height + theOffset + actualRowHeights[row] + padTop);
//                }
//
//                // draw background
//                CPTFill *theFill = nil;
//                if ( delegateProvidesFills ) {
//                    theFill = [theDelegate legend:self fillForEntryAtIndex:entryIndex forPlot:entryPlot];
//                }
//                if ( !theFill ) {
//                    theFill = theEntryFill;
//                }
//                if ( theFill ) {
//                    CGContextBeginPath(context);
//                    CPTAddRoundedRectPath(context, CPTAlignIntegralRectToUserSpace(context, entryRect), entryRadius);
//                    [theFill fillPathInContext:context];
//                }
//
//                CPTLineStyle *theLineStyle = nil;
//                if ( delegateProvidesLines ) {
//                    theLineStyle = [theDelegate legend:self lineStyleForEntryAtIndex:entryIndex forPlot:entryPlot];
//                }
//                if ( !theLineStyle ) {
//                    theLineStyle = theEntryLineStyle;
//                }
//                if ( theLineStyle ) {
//                    [theLineStyle setLineStyleInContext:context];
//                    CGContextBeginPath(context);
//                    CPTAddRoundedRectPath(context, CPTAlignBorderedRectToUserSpace(context, entryRect, theLineStyle), entryRadius);
//                    [theLineStyle strokePathInContext:context];
//                }
//
//                // lay out swatch and title
//                CGFloat swatchLeft, swatchBottom;
//                CGFloat titleLeft, titleBottom;
//
//                switch ( self.swatchLayout ) {
//                    case CPTLegendSwatchLayoutLeft:
//                        swatchLeft   = CGRectGetMinX(entryRect) + padLeft;
//                        swatchBottom = CGRectGetMinY(entryRect) + (entryRect.size.height - theSwatchSize.height) * CPTFloat(0.5);
//
//                        titleLeft   = swatchLeft + theSwatchSize.width + theOffset;
//                        titleBottom = CGRectGetMinY(entryRect) + padBottom;
//                        break;
//
//                    case CPTLegendSwatchLayoutRight:
//                        swatchLeft   = CGRectGetMaxX(entryRect) - padRight - theSwatchSize.width;
//                        swatchBottom = CGRectGetMinY(entryRect) + (entryRect.size.height - theSwatchSize.height) * CPTFloat(0.5);
//
//                        titleLeft   = CGRectGetMinX(entryRect) + padLeft;
//                        titleBottom = CGRectGetMinY(entryRect) + padBottom;
//                        break;
//
//                    case CPTLegendSwatchLayoutTop:
//                        swatchLeft   = CGRectGetMidX(entryRect) - theSwatchSize.width * CPTFloat(0.5);
//                        swatchBottom = CGRectGetMaxY(entryRect) - padTop - theSwatchSize.height;
//
//                        titleLeft   = CGRectGetMidX(entryRect) - actualColumnWidths[col] * CPTFloat(0.5);
//                        titleBottom = CGRectGetMinY(entryRect) + padBottom;
//                        break;
//
//                    case CPTLegendSwatchLayoutBottom:
//                        swatchLeft   = CGRectGetMidX(entryRect) - theSwatchSize.width * CPTFloat(0.5);
//                        swatchBottom = CGRectGetMinY(entryRect) + padBottom;
//
//                        titleLeft   = CGRectGetMidX(entryRect) - actualColumnWidths[col] * CPTFloat(0.5);
//                        titleBottom = swatchBottom + theOffset + theSwatchSize.height;
//                        break;
//                }
//
//                // draw swatch
//                CGRect swatchRect = CPTRectMake(swatchLeft,
//                                                swatchBottom,
//                                                theSwatchSize.width,
//                                                theSwatchSize.height);
//
//                BOOL legendShouldDrawSwatch = YES;
//                if ( delegateCanDraw ) {
//                    legendShouldDrawSwatch = [theDelegate legend:self
//                                         shouldDrawSwatchAtIndex:entryIndex
//                                                         forPlot:entryPlot
//                                                          inRect:swatchRect
//                                                       inContext:context];
//                }
//                if ( legendShouldDrawSwatch ) {
//                    [entryPlot drawSwatchForLegend:self
//                                           atIndex:entryIndex
//                                            inRect:swatchRect
//                                         inContext:context];
//                }
//
//                // draw title
//                CGRect titleRect = CPTRectMake(titleLeft,
//                                               titleBottom,
//                                               actualColumnWidths[col] + CPTFloat(1.0),
//                                               actualRowHeights[row]);
//
//                [legendEntry drawTitleInRect:CPTAlignRectToUserSpace(context, titleRect)
//                                   inContext:context
//                                       scale:self.contentsScale];
//            }
//        }
//
//        free(actualColumnWidths);
//        free(columnPositions);
//        free(actualRowHeights);
//        free(rowPositions);
    }

}
