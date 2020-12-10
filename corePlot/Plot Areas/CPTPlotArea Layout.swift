//
//  CPTPlotArea Layout.swift
//  corePlot
//
//  Created by thierryH24 on 09/12/2020.
//

import Foundation

extension CPTPlotArea {
    
    
    // MARK: Layout
    //
    //    /// @name Layout
    //    /// @{
    //
    //    /**
    //     *  @brief Updates the layout of all sublayers. Sublayers fill the super layer&rsquo;s bounds
    //     *  except for the @ref plotGroup, which will fill the receiver&rsquo;s bounds.
    //     *
    //     *  This is where we do our custom replacement for the Mac-only layout manager and autoresizing mask.
    //     *  Subclasses should override this method to provide a different layout of their own sublayers.
    //     **/
        override func layoutSublayers()
        {
            super.layoutSublayers()
            
            let myAxisSet = self.axisSet;
            let axisSetHasBorder = myAxisSet?.borderLineStyle != nil
            
            let superlayer   = self.superlayer as CALayer
            var sublayerBounds = self.convertRect:superlayer.bounds fromLayer:superlayer];
            
            sublayerBounds.origin = CGPointZero;
            CGPoint sublayerPosition = [self convertPoint:self.bounds.origin toLayer:superlayer];
            
            sublayerPosition = CPTPointMake(-sublayerPosition.x, -sublayerPosition.y);
            CGRect sublayerFrame = CPTRectMake(sublayerPosition.x, sublayerPosition.y, sublayerBounds.size.width, sublayerBounds.size.height);
            
            self.minorGridLineGroup.frame = sublayerFrame;
            self.majorGridLineGroup.frame = sublayerFrame;
            if axisSetHasBorder == true {
                self.axisSet.frame = sublayerFrame;
            }
            
            // make the plot group the same size as the plot area to clip the plots
            let thePlotGroup = self.plotGroup;
            
            if (( thePlotGroup ) != nil) {
                let selfBoundsSize = self.bounds.size;
                thePlotGroup?.frame = CGRect(x: 0.0, y: 0.0, width: selfBoundsSize.width, height: selfBoundsSize.height);
            }
            
            // the label and title groups never have anything to draw; make them as small as possible to save memory
            sublayerFrame             = CGRect(sublayerPosition.x, sublayerPosition.y, 0.0, 0.0);
            self.axisLabelGroup.frame = sublayerFrame;
            self.axisTitleGroup.frame = sublayerFrame;
            if ( axisSetHasBorder == false) {
                myAxisSet.frame = sublayerFrame;
                myAxisSet?.layoutSublayers()
            }
        }
    //
    //    /// @}
    //
    //    /// @cond
    //
    override func sublayersExcludedFromAutomaticLayout()->CPTSublayerSet
        {
            let minorGrid = self.minorGridLineGroup;
            let majorGrid = self.majorGridLineGroup;
            let theAxisSet      = self.axisSet;
            let thePlotGroup  = self.plotGroup;
            let labels   = self.axisLabelGroup;
            let titles   = self.axisTitleGroup;
            
        if ( (minorGrid != nil) || (majorGrid != nil) || (theAxisSet != nil) || (thePlotGroup != nil) || (labels != nil) || (titles != nil) ) {
            var excludedSublayers = super.sublayersExcludedFromAutomaticLayout()
                if ( (excludedSublayers == nil) ) {
                    excludedSublayers = NSMutableSet()
                }
                
            if  (minorGrid != nil)  {
                    excludedSublayers.add(minorGrid)
                }
            if (( majorGrid ) != nil) {
                    excludedSublayers.addObject(majorGrid)
                }
            if (( theAxisSet ) != nil) {
                    excludedSublayers.addObject:theAxisSet];
                }
                if ( thePlotGroup ) {
                    excludedSublayers.addObject(thePlotGroup];
                }
                if ( labels ) {
                    excludedSublayers.addObject(labels)
                }
                if (( titles ) != nil) {
                    excludedSublayers.addObject(titles)
                }
                
                return excludedSublayers;
            }
            else {
                return super.sublayersExcludedFromAutomaticLayout()!
            }
        }

}
