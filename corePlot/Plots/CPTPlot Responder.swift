//
//  CPTPlot Responder.swift
//  corePlot
//
//  Created by thierryH24 on 24/11/2020.
//

import Foundation


extension CPTPlot {
    
    
    // MARK: - Responder Chain and User interaction
    override func pointingDeviceDownEvent(event: CPTNativeEvent, atPoint interactionPoint:CGPoint)-> Bool
    {
        self.pointingDeviceDownLabelIndex = NSNotFound;
        
        guard self.isHidden == false else { return false }
        
        let theGraph = self.graph;
        guard theGraph != nil else { return false }
        
        weak var theDelegate = self.delegate as? CPTPlotDelegate
        
        // Inform delegate if a label was hit
        let labelArray = self.labelAnnotations;
        let labelCount = labelArray.count
        
        for  idx in 0..<labelCount {
            
            let annotation = labelArray[idx];
            
            let labelLayer = annotation.contentLayer;
            if ( (labelLayer != nil) && !labelLayer!.isHidden ) {
                let labelPoint = theGraph?.convert(interactionPoint, to:labelLayer)
                
                if  labelLayer!.bounds.contains( labelPoint!) == true{
                    self.pointingDeviceDownLabelIndex = idx;
                    var handled = false
                    
                    if (theDelegate?.plot(plot: dataLabelTouchDownAtRecordIndex:)) != nil  {
                        handled = true
                        theDelegate?.plot(plot:self, dataLabelTouchDownAtRecordIndex: idx)
                    }
                    
                    if (theDelegate?.plot(plot:  dataLabelTouchDownAtRecordIndex: event:)) != nil {
                        handled = true
                        theDelegate?.plot(plot: self, dataLabelTouchDownAtRecordIndex: idx, event: event)
                    }
                    
                    guard handled == false else { return true }
                }
            }
        }
        return super.pointingDeviceDownEvent(event: event, atPoint:interactionPoint);
    }
    
    override func pointingDeviceUpEvent(event: CPTNativeEvent, atPoint interactionPoint:CGPoint)-> Bool
    {
        let selectedDownIndex = self.pointingDeviceDownLabelIndex;
        
        self.pointingDeviceDownLabelIndex = NSNotFound;
        
        guard self.isHidden == false else { return false }
        
        let theGraph = self.graph;
        guard theGraph != nil else { return false }
        
        weak var theDelegate = self.delegate as? CPTPlotDelegate
        
        // Inform delegate if a label was hit
        let labelArray = self.labelAnnotations;
        let labelCount = labelArray.count;
        
        for idx in 0..<labelCount {
            let annotation = labelArray[idx];
            
            let labelLayer = annotation.contentLayer;
            if ( (labelLayer != nil) && !labelLayer!.isHidden ) {
                let labelPoint = theGraph?.convert(interactionPoint, to:labelLayer)
                
                if labelLayer!.bounds.contains( labelPoint!)
                {
                    var handled = false
                    
                    if (theDelegate?.plot(plot:  dataLabelTouchUpAtRecordIndex: )) != nil {
                        handled = true
                        theDelegate?.plot(plot: self, dataLabelTouchUpAtRecordIndex: idx)
                    }
                    
                    if (theDelegate?.plot(plot: dataLabelTouchUpAtRecordIndex: event: )) != nil {
                        handled = true
                        theDelegate?.plot(plot: self, dataLabelTouchUpAtRecordIndex:idx, event:event)
                    }
                    
                    if ( idx == selectedDownIndex ) {
                        if (theDelegate?.plot(plot: dataLabelWasSelectedAtRecordIndex:)) != nil {
                            handled = true
                            theDelegate?.plot(plot: self, dataLabelWasSelectedAtRecordIndex:idx)
                        }
                        
                        if (theDelegate?.plot(plot: dataLabelWasSelectedAtRecordIndex: event: )) != nil {
                            handled = true
                            theDelegate?.plot(plot: self, dataLabelWasSelectedAtRecordIndex:idx, event:event)
                        }
                    }
                    guard handled == false else { return true }
                }
            }
        }
        return super.pointingDeviceUpEvent(event: event, atPoint:interactionPoint)
    }
}
