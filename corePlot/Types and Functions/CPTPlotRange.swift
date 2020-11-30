//
//  CPTPlotRange.swift
//  corePlot
//
//  Created by thierryH24 on 11/11/2020.
//

import Cocoa

class CPTPlotRange: NSObject {

    var location : NSNumber = 0.0
    var length: NSNumber = 0.0
    var  end: NSNumber = 0.0
    var locationDecimal:  Decimal = 0.0
    var lengthDecimal: Decimal = 0.0
    var  endDecimal: Decimal = 0.0
    var  locationDouble : Double = 0.0
    var  lengthDouble: Double = 0.0
    var  endDouble: Double = 0.0

    var minLimit: NSNumber = 0.0
    var midPoint: NSNumber = 0.0;
    var maxLimit: NSNumber = 0.0
    var minLimitDecimal: Decimal = 0.0;
    var midPointDecimal: Decimal = 0.0
    var maxLimitDecimal: Decimal = 0.0
    var minLimitDouble: Double = 0.0
    var midPointDouble: Double = 0.0;
    var maxLimitDouble: Double = 0.0

    var  isInfinite: Bool = true
    var  lengthSign: CPTSign = .positive

   // MARK: Init/Dealloc
    +(nonnull instancetype)plotRangeWithLocation:(nonnull NSNumber *)loc length:(nonnull NSNumber *)len
    {
        return [[self alloc] initWithLocation:loc length:len];
    }

    /** @brief Creates and returns a new CPTPlotRange instance initialized with the provided location and length.
     *  @param loc The starting location of the range.
     *  @param len The length of the range.
     *  @return A new CPTPlotRange instance initialized with the provided location and length.
     **/
    +(nonnull instancetype)plotRangeWithLocationDecimal:(NSDecimal)loc lengthDecimal:(NSDecimal)len
    {
        return [[self alloc] initWithLocationDecimal:loc lengthDecimal:len];
    }
//
//    /** @brief Initializes a newly allocated CPTPlotRange object with the provided location and length.
//     *  @param loc The starting location of the range.
//     *  @param len The length of the range.
//     *  @return The initialized CPTPlotRange object.
//     **/
    
    
    init(location: CGFloat, length:CGFloat)
    {

        super.init()
            locationDecimal = location.decimalValue;
            locationDouble  = location.doubleValue;

            lengthDecimal = location.decimalValue;
            lengthDouble  = location.doubleValue;

            if ( isnan(lengthDouble)) {
                isInfinite = false
                lengthSign = CPTSignNone;
            }
            else {
                isInfinite = (BOOL)isinf(lengthDouble);
                lengthSign = lengthDouble.signbit() ? CPTSign.negative : CPTSign.positive
            }
        }

    }
//
//    /** @brief Initializes a newly allocated CPTPlotRange object with the provided location and length.
//     *  @param loc The starting location of the range.
//     *  @param len The length of the range.
//     *  @return The initialized CPTPlotRange object.
//     **/
    -(nonnull instancetype)initWithLocationDecimal:(NSDecimal)loc lengthDecimal:(NSDecimal)len
    {
        return [self initWithLocation:[NSDecimalNumber decimalNumberWithDecimal:loc]
                               length:[NSDecimalNumber decimalNumberWithDecimal:len]];
    }
//
//    /// @name Initialization
//    /// @{
//
//    /** @brief Initializes a newly allocated CPTPlotRange object.
//     *
//     *  The initialized object will have the following properties:
//     *  - @ref location = @num{0.0}
//     *  - @ref length = @num{0.0}
//     *
//     *  @return The initialized object.
//     **/
    -(nonnull instancetype)init
    {
        return [self initWithLocation:@0.0 length:@0.0];
    }
