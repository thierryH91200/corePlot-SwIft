//
//  CPTTextStyle.swift
//  corePlot
//
//  Created by thierryH24 on 09/11/2020.
//

//==============================
//  OK
//==============================


import AppKit

class CPTTextStyle: NSObject {
    
    var font = NSFont()
    var fontName = ""
    var fontSize = CGFloat(0)
    var color = NSColor.black
    var textAlignment =  NSTextAlignment.left
    var lineBreakMode = NSLineBreakMode.byWordWrapping
    
    
    init( textStyle: CPTTextStyle)  {
        
        super.init()
        let newTextStyle = CPTTextStyle()

        newTextStyle.font = textStyle.font
        newTextStyle.color = textStyle.color
        newTextStyle.fontName = textStyle.fontName
        newTextStyle.fontSize = textStyle.fontSize
        newTextStyle.textAlignment = textStyle.textAlignment
        newTextStyle.lineBreakMode = textStyle.lineBreakMode
    }
    
    override init ()
    {
        super.init()
        font          = NSFont();
        fontName      = "Helvetica"
        fontSize      = CGFloat(12.0);
        color         = NSColor.black
        textAlignment = NSTextAlignment.left
        lineBreakMode = NSLineBreakMode.byWordWrapping
    }
    
    // MARK: - Accessors
    func attributes()-> [NSAttributedString.Key: Any]
    {
        var myAttributes = [NSAttributedString.Key: Any]()

        // Text alignment and line break mode
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byClipping
        paragraphStyle.alignment = .left
        
        paragraphStyle.alignment     = self.textAlignment;
        paragraphStyle.lineBreakMode = self.lineBreakMode;
        
        
        myAttributes = [.font: NSFont( name:fontName, size:self.fontSize)!,
                        .foregroundColor : color,
                        .backgroundColor : NSColor.black,
                        .paragraphStyle  : paragraphStyle]
        return myAttributes
    }
}
