//
//  CPTTextStylePlatformSpecific.swift
//  corePlot
//
//  Created by thierryH24 on 19/12/2020.
//

import AppKit



extension CPTTextStyle//(CPTPlatformSpecificTextStyleExtensions)
{
    
}
//
///** @property nonnull CPTDictionary *attributes
// *  @brief A dictionary of standard text attributes suitable for formatting an NSAttributedString.
// *
// *  The dictionary will contain values for the following keys that represent the receiver's text style:
// *  - #NSFontAttributeName: The font used to draw text. If missing, no font information was specified.
// *  - #NSForegroundColorAttributeName: The color used to draw text. If missing, no color information was specified.
// *  - #NSParagraphStyleAttributeName: The text alignment and line break mode used to draw multi-line text.
// **/
//@dynamic attributes;
//


// MARK: - Init/Dealloc
//
///** @brief Creates and returns a new CPTTextStyle instance initialized from a dictionary of text attributes.
// *
// *  The text style will be initalized with values associated with the following keys:
// *  - #NSFontAttributeName: Sets the @link CPTTextStyle::fontName fontName @endlink
// *  and @link CPTTextStyle::fontSize fontSize @endlink.
// *  - #NSForegroundColorAttributeName: Sets the @link CPTTextStyle::color color @endlink.
// *  - #NSParagraphStyleAttributeName: Sets the @link CPTTextStyle::textAlignment textAlignment @endlink and @link CPTTextStyle::lineBreakMode lineBreakMode @endlink.
// *
// *  Properties associated with missing keys will be inialized to their default values.
// *
// *  @param attributes A dictionary of standard text attributes.
// *  @return A new CPTTextStyle instance.
// **/
//+(nonnull instancetype)textStyleWithAttributes:(nullable CPTDictionary *)attributes
//{
//    CPTMutableTextStyle *newStyle = [CPTMutableTextStyle textStyle];
//
//    // Font
//    NSFont *styleFont = attributes[NSFontAttributeName];
//
//    if ( styleFont ) {
//        newStyle.font     = styleFont;
//        newStyle.fontName = styleFont.fontName;
//        newStyle.fontSize = styleFont.pointSize;
//    }
//
//    // Color
//    NSColor *styleColor = attributes[NSForegroundColorAttributeName];
//
//    if ( styleColor ) {
//        // CGColor property is available in macOS 10.8 and later
//        if ( [styleColor respondsToSelector:@selector(CGColor)] ) {
//            newStyle.color = [CPTColor colorWithCGColor:styleColor.CGColor];
//        }
//        else {
//            const NSInteger numberOfComponents = styleColor.numberOfComponents;
//
//            CGFloat *components = calloc((size_t)numberOfComponents, sizeof(CGFloat));
//            [styleColor getComponents:components];
//
//            CGColorSpaceRef colorSpace = styleColor.colorSpace.CGColorSpace;
//            CGColorRef styleCGColor    = CGColorCreate(colorSpace, components);
//
//            newStyle.color = [CPTColor colorWithCGColor:styleCGColor];
//
//            CGColorRelease(styleCGColor);
//            free(components);
//        }
//    }
//
//    // Text alignment and line break mode
//    NSParagraphStyle *paragraphStyle = attributes[NSParagraphStyleAttributeName];
//
//    if ( paragraphStyle ) {
//        newStyle.textAlignment = (CPTTextAlignment)paragraphStyle.alignment;
//        newStyle.lineBreakMode = paragraphStyle.lineBreakMode;
//    }
//
//    return [newStyle copy];
//}
//
//#pragma mark -
//#pragma mark Accessors
//
///// @cond
//
//-(nonnull CPTDictionary *)attributes
//{
//    CPTMutableDictionary *myAttributes = [NSMutableDictionary dictionary];
//
//    // Font
//    NSFont *styleFont  = self.font;
//    NSString *fontName = self.fontName;
//
//    if ((styleFont == nil) && fontName ) {
//        styleFont = [NSFont fontWithName:fontName size:self.fontSize];
//    }
//
//    if ( styleFont ) {
//        [myAttributes setValue:styleFont
//                        forKey:NSFontAttributeName];
//    }
//
//    // Color
//    NSColor *styleColor = self.color.nsColor;
//
//    if ( styleColor ) {
//        [myAttributes setValue:styleColor
//                        forKey:NSForegroundColorAttributeName];
//    }
//
//    // Text alignment and line break mode
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//
//    paragraphStyle.alignment     = (NSTextAlignment)self.textAlignment;
//    paragraphStyle.lineBreakMode = self.lineBreakMode;
//
//    [myAttributes setValue:paragraphStyle
//                    forKey:NSParagraphStyleAttributeName];
//
//    return [myAttributes copy];
//}
//
///// @endcond
//
//@end
//
//#pragma mark -
//
//@implementation CPTMutableTextStyle(CPTPlatformSpecificMutableTextStyleExtensions)
//
///** @brief Creates and returns a new CPTMutableTextStyle instance initialized from a dictionary of text attributes.
// *
// *  The text style will be initalized with values associated with the following keys:
// *  - #NSFontAttributeName: Sets the @link CPTMutableTextStyle::fontName fontName @endlink
// *  and @link CPTMutableTextStyle::fontSize fontSize @endlink.
// *  - #NSForegroundColorAttributeName: Sets the @link CPTMutableTextStyle::color color @endlink.
// *  - #NSParagraphStyleAttributeName: Sets the @link CPTMutableTextStyle::textAlignment textAlignment @endlink and @link CPTMutableTextStyle::lineBreakMode lineBreakMode @endlink.
// *
// *  Properties associated with missing keys will be inialized to their default values.
// *
// *  @param attributes A dictionary of standard text attributes.
// *  @return A new CPTMutableTextStyle instance.
// **/
//+(nonnull instancetype)textStyleWithAttributes:(nullable CPTDictionary *)attributes
//{
//    CPTMutableTextStyle *newStyle = [CPTMutableTextStyle textStyle];
//
//    // Font
//    NSFont *styleFont = attributes[NSFontAttributeName];
//
//    if ( styleFont ) {
//        newStyle.font     = styleFont;
//        newStyle.fontName = styleFont.fontName;
//        newStyle.fontSize = styleFont.pointSize;
//    }
//
//    // Color
//    NSColor *styleColor = attributes[NSForegroundColorAttributeName];
//
//    if ( styleColor ) {
//        // CGColor property is available in macOS 10.8 and later
//        if ( [styleColor respondsToSelector:@selector(CGColor)] ) {
//            newStyle.color = [CPTColor colorWithCGColor:styleColor.CGColor];
//        }
//        else {
//            const NSInteger numberOfComponents = styleColor.numberOfComponents;
//
//            CGFloat *components = calloc((size_t)numberOfComponents, sizeof(CGFloat));
//            [styleColor getComponents:components];
//
//            CGColorSpaceRef colorSpace = styleColor.colorSpace.CGColorSpace;
//            CGColorRef styleCGColor    = CGColorCreate(colorSpace, components);
//
//            newStyle.color = [CPTColor colorWithCGColor:styleCGColor];
//
//            CGColorRelease(styleCGColor);
//            free(components);
//        }
//    }
//
//    // Text alignment and line break mode
//    NSParagraphStyle *paragraphStyle = attributes[NSParagraphStyleAttributeName];
//
//    if ( paragraphStyle ) {
//        newStyle.textAlignment = (CPTTextAlignment)paragraphStyle.alignment;
//        newStyle.lineBreakMode = paragraphStyle.lineBreakMode;
//    }
//
//    return newStyle;
//}
//
//@end
extension String {

