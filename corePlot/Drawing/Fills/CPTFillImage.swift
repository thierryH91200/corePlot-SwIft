//
//  CPTFillImage.swift
//  corePlot
//
//  Created by thierryH24 on 09/11/2020.
//

import Cocoa

class CPTFillImage: CPTFill {
    
    
    var fillColor : NSColor
    
    // MARK: Drawing

    /** @brief Draws the color into the given graphics context inside the provided rectangle.
     *  @param rect The rectangle to draw into.
     *  @param context The graphics context to draw into.
     **/
    func fillRect(rect: CGRect, context: CGContext)
    {
        context.saveGState();
        context.setFillColor(self.fillColor.cgColor);
        context.fill(rect);
        context.restoreGState();
    }

    /** @brief Draws the color into the given graphics context clipped to the current drawing path.
     *  @param context The graphics context to draw into.
     **/
    func fillPathInContext(context: CGContext)
    {
        context.saveGState();
        context.setFillColor(self.fillColor.cgColor);
        context.fillPath();
        context.restoreGState();
    }

    // MARK: Opacity

    func isOpaque () -> Bool
    {
        return self.fillColor.opaque;
    }

    // MARK: Color

    func cgColor() -> CGColor
    {
        return self.fillColor.cgColor;
    }



}
