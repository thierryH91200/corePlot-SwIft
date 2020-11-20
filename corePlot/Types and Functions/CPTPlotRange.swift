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

}
