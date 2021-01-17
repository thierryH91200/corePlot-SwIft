//
//  CPTPlotRange.swift
//  corePlot
//
//  Created by thierryH24 on 11/11/2020.
//

import AppKit

typealias CPTPlotRangeArray = [CPTPlotRange]

class CPTPlotRange: NSObject {
    
    enum CPTPlotRangeComparisonResult : Int {
        case belowRange ///< Number is below the range.
        case inRange ///< Number is in the range.
        case aboveRange ///< Number is above the range.
        case undefined ///< Number is undefined (e.g., @NAN).
    }
    
    var location : CGFloat = 0.0
    //    var length: CGFloat = 0.0
    //    var end: CGFloat = 0.0
    
    //    var locationDecimal:  CGFloat = 0.0
    var lengthDecimal: CGFloat = 0.0
    //    var endDecimal: CGFloat = 0.0
    
    //    var locationDouble : Double = 0.0
    var lengthDouble: Double = 0.0
    //    var endDouble: Double = 0.0
    
    //    var minLimit = CGFloat(0.0)
    //    var midPoint = CGFloat(0.0);
    //    var maxLimit = CGFloat(0.0)
    
//    var minLimitDecimal = CGFloat(0.0)
    //    var midPointDecimal = CGFloat(0.0)
    //    var maxLimitDecimal = CGFloat(0.0)
    
    //    var minLimitDouble = Double(0.0)
    //    var midPointDouble = Double(0.0)
    //    var maxLimitDouble = Double(0.0)
    
    var  isInfinite = true
    var  lengthSign  = CPTSign.positive
    
    var maxLimitDecimal:  CGFloat {
        get {
            let  loc = self.locationDecimal;
            let len = self.lengthDecimal;
            
            if len.isNaN {
                return loc;
            }
            else if len > CGFloat(0) {
                return loc + len
            }
            else {
                return loc;
            }
        }
        set { }
    }
    
    // MARK: Init/Dealloc
    
    //    class func plotRange(withLocation loc: NSNumber, length len: NSNumber) -> Self {
    //        return self.init(location: loc, length: len)
    //    }
    
    //
    //    /** @brief Creates and returns a new CPTPlotRange instance initialized with the provided location and length.
    //     *  @param loc The starting location of the range.
    //     *  @param len The length of the range.
    //     *  @return A new CPTPlotRange instance initialized with the provided location and length.
    //     **/
    //    +(nonnull instancetype)plotRangeWithLocationDecimal:(NSDecimal)loc lengthDecimal:(NSDecimal)len
    //    {
    //        return [[self alloc] initWithLocationDecimal:loc lengthDecimal:len];
    //    }
    
    //** @brief Initializes a newly allocated CPTPlotRange object with the provided location and length.
    //*  @param loc The starting location of the range.
    //*  @param len The length of the range.
    //  @return The initialized CPTPlotRange object.
    init(location: CGFloat, length:CGFloat)
    {
        super.init()
        locationDecimal = location
        //        locationDouble  = location
        
        lengthDecimal = length
        //        lengthDouble  = length
        
        if lengthDouble.isNaN {
            isInfinite = false
            lengthSign = CPTSign.none
        }
        else {
            isInfinite = lengthDecimal.isInfinite
            lengthSign = lengthDecimal.signbit() ? CPTSign.negative : CPTSign.positive
        }
    }
    
    init(location: Double, length:Double)
    {
        super.init()
        //        locationDecimal = location
        locationDouble  = location
        
        //        lengthDecimal = length
        lengthDouble  = length
        
        if lengthDouble.isNaN {
            isInfinite = false
            lengthSign = CPTSign.none
        }
        else {
            isInfinite = lengthDouble.isInfinite
            lengthSign = lengthDouble.signbit() ? CPTSign.negative : CPTSign.positive
        }
    }
    
    /** @brief Initializes a newly allocated CPTPlotRange object with the provided location and length.
     *  @param loc The starting location of the range.
     *  @param len The length of the range.
     *  @return The initialized CPTPlotRange object.
     **/
    convenience init(locationDecimal loc: CGFloat, lengthDecimal len: CGFloat) {
        self.init(locationDecimal:  loc, lengthDecimal: len)
    }
    
    
    /** @brief Initializes a newly allocated CPTPlotRange object.
     *
     *  The initialized object will have the following properties:
     *  - @ref location = @num{0.0}
     *  - @ref length = @num{0.0}
     *
     *  @return The initialized object.
     **/
    override init()
    {
        locationDecimal = 0
        locationDouble  = 0
        
        lengthDecimal = 0
        lengthDouble  = 0
        super.init()
    }
    
