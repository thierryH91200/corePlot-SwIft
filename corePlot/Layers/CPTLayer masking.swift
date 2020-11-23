//
//  CPTLayer masking.swift
//  corePlot
//
//  Created by thierryH24 on 23/11/2020.
//

import Foundation


extension CPTLayer {

#pragma mark Masking

/// @cond

// default path is the rounded rect layer bounds
-(nullable CGPathRef)maskingPath
{
    if ( self.masksToBounds ) {
        CGPathRef path = self.outerBorderPath;
        if ( path ) {
            return path;
        }

        path                 = CPTCreateRoundedRectPath(self.bounds, self.cornerRadius);
        self.outerBorderPath = path;
        CGPathRelease(path);

        return self.outerBorderPath;
    }
    else {
        return NULL;
    }
}

-(nullable CGPathRef)sublayerMaskingPath
{
    return self.innerBorderPath;
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
-(void)applySublayerMaskToContext:(nonnull CGContextRef)context forSublayer:(nonnull CPTLayer *)sublayer withOffset:(CGPoint)offset
{
    CGPoint sublayerBoundsOrigin = sublayer.bounds.origin;
    CGPoint layerOffset          = offset;

    if ( !self.renderingRecursively ) {
        CGPoint convertedOffset = [self convertPoint:sublayerBoundsOrigin fromLayer:sublayer];
        layerOffset.x += convertedOffset.x;
        layerOffset.y += convertedOffset.y;
    }

    CGAffineTransform sublayerTransform = CATransform3DGetAffineTransform(sublayer.transform);

    CGContextConcatCTM(context, CGAffineTransformInvert(sublayerTransform));

    CALayer *superlayer = self.superlayer;

    if ( [superlayer isKindOfClass:[CPTLayer class]] ) {
        [(CPTLayer *) superlayer applySublayerMaskToContext:context forSublayer:self withOffset:layerOffset];
    }

    CGPathRef maskPath = self.sublayerMaskingPath;

    if ( maskPath ) {
        CGContextTranslateCTM(context, -layerOffset.x, -layerOffset.y);
        CGContextAddPath(context, maskPath);
        CGContextClip(context);
        CGContextTranslateCTM(context, layerOffset.x, layerOffset.y);
    }

    CGContextConcatCTM(context, sublayerTransform);
}

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
