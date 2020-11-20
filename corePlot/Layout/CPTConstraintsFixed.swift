//
//  CPTConstraintsFixed.swift
//  corePlot
//
//  Created by thierryH24 on 11/11/2020.
//

import Cocoa

class CPTConstraintsFixed: CPTConstraints {
    
    static let shared = CPTConstraintsFixed()
    
    var  offset = CGFloat(0)
    var  isFixedToLower = false
    
    // MARK: Init/Dealloc
    init () {
        offset = CGFloat(0)
    }
    
    func initWithLowerOffset(newOffset: CGFloat)
    {
        offset         = newOffset;
        isFixedToLower = true;
    }
    
    func initWithUpperOffset( newOffset : CGFloat)
    {
        offset         = newOffset
        isFixedToLower = false
    }
    
    //MARK: Comparison
    override func isEqualToConstraint(otherConstraint: CPTConstraints) -> Bool
    {
        if ( otherConstraint is CPTConstraintsFixed ) == false {
            return false
        }
        let _otherConstraint = otherConstraint as! CPTConstraintsFixed
        return (self.offset == _otherConstraint.offset) &&
            (self.isFixedToLower == _otherConstraint.isFixedToLower);
    }
    
    //MARK: Positioning
    override func positionFor( lowerBound: CGFloat, upperBound: CGFloat) -> CGFloat
    {
        assert(lowerBound <= upperBound, "lowerBound must be less than or equal to upperBound")

        var  position = CGFloat(0)

        if  self.isFixedToLower == true {
            position = lowerBound + self.offset;
        }
        else {
            position = upperBound - self.offset;
        }
        return position
    }
}