    // MARK: - Accessors
    var _locationDecimal:  CGFloat = 0.0
    var locationDecimal: CGFloat {
        get { return _locationDecimal }
        set {
            if _locationDecimal != newValue {
                _locationDecimal = newValue
                locationDouble = Double(newValue)
            }
        }
    }
    var _locationDouble:  Double = 0.0
    var locationDouble: Double {
        get { return _locationDouble }
        set {
            if _locationDouble != newValue {
                _locationDouble = newValue
                locationDecimal = CGFloat(newValue)
            }
        }
    }
    
    var length : CGFloat {
        get {return self.lengthDecimal}
        
        set {
            if lengthDecimal != newValue {
                lengthDecimal = newValue;
                
                self.lengthDouble = Double(newValue)
            }
            
        }
    }
    
    func setLengthDouble(newLength: Double)
    {
        if ( lengthDouble != newLength ) {
            lengthDouble = newLength;
            
            if newLength.isNaN {
                self.isInfinite = false
                self.lengthSign = CPTSign.none;
            }
            else {
                self.isInfinite = newLength.isInfinite
                self.lengthSign = newLength.signbit() ? CPTSign.negative : CPTSign.positive;
            }
            
            self.lengthDecimal = CGFloat(newLength);
        }
    }
    
    var _endDecimal : CGFloat = 0
    var endDecimal : CGFloat {
        get { return self.locationDecimal + self.lengthDecimal }
        set { }
    }
    
    
    func end()-> CGFloat
    {
        return self.endDecimal
    }
    
    
    //    var endDouble: Double = 0.0
    func endDouble()-> Double
    {
        return self.locationDouble + self.lengthDouble;
    }
    
    var _minLimit = CGFloat(0.0)
    func minLimit() -> CGFloat
    {
        return self.minLimitDecimal
    }
    
    
    var minLimitDecimal : CGFloat {
        get {
            let loc = self.locationDecimal;
            let len = self.lengthDecimal;
            
            if len.isNaN {
                return loc;
            }
            else if len < CGFloat(0) {
                return loc + len
            }
            else {
                return loc;
            }

        }
        set { }
    }

    //    var minLimitDouble = Double(0.0)
    func minLimitDouble() -> Double
    {
        let doubleLoc = self.locationDouble;
        let doubleLen = self.lengthDouble;
        
        if ( doubleLen < 0.0 ) {
            return doubleLoc + doubleLen;
        }
        else {
            return doubleLoc;
        }
    }
    
    func midPoint() -> CGFloat
    {
        return self._midPointDecimal
    }
    
    var _midPointDecimal : CGFloat = 0
    func midPointDecimal()-> CGFloat
    {
        return self.locationDecimal + (self.lengthDecimal / 2)
    }
    
    func midPointDouble() -> Double
    {
        return fma(self.lengthDouble, 0.5, self.locationDouble);
    }
    
    func maxLimit() -> CGFloat
    {
        return self.maxLimitDecimal
    }
    
    
    func maxLimitDouble()-> Double
    {
        let doubleLoc = self.locationDouble;
        let doubleLen = self.lengthDouble;
        
        if ( doubleLen > 0.0 ) {
            return doubleLoc + doubleLen;
        }
        else {
            return doubleLoc;
        }
    }
    
    
    // MARK: -  Checking Containership
    func contains(_ number: CGFloat) -> Bool {
        
        var result = false
        if isInfinite == true {
            switch lengthSign {
            case CPTSign.positive:
                result = number >= minLimitDecimal
            case CPTSign.negative:
                result = number <= maxLimitDecimal
            default:
                break
            }
        } else {
            result = number >= minLimitDecimal && number <= maxLimitDecimal
        }
        return result
    }
    
    
    /** @brief Determines whether a given number is inside the range.
     *  @param number The number to check.
     *  @return @YES if @ref locationDouble ≤ @par{number} ≤ @ref endDouble.
     **/
    func containsDouble(number: Double) -> Bool
    {
        return (number >= self.minLimitDouble()) && (number <= self.maxLimitDouble())
    }
    
    /** @brief Determines whether a given number is inside the range.
     *  @param number The number to check.
     *  @return @YES if @ref location ≤ @par{number} ≤ @ref end.
     **/
    func containsNumber(number: Any)->Bool
    {
        if (number is CGFloat ) {
            return self.contains(number as! CGFloat)
        }
        else {
            return self.contains(number as! CGFloat)
        }
    }
    
    /** @brief Determines whether a given range is equal to the range of the receiver.
     *  @param otherRange The range to check.
     *  @return @YES if the ranges both have the same location and length.
     **/
    func isEqualToRange(otherRange: CPTPlotRange? )-> Bool
    {
        if (( otherRange ) != nil) {
            return self.locationDecimal == otherRange?.locationDecimal &&
                self.lengthDecimal == otherRange?.lengthDecimal &&
                self.isInfinite == otherRange?.isInfinite &&
                self.lengthSign == otherRange?.lengthSign
        }
        else {
            return false
        }
    }
    
