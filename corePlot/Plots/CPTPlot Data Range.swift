//
//  CPTPlot Data Range.swift
//  corePlot
//
//  Created by thierryH24 on 24/11/2020.
//

import Foundation


extension CPTPlot {


// MARK:  Data Ranges
//
///** @brief Determines the smallest plot range that fully encloses the data for a particular field.
// *  @param fieldEnum The field enumerator identifying the field.
// *  @return The plot range enclosing the data.
// **/
    func plotRangeForField(fieldEnum: Int )-> CPTPlotRange
    {
        if self.dataNeedsReloading == true {
            self.reloadData()
        }
        let numbers = self.cachedNumbersForField(fieldEnum)
        let range            : CPTPlotRange?
        
        let numberOfSamples = numbers.numberOfSamples;
        
        if ( numberOfSamples > 0 ) {
            if ( self.doublePrecisionCache ) {
                let  min = Double.infinity
                let max = -Double.infinity
                
               let doubles    = (const double *)numbers.bytes;
                let lastSample = doubles + numberOfSamples;
                
                while ( doubles < lastSample ) {
                    var value = doubles++;
                    
                    
                    if ( !isnan(value)) {
                        if ( value < min ) {
                            min = value;
                        }
                        if ( value > max ) {
                            max = value;
                        }
                    }
                }
                
                if ( max >= min ) {
                    range = [CPTPlotRange plotRangeWithLocation:@(min) length:max - min);
                }
            }
            else {
                let min = [NSDecimalNumber maximumDecimalNumber].decimalValue;
                let max = [NSDecimalNumber minimumDecimalNumber].decimalValue;
                
                let decimals   = (const NSDecimal *)numbers.bytes;
                let lastSample = decimals + numberOfSamples;
                
                while ( decimals < lastSample ) {
                     value = decimals
                    decimals += 1
                    
                    if ( !value.isNaN) {
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
//
///** @brief Determines the smallest plot range that fully encloses the data for a particular coordinate.
// *  @param coord The coordinate identifier.
// *  @return The plot range enclosing the data.
// **/
    func plotRangeForCoordinate(coord: CPTCoordinate)-> CPTPlotRange?
    {
        let fields = self.fieldIdentifiersForCoordinate(coord: coord)
        
        guard ( fields.count != 0 ) else { return nil }
        
        var unionRange : CPTMutablePlotRange?
        
        for field in fields  {
            let currentRange = self.plotRangeForField(fieldEnum: Int(field))
            if ( (unionRange == nil) ) {
                unionRange = currentRange as? CPTMutablePlotRange
            }
            else {
                unionRange?.unionPlotRange(self, plotRangeForField(fieldEnum: Int(field)))
            }
        }
        
        return unionRange;
    }
//
///** @brief Determines the smallest plot range that fully encloses the entire plot for a particular field.
// *  @param fieldEnum The field enumerator identifying the field.
// *  @return The plot range enclosing the data.
// **/
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
        var fields = self.fieldIdentifiersForCoordinate(coord: coord)
        guard fields.isEmpty == false else  { return nil }
        
        var unionRange = [CPTPlotRange]()
        
        for field in fields {
            let currentRange = self.plotRangeEnclosingField(fieldEnum: Int(field))
            if  unionRange.isEmpty == false  {
                unionRange = currentRange
            }
            else {
                unionRange.unionPlotRange(self.plotRangeEnclosingField(fieldEnum: Int(field)))
            }
        }
        return unionRange;
    }

    // MARK: -  Data Labels
//
///**
// *  @brief Marks the receiver as needing to update all data labels before the content is next drawn.
// *  @see @link CPTPlot::relabelIndexRange: -relabelIndexRange: @endlink
// **/
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

    let  nullObject         = [NSNull null];
//    Class nullClass       = [NSNull class];
//    Class annotationClass = [CPTAnnotation class];

    let dataLabelTextStyle = self.labelTextStyle;
    let dataLabelFormatter  = self.labelFormatter;
    let plotProvidesLabels  = dataLabelTextStyle && dataLabelFormatter
    
    var hasCachedLabels               = false
    var cachedLabels = (CPTMutableLayerArray *)[self.cachedArrayForKey:CPTPlotBindingDataLabels];

    for ( CPTLayer label in cachedLabels ) {
        if ( !label isKindOfClass:nullClass] ) {
            hasCachedLabels = true
            break
        }
    }

    if ( !self.showLabels || (!hasCachedLabels && !plotProvidesLabels)) {
        for ( CPTAnnotation *annotation in self.labelAnnotations ) {
            if ( [annotation isKindOfClass:annotationClass] ) {
                [self removeAnnotation:annotation];
            }
        }
        self.labelAnnotations = nil;
        return;
    }

    let textAttributes = dataLabelTextStyle?.attributes
    let hasAttributedFormatter   = ([dataLabelFormatter.attributedStringForObjectValue:[NSDecimalNumber zero]
                                                                  withDefaultAttributes:textAttributes] != nil);

    let sampleCount = self.cachedDataCount;
    let indexRange     = self.labelIndexRange;
    let maxIndex    = NSMaxRange(indexRange)

    if ( !self.labelAnnotations.isEmpty ) {
        self.labelAnnotations = []()
    }

    let thePlotSpace            = self.plotSpace;
    let theRotation                   = self.labelRotation;
    let labelArray = self.labelAnnotations;
    let oldLabelCount    = labelArray.count;
    id nilObject         = [CPTPlot nilData];

    CPTMutableNumericData *labelFieldDataCache = [self cachedNumbersForField:self.labelField];
    let theShadow                       = self.labelShadow;

    for i in indexRange.location..<maxIndex {
        let dataValue = labelFieldDataCache (sampleValue:i)

        let newLabelLayer = CPTLayer()
        if ( isnan([dataValue doubleValue])) {
            newLabelLayer = nil;
        }
        else {
            newLabelLayer = self.cachedValueForKey(CPTPlotBindingDataLabels recordIndex:i)

            if (((newLabelLayer == nil) || (newLabelLayer == nilObject)) && plotProvidesLabels ) {
                if ( hasAttributedFormatter ) {
                    let labelString = [dataLabelFormatter attributedStringForObjectValue:dataValue withDefaultAttributes:textAttributes];
                    newLabelLayer = CPTTextLayer(newText: labelString)
                }
                else {
                    let labelString = dataLabelFormatter.stringForObjectValue(dataValue)
                    newLabelLayer = CPTTextLayer(newText: labelString, style:dataLabelTextStyle)
                }
            }

            if ( newLabelLayer is nullClass || (newLabelLayer == nilObject)) {
                newLabelLayer = nil;
            }
        }
        newLabelLayer.shadow = theShadow;

       var labelAnnotation : CPTPlotSpaceAnnotation
        if ( i < oldLabelCount ) {
            labelAnnotation = labelArray[i]
            if ( newLabelLayer ) {
                if ( [labelAnnotation is nullClass] ) {
                    labelAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:thePlotSpace anchorPlotPoint:nil];
                    labelArray[i]   = labelAnnotation;
                    [self addAnnotation:labelAnnotation];
                }
            }
            else {
                if ( labelAnnotation is annotationClass) {
                    labelArray[i] = nullObject;
                    self.removeAnnotation(labelAnnotation)
                }
            }
        }
        else {
            if ( newLabelLayer ) {
                labelAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:thePlotSpace anchorPlotPoint:nil];
                [labelArray addObject:labelAnnotation];
                [self addAnnotation:labelAnnotation];
            }
            else {
                labelArray.apppend(nullObject)
            }
        }

        if ( newLabelLayer ) {
            labelAnnotation.contentLayer = newLabelLayer;
            labelAnnotation.rotation     = theRotation;
            [self.positionLabelAnnotationlabelAnnotation, for Index:i)
                self.updateContentAnchorForLabel(labelAnnotation)
        }
    }

    // remove labels that are no longer needed
    while ( labelArray.count > sampleCount ) {
        let oldAnnotation = labelArray[labelArray.count - 1];
        if oldAnnotation is annotationClass {
                self.removeAnnotation(oldAnnotation)
        }
        labelArray.removeLastObject
    }
}
//
///** @brief Marks the receiver as needing to update a range of data labels before the content is next drawn.
// *  @param indexRange The index range needing update.
// *  @see setNeedsRelabel()
// **/
    func relabelIndexRange(indexRange: NSRange)
{
    self.labelIndexRange = indexRange;
    self.needsRelabel    = true;
}


