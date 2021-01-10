//
//  CPTPlot Data Range.swift
//  corePlot
//
//  Created by thierryH24 on 24/11/2020.
//

import AppKit


extension CPTPlot {
    
    
    // MARK:  Data Ranges
    
    /** @brief Determines the smallest plot range that fully encloses the data for a particular field.
     *  @param fieldEnum The field enumerator identifying the field.
     *  @return The plot range enclosing the data.
     **/
    func plotRangeForField(fieldEnum: Int )-> CPTPlotRange
    {
        if self.dataNeedsReloading == true {
            self.reloadData()
        }
        let numbers = self.cachedNumbersForField(fieldEnum: fieldEnum)
        let range            : CPTPlotRange?
        
        let numberOfSamples = numbers.count
        
        if ( numberOfSamples > 0 ) {
            if ( self.doublePrecisionCache )() {
                var min = Double.infinity
                var max = -Double.infinity
                
                let doubles    = numbers
                let lastSample = doubles + numberOfSamples
                
                while ( doubles < lastSample ) {
                    doubles += 1
                    var value = doubles
                    
                    
                    if ( !isnan(value) {
                        if ( value < min ) {
                            min = value;
                        }
                        if ( value > max ) {
                            max = value;
                        }
                    }
                    }
                
                if ( max >= min ) {
                    range = plotRangeWithLocation(min, length: max - min);
                }
            }
            else {
                let min = maximumDecimalNumber
                let max = minimumDecimalNumber
                
                let decimals   = numbers
                let lastSample = decimals + numberOfSamples;
                
                while ( decimals < lastSample ) {
                    value = decimals
                    decimals += 1
                    
                    if ( !value!!.isNaN) {
                        if value < min {
                            min = value;
                        }
                        if value > max {
                            max = value;
                        }
                    }
                }
                
                if  max >= min {
                    range = CPTPlotRange( location :min ,length: max - min)
                }
            }
        }
        return range!
    }
    
    /** @brief Determines the smallest plot range that fully encloses the data for a particular coordinate.
     *  @param coord The coordinate identifier.
     *  @return The plot range enclosing the data.
     **/
    
    /** @brief Determines the smallest plot range that fully encloses the entire plot for a particular field.
     *  @param fieldEnum The field enumerator identifying the field.
     *  @return The plot range enclosing the data.
     **/
    func plotRangeEnclosingField(fieldEnum: Int)-> CPTPlotRange?
    {
        return self.plotRangeForField(fieldEnum: fieldEnum)
    }
    
    ///** @brief Determines the smallest plot range that fully encloses the entire plot for a particular coordinate.
    // *  @param coord The coordinate identifier.
    // *  @return The plot range enclosing the data.
    // **/
    func plotRangeEnclosingCoordinate(coord: CPTCoordinate)-> CPTPlotRange?
    {
        let fields = self.fieldIdentifiersForCoordinate(coord: coord)
        guard fields.isEmpty == false else  { return nil }
        
        var unionRange : CPTMutablePlotRange?
        
        for field in fields {
            let currentRange = self.plotRangeEnclosingField(fieldEnum: Int(field))
            if  (unionRange != nil)  {
                unionRange = currentRange as? CPTMutablePlotRange
            }
            else {
                unionRange?.unionPlotRange(other: self.plotRangeEnclosingField(fieldEnum: Int(field)))
            }
        }
        return unionRange;
    }
    
    // MARK: -  Data Labels
    
    /**
     *  @brief Marks the receiver as needing to update all data labels before the content is next drawn.
     *  @see @link CPTPlot::relabelIndexRange: -relabelIndexRange: @endlink
     **/
    func setNeedsRelabel()
    {
        self.labelIndexRange = NSRange(location: 0, length: self.cachedDataCount);
        self.needsRelabel    = true
    }
    
    /**
     *  @brief Updates the data labels in the labelIndexRange.
     **/
    func relabel()
    {
        guard self.needsRelabel == true else { return }
        self.needsRelabel = false
        
        let  nullObject         : String?
        
        let dataLabelTextStyle = self.labelTextStyle
        let boolLabel = labelTextStyle != nil ? true : false
        
        let dataLabelFormatter = self.labelFormatter
        var boolFormat = dataLabelFormatter != nil ? true : false
        
        let plotProvidesLabels = boolLabel && boolFormat
        
        var hasCachedLabels    = false
        var cachedLabels = self.cachedArrayForKey(key: NSBindingName.PlotDataLabels.rawValue)
        
        for  label in cachedLabels as? [CPTLayer] {
            if ( label != nil) {
                hasCachedLabels = true
                break
            }
        }
        let nullClass = NSNull.self
        for label in cachedLabels {
            if !(label is NSNull) {
                hasCachedLabels = true
                break
            }
        }
        
        if ( !self.showLabels || (hasCachedLabels == false && plotProvidesLabels == false )) {
            for annotation in self.labelAnnotations  {
                self.removeAnnotation(annotation)
            }
            self.labelAnnotations.removeAll()
            return
        }
        
        let textAttributes = dataLabelTextStyle?.attributes
        let hasAttributedFormatter   = dataLabelFormatter.attributedStringForObjectValue( 0, withDefaultAttributes: textAttributes) != nil
        
        let sampleCount = self.cachedDataCount;
        let indexRange     = self.labelIndexRange;
        let maxIndex    = NSMaxRange(indexRange)
        
        if ( !self.labelAnnotations.isEmpty ) {
            self.labelAnnotations.removeAll()
        }
        
        let thePlotSpace = self.plotSpace;
        let theRotation  = self.labelRotation;
        var labelArray  = self.labelAnnotations;
        let oldLabelCount = labelArray.count;
        let nilObject         : CPTPlot?
        
        let labelFieldDataCache = self.cachedNumbersForField(fieldEnum: self.labelField)
        let theShadow = self.labelShadow;
        
        for i in indexRange.location..<maxIndex {
            let dataValue = labelFieldDataCache (sampleValue:i)
            
            let newLabelLayer : CPTLayer?
            if dataValue.isNan  {
                newLabelLayer = nil;
            }
            else {
                newLabelLayer = self.cachedValueForKey(key: NSBindingName.PlotDataLabels.rawValue, recordIndex:i) as? CPTLayer
                
                if (((newLabelLayer == nil) || (newLabelLayer == nilObject)) && plotProvidesLabels ) {
                    if ( hasAttributedFormatter ) {
                        let labelString = dataLabelFormatter.attributedStringForObjectValue(dataValue, withDefaultAttributes:textAttributes)
                        newLabelLayer = CPTTextLayer(newText: labelString)
                    }
                    else {
                        let labelString = dataLabelFormatter.stringForObjectValue(dataValue)
                        newLabelLayer = CPTTextLayer(newText: labelString, style:dataLabelTextStyle)
                    }
                }
                
                if ( newLabelLayer is nullClass || newLabelLayer == nilObject) {
                    newLabelLayer = nil;
                }
            }
            newLabelLayer?.shadow = theShadow
            
            let nullClass : CPTPlotSpaceAnnotation? = nil
            var labelAnnotation : CPTPlotSpaceAnnotation
            
            if i < oldLabelCount {
                
                labelAnnotation = labelArray[i] as! CPTPlotSpaceAnnotation
                if newLabelLayer != nil {
                    if labelAnnotation == nullClass {
                        labelAnnotation = CPTPlotSpaceAnnotation(plotSpace: thePlotSpace, anchorPlotPoint: nil)
                        labelArray[i]   = labelAnnotation;
                        self.addAnnotation(labelAnnotation)
                    }
                }
                else
                {
                    if labelAnnotation is annotationClass {
                        labelArray[i] = nullObject;
                        self.removeAnnotation(labelAnnotation )
                    }
                }
            }
            else {
                if (( newLabelLayer ) != nil) {
                    labelAnnotation = CPTPlotSpaceAnnotation(newPlotSpace: thePlotSpace!, newPlotPoint:[])
                    labelArray.append(labelAnnotation)
                    self.addAnnotation(labelAnnotation)
                }
                else {
                    labelArray.apppend(nullObject)
                }
            }
            
            if (( newLabelLayer ) != nil) {
                labelAnnotation.contentLayer = newLabelLayer;
                labelAnnotation.rotation     = theRotation;
                self.positionLabelAnnotation( label: labelAnnotation, forIndex:i)
                self.updateContentAnchorForLabel(label: labelAnnotation)
            }
        }
        
        // remove labels that are no longer needed
        while ( labelArray.count > sampleCount ) {
            let oldAnnotation = labelArray[labelArray.count - 1];
            self.removeAnnotation(oldAnnotation)
            labelArray.removeLast()
        }
    }
    
    /** @brief Marks the receiver as needing to update a range of data labels before the content is next drawn.
     *  @param indexRange The index range needing update.
     *  @see setNeedsRelabel()
     **/
    func relabelIndexRange(indexRange: NSRange)
    {
        self.labelIndexRange = indexRange;
        self.needsRelabel    = true;
    }
    
    
    func updateContentAnchorForLabel(label: CPTPlotSpaceAnnotation)
    {
        if ( self.adjustLabelAnchors == true ) {
            var displacement = label.displacement
            
            if ( displacement!.equalTo(CGPoint())) {
                displacement?.y = CGFloat(1.0); // put the label above the data point if zero displacement
            }
            let atn = CGFloat(atan2(displacement!.y, displacement!.x))
            let angle      = CGFloat.pi + atn - CGFloat((label.rotation!))
            var newAnchorX = cos(angle);
            var newAnchorY = sin(angle);
            
            if ( abs(newAnchorX) <= abs(newAnchorY)) {
                newAnchorX /= abs(newAnchorY);
                newAnchorY  = newAnchorY.signbit() ? CGFloat(-1.0) : CGFloat(1.0);
            }
            else {
                newAnchorY /= abs(newAnchorX);
                newAnchorX  = newAnchorX.signbit() ? CGFloat(-1.0) : CGFloat(1.0);
            }
            
            label.contentAnchorPoint = CGPoint(x: (newAnchorX + CGFloat(1.0)) / CGFloat(2.0), y: (newAnchorY + CGFloat(1.0)) / CGFloat(2.0));
        }
    }
    
    func repositionAllLabelAnnotations()
    {
        let annotations = self.labelAnnotations;
        let labelCount           = annotations.count;
        _           = CPTAnnotation()
        
        for  i in 0..<labelCount {
            let annotation = annotations[i]
            if annotation is CPTPlotSpaceAnnotation {
                self.positionLabelAnnotation(label:annotation as! CPTPlotSpaceAnnotation, forIndex:i)
                self.updateContentAnchorForLabel(label:(annotation as? CPTPlotSpaceAnnotation)!)
            }
        }
    }
}
