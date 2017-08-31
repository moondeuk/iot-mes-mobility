//
//  MqttConnection.swift
//  PuckStation
//
//  Created by 문득룡 on 6/10/16.
//  Copyright © 2016 문득룡. All rights reserved.
//

import UIKit

class Settings: NSObject, NSCoding {
    
    // MARK: Properties
    var clientId: String
    var subscribeTopic: String
    var publishTopic: String
    var beaconEnabled: Bool
    var beaconUuid: String
    var beaconMajor: String
    var beaconMinor: String

    
    // MARK: Types
    struct ProductKey {
        static let clientIdKey = "clientId"
        static let subscribeTopicKey = "subscribeTopic"
        static let publishTopicKey = "publishTopic"
        static let beaconEnabledKey = "beaconEnabled"
        static let beaconUuidKey = "beaconUuid"
        static let beaconMajorKey = "beaconUuidMajor"
        static let beaconMinorKey = "beaconUuidMinor"
  
    }
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("settings")
    
    // MARK: Initialization
    
    init?(clientId:String?, subscribeTopic:String?, publishTopic:String?, beaconEnabled:Bool?, beaconUuid:String?, beaconMajor:String?, beaconMinor:String?){
        
       
        self.clientId = clientId!

        self.publishTopic = publishTopic!
       
        self.subscribeTopic = subscribeTopic!
    
        
        if beaconEnabled != nil {
            self.beaconEnabled = beaconEnabled!
        }
        else{
            self.beaconEnabled = false
        }

        if beaconUuid != nil {
            self.beaconUuid = beaconUuid!
        }
        else{
            self.beaconUuid = ""
        }

        if beaconMajor != nil {
            self.beaconMajor = beaconMajor!
        }
        else{
            self.beaconMajor = ""
        }

        if beaconMinor != nil {
            self.beaconMinor = beaconMinor!
        }
        else{
            self.beaconMinor = ""
        }

        
        super.init()
        
        if clientId!.isEmpty || subscribeTopic!.isEmpty || publishTopic!.isEmpty {
            return nil
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(clientId, forKey: ProductKey.clientIdKey)
        aCoder.encodeObject(subscribeTopic, forKey: ProductKey.subscribeTopicKey)
        aCoder.encodeObject(publishTopic, forKey: ProductKey.publishTopicKey)
        aCoder.encodeObject(beaconEnabled, forKey: ProductKey.beaconEnabledKey)
        aCoder.encodeObject(beaconUuid, forKey: ProductKey.beaconUuidKey)
        aCoder.encodeObject(beaconMajor, forKey: ProductKey.beaconMajorKey)
        aCoder.encodeObject(beaconMinor, forKey: ProductKey.beaconMinorKey)

    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let clientId = aDecoder.decodeObjectForKey(ProductKey.clientIdKey) as! String
        let subscribeTopic = aDecoder.decodeObjectForKey(ProductKey.subscribeTopicKey) as! String
        let publishTopic = aDecoder.decodeObjectForKey(ProductKey.publishTopicKey) as! String
        let beaconEnabled = aDecoder.decodeObjectForKey(ProductKey.beaconEnabledKey) as? Bool
        let beaconUuid = aDecoder.decodeObjectForKey(ProductKey.beaconUuidKey) as? String
        let beaconMajor = aDecoder.decodeObjectForKey(ProductKey.beaconMajorKey) as? String
        let beaconMinor = aDecoder.decodeObjectForKey(ProductKey.beaconMinorKey) as? String

  
        
        self.init(clientId: clientId, subscribeTopic: subscribeTopic, publishTopic: publishTopic, beaconEnabled:beaconEnabled, beaconUuid:beaconUuid, beaconMajor:beaconMajor, beaconMinor:beaconMinor)
    }
    
    
    
}