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
    
    // MARK: Drawing
    override func fillRect(rect: CGRect, context: CGContext)
    {
        context.saveGState();

        let bounds = context.boundingBoxOfPath;
        context.clip();
        self.fillImage.drawInRect(rect: bounds, inContext:context)
        context.restoreGState();
    }

    override func fillPathInContext(context: CGContext)
    {
        context.saveGState();
        let bounds = context.boundingBoxOfPath
        context.clip()
        self.fillImage.drawInRect(rect: bounds, inContext:context)
        context.restoreGState();
    }

    // MARK: Opacity
    override var isOpaque : Bool {
        get { return self.fillImage.isOpaque }
        set { }
    }
}
