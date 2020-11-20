//
//  CPTMaskLayer.swift
//  corePlot
//
//  Created by thierryH24 on 19/11/2020.
//

import Cocoa

class CPTMaskLayer: CPTLayer {

    
    // MARK:  Init/Dealloc

    /** @brief Initializes a newly allocated CPTMaskLayer object with the provided frame rectangle.
     *
     *  This is the designated initializer. The initialized layer will have the following properties:
     *  - @ref needsDisplayOnBoundsChange = @YES
     *
     *  @param newFrame The frame rectangle.
     *  @return The initialized CPTMaskLayer object.
     **/
    override init(frame: CGRect)
    {
        super.init(frame: frame)
            self.needsDisplayOnBoundsChange = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -  Drawing
    override func renderAsVectorInContext(context: CGContext)
    {
        super.renderAsVectorInContext(context: context)

        let theMaskedLayer = superlayer as? CPTLayer
        
        if (( theMaskedLayer ) != nil) {
            
            context.setFillColor(red: CGFloat(0.0), green: CGFloat(0.0), blue: CGFloat(0.0), alpha: CGFloat(1.0));

            if theMaskedLayer != nil {
                let maskingPath = theMaskedLayer.sublayerMaskingPath

                if ( maskingPath ) {
                    CGContextAddPath(context, maskingPath as! CGPath);
                    context.fillPath();
                }
            }
            else {
                context.fill(self.bounds);
            }
        }
    }

}
