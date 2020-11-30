//
//  CPTPlot Legend.swift
//  corePlot
//
//  Created by thierryH24 on 24/11/2020.
//

import Foundation


extension CPTPlot {
    
    
    // MARK: Legends
    func numberOfLegendEntries()->Int
    {
        return 1
    }
    
    ///** @brief The title text of a legend entry.
    // *  @param idx The index of the desired title.
    // *  @return The title of the legend entry at the requested index.
    // **/
    func titleForLegendEntryAtIndex(idx: Int) ->String
    {
        var legendTitle = self.title
        
        if ( legendTitle != "" ) {
            let  myIdentifier = self.identifier;
            
            if myIdentifier is String {
                legendTitle = myIdentifier;
            }
        }
        return legendTitle!;
    }
    
    func attributedTitleForLegendEntryAtIndex(idx: Int )-> NSAttributedString
    {
        let legendTitle = self.attributedTitle;
        
        if ( (legendTitle == nil) ) {
            var  myIdentifier = self.identifier
            
            if myIdentifier is NSAttributedString {
                legendTitle = myIdentifier;
            }
        }
        
        return legendTitle!
    }

///** @brief Draws the legend swatch of a legend entry.
// *  Subclasses should call @super to draw the background fill and border.
// *  @param legend The legend being drawn.
// *  @param idx The index of the desired swatch.
// *  @param rect The bounding rectangle where the swatch should be drawn.
// *  @param context The graphics context to draw into.
// **/
    func drawSwatchForLegend(legend: CPTLegend, atIndex:Int , inRect:CGRect, context: CGContext)
{
    let theDelegate = self.delegate;

     var theFill : CPTFill?;

        if ( theDelegate.respondsToSelector(to: :#selector(legend:fillForSwatchAtIndex:forPlot:)] ) {
            theFill = theDelegate.legend:legend.fillForSwatchAtIndex(:idx forPlot:self)
    }
        if ( (theFill == nil) ) {
        theFill = legend.swatchFill;
    }

        var theLineStyle : CPTLineStyle?

        if ( [theDelegate respondsToSelector( to:#selector(legend:lineStyleForSwatchAtIndex:forPlot:)] ) {
        theLineStyle = theDelegate.legend(legend:legend ,lineStyleForSwatchAtIndex(idx, forPlot:self)
    }
    if ( !theLineStyle ) {
        theLineStyle = legend.swatchBorderLineStyle
    }

    if ( theFill || theLineStyle ) {
        let radius = legend.swatchCornerRadius;

        if ( theFill ) {
            CGContextBeginPath(context);
            CPTAddRoundedRectPath(context, CPTAlignIntegralRectToUserSpace(context, rect), radius);
            theFill.fillPathInContext(context)
        }

        if ( theLineStyle ) {
            theLineStyle.setLineStyleInContext(context)
            CGContextBeginPath(context)
            CPTAddRoundedRectPath(context, CPTAlignBorderedRectToUserSpace(context, rect, theLineStyle), radius);
            theLineStyle.strokePathInContext(context)
        }
    }
}

}
