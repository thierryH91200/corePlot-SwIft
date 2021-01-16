//
//  CPTMutablePlotRange.swift
//  corePlot
//
//  Created by thierryH24 on 04/12/2020.
//

import AppKit

class CPTMutablePlotRange: CPTPlotRange {
    
    
    var inValueUpdate = false
    
    override var location : CGFloat {
        get { return super.location  }
        set { super.location = newValue }
    }
    
    /** @property nonnull NSNumber *length
     *  @brief The length of the range.
     *  @see @ref lengthDecimal, @ref lengthDouble
     **/
    override var length : CGFloat {
        get { return super.length  }
        set { super.length = newValue }
    }
    
    /** @property NSDecimal locationDecimal
     *  @brief The starting value of the range.
     *  @see @ref location, @ref locationDouble
     **/
    override var locationDecimal : CGFloat {
        get { return super.locationDecimal  }
        set { super.locationDecimal = newValue }
    }
    
    /** @property NSDecimal lengthDecimal
     *  @brief The length of the range.
     *  @see @ref length, @ref lengthDouble
     **/
    override var lengthDecimal : CGFloat {
        get { return super.lengthDecimal  }
        set { super.lengthDecimal = newValue }
    }
    
    
    /** @property double locationDouble
     *  @brief The starting value of the range as a @double.
     *  @see @ref location, @ref locationDecimal
     **/
    override var locationDouble : Double {
        get { return super.locationDouble  }
        set { super.locationDouble = newValue }
    }
    /** @property double lengthDouble
     *  @brief The length of the range as a @double.
     *  @see @ref length, @ref lengthDecimal
     **/
    override var lengthDouble : Double {
        get { return super.lengthDouble  }
        set { super.lengthDouble = newValue }
    }
    
    // MARK: -  Combining ranges
    
