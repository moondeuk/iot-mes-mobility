//
//  MqttConnection.swift
//  PuckStation
//
//  Created by 문득룡 on 6/10/16.
//  Copyright © 2016 문득룡. All rights reserved.
//

import UIKit

class Connection: NSObject, NSCoding {
    
    // MARK: Properties
    var connectionId: Int
    var connectionName: String
    var hostName: String
    var port: Int
    var keepAlive: Int
    var isConnected: Bool
    
    // MARK: Types
    struct ProductKey {
        static let connectionIdKey = "connectionId"
        static let connectionNameKey = "connectionName"
        static let hostNameKey = "hostName"
        static let portKey = "port"
        static let keepAliveKey = "keepAlive"
        static let cliendIdKey = "cliendId"
    }
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("connections")
    
    // MARK: Initialization
    
    init?(connectionId:Int, connectionName:String, hostName:String, port:Int, keepAlive:Int){
        self.connectionId = connectionId
        self.connectionName = connectionName
        self.hostName = hostName
        self.port = port
        self.keepAlive = keepAlive
        self.isConnected = false
        
        super.init()
        
        if connectionId < 0 || connectionName.isEmpty || hostName.isEmpty || port < 0 || keepAlive < 0 {
            return nil
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(connectionId, forKey: ProductKey.connectionIdKey)
        aCoder.encodeObject(connectionName, forKey: ProductKey.connectionNameKey)
        aCoder.encodeObject(hostName, forKey: ProductKey.hostNameKey)
        aCoder.encodeObject(port, forKey: ProductKey.portKey)
        aCoder.encodeObject(keepAlive, forKey: ProductKey.keepAliveKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let connectionId = aDecoder.decodeObjectForKey(ProductKey.connectionIdKey) as! Int
        let connectionName = aDecoder.decodeObjectForKey(ProductKey.connectionNameKey) as! String
        let hostName = aDecoder.decodeObjectForKey(ProductKey.hostNameKey) as! String
        let port = aDecoder.decodeObjectForKey(ProductKey.portKey) as! Int
        let keepAlive = aDecoder.decodeObjectForKey(ProductKey.keepAliveKey) as! Int
        
        self.init(connectionId: connectionId, connectionName: connectionName, hostName: hostName, port: port, keepAlive: keepAlive)
    }
    
    
    
}