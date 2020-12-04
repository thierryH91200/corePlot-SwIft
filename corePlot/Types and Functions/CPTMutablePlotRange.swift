//
//  CPTMutablePlotRange.swift
//  corePlot
//
//  Created by thierryH24 on 04/12/2020.
//

import Cocoa

class CPTMutablePlotRange: CPTPlotRange {

    
    var inValueUpdate = false

    var location = CGFloat(0)

    /** @property nonnull NSNumber *length
     *  @brief The length of the range.
     *  @see @ref lengthDecimal, @ref lengthDouble
     **/
    var length = CGFloat(0)

    /** @property NSDecimal locationDecimal
     *  @brief The starting value of the range.
     *  @see @ref location, @ref locationDouble
     **/
    var locationDecimal;

    /** @property NSDecimal lengthDecimal
     *  @brief The length of the range.
     *  @see @ref length, @ref lengthDouble
     **/
    @dynamic lengthDecimal;

    /** @property double locationDouble
     *  @brief The starting value of the range as a @double.
     *  @see @ref location, @ref locationDecimal
     **/
    var locationDouble =

    /** @property double lengthDouble
     *  @brief The length of the range as a @double.
     *  @see @ref length, @ref lengthDecimal
     **/
    @dynamic lengthDouble;



    /** @brief Extends the range to include another range. The sign of @ref length is unchanged.
     *  @param other The other plot range.
     **/
    func unionPlotRange(other: CPTPlotRange )
    {
        if ( !other ) {
            return;
        }

        let min1    = self.minLimitDecimal;
        let min2    = other.minLimitDecimal;
        let minimum = CPTDecimalMin(min1, min2);

        let max1    = self.maxLimitDecimal;
        let max2    = other.maxLimitDecimal;
        let maximum = CPTDecimalMax(max1, max2);

        if ( self.isInfinite && other.isInfinite ) {
            if ( self.lengthSign == other.lengthSign ) {
                switch ( self.lengthSign ) {
                case .positive:
                        self.locationDecimal = minimum;
                        break;

                case .negative:
                        self.locationDecimal = maximum;
                        break;

                    default:
                        break;
                }
            }
            else {
                self.locationDouble = -HUGE_VAL;
                self.lengthDouble   = CGFloat.infinity  // HUGE_VAL;
            }
        }
        else if ( self.isInfinite && !other.isInfinite ) {
            switch ( self.lengthSign ) {
            case .positive:
                    self.locationDecimal = minimum;
                    break;

            case .negative:
                    self.locationDecimal = maximum;
                    break;

                default:
                    break;
            }
        }
        else if ( !self.isInfinite && other.isInfinite ) {
            switch ( other.lengthSign ) {
            case .positive:
                    self.locationDecimal = minimum;
                    self.lengthDouble    = HUGE_VAL;
                    break;

            case .negative:
                    self.locationDecimal = maximum;
                    self.lengthDouble    = -HUGE_VAL;
                    break;

                default:
                    break;
            }
        }
        else if ( NSDecimalIsNotANumber(&minimum) || NSDecimalIsNotANumber(&maximum)) {
            self.locationDecimal = CPTDecimalNaN();
            self.lengthDecimal   = CPTDecimalNaN();
        }
        else {
            if ( CPTDecimalGreaterThanOrEqualTo(self.lengthDecimal, CPTDecimalFromInteger(0))) {
                self.locationDecimal = minimum;
                self.lengthDecimal   = CPTDecimalSubtract(maximum, minimum);
            }
            else {
                self.locationDecimal = maximum;
                self.lengthDecimal   = CPTDecimalSubtract(minimum, maximum);
            }
        }
    }

