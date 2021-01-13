//
//  CPTConstraintsRelative.swift
//  corePlot
//
//  Created by thierryH24 on 11/11/2020.
//

import AppKit

class CPTConstraintsRelative: CPTConstraints {
    
    static let shared = CPTConstraintsRelative()
    var  offset = CGFloat(0)
    
    
    // MARK: Init/Dealloc
    init () {
        offset = CGFloat(0)
    }
    
    func initWithRelativeOffset(newOffset : CGFloat)
    {
        offset = newOffset;
    }
    
    override func isEqualToConstraint(  otherConstraint : CPTConstraints) -> Bool
    {
        if ( otherConstraint is CPTConstraintsRelative ) == false{
            return false;
        }
        let _otherConstraint = otherConstraint as! CPTConstraintsRelative
        return self.offset == _otherConstraint.offset;
    }
    
    
    
    // MARK: Positioning
    override func positionFor(lowerBound : CGFloat, upperBound:CGFloat)-> CGFloat
    {
        assert(lowerBound <= upperBound, "lowerBound must be less than or equal to upperBound")
        
        let position = fma(upperBound - lowerBound, self.offset, lowerBound);
        return position;
    }



    
    
}
