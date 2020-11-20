//
//  CPTImagePlatformSpecific.swift
//  corePlot
//
//  Created by thierryH24 on 18/11/2020.
//

import AppKit


extension CPTImage {

    convenience init(nativeImage anImage: CPTNativeImage?) {
        self.init()
        nativeImage = anImage
    }

    convenience init(for path: String) {
        var imageScale = CGFloat(1.0)

        // Try to load @2x file if the system supports hi-dpi display
        let newNativeImage = NSImage()
        var imageRep: NSImageRep? = nil

        for screen in NSScreen.screens {
            imageScale = CGFloat(max(imageScale, screen.backingScaleFactor))
        }

        while imageScale > CGFloat(1.0) {
            var hiDpiPath = path
            let replaceCount = if let subRange = Range<String.Index>(NSRange(location: hiDpiPath.count - 4, length: 4), in: hiDpiPath) { hiDpiPath = hiDpiPath.replacingOccurrences(of: ".png", with: String(format: "@%dx.png", Int(imageScale)), options: [.caseInsensitive, .backwards, .anchored], range: subRange) }
            if replaceCount == 1 {
                imageRep = NSImageRep(contentsOfFile: hiDpiPath)
                if let imageRep = imageRep {
                    newNativeImage.addRepresentation(imageRep)
                }
            }
            imageScale -= CGFloat(1.0)
        }

        imageRep = NSImageRep(contentsOfFile: path)
        if let imageRep = imageRep {
            newNativeImage.addRepresentation(imageRep)
        }
        self.init(nativeImage: newNativeImage)
    }
    
}