//
//    /// @}
//
//    #pragma mark -
//    #pragma mark Accessors
//
//    /// @cond
//
//    -(NSNumber *)location
//    {
//        return [NSDecimalNumber decimalNumberWithDecimal:self.locationDecimal];
//    }
//
//    -(void)setLocationDecimal:(NSDecimal)newLocation
//    {
//        if ( !CPTDecimalEquals(locationDecimal, newLocation)) {
//            locationDecimal = newLocation;
//
//            if ( !self.inValueUpdate ) {
//                self.inValueUpdate = YES;
//
//                self.locationDouble = CPTDecimalDoubleValue(newLocation);
//
//                self.inValueUpdate = NO;
//            }
//        }
//    }
//
//    -(void)setLocationDouble:(double)newLocation
//    {
//        if ( locationDouble != newLocation ) {
//            locationDouble = newLocation;
//
//            if ( !self.inValueUpdate ) {
//                self.inValueUpdate = YES;
//
//                self.locationDecimal = CPTDecimalFromDouble(newLocation);
//
//                self.inValueUpdate = NO;
//            }
//        }
//    }
//
//    -(NSNumber *)length
//    {
//        return [NSDecimalNumber decimalNumberWithDecimal:self.lengthDecimal];
//    }
//
//    -(void)setLengthDecimal:(NSDecimal)newLength
//    {
//        if ( !CPTDecimalEquals(lengthDecimal, newLength)) {
//            lengthDecimal = newLength;
//
//            if ( !self.inValueUpdate ) {
//                self.inValueUpdate = YES;
//
//                self.lengthDouble = CPTDecimalDoubleValue(newLength);
//
//                self.inValueUpdate = NO;
//            }
//        }
//    }
//
//    -(void)setLengthDouble:(double)newLength
//    {
//        if ( lengthDouble != newLength ) {
//            lengthDouble = newLength;
//
//            if ( isnan(newLength)) {
//                self.isInfinite = NO;
//                self.lengthSign = CPTSignNone;
//            }
//            else {
//                self.isInfinite = (BOOL)isinf(newLength);
//                self.lengthSign = signbit(newLength) ? CPTSignNegative : CPTSignPositive;
//            }
//
//            if ( !self.inValueUpdate ) {
//                self.inValueUpdate = YES;
//
//                self.lengthDecimal = CPTDecimalFromDouble(newLength);
//
//                self.inValueUpdate = NO;
//            }
//        }
//    }
//
//    -(NSNumber *)end
//    {
//        return [NSDecimalNumber decimalNumberWithDecimal:self.endDecimal];
//    }
//
//    -(NSDecimal)endDecimal
//    {
//        return CPTDecimalAdd(self.locationDecimal, self.lengthDecimal);
//    }
//
//    -(double)endDouble
//    {
//        return self.locationDouble + self.lengthDouble;
//    }
//
//    -(NSNumber *)minLimit
//    {
//        return [NSDecimalNumber decimalNumberWithDecimal:self.minLimitDecimal];
//    }
//
//    -(NSDecimal)minLimitDecimal
//    {
//        NSDecimal loc = self.locationDecimal;
//        NSDecimal len = self.lengthDecimal;
//
//        if ( NSDecimalIsNotANumber(&len)) {
//            return loc;
//        }
//        else if ( CPTDecimalLessThan(len, CPTDecimalFromInteger(0))) {
//            return CPTDecimalAdd(loc, len);
//        }
//        else {
//            return loc;
//        }
//    }
//
//    -(double)minLimitDouble
//    {
//        double doubleLoc = self.locationDouble;
//        double doubleLen = self.lengthDouble;
//
//        if ( doubleLen < 0.0 ) {
//            return doubleLoc + doubleLen;
//        }
//        else {
//            return doubleLoc;
//        }
//    }
//
//    -(NSNumber *)midPoint
//    {
//        return [NSDecimalNumber decimalNumberWithDecimal:self.midPointDecimal];
//    }
//
//    -(NSDecimal)midPointDecimal
//    {
//        return CPTDecimalAdd(self.locationDecimal, CPTDecimalDivide(self.lengthDecimal, CPTDecimalFromInteger(2)));
//    }
//
//    -(double)midPointDouble
//    {
//        return fma(self.lengthDouble, 0.5, self.locationDouble);
//    }
//
//    -(NSNumber *)maxLimit
//    {
//        return [NSDecimalNumber decimalNumberWithDecimal:self.maxLimitDecimal];
//    }
//
//    -(NSDecimal)maxLimitDecimal
//    {
//        NSDecimal loc = self.locationDecimal;
//        NSDecimal len = self.lengthDecimal;
//
//        if ( NSDecimalIsNotANumber(&len)) {
//            return loc;
//        }
//        else if ( CPTDecimalGreaterThan(len, CPTDecimalFromInteger(0))) {
//            return CPTDecimalAdd(loc, len);
//        }
//        else {
//            return loc;
//        }
//    }
//
//    -(double)maxLimitDouble
//    {
//        double doubleLoc = self.locationDouble;
//        double doubleLen = self.lengthDouble;
//
//        if ( doubleLen > 0.0 ) {
//            return doubleLoc + doubleLen;
//        }
//        else {
//            return doubleLoc;
//        }
//    }
//
//    /// @endcond
//
//    #pragma mark -
//
//    #pragma mark -
//    #pragma mark Checking Containership
//
//    /** @brief Determines whether a given number is inside the range.
//     *  @param number The number to check.
//     *  @return @YES if @ref location ≤ @par{number} ≤ @ref end.
//     **/
//    -(BOOL)contains:(NSDecimal)number
//    {
//        BOOL result = NO;
//
//        if ( self.isInfinite ) {
//            switch ( self.lengthSign ) {
//                case CPTSignPositive:
//                    result = CPTDecimalGreaterThanOrEqualTo(number, self.minLimitDecimal);
//                    break;
//
//                case CPTSignNegative:
//                    result = CPTDecimalLessThanOrEqualTo(number, self.maxLimitDecimal);
//                    break;
//
//                default:
//                    break;
//            }
//        }
//        else {
//            result = CPTDecimalGreaterThanOrEqualTo(number, self.minLimitDecimal) && CPTDecimalLessThanOrEqualTo(number, self.maxLimitDecimal);
//        }
//
//        return result;
//    }
//
//    /** @brief Determines whether a given number is inside the range.
//     *  @param number The number to check.
//     *  @return @YES if @ref locationDouble ≤ @par{number} ≤ @ref endDouble.
//     **/
//    -(BOOL)containsDouble:(double)number
//    {
//        return (number >= self.minLimitDouble) && (number <= self.maxLimitDouble);
//    }
//
//    /** @brief Determines whether a given number is inside the range.
//     *  @param number The number to check.
//     *  @return @YES if @ref location ≤ @par{number} ≤ @ref end.
//     **/
//    -(BOOL)containsNumber:(nullable NSNumber *)number
//    {
//        if ( [number isKindOfClass:[NSDecimalNumber class]] ) {
//            return [self contains:number.decimalValue];
//        }
//        else {
//            return [self containsDouble:number.doubleValue];
//        }
//    }
//
//    /** @brief Determines whether a given range is equal to the range of the receiver.
//     *  @param otherRange The range to check.
//     *  @return @YES if the ranges both have the same location and length.
//     **/
//    -(BOOL)isEqualToRange:(nullable CPTPlotRange *)otherRange
//    {
//        if ( otherRange ) {
//            return CPTDecimalEquals(self.locationDecimal, otherRange.locationDecimal) &&
//                   CPTDecimalEquals(self.lengthDecimal, otherRange.lengthDecimal) &&
//                   (self.isInfinite == otherRange.isInfinite) &&
//                   (self.lengthSign == otherRange.lengthSign);
//        }
//        else {
//            return NO;
//        }
//    }
//
//    /** @brief Determines whether the receiver entirely contains another range.
//     *  @param otherRange The range to check.
//     *  @return @YES if the other range fits entirely within the range of the receiver.
//     **/
//    -(BOOL)containsRange:(nullable CPTPlotRange *)otherRange
//    {
//        BOOL result = NO;
//
//        if ( otherRange ) {
//            if ( self.isInfinite ) {
//                if ( !otherRange.isInfinite || (otherRange.lengthSign == self.lengthSign)) {
//                    switch ( self.lengthSign ) {
//                        case CPTSignPositive:
//                            result = CPTDecimalGreaterThanOrEqualTo(otherRange.minLimitDecimal, self.minLimitDecimal);
//                            break;
//
//                        case CPTSignNegative:
//                            result = CPTDecimalLessThanOrEqualTo(otherRange.maxLimitDecimal, self.maxLimitDecimal);
//                            break;
//
//                        default:
//                            break;
//                    }
//                }
//            }
//            else {
//                result = CPTDecimalGreaterThanOrEqualTo(otherRange.minLimitDecimal, self.minLimitDecimal) && CPTDecimalLessThanOrEqualTo(otherRange.maxLimitDecimal, self.maxLimitDecimal);
//            }
//        }
//
//        return result;
//    }
//
//    /** @brief Determines whether a given range intersects the receiver.
//     *  @param otherRange The range to check.
//     *  @return @YES if the ranges intersect.
//     **/
//    -(BOOL)intersectsRange:(nullable CPTPlotRange *)otherRange
//    {
//        BOOL result = NO;
//
//        if ( otherRange ) {
//            if ( self.isInfinite ) {
//                if ( otherRange.isInfinite ) {
//                    result = (otherRange.lengthSign == self.lengthSign);
//                }
//                if ( !result ) {
//                    switch ( self.lengthSign ) {
//                        case CPTSignPositive:
//                            result = CPTDecimalGreaterThanOrEqualTo(otherRange.maxLimitDecimal, self.minLimitDecimal);
//                            break;
//
//                        case CPTSignNegative:
//                            result = CPTDecimalLessThanOrEqualTo(otherRange.minLimitDecimal, self.maxLimitDecimal);
//                            break;
//
//                        default:
//                            break;
//                    }
//                }
//            }
//            else {
//                if ( otherRange.isInfinite ) {
//                    switch ( otherRange.lengthSign ) {
//                        case CPTSignPositive:
//                            result = CPTDecimalLessThanOrEqualTo(otherRange.minLimitDecimal, self.maxLimitDecimal);
//                            break;
//
//                        case CPTSignNegative:
//                            result = CPTDecimalLessThanOrEqualTo(otherRange.maxLimitDecimal, self.minLimitDecimal);
//                            break;
//
//                        default:
//                            break;
//                    }
//                }
//                else {
//                    NSDecimal min1    = self.minLimitDecimal;
//                    NSDecimal min2    = otherRange.minLimitDecimal;
//                    NSDecimal minimum = CPTDecimalMax(min1, min2);
//
//                    NSDecimal max1    = self.maxLimitDecimal;
//                    NSDecimal max2    = otherRange.maxLimitDecimal;
//                    NSDecimal maximum = CPTDecimalMin(max1, max2);
//
//                    result = CPTDecimalGreaterThanOrEqualTo(maximum, minimum);
//                }
//            }
//        }
//
//        return result;
//    }
//
//    /** @brief Compares a number to the range, determining if it is in the range, or above or below it.
//     *  @param number The number to check.
//     *  @return The comparison result.
//     **/
//    -(CPTPlotRangeComparisonResult)compareToNumber:(nonnull NSNumber *)number
//    {
//        CPTPlotRangeComparisonResult result;
//
//        if ( [number isKindOfClass:[NSDecimalNumber class]] ) {
//            result = [self compareToDecimal:number.decimalValue];
//        }
//        else {
//            result = [self compareToDouble:number.doubleValue];
//        }
//        return result;
//    }
//
//    /** @brief Compares a number to the range, determining if it is in the range, or above or below it.
//     *  @param number The number to check.
//     *  @return The comparison result.
//     **/
//    -(CPTPlotRangeComparisonResult)compareToDecimal:(NSDecimal)number
//    {
//        CPTPlotRangeComparisonResult result;
//
//        if ( NSDecimalIsNotANumber(&number)) {
//            result = CPTPlotRangeComparisonResultNumberUndefined;
//        }
//        else if ( [self contains:number] ) {
//            result = CPTPlotRangeComparisonResultNumberInRange;
//        }
//        else if ( CPTDecimalLessThan(number, self.minLimitDecimal)) {
//            result = CPTPlotRangeComparisonResultNumberBelowRange;
//        }
//        else {
//            result = CPTPlotRangeComparisonResultNumberAboveRange;
//        }
//        return result;
//    }
//
//    /** @brief Compares a number to the range, determining if it is in the range, or above or below it.
//     *  @param number The number to check.
//     *  @return The comparison result.
//     **/
//    -(CPTPlotRangeComparisonResult)compareToDouble:(double)number
//    {
//        CPTPlotRangeComparisonResult result;
//
//        if ( isnan(number)) {
//            result = CPTPlotRangeComparisonResultNumberUndefined;
//        }
//        else if ( number < self.minLimitDouble ) {
//            result = CPTPlotRangeComparisonResultNumberBelowRange;
//        }
//        else if ( number > self.maxLimitDouble ) {
//            result = CPTPlotRangeComparisonResultNumberAboveRange;
//        }
//        else {
//            result = CPTPlotRangeComparisonResultNumberInRange;
//        }
//        return result;
//    }
//
//    #pragma mark -
//    #pragma mark Label comparison
//
//    /// @cond
//
//    -(BOOL)isEqual:(nullable id)object
//    {
//        if ( self == object ) {
//            return YES;
//        }
//        else if ( [object isKindOfClass:[self class]] ) {
//            return [self isEqualToRange:object];
//        }
//        else {
//            return NO;
//        }
//    }
//
//    -(NSUInteger)hash
//    {
//        NSDecimalNumber *locationNumber = [NSDecimalNumber decimalNumberWithDecimal:self.locationDecimal];
//        NSDecimalNumber *lengthNumber   = [NSDecimalNumber decimalNumberWithDecimal:self.lengthDecimal];
//
//        return locationNumber.hash + lengthNumber.hash;
//    }
//
//    /// @endcond
//
    
}
