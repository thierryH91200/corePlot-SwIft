//
//  CPTFillImage.swift
//  corePlot
//
//  Created by thierryH24 on 09/11/2020.
//

import AppKit

class CPTFillImage: CPTFill {
    
    var fillImage : CPTImage
    
    init(anImage: CPTImage )
    {
        super.init()
            fillImage = anImage
    }


    override init() {
    }
    
    
    // MARK: Drawing

    /** @brief Draws the color into the given graphics context inside the provided rectangle.
     *  @param rect The rectangle to draw into.
     *  @param context The graphics context to draw into.
     **/
    func fillPathInContext(rect: CGRect, context: CGContext)
    {
        context.saveGState();

        let bounds = context.boundingBoxOfPath;
        context.clip();
        self.fillImage.drawInRect(bounds, inContext:context)
        context.restoreGState();
    }

    /** @brief Draws the color into the given graphics context clipped to the current drawing path.
     *  @param context The graphics context to draw into.
     **/
    override func fillPathInContext(context: CGContext)
    {
        context.saveGState();
        let bounds = context.boundingBoxOfPath
        CGContextClip(context);
        self.fillImage.drawInRect(bounds, inContext:context)
        context.restoreGState();

//        contextsetFillColor(self.fillColor.cgColor)
//        .
//        context.fillPath();
    }

    // MARK: Opacity
    override var isOpaque : Bool {
        get { return self.fillImage.isOpaque }
        set { }
    }




}
