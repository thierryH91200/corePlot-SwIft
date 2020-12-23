//
//  CPTTextLayer ext.swift
//  corePlot
//
//  Created by thierryH24 on 16/11/2020.
//

import Appkit

extension CPTTextLayer {




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
