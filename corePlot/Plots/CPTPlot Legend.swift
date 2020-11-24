//
//  CPTPlot Legend.swift
//  corePlot
//
//  Created by thierryH24 on 24/11/2020.
//

import Foundation


extension CPTPlot {


//#pragma mark -
//#pragma mark Legends
//
///** @brief The number of legend entries provided by this plot.
// *  @return The number of legend entries.
// **/
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

///** @brief The styled title text of a legend entry.
// *  @param idx The index of the desired title.
// *  @return The styled title of the legend entry at the requested index.
// **/
func attributedTitleForLegendEntryAtIndex:(idx: Int )-> NSAttributedString
{
    let legendTitle = self.attributedTitle;

    if ( !legendTitle ) {
        var  myIdentifier = self.identifier

        if myIdentifier is NSAttributedString {
            legendTitle = (NSAttributedString *)myIdentifier;
        }
    }

    return legendTitle;
}

///** @brief Draws the legend swatch of a legend entry.
// *  Subclasses should call @super to draw the background fill and border.
// *  @param legend The legend being drawn.
// *  @param idx The index of the desired swatch.
// *  @param rect The bounding rectangle where the swatch should be drawn.
// *  @param context The graphics context to draw into.
// **/
//-(void)drawSwatchForLegend:(nonnull CPTLegend *)legend atIndex:(NSUInteger)idx inRect:(CGRect)rect inContext:(nonnull CGContextRef)context
//{
//    id<CPTLegendDelegate> theDelegate = (id<CPTLegendDelegate>)self.delegate;
//
//    CPTFill *theFill = nil;
//
//    if ( [theDelegate respondsToSelector:@selector(legend:fillForSwatchAtIndex:forPlot:)] ) {
//        theFill = [theDelegate legend:legend fillForSwatchAtIndex:idx forPlot:self];
//    }
//    if ( !theFill ) {
//        theFill = legend.swatchFill;
//    }
//
//    CPTLineStyle *theLineStyle = nil;
//
//    if ( [theDelegate respondsToSelector:@selector(legend:lineStyleForSwatchAtIndex:forPlot:)] ) {
//        theLineStyle = [theDelegate legend:legend lineStyleForSwatchAtIndex:idx forPlot:self];
//    }
//    if ( !theLineStyle ) {
//        theLineStyle = legend.swatchBorderLineStyle;
//    }
//
//    if ( theFill || theLineStyle ) {
//        CGFloat radius = legend.swatchCornerRadius;
//
//        if ( theFill ) {
//            CGContextBeginPath(context);
//            CPTAddRoundedRectPath(context, CPTAlignIntegralRectToUserSpace(context, rect), radius);
//            [theFill fillPathInContext:context];
//        }
//
//        if ( theLineStyle ) {
//            [theLineStyle setLineStyleInContext:context];
//            CGContextBeginPath(context);
//            CPTAddRoundedRectPath(context, CPTAlignBorderedRectToUserSpace(context, rect, theLineStyle), radius);
//            [theLineStyle strokePathInContext:context];
//        }
//    }
//}

}
