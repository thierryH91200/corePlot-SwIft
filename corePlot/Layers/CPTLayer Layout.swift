//
//  CPTLayer Layout.swift
//  corePlot
//
//  Created by thierryH24 on 23/11/2020.
//

import Foundation


extension CPTLayer {


#pragma mark -
#pragma mark Layout

/**
 *  @brief Align the receiver&rsquo;s position with pixel boundaries.
 **/
-(void)pixelAlign
{
    CGFloat scale           = self.contentsScale;
    CGPoint currentPosition = self.position;

    CGSize boundsSize = self.bounds.size;
    CGSize frameSize  = self.frame.size;

    CGPoint newPosition;

    if ( CGSizeEqualToSize(boundsSize, frameSize)) { // rotated 0° or 180°
        CGPoint anchor = self.anchorPoint;

        CGPoint newAnchor = CGPointMake(boundsSize.width * anchor.x,
                                        boundsSize.height * anchor.y);

        if ( scale == CPTFloat(1.0)) {
            newPosition.x = ceil(currentPosition.x - newAnchor.x - CPTFloat(0.5)) + newAnchor.x;
            newPosition.y = ceil(currentPosition.y - newAnchor.y - CPTFloat(0.5)) + newAnchor.y;
        }
        else {
            newPosition.x = ceil((currentPosition.x - newAnchor.x) * scale - CPTFloat(0.5)) / scale + newAnchor.x;
            newPosition.y = ceil((currentPosition.y - newAnchor.y) * scale - CPTFloat(0.5)) / scale + newAnchor.y;
        }
    }
    else if ((boundsSize.width == frameSize.height) && (boundsSize.height == frameSize.width)) { // rotated 90° or 270°
        CGPoint anchor = self.anchorPoint;

        CGPoint newAnchor = CGPointMake(boundsSize.height * anchor.y,
                                        boundsSize.width * anchor.x);

        if ( scale == CPTFloat(1.0)) {
            newPosition.x = ceil(currentPosition.x - newAnchor.x - CPTFloat(0.5)) + newAnchor.x;
            newPosition.y = ceil(currentPosition.y - newAnchor.y - CPTFloat(0.5)) + newAnchor.y;
        }
        else {
            newPosition.x = ceil((currentPosition.x - newAnchor.x) * scale - CPTFloat(0.5)) / scale + newAnchor.x;
            newPosition.y = ceil((currentPosition.y - newAnchor.y) * scale - CPTFloat(0.5)) / scale + newAnchor.y;
        }
    }
    else {
        if ( scale == CPTFloat(1.0)) {
            newPosition.x = round(currentPosition.x);
            newPosition.y = round(currentPosition.y);
        }
        else {
            newPosition.x = round(currentPosition.x * scale) / scale;
            newPosition.y = round(currentPosition.y * scale) / scale;
        }
    }

    self.position = newPosition;
}


}
