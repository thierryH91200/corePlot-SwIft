//
//  CPTLayer masking.swift
//  corePlot
//
//  Created by thierryH24 on 23/11/2020.
//

import Foundation


extension CPTLayer {

// MARK: Masking

/// @cond

// default path is the rounded rect layer bounds
    func maskingPath()-> CGPath?
{
    if ( self.masksToBounds ) {
        let path = self.outerBorderPath;
        if (( path ) != nil) {
            return path;
        }

        path            = CPTCreateRoundedRectPath(self.bounds, self.cornerRadius);
        self.outerBorderPath = path;

        return self.outerBorderPath;
    }
    else {
        return nil;
    }
}

    func sublayerMaskingPath() -> CGPath
    {
        return self.innerBorderPath!;
    }

/// @endcond

/** @brief Recursively sets the clipping path of the given graphics context to the sublayer masking paths of its superlayers.
 *
 *  The clipping path is built by recursively climbing the layer tree and combining the sublayer masks from
 *  each super layer. The tree traversal stops when a layer is encountered that is not a CPTLayer.
 *
 *  @param context The graphics context to clip.
 *  @param sublayer The sublayer that called this method.
 *  @param offset The cumulative position offset between the receiver and the first layer in the recursive calling chain.
 **/
//    func applySublayerMaskToContext(context: CGContext, forSublayer sublayer: CPTLayer, withOffset offset:CGPoint)
//    {
//        let  sublayerBoundsOrigin = sublayer.bounds.origin
//        var layerOffset          = offset
//        
//        if self.renderingRecursively == false {
//            let convertedOffset = self.convert(sublayerBoundsOrigin , from:sublayer)
//            layerOffset.x += convertedOffset.x;
//            layerOffset.y += convertedOffset.y;
//        }
//        
//        let sublayerTransform = CATransform3DGetAffineTransform(sublayer.transform)
//        
//        context.concatenate(sublayerTransform.inverted());
//        
//        let superlayer = self.superlayer;
//        
//        if ( superlayer is CPTLayer ) == true {
//            let superlayer.applySublayerMaskToContext:context forSublayer:self withOffset:layerOffset];
//        }
//        
//        let maskPath = self.sublayerMaskingPath;
//        
//        if ( maskPath ) {
//            context.translateBy(x: -layerOffset.x, y: -layerOffset.y);
//            context.addPath(maskPath());
//            context.clip();
//            context.translateBy(x: layerOffset.x, y: layerOffset.y);
//        }
//
//        context.concatenate(sublayerTransform);
//    }

/** @brief Sets the clipping path of the given graphics context to mask the content.
 *
 *  The clipping path is built by recursively climbing the layer tree and combining the sublayer masks from
 *  each super layer. The tree traversal stops when a layer is encountered that is not a CPTLayer.
 *
 *  @param context The graphics context to clip.
 **/
-(void)applyMaskToContext:(nonnull CGContextRef)context
{
    CPTLayer *mySuperlayer = (CPTLayer *)self.superlayer;

    if ( [mySuperlayer isKindOfClass:[CPTLayer class]] ) {
        [mySuperlayer applySublayerMaskToContext:context forSublayer:self withOffset:CGPointZero];
    }

    CGPathRef maskPath = self.maskingPath;

    if ( maskPath ) {
        CGContextAddPath(context, maskPath);
        CGContextClip(context);
    }
}

/// @cond

-(void)setNeedsLayout
{
    [super setNeedsLayout];

    CPTGraph *theGraph = self.graph;

    if ( theGraph ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CPTGraphNeedsRedrawNotification
                                                            object:theGraph];
    }
}

-(void)setNeedsDisplay
{
    [super setNeedsDisplay];

    CPTGraph *theGraph = self.graph;

    if ( theGraph ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CPTGraphNeedsRedrawNotification
                                                            object:theGraph];
    }
}


}