    /** @brief Sets the messaged object to the intersection with another range. The sign of @ref length is unchanged.
     *  @param other The other plot range.
     **/
    func intersectionPlotRange:(other: CPTPlotRange )
    {
        if ( !other ) {
            return;
        }

        NSDecimal min1    = self.minLimitDecimal;
        NSDecimal min2    = other.minLimitDecimal;
        NSDecimal minimum = CPTDecimalMax(min1, min2);

        NSDecimal max1    = self.maxLimitDecimal;
        NSDecimal max2    = other.maxLimitDecimal;
        NSDecimal maximum = CPTDecimalMin(max1, max2);

        if ( ![self intersectsRange:other] ) {
            self.locationDecimal = CPTDecimalNaN();
            self.lengthDecimal   = CPTDecimalNaN();
        }
        else if ( self.isInfinite && other.isInfinite ) {
            switch ( self.lengthSign ) {
                case CPTSignPositive:
                    self.locationDecimal = minimum;
                    break;

            case .negative:
                    self.locationDecimal = maximum;
                    break;

                default:
                    break;
            }
        }
        else if ( self.isInfinite && !other.isInfinite ) {
            switch ( self.lengthSign ) {
                case CPTSignPositive:
                    self.locationDecimal = minimum;
                    self.lengthDecimal   = CPTDecimalSubtract(other.maxLimitDecimal, minimum);
                    break;

            case .negative:
                    self.locationDecimal = maximum;
                    self.lengthDecimal   = CPTDecimalSubtract(other.minLimitDecimal, maximum);
                    break;

                default:
                    break;
            }
        }
        else if ( !self.isInfinite && other.isInfinite ) {
            switch ( other.lengthSign ) {
                case CPTSignPositive:
                    self.locationDecimal = minimum;
                    self.lengthDecimal   = CPTDecimalSubtract(self.maxLimitDecimal, minimum);
                    break;

            case .negative:
                    self.locationDecimal = maximum;
                    self.lengthDecimal   = CPTDecimalSubtract(self.minLimitDecimal, maximum);
                    break;

                default:
                    break;
            }
        }
        else if ( NSDecimalIsNotANumber(&minimum) || NSDecimalIsNotANumber(&maximum)) {
            self.locationDecimal = CPTDecimalNaN();
            self.lengthDecimal   = CPTDecimalNaN();
        }
        else {
            if ( CPTDecimalGreaterThanOrEqualTo(self.lengthDecimal, CPTDecimalFromInteger(0))) {
                self.locationDecimal = minimum;
                self.lengthDecimal   = CPTDecimalSubtract(maximum, minimum);
            }
            else {
                self.locationDecimal = maximum;
                self.lengthDecimal   = CPTDecimalSubtract(minimum, maximum);
            }
        }
    }

  // mark Expanding/Contracting ranges

    /** @brief Extends/contracts the range by a given factor.
     *  @param factor Factor used. A value of @num{1.0} gives no change.
     *  Less than @num{1.0} is a contraction, and greater than @num{1.0} is expansion.
     **/
    -(void)expandRangeByFactor:(nonnull NSNumber *)factor
    {
        NSDecimal oldLength      = self.lengthDecimal;
        NSDecimal newLength      = CPTDecimalMultiply(oldLength, factor.decimalValue);
        NSDecimal locationOffset = CPTDecimalDivide(CPTDecimalSubtract(oldLength, newLength), CPTDecimalFromInteger(2));
        NSDecimal newLocation    = CPTDecimalAdd(self.locationDecimal, locationOffset);

        self.locationDecimal = newLocation;
        self.lengthDecimal   = newLength;
    }

    #pragma mark -
    #pragma mark Shifting Range

    /** @brief Moves the whole range so that the @ref location fits in other range.
     *  @param otherRange Other range.
     *  The minimum possible shift is made. The range @ref length is unchanged.
     **/
    -(void)shiftLocationToFitInRange:(nonnull CPTPlotRange *)otherRange
    {
        NSParameterAssert(otherRange);

        switch ( [otherRange compareToDecimal:self.locationDecimal] ) {
            case CPTPlotRangeComparisonResultNumberBelowRange:
                self.locationDecimal = otherRange.minLimitDecimal;
                break;

            case CPTPlotRangeComparisonResultNumberAboveRange:
                self.locationDecimal = otherRange.maxLimitDecimal;
                break;

            default:
                // in range--do nothing
                break;
        }
    }

    /** @brief Moves the whole range so that the @ref end point fits in other range.
     *  @param otherRange Other range.
     *  The minimum possible shift is made. The range @ref length is unchanged.
     **/
    -(void)shiftEndToFitInRange:(nonnull CPTPlotRange *)otherRange
    {
        NSParameterAssert(otherRange);

        switch ( [otherRange compareToDecimal:self.endDecimal] ) {
            case CPTPlotRangeComparisonResultNumberBelowRange:
                self.locationDecimal = CPTDecimalSubtract(otherRange.minLimitDecimal, self.lengthDecimal);
                break;

            case CPTPlotRangeComparisonResultNumberAboveRange:
                self.locationDecimal = CPTDecimalSubtract(otherRange.maxLimitDecimal, self.lengthDecimal);
                break;

            default:
                // in range--do nothing
                break;
        }
    }

    // mark Accessors


    func setLocation(newLocation : NSNumber )
    {

        self.inValueUpdate = YES;

        self.locationDecimal = newLocation.decimalValue;
        self.locationDouble  = newLocation.doubleValue;

        self.inValueUpdate = NO;
    }

    func setLength:(newLength:  NSNumber )
    {
        self.inValueUpdate = YES;

        self.lengthDecimal = newLength.decimalValue;
        self.lengthDouble  = newLength.doubleValue;

        self.inValueUpdate = NO;
    }



}
