//
//  CPTPlot cacheArray.swift
//  corePlot
//
//  Created by thierryH24 on 01/01/2021.
//

import Foundation

extension CPTPlot {
    
    func cachedValueForKey(key : String, recordIndex idx:Int)-> Any?
    {
        return cachedArray(forKey: key)?[idx]
    }
    
    func cachedArray(forKey key: String) -> [Any]? {
        return cachedData[key]
    }
    
    func cacheArray(_ array: [Any], forKey key: String) {
        let sampleCount = array.count
        if sampleCount > 0 {
            cachedData[key] = array
        } else {
            cachedData.removeValue( forKey : key)
        }
        cachedDataCount = sampleCount
    }

    // cachedValues = array
    // cachedData: [String : [Any]] = [:]
    func cacheArray(array: [Any], forKey key: String, atRecordIndex idx: Int)
    {
        let sampleCount = array.count
        if sampleCount > 0 {
            
            // Ensure the data cache exists and is the right size
            weak var theDataSource = self.dataSource
            let numberOfRecords = theDataSource?.numberOfRecordsForPlot(plot: self)
            
            var cachedValues = self.cachedData[key]
            
            if cachedValues!.isEmpty == false {
                
                cachedValues = [String](repeating: "Any", count: numberOfRecords!)
                let nullObject : String?
                
                for _ in 0..<numberOfRecords! {
                    cachedValues!.append( nullObject!)
                }
                self.cachedData[key] = cachedValues! as [Any]
            }
            
            // Update the cache
            self.cachedDataCount = numberOfRecords!
            let dataArray = array
            
//   [cachedValues replaceObjectsInRange:NSMakeRange(idx, sampleCount)  withObjectsFromArray:dataArray];
            
            for (index, value) in dataArray.enumerated() {
                cachedValues![index] = value
            }
        }
    }
}
