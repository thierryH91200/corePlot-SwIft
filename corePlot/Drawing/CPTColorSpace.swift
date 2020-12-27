//
//  CPTColorSpace.swift
//  corePlot
//
//  Created by thierryH24 on 13/11/2020.
//

import AppKit

class CPTColorSpace: NSObject {
    
    static let shared = CPTColorSpace()
    var cgColorSpace : CGColorSpace?
    
    func genericRGBSpace() -> CPTColorSpace {
        
        var cgSpace: CGColorSpace? = nil
        
        #if targetEnvironment(simulator) || os(iOS)
        cgSpace = CGColorSpaceCreateDeviceRGB()
        #else
        cgSpace = CGColorSpaceCreateDeviceRGB()
        #endif
        let space = CPTColorSpace(cgColorSpace: cgSpace!)
        
        return space!
    }
    
    init?(cgColorSpace colorSpace: CGColorSpace) {
        super.init()
        cgColorSpace = colorSpace
    }
    
    override init()
    {
        //        let cgSpace = CGColorSpace(name: CGColorSpace.sRGB)
        super.init()
        //        super.init(colorSpace: cgSpace)
    }
    
    init(colorSpace: CGColorSpace)
    {
        cgColorSpace = colorSpace;
    }
}

