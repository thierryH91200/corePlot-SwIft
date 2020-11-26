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
//-(void)relabel
//{
//    if ( !self.needsRelabel ) {
//        return;
//    }
//
//    self.needsRelabel = NO;
//
//    id nullObject         = [NSNull null];
//    Class nullClass       = [NSNull class];
//    Class annotationClass = [CPTAnnotation class];
//
//    CPTTextStyle *dataLabelTextStyle = self.labelTextStyle;
//    NSFormatter *dataLabelFormatter  = self.labelFormatter;
//    BOOL plotProvidesLabels          = dataLabelTextStyle && dataLabelFormatter;
//
//    BOOL hasCachedLabels               = NO;
//    CPTMutableLayerArray *cachedLabels = (CPTMutableLayerArray *)[self cachedArrayForKey:CPTPlotBindingDataLabels];
//
//    for ( CPTLayer *label in cachedLabels ) {
//        if ( ![label isKindOfClass:nullClass] ) {
//            hasCachedLabels = YES;
//            break;
//        }
//    }
//
//    if ( !self.showLabels || (!hasCachedLabels && !plotProvidesLabels)) {
//        for ( CPTAnnotation *annotation in self.labelAnnotations ) {
//            if ( [annotation isKindOfClass:annotationClass] ) {
//                [self removeAnnotation:annotation];
//            }
//        }
//        self.labelAnnotations = nil;
//        return;
//    }
//
//    CPTDictionary *textAttributes = dataLabelTextStyle.attributes;
//    BOOL hasAttributedFormatter   = ([dataLabelFormatter attributedStringForObjectValue:[NSDecimalNumber zero]
//                                                                  withDefaultAttributes:textAttributes] != nil);
//
//    NSUInteger sampleCount = self.cachedDataCount;
//    NSRange indexRange     = self.labelIndexRange;
//    NSUInteger maxIndex    = NSMaxRange(indexRange);
//
//    if ( !self.labelAnnotations ) {
//        self.labelAnnotations = [NSMutableArray arrayWithCapacity:sampleCount];
//    }
//
//    CPTPlotSpace *thePlotSpace            = self.plotSpace;
//    CGFloat theRotation                   = self.labelRotation;
//    CPTMutableAnnotationArray *labelArray = self.labelAnnotations;
//    NSUInteger oldLabelCount              = labelArray.count;
//    id nilObject                          = [CPTPlot nilData];
//
//    CPTMutableNumericData *labelFieldDataCache = [self cachedNumbersForField:self.labelField];
//    CPTShadow *theShadow                       = self.labelShadow;
//
//    for ( NSUInteger i = indexRange.location; i < maxIndex; i++ ) {
//        NSNumber *dataValue = [labelFieldDataCache sampleValue:i];
//
//        CPTLayer *newLabelLayer;
//        if ( isnan([dataValue doubleValue])) {
//            newLabelLayer = nil;
//        }
//        else {
//            newLabelLayer = [self cachedValueForKey:CPTPlotBindingDataLabels recordIndex:i];
//
//            if (((newLabelLayer == nil) || (newLabelLayer == nilObject)) && plotProvidesLabels ) {
//                if ( hasAttributedFormatter ) {
//                    NSAttributedString *labelString = [dataLabelFormatter attributedStringForObjectValue:dataValue withDefaultAttributes:textAttributes];
//                    newLabelLayer = [[CPTTextLayer alloc] initWithAttributedText:labelString];
//                }
//                else {
//                    NSString *labelString = [dataLabelFormatter stringForObjectValue:dataValue];
//                    newLabelLayer = [[CPTTextLayer alloc] initWithText:labelString style:dataLabelTextStyle];
//                }
//            }
//
//            if ( [newLabelLayer isKindOfClass:nullClass] || (newLabelLayer == nilObject)) {
//                newLabelLayer = nil;
//            }
//        }
//        newLabelLayer.shadow = theShadow;
//
//        CPTPlotSpaceAnnotation *labelAnnotation;
//        if ( i < oldLabelCount ) {
//            labelAnnotation = labelArray[i];
//            if ( newLabelLayer ) {
//                if ( [labelAnnotation isKindOfClass:nullClass] ) {
//                    labelAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:thePlotSpace anchorPlotPoint:nil];
//                    labelArray[i]   = labelAnnotation;
//                    [self addAnnotation:labelAnnotation];
//                }
//            }
//            else {
//                if ( [labelAnnotation isKindOfClass:annotationClass] ) {
//                    labelArray[i] = nullObject;
//                    [self removeAnnotation:labelAnnotation];
//                }
//            }
//        }
//        else {
//            if ( newLabelLayer ) {
//                labelAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:thePlotSpace anchorPlotPoint:nil];
//                [labelArray addObject:labelAnnotation];
//                [self addAnnotation:labelAnnotation];
//            }
//            else {
//                [labelArray addObject:nullObject];
//            }
//        }
//
//        if ( newLabelLayer ) {
//            labelAnnotation.contentLayer = newLabelLayer;
//            labelAnnotation.rotation     = theRotation;
//            [self positionLabelAnnotation:labelAnnotation forIndex:i];
//            [self updateContentAnchorForLabel:labelAnnotation];
//        }
//    }
//
//    // remove labels that are no longer needed
//    while ( labelArray.count > sampleCount ) {
//        CPTAnnotation *oldAnnotation = labelArray[labelArray.count - 1];
//        if ( [oldAnnotation isKindOfClass:annotationClass] ) {
//            [self removeAnnotation:oldAnnotation];
//        }
//        [labelArray removeLastObject];
//    }
//}
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
//-(void)updateContentAnchorForLabel:(nonnull CPTPlotSpaceAnnotation *)label
//{
//    if ( label && self.adjustLabelAnchors ) {
//        CGPoint displacement = label.displacement;
//        if ( CGPointEqualToPoint(displacement, CGPointZero)) {
//            displacement.y = CPTFloat(1.0); // put the label above the data point if zero displacement
//        }
//        CGFloat angle      = CPTFloat(M_PI) + atan2(displacement.y, displacement.x) - label.rotation;
//        CGFloat newAnchorX = cos(angle);
//        CGFloat newAnchorY = sin(angle);
//
//        if ( ABS(newAnchorX) <= ABS(newAnchorY)) {
//            newAnchorX /= ABS(newAnchorY);
//            newAnchorY  = signbit(newAnchorY) ? CPTFloat(-1.0) : CPTFloat(1.0);
//        }
//        else {
//            newAnchorY /= ABS(newAnchorX);
//            newAnchorX  = signbit(newAnchorX) ? CPTFloat(-1.0) : CPTFloat(1.0);
//        }
//
//        label.contentAnchorPoint = CPTPointMake((newAnchorX + CPTFloat(1.0)) / CPTFloat(2.0), (newAnchorY + CPTFloat(1.0)) / CPTFloat(2.0));
//    }
//}
//
///// @endcond
//
///**
// *  @brief Repositions all existing label annotations.
// **/
//-(void)repositionAllLabelAnnotations
//{
//    CPTAnnotationArray *annotations = self.labelAnnotations;
//    NSUInteger labelCount           = annotations.count;
//    Class annotationClass           = [CPTAnnotation class];
//
//    for ( NSUInteger i = 0; i < labelCount; i++ ) {
//        CPTPlotSpaceAnnotation *annotation = annotations[i];
//        if ( [annotation isKindOfClass:annotationClass] ) {
//            [self positionLabelAnnotation:annotation forIndex:i];
//            [self updateContentAnchorForLabel:annotation];
//        }
//    }
//}

}