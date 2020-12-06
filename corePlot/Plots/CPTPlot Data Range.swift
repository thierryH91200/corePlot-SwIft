//
//  CPTPlot Data Range.swift
//  corePlot
//
//  Created by thierryH24 on 24/11/2020.
//

import Foundation


extension CPTPlot {


//#pragma mark -
//#pragma mark Data Ranges
//
///** @brief Determines the smallest plot range that fully encloses the data for a particular field.
// *  @param fieldEnum The field enumerator identifying the field.
// *  @return The plot range enclosing the data.
// **/
//-(nullable CPTPlotRange *)plotRangeForField:(NSUInteger)fieldEnum
//{
//    if ( self.dataNeedsReloading ) {
//        [self reloadData];
//    }
//    CPTMutableNumericData *numbers = [self cachedNumbersForField:fieldEnum];
//    CPTPlotRange *range            = nil;
//
//    NSUInteger numberOfSamples = numbers.numberOfSamples;
//
//    if ( numberOfSamples > 0 ) {
//        if ( self.doublePrecisionCache ) {
//            double min = (double)INFINITY;
//            double max = -(double)INFINITY;
//
//            const double *doubles    = (const double *)numbers.bytes;
//            const double *lastSample = doubles + numberOfSamples;
//
//            while ( doubles < lastSample ) {
//                double value = *doubles++;
//
//                if ( !isnan(value)) {
//                    if ( value < min ) {
//                        min = value;
//                    }
//                    if ( value > max ) {
//                        max = value;
//                    }
//                }
//            }
//
//            if ( max >= min ) {
//                range = [CPTPlotRange plotRangeWithLocation:@(min) length:@(max - min)];
//            }
//        }
//        else {
//            NSDecimal min = [NSDecimalNumber maximumDecimalNumber].decimalValue;
//            NSDecimal max = [NSDecimalNumber minimumDecimalNumber].decimalValue;
//
//            const NSDecimal *decimals   = (const NSDecimal *)numbers.bytes;
//            const NSDecimal *lastSample = decimals + numberOfSamples;
//
//            while ( decimals < lastSample ) {
//                NSDecimal value = *decimals++;
//
//                if ( !NSDecimalIsNotANumber(&value)) {
//                    if ( CPTDecimalLessThan(value, min)) {
//                        min = value;
//                    }
//                    if ( CPTDecimalGreaterThan(value, max)) {
//                        max = value;
//                    }
//                }
//            }
//
//            if ( CPTDecimalGreaterThanOrEqualTo(max, min)) {
//                range = [CPTPlotRange plotRangeWithLocationDecimal:min lengthDecimal:CPTDecimalSubtract(max, min)];
//            }
//        }
//    }
//    return range;
//}
//
///** @brief Determines the smallest plot range that fully encloses the data for a particular coordinate.
// *  @param coord The coordinate identifier.
// *  @return The plot range enclosing the data.
// **/
//-(nullable CPTPlotRange *)plotRangeForCoordinate:(CPTCoordinate)coord
//{
//    CPTNumberArray *fields = [self fieldIdentifiersForCoordinate:coord];
//
//    if ( fields.count == 0 ) {
//        return nil;
//    }
//
//    CPTMutablePlotRange *unionRange = nil;
//
//    for ( NSNumber *field in fields ) {
//        CPTPlotRange *currentRange = [self plotRangeForField:field.unsignedIntegerValue];
//        if ( !unionRange ) {
//            unionRange = [currentRange mutableCopy];
//        }
//        else {
//            [unionRange unionPlotRange:[self plotRangeForField:field.unsignedIntegerValue]];
//        }
//    }
//
//    return unionRange;
//}
//
///** @brief Determines the smallest plot range that fully encloses the entire plot for a particular field.
// *  @param fieldEnum The field enumerator identifying the field.
// *  @return The plot range enclosing the data.
// **/
//-(nullable CPTPlotRange *)plotRangeEnclosingField:(NSUInteger)fieldEnum
//{
//    return [self plotRangeForField:fieldEnum];
//}
//
///** @brief Determines the smallest plot range that fully encloses the entire plot for a particular coordinate.
// *  @param coord The coordinate identifier.
// *  @return The plot range enclosing the data.
// **/
//-(nullable CPTPlotRange *)plotRangeEnclosingCoordinate:(CPTCoordinate)coord
//{
//    CPTNumberArray *fields = [self fieldIdentifiersForCoordinate:coord];
//
//    if ( fields.count == 0 ) {
//        return nil;
//    }
//
//    CPTMutablePlotRange *unionRange = nil;
//
//    for ( NSNumber *field in fields ) {
//        CPTPlotRange *currentRange = [self plotRangeEnclosingField:field.unsignedIntegerValue];
//        if ( !unionRange ) {
//            unionRange = [currentRange mutableCopy];
//        }
//        else {
//            [unionRange unionPlotRange:[self plotRangeEnclosingField:field.unsignedIntegerValue]];
//        }
//    }
//
//    return unionRange;
//}
//
//#pragma mark -
//#pragma mark Data Labels
//
///**
// *  @brief Marks the receiver as needing to update all data labels before the content is next drawn.
// *  @see @link CPTPlot::relabelIndexRange: -relabelIndexRange: @endlink
// **/
//-(void)setNeedsRelabel
//{
//    self.labelIndexRange = NSMakeRange(0, self.cachedDataCount);
//    self.needsRelabel    = YES;
//}
//
///**
// *  @brief Updates the data labels in the labelIndexRange.
// **/
func relabel()
{
    guard self.needsRelabel == true else { return }

    self.needsRelabel = false

    let  nullObject         = [NSNull null];
    Class nullClass       = [NSNull class];
    Class annotationClass = [CPTAnnotation class];

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
    CPTShadow *theShadow                       = self.labelShadow;

    for ( NSUInteger i = indexRange.location; i < maxIndex; i++ ) {
        NSNumber *dataValue = [labelFieldDataCache sampleValue:i];

        CPTLayer *newLabelLayer;
        if ( isnan([dataValue doubleValue])) {
            newLabelLayer = nil;
        }
        else {
            newLabelLayer = [self cachedValueForKey:CPTPlotBindingDataLabels recordIndex:i];

            if (((newLabelLayer == nil) || (newLabelLayer == nilObject)) && plotProvidesLabels ) {
                if ( hasAttributedFormatter ) {
                    NSAttributedString *labelString = [dataLabelFormatter attributedStringForObjectValue:dataValue withDefaultAttributes:textAttributes];
                    newLabelLayer = [[CPTTextLayer alloc] initWithAttributedText:labelString];
                }
                else {
                    NSString *labelString = [dataLabelFormatter stringForObjectValue:dataValue];
                    newLabelLayer = [[CPTTextLayer alloc] initWithText:labelString style:dataLabelTextStyle];
                }
            }

            if ( [newLabelLayer isKindOfClass:nullClass] || (newLabelLayer == nilObject)) {
                newLabelLayer = nil;
            }
        }
        newLabelLayer.shadow = theShadow;

       var labelAnnotation : CPTPlotSpaceAnnotation
        if ( i < oldLabelCount ) {
            labelAnnotation = labelArray[i]
            if ( newLabelLayer ) {
                if ( [labelAnnotation isKindOfClass:nullClass] ) {
                    labelAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:thePlotSpace anchorPlotPoint:nil];
                    labelArray[i]   = labelAnnotation;
                    [self addAnnotation:labelAnnotation];
                }
            }
            else {
                if ( [labelAnnotation isKindOfClass:annotationClass] ) {
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
                labelArray.apppend(:nullObject)
            }
        }

        if ( newLabelLayer ) {
            labelAnnotation.contentLayer = newLabelLayer;
            labelAnnotation.rotation     = theRotation;
            [self positionLabelAnnotation:labelAnnotation forIndex:i];
            [self updateContentAnchorForLabel:labelAnnotation];
        }
    }

    // remove labels that are no longer needed
    while ( labelArray.count > sampleCount ) {
        CPTAnnotation *oldAnnotation = labelArray[labelArray.count - 1];
        if ( [oldAnnotation isKindOfClass:annotationClass] ) {
            [self removeAnnotation:oldAnnotation];
        }
        labelArray.removeLastObject
    }
}
//
///** @brief Marks the receiver as needing to update a range of data labels before the content is next drawn.
// *  @param indexRange The index range needing update.
// *  @see setNeedsRelabel()
// **/
//-(void)relabelIndexRange:(NSRange)indexRange
//{
//    self.labelIndexRange = indexRange;
//    self.needsRelabel    = YES;
//}
//
///// @cond
//
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
    
    ///// @endcond
    //
    ///**
    // *  @brief Repositions all existing label annotations.
    // **/
    
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
