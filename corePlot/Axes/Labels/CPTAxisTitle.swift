//
//  CPTAxisTitle.swift
//  corePlot
//
//  Created by thierryH24 on 16/11/2020.
//

import AppKit

class CPTAxisTitle: CPTAxisLabel {
    
    override init(layer: CPTLayer)
    {
        super.init(layer: layer)
        self.rotation = CGFloat.nan
    }
    
    
    // MARK: Comparison
    
    /** @brief Returns a boolean value that indicates whether the received is equal to the given object.
     *  Axis titles are equal if they have the same @ref tickLocation, @ref rotation, and @ref contentLayer.
     *  @param object The object to be compared with the receiver.
     *  @return @YES if @par{object} is equal to the receiver, @false otherwise.
     **/
    func isEqual(object :Any)->Bool
    {
        if ( self == object ) {
            return true
        }
        else if (object is CPTAxisTitle) == true {
            var otherTitle = object as! CPTAxisTitle
            
            if ((self.rotation != otherTitle.rotation) || (self.offset != otherTitle.offset)) {
                return false;
            }
            if self.contentLayer.isEqual(otherTitle ) == false {
                return false;
            }
            
            let location = (object as! CPTAxisLabel).tickLocation;
            
            if ( location ) {
                return [self.tickLocation isEqualToNumber:location];
            }
            else {
                return false;
            }
        }
        else {
            return false;
        }
    }
    
    /// @}
    
    /// @cond
    
    //    -(NSUInteger)hash
    //    {
    //    NSUInteger hashValue = 0;
    //
    //    // Equal objects must hash the same.
    //    double tickLocationAsDouble = self.tickLocation.doubleValue;
    //
    //    if ( !isnan(tickLocationAsDouble)) {
    //    hashValue = (NSUInteger)lrint(fmod(ABS(tickLocationAsDouble), (double)NSUIntegerMax));
    //    }
    //    hashValue += (NSUInteger)lrint(fmod(ABS(self.rotation), (double)NSUIntegerMax));
    //    hashValue += (NSUInteger)lrint(fmod(ABS(self.offset), (double)NSUIntegerMax));
    //
    //    return hashValue;
    //    }
    
}