    /** @brief Determines whether the receiver entirely contains another range.
     *  @param otherRange The range to check.
     *  @return @YES if the other range fits entirely within the range of the receiver.
     **/
    func contains(_ otherRange: CPTPlotRange?) -> Bool {
        var result = false
        
        if let otherRange = otherRange {
            if isInfinite {
                if !otherRange.isInfinite || (otherRange.lengthSign == lengthSign) {
                    switch lengthSign {
                    case CPTSign.positive:
                        result = otherRange.minLimitDecimal >= minLimitDecimal
                    case CPTSign.negative:
                        result = otherRange.maxLimitDecimal <= maxLimitDecimal
                    default:
                        break
                    }
                }
            } else {
                result = otherRange.minLimitDecimal >= minLimitDecimal && otherRange.maxLimitDecimal <= maxLimitDecimal
            }
        }
        return result
    }
    
    /** @brief Determines whether a given range intersects the receiver.
     *  @param otherRange The range to check.
     *  @return @YES if the ranges intersect.
     **/
    func intersectsRange(otherRange: CPTPlotRange? ) -> Bool
    {
        var result = false
        
        if (( otherRange ) != nil) {
            if ( self.isInfinite ) {
                if (( otherRange?.isInfinite ) != nil) {
                    result = (otherRange?.lengthSign == self.lengthSign);
                }
                if ( !result ) {
                    switch ( self.lengthSign ) {
                    case .positive:
                        result = otherRange!.maxLimitDecimal >= self.minLimitDecimal
                        break;
                        
                    case .negative:
                        result = otherRange!.minLimitDecimal <= self.maxLimitDecimal
                        break;
                        
                    default:
                        break;
                    }
                }
            }
            else {
                if (( otherRange?.isInfinite ) != nil) {
                    switch ( otherRange?.lengthSign ) {
                    case .positive:
                        result = otherRange!.minLimitDecimal <= self.maxLimitDecimal
                        break;
                        
                    case .negative:
                        result = otherRange!.maxLimitDecimal <= self.minLimitDecimal
                        break;
                        
                    default:
                        break;
                    }
                }
                else {
                    let min1    = self.minLimitDecimal;
                    let min2    = otherRange!.minLimitDecimal;
                    let minimum = max(min1, min2);
                    
                    let max1    = self.maxLimitDecimal
                    let max2    = otherRange!.maxLimitDecimal
                    let maximum = min(max1, max2)
                    
                    result = maximum >= minimum
                }
            }
        }
        return result;
    }
    
    /** @brief Compares a number to the range, determining if it is in the range, or above or below it.
     *  @param number The number to check.
     *  @return The comparison result.
     **/
    func compareToNumber(number: Any )-> CPTPlotRangeComparisonResult
    {
        var  result : CPTPlotRangeComparisonResult
        
        if number  is CGFloat {
            let number = number as! CGFloat
            result = self.compareToDecimal(number: number )
        }
        else {
            let number = number as! Double
            result = self.compareToDouble(number : number)
        }
        return result;
    }
    
    /** @brief Compares a number to the range, determining if it is in the range, or above or below it.
     *  @param number The number to check.
     *  @return The comparison result.
     **/
    func compareToDecimal(number: CGFloat) -> CPTPlotRangeComparisonResult
    {
        var result : CPTPlotRangeComparisonResult
        
        if ( number.isNaN) {
            result = .undefined
        }
        else if self.contains(number) == true {
            result = .inRange
        }
        else if number < self.minLimitDecimal {
            result = .belowRange
        }
        else {
            result = .aboveRange;
        }
        return result;
    }
    
    /** @brief Compares a number to the range, determining if it is in the range, or above or below it.
     *  @param number The number to check.
     *  @return The comparison result.
     **/
    func compareToDouble(number: Double)-> CPTPlotRangeComparisonResult
    {
        var result : CPTPlotRangeComparisonResult
        
        if number.isNaN {
            result = .undefined;
        }
        else if ( number < self.minLimitDouble() ) {
            result = .belowRange
        }
        else if ( number > self.maxLimitDouble() ) {
            result = .aboveRange
        }
        else {
            result = .inRange
        }
        return result;
    }
    
    // MARK: -  Label comparison
    //    -(BOOL)isEqual:(nullable id)object
    //    {
    //        if ( self == object ) {
    //            return YES;
    //        }
    //        else if ( [object isKindOfClass:[self class]] ) {
    //            return [self isEqualToRange:object];
    //        }
    //        else {
    //            return false
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
    
    
}
