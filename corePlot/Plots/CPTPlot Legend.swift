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
                legendTitle = myIdentifier as? String
            }
        }
        return legendTitle!;
    }
    
    func attributedTitleForLegendEntryAtIndex(idx: Int )-> NSAttributedString
    {
        var legendAttributedTitle = self.attributedTitle
        
        if ( legendAttributedTitle == nil ) {
            let  myIdentifier = self.identifier
            
            if myIdentifier is NSAttributedString {
                legendAttributedTitle = myIdentifier as? NSAttributedString
            }
        }
        return legendAttributedTitle!
    }

///** @brief Draws the legend swatch of a legend entry.
// *  Subclasses should call @super to draw the background fill and border.
// *  @param legend The legend being drawn.
// *  @param idx The index of the desired swatch.
// *  @param rect The bounding rectangle where the swatch should be drawn.
// *  @param context The graphics context to draw into.
// **/
    func drawSwatchForLegend(legend: CPTLegend, atIndex idx:Int , inRect rect: CGRect, context: CGContext)
    {
        weak var theDelegate = self.delegate as? CPTLegendDelegate
        
        var theFill : CPTFill?
//        let defaultHandler = {}
        
        if let method = theDelegate?.legend?( legend: legend, fillForSwatchAtIndex: idx, forPlot: self) {
            theFill =   method
        }
        
        if ( theFill == nil ) {
            theFill = legend.swatchFill
        }
        
        var theLineStyle : CPTLineStyle?
        
        if let method =  theDelegate?.legend?(legend: legend , lineStyleForSwatchAtIndex: idx, forPlot: self)  {
            theLineStyle = method
        }
        if ( (theLineStyle == nil) ) {
            theLineStyle = legend.swatchBorderLineStyle
        }
        
        if ( (theFill != nil) || (theLineStyle != nil) ) {
            let radius = legend.swatchCornerRadius
            
            if (( theFill ) != nil) {
                context.beginPath();
                CPTPathExtensions.shared.CPTAddRoundedRectPath(
                    context: context,
                    rect: CPTUtilities.shared.CPTAlignIntegralRectToUserSpace(context: context, rect: rect),
                    cornerRadius: radius);
                theFill?.fillPathInContext(context: context)
            }
            
            if ( theLineStyle != nil) {
                theLineStyle?.setLineStyleInContext(context: context)
                context.beginPath()
                CPTPathExtensions.shared.CPTAddRoundedRectPath(context: context, rect: CPTUtilities.shared.CPTAlignBorderedRectToUserSpace(context: context, rect: rect, borderLineStyle: theLineStyle!), cornerRadius: radius);
                theLineStyle?.strokePathInContext(context: context)
            }
        }
    }
}
