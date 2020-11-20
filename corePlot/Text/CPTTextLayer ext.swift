//
//  CPTTextLayer ext.swift
//  corePlot
//
//  Created by thierryH24 on 16/11/2020.
//

import Cocoa

extension CPTTextLayer {

    
    #pragma mark Accessors

    /// @cond

    -(void)setText:(nullable NSString *)newValue
    {
        if ( text != newValue ) {
            text = [newValue copy];

            if ( !self.inTextUpdate ) {
                self.inTextUpdate   = YES;
                self.attributedText = nil;
                self.inTextUpdate   = NO;

                [self sizeToFit];
            }
        }
    }

    -(void)setTextStyle:(nullable CPTTextStyle *)newStyle
    {
        if ( textStyle != newStyle ) {
            textStyle = newStyle;

            if ( !self.inTextUpdate ) {
                self.inTextUpdate   = YES;
                self.attributedText = nil;
                self.inTextUpdate   = NO;

                [self sizeToFit];
            }
        }
    }

    -(void)setAttributedText:(nullable NSAttributedString *)newValue
    {
        if ( attributedText != newValue ) {
            attributedText = [newValue copy];

            if ( !self.inTextUpdate ) {
                self.inTextUpdate = YES;

                if ( newValue.length > 0 ) {
                    self.textStyle = [CPTTextStyle textStyleWithAttributes:[newValue attributesAtIndex:0
                                                                                        effectiveRange:NULL]];
                    self.text = newValue.string;
                }
                else {
                    self.textStyle = nil;
                    self.text      = nil;
                }

                self.inTextUpdate = NO;
                [self sizeToFit];
            }
        }
    }

    -(void)setMaximumSize:(CGSize)newSize
    {
        if ( !CGSizeEqualToSize(maximumSize, newSize)) {
            maximumSize = newSize;
            [self sizeToFit];
        }
    }

    -(void)setShadow:(nullable CPTShadow *)newShadow
    {
        if ( newShadow != self.shadow ) {
            super.shadow = newShadow;
            [self sizeToFit];
        }
    }

    -(void)setPaddingLeft:(CGFloat)newPadding
    {
        if ( newPadding != self.paddingLeft ) {
            super.paddingLeft = newPadding;
            [self sizeToFit];
        }
    }

    -(void)setPaddingRight:(CGFloat)newPadding
    {
        if ( newPadding != self.paddingRight ) {
            super.paddingRight = newPadding;
            [self sizeToFit];
        }
    }

    -(void)setPaddingTop:(CGFloat)newPadding
    {
        if ( newPadding != self.paddingTop ) {
            super.paddingTop = newPadding;
            [self sizeToFit];
        }
    }

    -(void)setPaddingBottom:(CGFloat)newPadding
    {
        if ( newPadding != self.paddingBottom ) {
            super.paddingBottom = newPadding;
            [self sizeToFit];
        }
    }

}
