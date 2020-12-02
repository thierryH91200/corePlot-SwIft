//
//  CPTAxisLabelGroup.swift
//  corePlot
//
//  Created by thierryH24 on 16/11/2020.
//

import Cocoa

class CPTAxisLabelGroup: CPTLayer {

    // MARK: - Drawing

    func dissplay()
    {
        // nothing to draw
    }

    @objc override func renderAsVectorInContext(context:  CGContext)
    {
    }

    // MARK: - Layout
    override func layoutSublayers()
    {
        // do nothing--axis is responsible for positioning its labels
    }

}
