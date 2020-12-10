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
        
        return (thePlot?.titleForLegendEntryAtIndex(idx:self.index))!
    }
    
    func attributedTitle() -> NSAttributedString
    {
        return (self.plot?.attributedTitleForLegendEntryAtIndex(idx: self.index))!
    }
    
    
    var _titleSize =  CGSize()
    var titleSize : CGSize {
        get {
            var titleSize = CGSize()
            let styledTitle = self.attributedTitle
            
            if ( styledTitle().length > 0 ) {
                titleSize = styledTitle.sizeAsDrawn
            }
            else {
                var theTitle = styledTitle.string;
                if theTitle != "" {
                    theTitle = self.title();
                }
                
                let theTextStyle = self.textStyle
                
                if ( theTitle && theTextStyle ) {
                    theTitleSize = theTitle.sizeWithTextStyle(theTextStyle)
                }
            }
            
            titleSize.width  = ceil(titleSize.width)
            titleSize.height = ceil(titleSize.height)
            
            return titleSize;
        }
        set { }
    }

    
    func drawTitle(in rect: CGRect, in context: CGContext, scale: CGFloat) {
        
        // center the title vertically
        let textRect     = rect;
        let theTitleSize = self.titleSize;
        
        
        if theTitleSize().height < textRect.size.height {
            var offset = (textRect.size.height - theTitleSize.height) / CGFloat(2.0);
            if ( scale == CGFloat(1.0)) {
                offset = round(offset);
            }
            else {
                offset = round(offset * scale) / scale;
            }
            
            textRect = CPTRectInset(textRect, 0.0, offset);
        }
        
        
        CPTAlignRectToUserSpace(context, textRect);
        
        let styledTitle = self.attributedTitle;
        
        if ((styledTitle.length > 0) && styledTitle.respondsToSelector(#selector(drawInRect:) ) {
            styledTitle.drawInRect(rect: textRect,context:context)
        }
        else {
            let theTitle = styledTitle.string;
            
            if ( !theTitle ) {
                theTitle = self.title;
            }
            
            theTitle.drawInRect(textRect)
            withTextStyle:self.textStyle
            inContext:context];
        }
        
        
        
    }
}
