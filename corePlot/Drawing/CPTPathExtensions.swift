//
//  CPTPathExtensions.swift
//  corePlot
//
//  Created by thierryH24 on 19/11/2020.
//

import Foundation



class CPTPathExtensions
{
    static let shared = CPTUtilities()
    
    func CPTCreateRoundedRectPath(rect: CGRect ,cornerRadius: CGFloat ) ->CGPath
    {
        var cornerRadius = cornerRadius
        if ( cornerRadius > CGFloat(0.0)) {
            cornerRadius = min(min(cornerRadius, rect.size.width * CGFloat(0.5)), rect.size.height * CGFloat(0.5));
            
            // CGPathCreateWithRoundedRect() is available in macOS 10.9 and iOS 7 but not marked in the header file
            if #available(macOS 9, iOS 7.0, *) {
                
                return CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil);
            }
            else {
                // In order to draw a rounded rectangle, we will take advantage of the fact that
                // CGPathAddArcToPoint will draw straight lines past the start and end of the arc
                // in order to create the path from the current position and the destination position.
                let minX = rect.minX, midX = rect.midX, maxX = rect.maxX;
                let minY = rect.minY, midY = rect.midY, maxY = rect.maxY;
                
                let path = CGMutablePath()
                
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
            return CGPath(rect: rect, transform: nil)
        }
    }
    
    /** @brief Adds a rectangular path with rounded corners to a graphics context.
     *
     *  @param context The graphics context.
     *  @param rect The bounding rectangle for the path.
     *  @param cornerRadius The radius of the rounded corners.
     **/
    func CPTAddRoundedRectPath(context: CGContext , rect: CGRect, cornerRadius: CGFloat)
    {
        let path = CPTCreateRoundedRectPath(rect: rect, cornerRadius: cornerRadius);
        context.addPath(path);
    }
    
    
    
}
