//
//  CPTImage ext3.swift
//  corePlot
//
//  Created by thierryH24 on 18/11/2020.
//

import Foundation

extension CPTImage{
    
    
    func drawImage( theImage: CGImage?,  context: CGContext, rect:CGRect, scaleRatio: CGFloat)
    {
        if ( theImage != nil && (rect.size.width > CGFloat(0.0)) && (rect.size.height > CGFloat(0.0))) {
            let imageScale = self.scale;
            
            context.saveGState();
            
            if ( self.tiled ) {
                context.clip(to: rect);
                if ( !self.tileAnchoredToContext ) {
                    context.translateBy(x: rect.origin.x, y: rect.origin.y);
                }
                context.scaleBy(x: scaleRatio, y: scaleRatio)
                
                let  imageBounds = CGRect(x: 0.0, y: 0.0, width: CGFloat(theImage!.width) / imageScale, height: CGFloat(theImage!.height) / imageScale)
                
                //                CGContextDrawTiledImage(context, imageBounds, theImage);
                
                context.draw(theImage!.cgImage!, in: imageBounds)
                
            }
            else {
                context.scaleBy(x: scaleRatio, y: scaleRatio);
                //                CGContextDrawImage(context, rect, theImage);
            }
            
            context.restoreGState();
        }
    }
}