    // MARK: -  Layout
    func sizeWithTextStyle(style: CPTTextStyle )->CGSize
    {
        var rect = CGRect()
        
        
//        if ( [self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)] ) {
        rect = self.boundingRect(with: CGSize(width: 10000.0, height: 10000.0),
                    options: [.usesLineFragmentOrigin , .usesFontLeading , .truncatesLastVisibleLine],
                    attributes:style.attributes,
                    context:nil)
        
        var textSize = rect.size
        
        textSize.width  = ceil(textSize.width);
        textSize.height = ceil(textSize.height);
        
        return textSize;
    }
    
    // MARK: -  Drawing
    func drawInRect(rect: CGRect, style: CPTTextStyle, context: CGContext)
    {
        let  textColor = style.color.cgColor;
        
        context.setStrokeColor(textColor);
        context.setFillColor(textColor);
        
        NSUIGraphicsPushContext(context);
        
        var theFont    = style.font;
        let fontName = style.fontName;
        
        theFont = NSFont (name:fontName, size: style.fontSize)!

        let foregroundColor                = style.color
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = style.lineBreakMode;
        
        
        let attributes: [NSAttributedString.Key : Any] = [
            .font:theFont,
            .foregroundColor: foregroundColor,
            .paragraphStyle: paragraphStyle   ]
        
        self.draw(with: rect,
                  options: [.usesLineFragmentOrigin , .usesFontLeading , .truncatesLastVisibleLine],
                  attributes:attributes)

        NSUIGraphicsPopContext();
    }


}