    func updateContentAnchorForLabel(label: CPTPlotSpaceAnnotation )
    {
        if ( label && self.adjustLabelAnchors == true ) {
            var displacement = label.displacement
            
            if ( displacement!.equalTo(CGPoint())) {
                displacement?.y = CGFloat(1.0); // put the label above the data point if zero displacement
            }
            var angle      = CGFloat(M_PI) + atan2(displacement?.y, displacement?.x) - label.rotation
            var newAnchorX = cos(angle);
            var newAnchorY = sin(angle);
            
            if ( abs(newAnchorX) <= abs(newAnchorY)) {
                newAnchorX /= abs(newAnchorY);
                newAnchorY  = signbit(newAnchorY) ? CGFloat(-1.0) : CGFloat(1.0);
            }
            else {
                newAnchorY /= abs(newAnchorX);
                newAnchorX  = signbit(newAnchorX) ? CGFloat(-1.0) : CGFloat(1.0);
            }
            
            label.contentAnchorPoint = CGPoint((newAnchorX + CGFloat(1.0)) / CGFloat(2.0), (newAnchorY + CGFloat(1.0)) / CGFloat(2.0));
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
                self.updateContentAnchorForLabel(label:annotation as! CPTPlotSpaceAnnotation)
            }
        }
    }
}
