//
//  CPTLayer ext1.swift
//  corePlot
//
//  Created by thierryH24 on 20/11/2020.
//

import AppKit

extension CPTLayer {
    
    
/**     *  @brief Updates the layout of all sublayers. Sublayers fill the super layer&rsquo;s bounds minus any padding.
    
     *  This is where we do our custom replacement for the Mac-only layout manager and autoresizing mask.
     *  Subclasses should override this method to provide a different layout of their own sublayers.
     **/
//    public override func layoutSublayers()
//    {
//        let selfBounds = self.bounds;
//        let mySublayers = self.sublayers;
//
//        if (mySublayers!.count > 0) {
//
//            var  leftPadding = CGFloat(0)
//            var  topPadding = CGFloat(0)
//            var  rightPadding = CGFloat(0)
//            var  bottomPadding = CGFloat(0)
//
//            self.sublayerMargin(left: &leftPadding ,top: &topPadding, right:&rightPadding, bottom:&bottomPadding)
//
//            var subLayerSize = selfBounds.size;
//            subLayerSize.width  -= leftPadding + rightPadding;
//            subLayerSize.width   = max(subLayerSize.width, CGFloat(0.0));
//            subLayerSize.width   = round(subLayerSize.width);
//            subLayerSize.height -= topPadding + bottomPadding;
//            subLayerSize.height  = max(subLayerSize.height, CGFloat(0.0));
//            subLayerSize.height  = round(subLayerSize.height);
//
//            var subLayerFrame = CGRect()
//            subLayerFrame.origin = CGPoint(x: round(leftPadding), y: round(bottomPadding));
//            subLayerFrame.size   = subLayerSize;
//
//            let excludedSublayers = self.sublayersExcludedFromAutomaticLayout()
//
//            for  subLayer in mySublayers! {
//                if ( subLayer is CPTLayer) == true && (excludedSublayers?.contains(subLayer )) == false {
//                    subLayer.frame = subLayerFrame
//                }
//            }
//        }
//    }
//
//    @objc func sublayersExcludedFromAutomaticLayout() -> CPTSublayerSet? {
//        return nil
//    }
//
//    func sublayerMargin( left: inout CGFloat, top: inout CGFloat, right: inout CGFloat, bottom: inout CGFloat )
//    {
//        left   = self.paddingLeft
//        top    = self.paddingTop
//        right  = self.paddingRight
//        bottom = self.paddingBottom
//    }
}
