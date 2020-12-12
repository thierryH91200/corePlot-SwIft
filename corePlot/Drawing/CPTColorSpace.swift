//
//  CPTColorSpace.swift
//  corePlot
//
//  Created by thierryH24 on 13/11/2020.
//

import AppKit

class CPTColorSpace: NSObject {
    
    
    var cgColorSpace : CGColorSpace?
    
    
//    +(nonnull instancetype)genericRGBSpace
//{
//static CPTColorSpace *space      = nil;
//
//dispatch_once(&onceToken, ^{
//CGColorSpaceRef cgSpace = NULL;
//#if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
//cgSpace = CGColorSpaceCreateDeviceRGB();
//#else
//cgSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
//#endif
//space = [[self alloc] initWithCGColorSpace:cgSpace];
//CGColorSpaceRelease(cgSpace);
//});

//return space;
//}

//    +(nonnull instancetype)genericRGBSpace
//    {
//        static CPTColorSpace *space      = nil;
//        static dispatch_once_t onceToken = 0;
//
//        dispatch_once(&onceToken, ^{
//            CGColorSpaceRef cgSpace = NULL;
//    #if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
//            cgSpace = CGColorSpaceCreateDeviceRGB();
//    #else
//            cgSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
//    #endif
//            space = [[self alloc] initWithCGColorSpace:cgSpace];
//            CGColorSpaceRelease(cgSpace);
//        });
//
//        return space;
//    }
    
    override init()
    {
        let cgSpace = CGColorSpace(name: CGColorSpace.sRGB)
        super.init()
        super.init(colorSpace: cgSpace)

    }
    
    init(colorSpace: CGColorSpace)
    {
        cgColorSpace = colorSpace;
    }
}

