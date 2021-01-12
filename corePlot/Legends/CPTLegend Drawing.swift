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
        guard self.legendEntries.isEmpty == false else { return }
        
        var isHorizontalLayout = false
        
        switch ( self.swatchLayout ) {
        case .left:
            fallthrough
        case .right:
            isHorizontalLayout = true
            break;
            
        case .top:
            fallthrough
        case .bottom:
            isHorizontalLayout = false;
            break;
        }
        
        // calculate column positions
        let computedColumnWidths = self.columnWidthsThatFit;
        let columnCount               = computedColumnWidths.count;
        var actualColumnWidths          = [CGFloat]()
        var columnPositions             = [CGFloat]()
        
        columnPositions[0] = self.paddingLeft;
        let theOffset       = self.titleOffset;
        let theSwatchSize    = self.swatchSize;
        let theColumnMargin = self.columnMargin;
        
        let padLeft   = self.entryPaddingLeft;
        let padTop    = self.entryPaddingTop;
        let padRight  = self.entryPaddingRight;
        let padBottom = self.entryPaddingBottom;
        
        for  col in 0..<columnCount {
            let colWidth = computedColumnWidths[col]
            let width      = colWidth //cgFloatValue];
            actualColumnWidths[col] = width;
            if ( col < columnCount - 1 ) {
                columnPositions[col + 1] = columnPositions[col] + padLeft + width + padRight + (isHorizontalLayout ? theOffset + theSwatchSize.width : CGFloat(0.0)) + theColumnMargin;
            }
        }
        
        // calculate row positions
        let computedRowHeights = self.rowHeightsThatFit;
        let rowCount                = computedRowHeights.count;
        var actualRowHeights          = [CGFloat]()
        var rowPositions              = [CGFloat]()
        
        rowPositions[rowCount - 1] = self.paddingBottom;
        let theRowMargin  = self.rowMargin;
        var lastRowHeight = CGFloat(0.0)
        
        for rw in 0..<rowCount {
            let row      = rowCount - rw - 1;
            let rowHeight = computedRowHeights[row];
            let height      = rowHeight
            actualRowHeights[row] = height;
            if ( row < rowCount - 1 ) {
                rowPositions[row] = rowPositions[row + 1] + padBottom + lastRowHeight + padTop + (isHorizontalLayout ? CGFloat(0.0) : theOffset + theSwatchSize.height) + theRowMargin;
            }
            lastRowHeight = height;
        }
        
        // draw legend entries
        let desiredRowCount    = self.numberOfRows;
        let desiredColumnCount = self.numberOfColumns;
        
        let theEntryFill           = self.entryFill;
        let theEntryLineStyle = self.entryBorderLineStyle;
        let entryRadius             = self.entryCornerRadius;
        
        let  theDelegate = self.delegate as? CPTLegendDelegate
        
        //        let delegateCanDraw              = theDelegate.legend(self, shouldDrawSwatchAtIndex:forPlot: inRect:inContext:)
        //        let delegateProvidesFills        = theDelegate.legend(:fillForEntryAtIndex:forPlot:)
        //        let delegateProvidesLines        = theDelegate.legend(:lineStyleForEntryAtIndex:forPlot:)
        let delegateCanDraw              = true
        let delegateProvidesFills        = true
        let delegateProvidesLines        = true
        
        for legendEntry in self.legendEntries  {
            let row = legendEntry.row;
            let col = legendEntry.column;
            
            if (((desiredRowCount == 0) || (row < desiredRowCount)) &&
                    ((desiredColumnCount == 0) || (col < desiredColumnCount))) {
                let entryIndex = legendEntry.index;
                let entryPlot    = legendEntry.plot;
                
                let left        = columnPositions[col];
                let rowPosition = rowPositions[row];
                
                var entryRect = CGRect()
                
                if ( isHorizontalLayout ) {
                    entryRect = CGRect(x: left,
                                       y: rowPosition,
                                       width: padLeft + theSwatchSize.width + theOffset + actualColumnWidths[col] + CGFloat(1.0) + padRight,
                                       height: padBottom + actualRowHeights[row] + padTop)
                }
                else {
                    entryRect = CGRect(x: left,
                                       y: rowPosition,
                                       width: padLeft + max(theSwatchSize.width, actualColumnWidths[col]) + CGFloat(1.0) + padRight,
                                       height: padBottom + theSwatchSize.height + theOffset + actualRowHeights[row] + padTop);
                }
                
                // draw background
                let theFill : CPTFill?
                if ( delegateProvidesFills == true ) {
                    theFill = theDelegate?.legend!(legend:self,
                                                  fillForEntryAtIndex:entryIndex,
                                                  forPlot:entryPlot!)
                }
                if ( (theFill == nil) ) {
                    theFill = theEntryFill!;
                }
                if (( theFill ) != nil) {
                    context.beginPath();
                    
                    let rect = CPTUtilities.shared.CPTAlignIntegralRectToUserSpace(context: context, rect: entryRect)
                    CPTPathExtensions.shared.CPTAddRoundedRectPath(context: context,
                                                                   rect: rect,
                                                                   cornerRadius: entryRadius);
                    theFill?.fillPathInContext(context: context)
                }
                
                let theLineStyle : CPTLineStyle?
                if ( delegateProvidesLines == true) {
                    theLineStyle = theDelegate?.legend!(
                        legend: self,
                        lineStyleForSwatchAtIndex:entryIndex,
                        forPlot:entryPlot!)
                }
                if ( (theLineStyle == nil) ) {
                    theLineStyle = theEntryLineStyle;
                }
                if (( theLineStyle ) != nil) {
                    theLineStyle?.setLineStyleInContext(context: context)
                    context.beginPath()
                    let rect = CPTUtilities.shared.CPTAlignBorderedRectToUserSpace(context: context, rect: entryRect, borderLineStyle: theLineStyle!)
                    CPTPathExtensions.shared.CPTAddRoundedRectPath(context: context, rect: rect, cornerRadius: entryRadius);
                    theLineStyle?.strokePathInContext(context: context)
                }
                
                // lay out swatch and title
                var swatchLeft = CGFloat(0);
                var swatchBottom = CGFloat(0);
                var titleLeft = CGFloat(0)
                var titleBottom = CGFloat(0)
                
                switch ( self.swatchLayout ) {
                case .left:
                    swatchLeft   = entryRect.minX + padLeft;
                    swatchBottom = entryRect.minY + (entryRect.size.height - theSwatchSize.height) * CGFloat(0.5);
                    
                    titleLeft   = swatchLeft + theSwatchSize.width + theOffset;
                    titleBottom = entryRect.minY + padBottom;
                    
                case .right:
                    swatchLeft   = entryRect.maxX - padRight - theSwatchSize.width;
                    swatchBottom = entryRect.minY + (entryRect.size.height - theSwatchSize.height) * CGFloat(0.5);
                    
                    titleLeft   = entryRect.minX + padLeft;
                    titleBottom = entryRect.minY + padBottom;
                    
                case .top:
                    swatchLeft   = entryRect.midX - theSwatchSize.width * CGFloat(0.5);
                    swatchBottom = entryRect.maxY - padTop - theSwatchSize.height;
                    
                    titleLeft   = entryRect.midX - actualColumnWidths[col] * CGFloat(0.5);
                    titleBottom = entryRect.minY + padBottom;
                    
                case .bottom:
                    swatchLeft   = entryRect.midX - theSwatchSize.width * CGFloat(0.5);
                    swatchBottom = entryRect.minY + padBottom
                    
                    titleLeft   = entryRect.midX - actualColumnWidths[col] * CGFloat(0.5);
                    titleBottom = swatchBottom + theOffset + theSwatchSize.height
                }
                
                // draw swatch
                let swatchRect = CGRect(x: swatchLeft,
                                        y: swatchBottom,
                                        width: theSwatchSize.width,
                                        height: theSwatchSize.height)
                
                var legendShouldDrawSwatch : Bool?
                if ( delegateCanDraw == true) {
                    legendShouldDrawSwatch = theDelegate?.legend!(
                        legend: self,
                        shouldDrawSwatchAtIndex: entryIndex,
                        forPlot: entryPlot!,
                        inRect: swatchRect,
                        inContext: context)
                }
                
                if  legendShouldDrawSwatch! == true {
                    entryPlot!.drawSwatchForLegend(
                        legend   : self,
                        atIndex  : entryIndex,
                        inRect   : swatchRect,
                        context  : context)
                }
                
                // draw title
                let titleRect = CGRect(x: titleLeft,
                                       y: titleBottom,
                                       width: actualColumnWidths[col] + CGFloat(1.0),
                                       height: actualRowHeights[row]);
                
                legendEntry.drawTitle(
                    in: CPTUtilities.shared.CPTAlignRectToUserSpace( context: context, rect: titleRect),
                    in:context,
                 scale:self.contentsScale)
            }
        }
        
    }
    
}
