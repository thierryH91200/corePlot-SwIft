//
//  CPTPlotArea Layout.swift
//  corePlot
//
//  Created by thierryH24 on 09/12/2020.
//

import AppKit

extension CPTPlotArea {
    
    
    // MARK: Layout

    //     *  @brief Updates the layout of all sublayers. Sublayers fill the super layer&rsquo;s bounds
    //     *  except for the @ref plotGroup, which will fill the receiver&rsquo;s bounds.
    //     *
    //     *  This is where we do our custom replacement for the Mac-only layout manager and autoresizing mask.
    //     *  Subclasses should override this method to provide a different layout of their own sublayers.
    //     **/
    public override func layoutSublayers()
    {
        super.layoutSublayers()
        
        let myAxisSet = self.axisSet;
        let axisSetHasBorder = myAxisSet?.borderLineStyle != nil
        
        let superlayer   = self.superlayer!
        var sublayerBounds = self.convert(superlayer.bounds, from:superlayer)
        
        sublayerBounds.origin = CGPoint()
        var sublayerPosition = self.convert(self.bounds.origin, to:superlayer)
        
        sublayerPosition = CGPoint(x: -sublayerPosition.x, y: -sublayerPosition.y);
        var sublayerFrame = CGRect(x: sublayerPosition.x, y: sublayerPosition.y, width: sublayerBounds.size.width, height: sublayerBounds.size.height);
        
        self.minorGridLineGroup?.frame = sublayerFrame
        self.majorGridLineGroup?.frame = sublayerFrame
        if axisSetHasBorder == true {
            self.axisSet?.frame = sublayerFrame;
        }
        
        // make the plot group the same size as the plot area to clip the plots
        let thePlotGroup = self.plotGroup;
        
        if (( thePlotGroup ) != nil) {
            let selfBoundsSize = self.bounds.size;
            thePlotGroup?.frame = CGRect(x: 0.0, y: 0.0, width: selfBoundsSize.width, height: selfBoundsSize.height);
        }
        
        // the label and title groups never have anything to draw; make them as small as possible to save memory
        sublayerFrame = CGRect(x: sublayerPosition.x, y: sublayerPosition.y, width: 0.0, height: 0.0)
        self.axisLabelGroup?.frame = sublayerFrame;
        self.axisTitleGroup?.frame = sublayerFrame;
        if ( axisSetHasBorder == false) {
            myAxisSet?.frame = sublayerFrame;
            myAxisSet?.layoutSublayers()
        }
    }

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
                excludedSublayers = NSMutableSet() as? CPTAnnotationHostLayer.CPTSublayerSet
            }
            if  (minorGrid != nil)  {
                excludedSublayers?.insert(minorGrid!)
            }
            if ( majorGrid != nil) {
                excludedSublayers?.insert(majorGrid!)
            }
            if ( theAxisSet != nil) {
                excludedSublayers?.insert(theAxisSet!)
            }
            if ( thePlotGroup != nil) {
                excludedSublayers?.insert(thePlotGroup!)
            }
            if ( labels != nil) {
                excludedSublayers?.insert(labels!)
            }
            if ( titles != nil) {
                excludedSublayers?.insert(titles!)
            }
            
            return excludedSublayers!
        }
        else {
            return super.sublayersExcludedFromAutomaticLayout()!
        }
    }

}