    /** @brief Extends the range to include another range. The sign of @ref length is unchanged.
     *  @param other The other plot range.
     **/
    func unionPlotRange(other: CPTPlotRange? )
    {
        guard ( other != nil) else  { return }
        
        let min1    = self.minLimitDecimal;
        let min2    = (other?.minLimitDecimal)!
        let minimum = min(min1, min2);
        
        let max1    = self.maxLimitDecimal;
        let max2    = (other?.maxLimitDecimal)!;
        let maximum = max(max1, max2);
        
        if ( self.isInfinite && other!.isInfinite ) {
            if ( self.lengthSign == other?.lengthSign ) {
                switch ( self.lengthSign ) {
                case .positive:
                    self.locationDecimal = minimum;
                    
                case .negative:
                    self.locationDecimal = maximum;
                    
                default:
                    break;
                }
            }
            else {
                self.locationDouble = -CGFloat.infinity;
                self.lengthDouble   = CGFloat.infinity  // HUGE_VAL;
            }
        }
        else if ( self.isInfinite && !other!.isInfinite ) {
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
        else if ( !self.isInfinite && ((other?.isInfinite) != nil) ) {
            switch ( other?.lengthSign ) {
            case .positive:
                self.locationDecimal = minimum;
                self.lengthDouble    = CGFloat.infinity;
                break;
                
            case .negative:
                self.locationDecimal = maximum;
                self.lengthDouble    = -CGFloat.infinity;
                break;
                
            default:
                break;
            }
        }
        else if minimum.isNaN || maximum.isNaN  {
            self.locationDecimal = CGFloat.nan
            self.lengthDecimal   = CGFloat.nan
        }
        else {
            if self.lengthDecimal >= CGFloat(0) {
                self.locationDecimal = CGFloat(minimum);
                self.lengthDecimal   = CGFloat(maximum - minimum)
            }
            else {
                self.locationDecimal = CGFloat(maximum);
                self.lengthDecimal   = CGFloat((minimum - maximum))
            }
        }
    }
    
    /** @brief Sets the messaged object to the intersection with another range. The sign of @ref length is unchanged.
     *  @param other The other plot range.
     **/
    func intersectionPlotRange(other: CPTPlotRange? )
    {
        guard ( other != nil) else { return }
        
        let min1    = self.minLimitDecimal
        let min2    = other?.minLimitDecimal;
        let minimum = max(min1, min2!);
        
        let max1    = self.maxLimitDecimal
        let max2    = (other?.maxLimitDecimal)!
        let maximum = min(max1, max2)
        
        if !self.intersectsRange(otherRange: other ) {
            self.locationDecimal = CGFloat.nan
            self.lengthDecimal   = CGFloat.nan
        }
        else if ( self.isInfinite && ((other?.isInfinite) != nil) ) {
            switch ( self.lengthSign ) {
            case .positive:
                self.locationDecimal = CGFloat(minimum);
                break;
                
            case .negative:
                self.locationDecimal = CGFloat(maximum);
                break;
                
            default:
                break;
            }
        }
        else if ( self.isInfinite && !other!.isInfinite ) {
            switch ( self.lengthSign ) {
            case .positive:
                self.locationDecimal = CGFloat(minimum);
                self.lengthDecimal   = CGFloat(other!.maxLimitDecimal - minimum)
                
            case .negative:
                self.locationDecimal = CGFloat(maximum);
                self.lengthDecimal   = CGFloat(other!.minLimitDecimal - maximum)
                
            default:
                break;
            }
        }
        else if ( !self.isInfinite && ((other?.isInfinite) != nil) ) {
            switch ( other?.lengthSign ) {
            case .positive:
                self.locationDecimal = CGFloat(minimum);
                self.lengthDecimal   = CGFloat(self.maxLimitDecimal - minimum)
                
            case .negative:
                self.locationDecimal = CGFloat(maximum)
                self.lengthDecimal   = self.minLimitDecimal - CGFloat(maximum)
                
            default:
                break;
            }
        }
        else if minimum.isNaN || maximum.isNaN  {
            self.locationDecimal = CGFloat.nan
            self.lengthDecimal   = CGFloat.nan
        }
        else {
            if  self.lengthDecimal >= CGFloat(0) {
                self.locationDecimal = CGFloat(minimum);
                self.lengthDecimal   = CGFloat(maximum - minimum)
            }
            else {
                self.locationDecimal = CGFloat(maximum);
                self.lengthDecimal   = CGFloat(minimum - maximum)
            }
        }
    }
    
    // MARK: - Expanding/Contracting ranges
    
    /** @brief Extends/contracts the range by a given factor.
     *  @param factor Factor used. A value of @num{1.0} gives no change.
     *  Less than @num{1.0} is a contraction, and greater than @num{1.0} is expansion.
     **/
    func expandRangeByFactor(factor: CGFloat )
    {
        let oldLength      = self.lengthDecimal
        let newLength      = oldLength * factor
        let locationOffset = ((oldLength - newLength) / (2));
        let newLocation    = self.locationDecimal + locationOffset
        
        self.locationDecimal = newLocation;
        self.lengthDecimal   = newLength;
    }
    
    // MARK: - Shifting Range
    
    /** @brief Moves the whole range so that the @ref location fits in other range.
     *  @param otherRange Other range.
     *  The minimum possible shift is made. The range @ref length is unchanged.
     **/
    func shiftLocationToFitInRange(otherRange: CPTPlotRange )
    {
        switch otherRange.compareToDecimal(number: self.locationDecimal ) {
        case .belowRange:
            self.locationDecimal = otherRange.minLimitDecimal;
            break;
            
        case .aboveRange:
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
    func shiftEndToFitInRange( otherRange: CPTPlotRange) {
        
        switch otherRange.compareToDecimal( number: endDecimal) {
        case .belowRange:
            locationDecimal = otherRange.minLimitDecimal - lengthDecimal
        case .aboveRange:
            locationDecimal = otherRange.maxLimitDecimal - lengthDecimal
        default:
            // in range--do nothing
            break
        }
    }
    
    // MARK: - Accessors
    func setLocation(newLocation : CGFloat )
    {
        self.inValueUpdate = true
        self.locationDecimal = newLocation
        self.locationDouble  = Double(newLocation)
        self.inValueUpdate = false
    }
    
    func setLength(newLength:  CGFloat )
    {
        self.inValueUpdate = true
        self.lengthDecimal = newLength
        self.lengthDouble  = Double(newLength)
        self.inValueUpdate = false;
    }
}
