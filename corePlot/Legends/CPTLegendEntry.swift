//
//  CPTLegendEntry.swift
//  corePlot
//
//  Created by thierryH24 on 13/11/2020.
//

import AppKit

class CPTLegendEntry: NSObject {

    var plot : CPTPlot?
    var  index = 0
    
    var textStyle: CPTTextStyle?

    var row = 0
    var column = 0
    var titleSize =  CGSize()
    
    override init()
    {
        super.init()
            plot      = nil;
            index     = 0;
            row       = 0;
            column    = 0;
            textStyle = nil;
    }

    
    func title() -> String
    {
        let thePlot = self.plot

        return thePlot.titleForLegendEntryAtIndex(index:self)
    }
    
     func attributedTitle() -> NSAttributedString
    {
        let thePlot = self.plot;

        return [thePlot attributedTitleForLegendEntryAtIndex:self.index];
    }

    func titleSize() -> CGSize
    {
        let theTitleSize = CGSize()
        let styledTitle = self.attributedTitle

        if ( styledTitle.length > 0 ) {
            theTitleSize = styledTitle sizeAsDrawn
        }
        else {
            let theTitle = styledTitle.string;
            if ( !theTitle ) {
                theTitle = self.title;
            }

            let theTextStyle = self.textStyle

            if ( theTitle && theTextStyle ) {
                theTitleSize = [theTitle sizeWithTextStyle:theTextStyle];
            }
        }

        theTitleSize.width  = ceil(theTitleSize.width)
        theTitleSize.height = ceil(theTitleSize.height)

        return theTitleSize;
    }
    
    -(void)drawTitleInRect:(CGRect)rect inContext:(nonnull CGContextRef)context scale:(CGFloat)scale
    {
    #if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, CPTFloat(0.0), rect.origin.y);
        CGContextScaleCTM(context, CPTFloat(1.0), CPTFloat(-1.0));
        CGContextTranslateCTM(context, CPTFloat(0.0), -CGRectGetMaxY(rect));
    #endif
        // center the title vertically
        CGRect textRect     = rect;
        CGSize theTitleSize = self.titleSize;
        if ( theTitleSize.height < textRect.size.height ) {
            CGFloat offset = (textRect.size.height - theTitleSize.height) / CPTFloat(2.0);
            if ( scale == CPTFloat(1.0)) {
                offset = round(offset);
            }
            else {
                offset = round(offset * scale) / scale;
            }
            textRect = CPTRectInset(textRect, 0.0, offset);
        }
        CPTAlignRectToUserSpace(context, textRect);

        NSAttributedString *styledTitle = self.attributedTitle;

        if ((styledTitle.length > 0) && [styledTitle respondsToSelector:@selector(drawInRect:)] ) {
            [styledTitle drawInRect:textRect
                          inContext:context];
        }
        else {
            NSString *theTitle = styledTitle.string;

            if ( !theTitle ) {
                theTitle = self.title;
            }

            [theTitle drawInRect:textRect
                   withTextStyle:self.textStyle
                       inContext:context];
        }

    #if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
        CGContextRestoreGState(context);
    #endif


}
