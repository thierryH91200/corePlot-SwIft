//
//  CPTAxis autoMajor.swift
//  corePlot
//
//  Created by thierryH24 on 07/12/2020.
//

import Foundation


extension CPTAxis {
    
    func autoGenerateMajorTickLocations(newMajorLocations :CPTFloatSet, newMinorLocations:CPTFloatSet)
    {
        var newMajorLocations = newMajorLocations
        var newMinorLocations = newMinorLocations
        
        // Create sets for locations
        var majorLocations = CPTFloatSet()
        var minorLocations = CPTFloatSet()
        
        // Get plot range
        var range    = self.plotSpace.plotRangeForCoordinate(coordinate)
        var theVisibleRange = self.visibleRange;
        
        if (theVisibleRange != nil)  {
            range.intersectionPlotRange(theVisibleRange)
        }
        
        // Validate scale type
        var valid             = true
        let scaleType = self.plotSpace?.scaleTypeForCoordinate(coordinate: self.coordinate)
        
        switch ( scaleType ) {
        case .linear:
            // supported scale type
            break;
            
        case .log:
            // supported scale type--check range
            if ((range.minLimitDouble <= 0.0) || (range.maxLimitDouble <= 0.0)) {
                valid = false
            }
            break;
            
        case .logModulus:
            // supported scale type
            break;
            
        default:
            // unsupported scale type--bail out
            valid = false
            break;
        }
        
        if ( valid == false) {
            newMajorLocations = majorLocations;
            newMinorLocations = minorLocations;
            return;
        }
        
        // Cache some values
        var numTicks   = self.preferredNumberOfMajorTicks;
        let minorTicks = self.minorTicksPerInterval + 1;
        let length         = fabs(range.lengthDouble);
        
        // Filter troublesome values and return empty sets
        if ((length != 0.0) && !isinf(length)) {
            switch ( scaleType ) {
            case .linear:
                
                // Determine interval value
                switch ( numTicks ) {
                case 0:
                    numTicks = 5;
                    break;
                    
                case 1:
                    numTicks = 2;
                    break;
                    
                default:
                    // ok
                    break;
                }
                
                let zero = CGFloat(0.0)
                let one  = 1.0
                
                var majorInterval = CGFloat(0.0)
                if ( numTicks == 2 ) {
                    majorInterval = CGFloat(0.0)
//                    majorInterval = CPTNiceLength(range.lengthDecimal);
                }
                else {
                    majorInterval = range.lengthDecimal / abs(numTicks - 1)
//                    majorInterval = CPTNiceNum(x: majorInterval);
                }
                if majorInterval < zero {
                    majorInterval = majorInterval * (-1)
                }
                
                var minorInterval = CGFloat(0.0)
                if ( minorTicks > 1 ) {
                    minorInterval = majorInterval / abs(minorTicks)
                }
                else {
                    minorInterval = zero
                }
                
                // Calculate actual range limit
                let minLimit = range.minLimitDecimal;
                let maxLimit = range.maxLimitDecimal
                
                // Determine the initial and final major indexes for the actual visible range
                var initialIndex = CGFloat(minLimit / majorInterval)
                
                initialIndex = initialIndex.roundDown(0)
                
                let finalIndex = maxLimit / majorInterval
                finalIndex = finalIndex.roundDown(0)
                
                // Iterate through the indexes with visible ticks and build the locations sets
                for i in initialIndex..<finalIndex {
                    
                    let pointLocation      = majorInterval * i
                    let minorPointLocation = pointLocation
                    
                    for  j in 1..<minorTicks {
                        minorPointLocation = minorPointLocation + minorInterval
                        
                        if minorPointLocation < minLimit {
                            continue;
                        }
                        if minorPointLocation > maxLimit {
                            continue;
                        }
                        minorLocations.addObject(minorPointLocation)
                    }
                    
                    if pointLocation < minLimit {
                        continue
                    }
                    if pointLocation > maxLimit {
                        continue
                    }
                    majorLocations.addObject(pointLocation)
                }
                
                break;
                
            case .log:
                
                let minLimit = range.minLimitDouble;
                let maxLimit = range.maxLimitDouble;
                
                if ((minLimit > 0.0) && (maxLimit > 0.0)) {
                    // Determine interval value
                    length = log10(maxLimit / minLimit);
                    
                    let interval     = signbit(length) ? -1.0 : 1.0;
                    let intervalStep = pow(10.0, fabs(interval));
                    
                    // Determine minor interval
                    let minorInterval = intervalStep * 0.9 * pow(10.0, floor(log10(minLimit))) / minorTicks;
                    
                    // Determine the initial and final major indexes for the actual visible range
                    let initialIndex = lrint(floor(log10(minLimit / fabs(interval)))) // can be negative
                    let finalIndex   = lrint(ceil(log10(maxLimit / fabs(interval))))  // can be negative
                    
                    // Iterate through the indexes with visible ticks and build the locations sets
                    for i in initialIndex..<finalIndex + 1 {
                        
                        let pointLocation = pow(10.0, i * interval);
                        
                        for j in 1..<minorTicks {
                            
                            let minorPointLocation = pointLocation + minorInterval * j
                            
                            if ( minorPointLocation < minLimit ) {
                                continue;
                            }
                            if ( minorPointLocation > maxLimit ) {
                                continue;
                            }
                            minorLocations.addObject(minorPointLocation)
                        }
                        minorInterval *= intervalStep;
                        
                        if ( pointLocation < minLimit ) {
                            continue
                        }
                        if ( pointLocation > maxLimit ) {
                            continue
                        }
                        majorLocations.addObject(pointLocation)
                    }
                }
                
                break;
                
            case .logModulus:
                
                let minLimit = range.minLimitDouble;
                let maxLimit = range.maxLimitDouble;
                
                // Determine interval value
                let modMinLimit = CPTLogModulus(minLimit);
                let modMaxLimit = CPTLogModulus(maxLimit);
                
                let multiplier = pow(10.0, floor(log10(length)));
                multiplier = (multiplier < 1.0) ? multiplier : 1.0;
                
                let intervalStep = 10.0;
                
                // Determine the initial and final major indexes for the actual visible range
                var initialIndex = lrint(floor(modMinLimit / multiplier)); // can be negative
                var finalIndex   = lrint(ceil(modMaxLimit / multiplier));  // can be negative
                
                if ( initialIndex < 0 ) {
                    // Determine minor interval
                    let minorInterval = intervalStep * 0.9 * multiplier / minorTicks;
                    
                    let mini = min(0, finalIndex)
                    
                    for i in stride(from: mini, to: initialIndex, by: -1) {
                        
                        //                    for ( i = mini; i >= initialIndex; i-- ) {
                        var pointLocation = 0.0
                        var sign = -multiplier;
                        
                        if ( multiplier < 1.0 ) {
                            pointLocation = sign * pow(10.0, fabs((double(i)) - 1.0))
                        }
                        else {
                            pointLocation = sign * pow(10.0, fabs(double(i)))
                        }
                        
                        for j in 1..<minorTicks {
                            let minorPointLocation = pointLocation + sign * minorInterval * j;
                            if ( minorPointLocation < minLimit ) {
                                continue
                            }
                            if ( minorPointLocation > maxLimit ) {
                                continue
                            }
                            minorLocations.addObject(minorPointLocation)
                        }
                        minorInterval *= intervalStep;
                        
                        if ( i == 0 ) {
                            pointLocation = 0.0;
                        }
                        if ( pointLocation < minLimit ) {
                            continue
                        }
                        if ( pointLocation > maxLimit ) {
                            continue;
                        }
                        majorLocations.addObject(pointLocation)
                    }
                }
                
                if ( finalIndex >= 0 ) {
                    // Determine minor interval
                    let minorInterval = intervalStep * 0.9 * multiplier / minorTicks;
                    
                    let maxi = max(0, initialIndex)
                    for i in maxi..<finalIndex + 1 {
                        var pointLocation = 0
                        var sign = multiplier;
                        
                        if ( multiplier < 1.0 ) {
                            pointLocation = sign * pow(10.0, fabs((double(i)) - 1.0))
                        }
                        else {
                            pointLocation = sign * pow(10.0, fabs(double(i)))
                        }
                        
                        for   j in 1..<minorTicks {
                            
                            var minorPointLocation = pointLocation + sign * minorInterval * j
                            if ( minorPointLocation < minLimit ) {
                                continue;
                            }
                            if ( minorPointLocation > maxLimit ) {
                                continue;
                            }
                            minorLocations.addObject(minorPointLocation)
                        }
                        minorInterval *= intervalStep
                        
                        if ( i == 0 ) {
                            pointLocation = 0.0;
                        }
                        if ( pointLocation < minLimit ) {
                            continue;
                        }
                        if ( pointLocation > maxLimit ) {
                            continue;
                        }
                        majorLocations.addObject(pointLocation)
                    }
                    break
                    
                }
            default:
                break
                
            }
        }
    }
    
    
    func  CPTLogModulus(value: Double )-> Double
    {
        if ( value != 0.0 ) {
            let sign = ((value.signbit()) ? -1.0 : +1.0);
            
            return sign * log10(fabs(value) + 1.0);
        }
        else {
            return 0.0;
        }
    }
    
//    NSDecimal CPTNiceNum(NSDecimal x)
//    {
//        NSDecimal zero = CPTDecimalFromInteger(0);
//
//        if ( CPTDecimalEquals(x, zero)) {
//            return zero;
//        }
//
//        NSDecimal minusOne = CPTDecimalFromInteger(-1);
//
//        BOOL xIsNegative = CPTDecimalLessThan(x, zero);
//
//        if ( xIsNegative ) {
//            x = CPTDecimalMultiply(x, minusOne);
//        }
//
//        short exponent = (short)lrint(floor(log10(CPTDecimalDoubleValue(x))));
//
//        NSDecimal fractionPart;
//
//        NSDecimalMultiplyByPowerOf10(&fractionPart, &x, -exponent, NSRoundPlain);
//
//        NSDecimal roundedFraction;
//
//        if ( CPTDecimalLessThan(fractionPart, CPTDecimalFromDouble(1.5))) {
//            roundedFraction = CPTDecimalFromInteger(1);
//        }
//        else if ( CPTDecimalLessThan(fractionPart, CPTDecimalFromInteger(3))) {
//            roundedFraction = CPTDecimalFromInteger(2);
//        }
//        else if ( CPTDecimalLessThan(fractionPart, CPTDecimalFromInteger(7))) {
//            roundedFraction = CPTDecimalFromInteger(5);
//        }
//        else {
//            roundedFraction = CPTDecimalFromInteger(10);
//        }
//
//        if ( xIsNegative ) {
//            roundedFraction = CPTDecimalMultiply(roundedFraction, minusOne);
//        }
//
//        NSDecimal roundedNumber;
//
//        NSDecimalMultiplyByPowerOf10(&roundedNumber, &roundedFraction, exponent, NSRoundPlain);
//
//        return roundedNumber;
//    }
//
//    /**
//     *  @internal
//     *  @brief Determines a @quote{nice} range length (a multiple of @num{2}, @num{5}, or @num{10}) less than or equal to the given length.
//     *  @param length The length to round.
//     */
//
//
//
//
//    NSDecimal CPTNiceLength(NSDecimal length)
//    {
//        NSDecimal zero = CPTDecimalFromInteger(0);
//
//        if ( CPTDecimalEquals(length, zero)) {
//            return zero;
//        }
//
//        NSDecimal minusOne = CPTDecimalFromInteger(-1);
//
//        BOOL isNegative = CPTDecimalLessThan(length, zero);
//
//        if ( isNegative ) {
//            length = CPTDecimalMultiply(length, minusOne);
//        }
//
//        NSDecimal roundedNumber;
//
//        if ( CPTDecimalGreaterThan(length, CPTDecimalFromInteger(10))) {
//            NSDecimalRound(&roundedNumber, &length, 0, NSRoundDown);
//        }
//        else {
//            short exponent = (short)lrint(floor(log10(CPTDecimalDoubleValue(length)))) - 1;
//            NSDecimalRound(&roundedNumber, &length, -exponent, NSRoundDown);
//        }
//
//        if ( isNegative ) {
//            roundedNumber = CPTDecimalMultiply(roundedNumber, minusOne);
//        }
//
//        return roundedNumber;
//    }

    
    
}

extension CGFloat{
    func roundDown(decimals:Int)->CGFloat{
        let from: CGFloat = self
        var to: CGFloat = 0.0
        let k : CGFloat = CGFloat(pow(10.0, Double(decimals))) //k here is 100
        
        let cent = from * k
        let centRound = floor(cent) //get floor (integer) value of this double.You will get 154.
        
        to = centRound/k
        return to
    }
}

