//
//  CPTAxisTitle.swift
//  corePlot
//
//  Created by thierryH24 on 16/11/2020.
//

//==============================
//  OK
// 18/12/20
//==============================

import AppKit

public class CPTAxisTitle: CPTAxisLabel {
    
    override init(layer: Any)
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
    
    // https://stackoverflow.com/questions/24022874/custom-equality-in-swift-objects-preserving-compatibility-with-legacy-objective
    override public func isEqual(_ object :Any?)->Bool
    {
        if ( self == object as? CPTAxisTitle) {
            return true
        }
        else if (object is CPTAxisTitle) == true {
            let otherTitle = object as! CPTAxisTitle
            
            if ((self.rotation != otherTitle.rotation) || (self.offset != otherTitle.offset)) {
                return false;
            }
            if self.contentLayer.isEqual(otherTitle ) == false {
                return false
            }
            
            let location = (object as! CPTAxisLabel).tickLocation;
            
            if location != 0 {
                return self.tickLocation == location
            }
            else {
                return false;
            }
        }
        else {
            return false;
        }
    }
    
    static func == (lhs: CPTAxisTitle, rhs: CPTAxisTitle) -> Bool {
        return lhs.rotation == rhs.rotation //&& lhs.height == rhs.height
    }
    
    override public var hash: Int {
        return rotation.hashValue
    }
}
    
