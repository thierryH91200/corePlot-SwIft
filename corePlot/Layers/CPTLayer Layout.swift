//
//  CPTLayer Layout.swift
//  corePlot
//
//  Created by thierryH24 on 23/11/2020.
//

import AppKit


extension CPTLayer {
    
    
    // MARK: Layoutf
    func pixelAlign()
    {
        let scale           = self.contentsScale;
        let currentPosition = self.position;
        
        let boundsSize = self.bounds.size;
        let frameSize  = self.frame.size;
        
        var newPosition = CGPoint()
        
        if ( boundsSize.equalTo(frameSize)) { // rotated 0° or 180°
            let anchor = self.anchorPoint;
            
            let newAnchor = CGPoint(x: boundsSize.width * anchor.x,
                                    y: boundsSize.height * anchor.y);
            
            if ( scale == CGFloat(1.0)) {
                newPosition.x = ceil(currentPosition.x - newAnchor.x - CGFloat(0.5)) + newAnchor.x;
                newPosition.y = ceil(currentPosition.y - newAnchor.y - CGFloat(0.5)) + newAnchor.y;
            }
            else {
                newPosition.x = ceil((currentPosition.x - newAnchor.x) * scale - CGFloat(0.5)) / scale + newAnchor.x;
                newPosition.y = ceil((currentPosition.y - newAnchor.y) * scale - CGFloat(0.5)) / scale + newAnchor.y;
            }
        }
        else if ((boundsSize.width == frameSize.height) && (boundsSize.height == frameSize.width)) { // rotated 90° or 270°
            let anchor = self.anchorPoint;
            
            let newAnchor = CGPoint(x: boundsSize.height * anchor.y,
                                    y: boundsSize.width * anchor.x);
            
            if ( scale == CGFloat(1.0)) {
                newPosition.x = ceil(currentPosition.x - newAnchor.x - CGFloat(0.5)) + newAnchor.x;
                newPosition.y = ceil(currentPosition.y - newAnchor.y - CGFloat(0.5)) + newAnchor.y;
            }
            else {
                newPosition.x = ceil((currentPosition.x - newAnchor.x) * scale - CGFloat(0.5)) / scale + newAnchor.x;
                newPosition.y = ceil((currentPosition.y - newAnchor.y) * scale - CGFloat(0.5)) / scale + newAnchor.y;
            }
        }
        else {
            if ( scale == CGFloat(1.0)) {
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
