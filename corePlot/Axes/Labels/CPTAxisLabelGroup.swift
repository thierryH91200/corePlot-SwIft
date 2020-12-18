//
//  CPTAxisLabelGroup.swift
//  corePlot
//
//  Created by thierryH24 on 16/11/2020.
//

//==============================
//  OK
// 18/12/20
//==============================


import AppKit

class CPTAxisLabelGroup: CPTLayer {

    // MARK: - Drawing

    override func display()
    {
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
