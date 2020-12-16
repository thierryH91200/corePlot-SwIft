//
//  CPTImage ext.swift
//  corePlot
//
//  Created by thierryH24 on 17/11/2020.
//

import Foundation

extension CPTImage{
    
    
    func makeImageSlices()
    {
        let theImage = self.image;
        
        let width  = CGFloat(theImage!.width)
        let height =  CGFloat(theImage!.height)
        
        let imageScale   = self.scale;
        let insets = self.edgeInsets;
        
        let capTop    = insets!.top * imageScale;
        let capLeft   = CGFloat(insets!.left * imageScale)
        let capBottom = insets!.bottom * imageScale;
        let capRight  = insets!.right * imageScale;
        
        let centerSize = CGSize(width: width - capLeft - capRight,
                                height: height - capTop - capBottom);
        
        var imageSlices : CPTImageSlices
        
        for i in 0..<9 {
            imageSlices.slice[i] = nil
        }
        
        // top row
        if ( capTop > CGFloat(0.0)) {
            if  capLeft > CGFloat(0.0) {
                let sliceImage = theImage!.cropping(to: CGRect(x: 0.0, y: 0.0, width: capLeft, height: capTop))
                imageSlices.slice[CPTSlice.topLeft.rawValue] = sliceImage;
            }
            
            if  centerSize.width > CGFloat(0.0) {
                let sliceImage = theImage!.cropping(to: CGRect(x: capLeft, y: 0.0, width: centerSize.width, height: capTop))
                imageSlices.slice[CPTSlice.top.rawValue] = sliceImage
            }
            
            if ( capRight > CGFloat(0.0)) {
                let sliceImage = theImage!.cropping( to: CGRect(x: width - capRight, y: 0.0, width: capRight, height: capTop))
                
                imageSlices.slice[CPTSlice.topRight.rawValue] = sliceImage
            }
        }
        
        // middle row
        if ( centerSize.height > CGFloat(0.0)) {
            if ( capLeft > CGFloat(0.0)) {
                let sliceImage = theImage!.cropping(to: CGRect(x: 0.0, y: capTop, width: capLeft, height: centerSize.height));
                imageSlices.slice[CPTSlice.left.rawValue] = sliceImage;
            }
            
            if ( centerSize.width > CGFloat(0.0)) {
                let sliceImage = theImage!.cropping(to: CGRect(x: capLeft, y: capTop, width: centerSize.width, height: centerSize.height));
                imageSlices.slice[CPTSlice.middle.rawValue] = sliceImage
            }
            
            if ( capRight > CGFloat(0.0)) {
                let sliceImage = theImage!.cropping(to: CGRect(x: width - capRight, y: capTop, width: capRight, height: centerSize.height));
                imageSlices.slice[CPTSlice.right.rawValue] = sliceImage
            }
        }
        
        // bottom row
        if ( capBottom > CGFloat(0.0)) {
            if ( capLeft > CGFloat(0.0)) {
                let sliceImage = theImage!.cropping(to: CGRect(x: 0.0, y: height - capBottom, width: capLeft, height: capBottom));
                imageSlices.slice[CPTSlice.bottomLeft.rawValue] = sliceImage;
            }
            
            if ( centerSize.width > CGFloat(0.0)) {
                
                let crop = CGRect(x: capLeft, y: height - capBottom, width: centerSize.width, height: capBottom)
                let sliceImage = theImage!.cropping(to: crop)
                imageSlices.slice[CPTSlice.bottom.rawValue] = sliceImage;
            }
            
            if ( capRight > CGFloat(0.0)) {
                
                let crop =  CGRect(x: width - capRight, y: height - capBottom, width: capRight, height: capBottom)
                let sliceImage = theImage!.cropping(to: crop)
                imageSlices.slice[CPTSlice.bottomRight.rawValue] = sliceImage;
            }
        }
        
//            self.slices = imageSlices;
    }
    
}



