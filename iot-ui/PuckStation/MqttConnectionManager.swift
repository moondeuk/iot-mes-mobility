//
//  ConnectionManager.swift
//  PuckStation
//
//  Created by 문득룡 on 6/12/16.
//  Copyright © 2016 문득룡. All rights reserved.
//

import Foundation
import Moscapsule



class MqttConnectionManager: NSObject {
    var mqttClientsDictionary : [Int:MQTTClient] = [:]
    var connections = [Connection]()
    var settings : Settings!
    var initFlag = false
    var isConnectionEnabled = false
    
    
    override init() {
        super.init()
        if let savedConnections = loadConnections() {
            connections = savedConnections
        }
        
        
        if !initFlag {
            initFlag = true
            moscapsule_init()
        }
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.didConnectionInfoChanged(_:)), name: connectionTableViewControllerDidConnectionTableChangedNotification, object: nil   )
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.didConnectionInfoRemoved(_:)), name: connectionTableViewControllerDidConnectionTableRemovedNotification, object: nil   )
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.didSettingsChanged(_:)), name: settingsViewControllerDidSettingChangedNotification, object: nil   )
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.didPublishRequested(_:)), name: mainViewControllerDidPublishRequestedNotification, object: nil   )
        
        if let savedSettings = loadSettings() {
            settings = savedSettings
            startConnections()
        }
        
    }
    
    func didPublishRequested(notification: NSNotification){
        let barcodeData = notification.userInfo![mainViewControllerBarcodeDataKey] as! String
        let jsonData = "{\"barcodeData\":\"" + barcodeData + "\",\"clientId\":\"" + self.settings.clientId + "\"}"
        for (_, mqttClient) in self.mqttClientsDictionary {
            mqttClient.publishString(jsonData, topic: self.settings.publishTopic, qos: 2, retain: false)
        }

    }
    
    func didSettingsChanged(notification: NSNotification){
        stopConnections()
        startConnections()
    }
    
    func didConnectionInfoChanged(notification: NSNotification){
        let changedConnection = notification.userInfo![connectionManagerUserInfoConnectionKey] as! Connection
        var connectionIndex = -1
        
        for (index, connection) in connections.enumerate() {
            if(connection.connectionId == changedConnection.connectionId){
                connections[index] = changedConnection
                connectionIndex = index
            }
        }
        if connectionIndex < 0 {
            connections.append(changedConnection)
        }
        
        stopConnection(changedConnection)
        startConnection(changedConnection)
        
        NSNotificationCenter.defaultCenter().postNotificationName(connectionManagerDidConnectionStatusChangedNotification, object: self, userInfo: [connectionManagerUserInfoConnectionsKey: self.connections])
    }
    
    func didConnectionInfoRemoved(notification: NSNotification){
        let removedConnection = notification.userInfo![connectionManagerUserInfoConnectionKey] as! Connection
        
        for (index, connection) in connections.enumerate() {
            if(connection.connectionId == removedConnection.connectionId){
                connections.removeAtIndex(index)
            }
        }
        
        stopConnection(removedConnection)
        
        NSNotificationCenter.defaultCenter().postNotificationName(connectionManagerDidConnectionStatusChangedNotification, object: self, userInfo: [connectionManagerUserInfoConnectionsKey: self.connections])
    }
    
    func startConnections(){
        for connection in connections {
            startConnection(connection)
        }
    }
    
    func startConnection(connection: Connection){
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {[unowned self] in
            
        
            let clientId = "\(self.settings.clientId)-\(connection.connectionId)"
            
            //XCTAssertTrue(clientId.characters.count > Int(MOSQ_MQTT_ID_MAX_LENGTH))
            let mqttConfig = MQTTConfig(clientId: clientId, host: connection.hostName, port: Int32(connection.port), keepAlive: Int32(connection.keepAlive))
            
            mqttConfig.onConnectCallback = { returnCode in
                NSLog("Return Code is \(returnCode.description) (this callback is declared in swift.)")
                connection.isConnected = true
                NSNotificationCenter.defaultCenter().postNotificationName(connectionManagerDidConnectionStatusChangedNotification, object: self, userInfo: [connectionManagerUserInfoConnectionsKey: self.connections])
                
                self.mqttClientsDictionary[connection.connectionId]?.subscribe(self.settings.subscribeTopic, qos: 2)
                
            }
            mqttConfig.onDisconnectCallback = { reasonCode in
                NSLog("Reason Code is \(reasonCode.description) (this callback is declared in swift.)")
                connection.isConnected = false
                NSNotificationCenter.defaultCenter().postNotificationName(connectionManagerDidConnectionStatusChangedNotification, object: self, userInfo: [connectionManagerUserInfoConnectionsKey: self.connections])
            }
            
            mqttConfig.onMessageCallback = { mqttMessage in
                NSLog("MQTT Message received: payload=\(mqttMessage.payloadString)")
                
                do {
                    if let jsonResult = try NSJSONSerialization.JSONObjectWithData(mqttMessage.payload, options: [.MutableContainers, .AllowFragments]) as? NSDictionary {
                        
                        NSNotificationCenter.defaultCenter().postNotificationName(connectionManagerDidReceivedMessageNotification, object: self, userInfo: [connectionManagerUserInfoMessageJsonKey: jsonResult])
                    }
                }
                catch{
                    NSLog("Error on mqtt message callback: \(error)")
                }
                
            }
            
            let mqttClient = MQTT.newConnection(mqttConfig)
            
            
            //mqttClient.subscribe(self.settings.subscribeTopic, qos: 2)
            
            self.mqttClientsDictionary.updateValue(mqttClient, forKey: connection.connectionId)
        }
    }
    
    func loadConnections() -> [Connection]?{
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Connection.ArchiveURL.path!) as? [Connection]
    }
    
    func loadSettings() -> Settings?{
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Settings.ArchiveURL.path!) as? Settings
    }
    
    func stopConnections(){
        
        for mqttClient in mqttClientsDictionary.values { // loop through data items
            mqttClient.disconnect()
        }
        
        mqttClientsDictionary.removeAll()
    }
    
    func stopConnection(connection: Connection){
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {[unowned self] in

            if let mqttClient = self.mqttClientsDictionary[connection.connectionId] {
                if(mqttClient.isConnected){
                    mqttClient.disconnect()
                }
                
                self.mqttClientsDictionary.removeValueForKey(connection.connectionId)
            }
        }
    }

}

