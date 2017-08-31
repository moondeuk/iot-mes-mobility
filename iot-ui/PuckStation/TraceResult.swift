//
//  TraceResult.swift
//  PuckStation
//
//  Created by 문득룡 on 6/19/16.
//  Copyright © 2016 문득룡. All rights reserved.
//

import Foundation

class TraceResult: NSObject {
    var traceID: String
    var partName: String
    var traceData: String
    var scanTime: String
    var scanResult: String
    var defectDescription: String
    
    init?(traceID:String?, partName:String?, traceData:String?, scanTime:String?, scanResult:String?, defectDescription:String?){
        
        
        self.traceID = traceID!
        
        self.partName = partName!
        
        self.traceData = traceData!
        
        self.scanTime = scanTime!
        
        self.scanResult = scanResult!
        
        self.defectDescription = ""
        if defectDescription != nil {
            self.defectDescription = defectDescription!
        }
        
        super.init()
        
        if traceID!.isEmpty {
            return nil
        }
    }
    
    static func traceResultWithJSON(results: NSDictionary) -> [TraceResult] {
        var traceResults = [TraceResult]()
        
        if results.count>0{
            
            for(_, value) in results as NSDictionary {
                
                if (value["traceId"] as? String) != nil {
                    let traceId = value["traceId"] as? String
                    let partName = value["partName"] as? String
                    let traceData = value["traceData"] as? String
                    let scanTime = value["scanTime"] as? String
                    let scanResult = value["scanResult"] as? String
                    let defectDescription = value["error"] as? String

                    let newTraceResult = TraceResult(traceID: traceId, partName: partName, traceData: traceData, scanTime: scanTime, scanResult: scanResult, defectDescription: defectDescription)
                    
                    traceResults.append(newTraceResult!)
                }
                
            }
            
        }
        
        return traceResults
    }
}