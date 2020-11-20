//
//  CPTPathExtensions.swift
//  corePlot
//
//  Created by thierryH24 on 19/11/2020.
//

import Foundation


extension CGPath {
    
    
    func CPTCreateRoundedRectPath(CGRect rect, CGFloat cornerRadius) ->CGPathRef
    {
        if ( cornerRadius > CGFloat(0.0)) {
            cornerRadius = MIN(MIN(cornerRadius, rect.size.width * CPTFloat(0.5)), rect.size.height * CPTFloat(0.5));

            // CGPathCreateWithRoundedRect() is available in macOS 10.9 and iOS 7 but not marked in the header file

            if ( CGPathCreateWithRoundedRect ) {
                return CGPathCreateWithRoundedRect(rect, cornerRadius, cornerRadius, NULL);
            }
            else {
                // In order to draw a rounded rectangle, we will take advantage of the fact that
                // CGPathAddArcToPoint will draw straight lines past the start and end of the arc
                // in order to create the path from the current position and the destination position.
                let minX = CGRectGetMinX(rect), midX = CGRectGetMidX(rect), maxX = CGRectGetMaxX(rect);
                let minY = CGRectGetMinY(rect), midY = CGRectGetMidY(rect), maxY = CGRectGetMaxY(rect);

                let path = CGPath()

                path.move(to: CGPoint(x: minX, y: midY), transform: .identity)
            path.addArc(tangent1End: CGPoint(x: minX, y: minY), tangent2End: CGPoint(x: midX, y: minY), radius: cornerRadius, transform: .identity)
            path.addArc(tangent1End: CGPoint(x: maxX, y: minY), tangent2End: CGPoint(x: maxX, y: midY), radius: cornerRadius, transform: .identity)
            path.addArc(tangent1End: CGPoint(x: maxX, y: maxY), tangent2End: CGPoint(x: midX, y: maxY), radius: cornerRadius, transform: .identity)
            path.addArc(tangent1End: CGPoint(x: minX, y: maxY), tangent2End: CGPoint(x: minX, y: midY), radius: cornerRadius, transform: .identity)
            path.closeSubpath()
                return path;
            }
        }
        else {
            return CGPathCreateWithRect(rect, NULL);
        }
    }

    
}
