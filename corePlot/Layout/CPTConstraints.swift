//
//  CPTConstraints.swift
//  corePlot
//
//  Created by thierryH24 on 11/11/2020.
//

import AppKit

class CPTConstraints: NSObject {
    
    //MARK: Factory methods
    class func constraint(withLowerOffset newOffset: CGFloat) -> Self {
        return CPTConstraintsFixed(lowerOffset: newOffset)
    }

    class func constraint(withUpperOffset newOffset: CGFloat) -> Self {
        return CPTConstraintsFixed(upperOffset: newOffset)
    }

    class func constraint(withRelativeOffset newOffset: CGFloat) -> Self {
        return CPTConstraintsRelative.shared.initWithRelativeOffset(newOffset: newOffset)
    }
    
    
    
    //MARK: Init/Dealloc
    init( lowerOffset : CGFloat)
    {
        CPTConstraintsFixed.shared.initWithLowerOffset (newOffset : lowerOffset)
    }
    
    init( upperOffset : CGFloat)
    {
        CPTConstraintsFixed.shared.initWithUpperOffset (newOffset : upperOffset)
    }
    
    init( relativeOffset : CGFloat)
    {
        CPTConstraintsRelative.shared.initWithRelativeOffset(newOffset: relativeOffset)
    }
    
    //MARK: Comparison
    func isEqualToConstraint(otherConstraint: CPTConstraints) -> Bool
    {
        return super.isEqual(otherConstraint)
    }
    
    // MARK: Positioning
    func positionFor(lowerBound : CGFloat, upperBound: CGFloat) -> CGFloat
    {
        return CGFloat.nan
    }
    
}
