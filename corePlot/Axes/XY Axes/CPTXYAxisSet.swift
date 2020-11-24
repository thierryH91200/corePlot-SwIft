//
//  CPTXYAxisSet.swift
//  corePlot
//
//  Created by thierryH24 on 14/11/2020.
//

import Cocoa

class CPTXYAxisSet: CPTAxisSet {
    var xAxis: CPTXYAxis
    var yAxis: CPTXYAxis
    
    // MARK: - Init/Dealloc

    init(frame : CGRect)
    {
        super.init(frame:frame)
            CPTXYAxis *xAxis = [[CPTXYAxis alloc] initWithFrame:newFrame];
            xAxis.coordinate    = CPTCoordinateX;
            xAxis.tickDirection = CPTSignNegative;

            let yAxis = CPTXYAxis( newFrame : newFrame)
            yAxis.coordinate    = CPTCoordinateY
            yAxis.tickDirection = CPTSignNegative

            self.axes = [xAxis, yAxis]
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MAR:  Drawing

    override func renderAsVectorInContext(context: CGContext)
    {
        if ( self.isHidden ) {
            return;
        }
        let theLineStyle = self.borderLineStyle;

        if (( theLineStyle ) != nil) {
            super.renderAsVectorInContext(context: context)

            let superlayer = self.superlayer;
            let borderRect   = CPTAlignRectToUserSpace(context, [self convertRect:superlayer.bounds fromLayer:superlayer]);

            theLineStyle?.setLineStyleInContext(context: context)

            let radius = superlayer?.cornerRadius;

            if ( radius! > CGFloat(0.0)) {
                context.beginPath();
                CPTAddRoundedRectPath(context, borderRect, radius);

                theLineStyle?.strokePathInContext(context]
                
            }
            else {
                theLineStyle.strokeRect(borderRect: , inContext:context)
            }
        }
    }

    /// @endcond

    #pragma mark -
    #pragma mark Layout

    /// @name Layout
    /// @{

    /**
     *  @brief Updates the layout of all sublayers. Sublayers (the axes) fill the plot area frame&rsquo;s bounds.
     *
     *  This is where we do our custom replacement for the Mac-only layout manager and autoresizing mask.
     *  Subclasses should override this method to provide a different layout of their own sublayers.
     **/
    -(void)layoutSublayers
    {
        // If we have a border, the default layout will work. Otherwise, the axis set layer has zero size
        // and we need to calculate the correct size for the axis layers.
        if ( self.borderLineStyle ) {
            [super layoutSublayers];
        }
        else {
            CALayer *plotAreaFrame = self.superlayer.superlayer;
            CGRect sublayerBounds  = [self convertRect:plotAreaFrame.bounds fromLayer:plotAreaFrame];
            sublayerBounds.origin = CGPointZero;
            CGPoint sublayerPosition = [self convertPoint:self.bounds.origin toLayer:plotAreaFrame];
            sublayerPosition = CGPointMake(-sublayerPosition.x, -sublayerPosition.y);
            CGRect subLayerFrame = CGRectMake(sublayerPosition.x, sublayerPosition.y, sublayerBounds.size.width, sublayerBounds.size.height);

            CPTSublayerSet *excludedSublayers = self.sublayersExcludedFromAutomaticLayout;
            Class layerClass                  = [CPTLayer class];
            for ( CALayer *subLayer in self.sublayers ) {
                if ( [subLayer isKindOfClass:layerClass] && ![excludedSublayers containsObject:subLayer] ) {
                    subLayer.frame = subLayerFrame;
                }
            }
        }
    }

    /// @}

    #pragma mark -
    #pragma mark Accessors

    /// @cond

    -(nullable CPTXYAxis *)xAxis
    {
        return (CPTXYAxis *)[self axisForCoordinate:CPTCoordinateX atIndex:0];
    }

    -(nullable CPTXYAxis *)yAxis
    {
        return (CPTXYAxis *)[self axisForCoordinate:CPTCoordinateY atIndex:0];
    }

    /// @endcond

    @end

}



