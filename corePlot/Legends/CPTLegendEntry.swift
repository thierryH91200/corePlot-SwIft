//
//  CPTLegendEntry.swift
//  corePlot
//
//  Created by thierryH24 on 13/11/2020.
//
//==============================
//  OK
//==============================


import AppKit

class CPTLegendEntry: NSObject {
    
    var plot : CPTPlot?
    var index = 0
    var textStyle: CPTTextStyle?
    var row = 0
    var column = 0
    
    // MARK: Init/Dealloc
    override init()
    {
        super.init()
        plot      = nil;
        index     = 0;
        row       = 0;
        column    = 0;
        textStyle = nil;
    }
    
    // MARK: Accessors
    var title: String {
        get { return (self.plot?.titleForLegendEntryAtIndex(idx:self.index))! }
        set {}
    }
    
    var  attributedTitle : NSAttributedString {
        get { return (self.plot?.attributedTitleForLegendEntryAtIndex(idx: self.index))! }
        set {}
    }
    
    
    var _titleSize =  CGSize()
    var titleSize : CGSize {
        get {
//            let titleSize = CGSize()
            let styledTitle = self.attributedTitle
            
            if ( styledTitle.length > 0 ) {
                _titleSize = styledTitle.sizeAsDrawn()
            }
            else {
                var theTitle = styledTitle.string;
                if theTitle != "" {
                    theTitle = self.title;
                }
                
                let theTextStyle = self.textStyle
                
                if ( theTitle != "" && _titleSize.equalTo(CGSize()) ) {
                    _titleSize = theTitle.sizeWithTextStyle(style: theTextStyle!)
                }
            }
            
            _titleSize.width  = ceil(_titleSize.width)
            _titleSize.height = ceil(_titleSize.height)
            
            return _titleSize;
        }
        set { }
    }
    
    // MARK: - Drawing
    func drawTitle(in rect: CGRect, in context: CGContext, scale: CGFloat) {
        
        // center the title vertically
        var textRect     = rect;
        let theTitleSize = self.titleSize;
        
        
        if theTitleSize.height < textRect.size.height {
            var offset = (textRect.size.height - theTitleSize.height) / CGFloat(2.0)
            if  scale == CGFloat(1.0) {
                offset = round(offset);
            }
            else {
                offset = round(offset * scale) / scale;
            }
            textRect = textRect.insetBy(dx: 0.0, dy: offset);
        }
        
        _ = CPTUtilities.shared.CPTAlignRectToUserSpace(context: context, rect: textRect)
        let styledTitle = self.attributedTitle
        
        if (styledTitle.length > 0)  {
            if let method = styledTitle.drawInRect(rect: textRect, context:context) {
                method
            }
            else {
                var theTitle = styledTitle.string;
                
                if  theTitle == ""  {
                    theTitle = self.title
                }
                theTitle.drawInRect(rect: textRect, style: self.textStyle!, context: context)
            }
        }
    }
}

