//
//  CPTPlotSpaceAnnotation.swift
//  corePlot
//
//  Created by thierryH24 on 09/11/2020.
//

import Cocoa

class CPTPlotSpaceAnnotation: CPTAnnotation {
    
    var decimalAnchor = 0.0
    var anchorCount = 0
    var anchorPlotPoint = [CGFloat]()
    var plotSpace = CPTPlotSpace()
    //
    //
    //    /** @property nullable CPTNumberArray *anchorPlotPoint
    //     *  @brief An array of NSDecimalNumber objects giving the anchor plot coordinates.
    //     **/
    //    @synthesize anchorPlotPoint;
    //
    //    /** @property nonnull CPTPlotSpace *plotSpace
    //     *  @brief The plot space which the anchor is defined in.
    //     **/
    //    @synthesize plotSpace;
    //
    
    // MARK: - Init/Dealloc
    init(newPlotSpace: CPTPlotSpace, newPlotPoint: [CGFloat])
    {
        
        super.init()
        plotSpace            = newPlotSpace;
        self.anchorPlotPoint = newPlotPoint;
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setContentNeedsLayout),
                                               name: .CoordinateMappingDidChangeNotification,
                                               object:plotSpace)
    }
    
    

    override init()         {
        super.init()

        self.init( newPlotSpace: CPTPlotSpace(), anchorPlotPoint:nil];
    }
    
    // MARK: Layout
       @objc func setContentNeedsLayout()
        {
            self.contentLayer?.superlayer?.setNeedsLayout()
        }
    
    override func positionContentLayer()
        {
            let content = self.contentLayer

        if (( content ) != nil) {
                let hostLayer = self.annotationHostLayer;
            if (( hostLayer ) != nil) {
                    let plotAnchor = self.anchorPlotPoint;
                if !plotAnchor.isEmpty {
                        // Get plot area point
                        let thePlotSpace      = self.plotSpace;
                        let plotAreaViewAnchorPoint = [thePlotSpace plotAreaViewPointForPlotPoint:self.decimalAnchor numberOfCoordinates:self.anchorCount];

                        CGPoint newPosition;
                        CPTGraph *theGraph    = thePlotSpace.graph;
                        CPTPlotArea *plotArea = theGraph.plotAreaFrame.plotArea;
                        if ( plotArea ) {
                            newPosition = [plotArea convertPoint:plotAreaViewAnchorPoint toLayer:hostLayer];
                        }
                        else {
                            newPosition = CGPointZero;
                        }
                        CGPoint offset = self.displacement;
                        newPosition.x += offset.x;
                        newPosition.y += offset.y;

                        content.anchorPoint = self.contentAnchorPoint;
                        content.position    = newPosition;
                        content.transform   = CATransform3DMakeRotation(self.rotation, CPTFloat(0.0), CPTFloat(0.0), CPTFloat(1.0));
                        [content pixelAlign];
                    }
                }
            }
        }
    
    
    // MARK: - Accessors
    func setAnchorPlotPoint(newPlotPoint: [CGFloat])
    {
        if  anchorPlotPoint != newPlotPoint  {
            anchorPlotPoint = newPlotPoint
            
            self.anchorCount = anchorPlotPoint.count
            
            //            let decimalPoint = calloc(self.anchorCount, sizeof(NSDecimal));
            for i in 0..<self.anchorCount {
                decimalPoint[i] = anchorPlotPoint[i]
            }
            self.decimalAnchor = decimalPoint;
            
            self.setContentNeedsLayout()
        }
    }
    
    func setDecimalAnchor(newAnchor : Double)
    {
        if ( decimalAnchor != newAnchor ) {
            decimalAnchor = newAnchor
        }
    }
    
}
