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
    
    override init() {
        super.init()
        
        self.init( newPlotSpace: CPTPlotSpace(), newPlotPoint:anchorPlotPoint.removeAll())
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
                    let plotAreaViewAnchorPoint = thePlotSpace.plotAreaViewPointForPlotPoint(self.decimalAnchor, numberOfCoordinates:self.anchorCount)
                    
                    var newPosition = CGPoint()
                    let theGraph    = thePlotSpace.graph
                    let plotArea = theGraph?.plotAreaFrame.plotArea
                    if ( plotArea ) {
                        newPosition = plotArea.convertPoin(plotAreaViewAnchorPoint, toLayer:hostLayer)
                    }
                    else {
                        newPosition = CGPoint()
                    }
                    let offset = self.displacement;
                    newPosition.x += offset!.x;
                    newPosition.y += offset!.y;
                    
                    content?.anchorPoint = self.contentAnchorPoint!
                    content?.position    = newPosition
                    content?.transform   = CATransform3DMakeRotation(self.rotation!, CGFloat(0.0), CGFloat(0.0), CGFloat(1.0));
                    content?.pixelAlign()
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
            
            var decimalPoint = [CGFloat]()
            for i in 0..<self.anchorCount {
                decimalPoint.append(anchorPlotPoint[i])
            }
            self.decimalAnchor = decimalPoint
            
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
