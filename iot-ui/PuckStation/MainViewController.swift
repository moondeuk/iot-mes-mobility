//
//  MainViewController.swift
//  PuckStation
//
//  Created by 문득룡 on 6/12/16.
//  Copyright © 2016 문득룡. All rights reserved.
//

import UIKit
import Moscapsule
import AVFoundation
import CoreBluetooth
import CoreLocation



var connectionManagerDidConnectionStatusChangedNotification = "connectionManagerDidConnectionStatusChangedNotification"
var connectionManagerDidReceivedMessageNotification = "connectionManagerDidReceivedMessagvartification"
var connectionTableViewControllerDidConnectionTableChangedNotification = "connectionTableViewControllerDidConnectionTableChangedNotification"
var connectionTableViewControllerDidConnectionTableRemovedNotification = "connectionTableViewControllerDidConnectionTableRemovedNotification"

var mainViewControllerDidTraceResultButtonTabbedNotification = "mainViewControllerDidTraceResultButtonTabbedNotification"

var settingsViewControllerDidSettingChangedNotification = "settingsViewControllerDidSettingChangedNotification"
var mainViewControllerDidPublishRequestedNotification = "mainViewControllerDidPublishRequestedNotification"
var connectionManagerUserInfoConnectionKey = "connectionManagerUserInfoConnectionKey"
var connectionManagerUserInfoConnectionsKey = "connectionManagerUserInfoConnectionsKey"
var connectionManagerUserInfoMessageJsonKey = "connectionManagerUserInfoMessageJsonKey"
var mainViewControllerBarcodeDataKey = "mainViewControllerBarcodeDataKey"

enum StatusType : String {
    case Error = "Error", Normal = "Normal", Alert = "Alert", Processing = "Processing", Initialized = "Initialized", Complete = "Complete"
    
    static let allValues = [Error, Normal, Alert]
}

class MainViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, CBPeripheralManagerDelegate {

    // MARK: Properties
    
    @IBOutlet weak var stationNameLabel: UILabel!
    
    @IBOutlet weak var pviTextField: UITextField!
    @IBOutlet weak var traceDataTextField: UITextField!
    
    @IBOutlet weak var barcodeScanTextView: UITextView!
    @IBOutlet weak var statusMessageTextView: UITextView!
    @IBOutlet weak var expectedBcTextField: UITextField!
    @IBOutlet weak var vinTextField: UITextField!

    
   
    @IBOutlet weak var statusImage: UIImageView!
    
    @IBOutlet weak var clientIdLabel: UILabel!
    
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!
    
    var myTraceResults: [TraceResult]?
    
    
    
    
    let popViewController : PopUpViewControllerSwift = PopUpViewControllerSwift(nibName: "PopUpViewController", bundle: nil)
    
   
    var initFlag = false
    var mqttConnectionManager : MqttConnectionManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mqttConnectionManager = MqttConnectionManager()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.didReceivedMessage(_:)), name: connectionManagerDidReceivedMessageNotification, object: nil   )
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.didConnectionStatusChanged(_:)), name: connectionManagerDidConnectionStatusChangedNotification, object: nil   )
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.didSettingsChanged(_:)), name: settingsViewControllerDidSettingChangedNotification, object: nil   )
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.didTraceResultButtonTabbed(_:)), name: mainViewControllerDidTraceResultButtonTabbedNotification, object: nil   )

        

        if mqttConnectionManager.settings != nil {
            clientIdLabel.text = mqttConnectionManager.settings.clientId
        }
        
        updateStatusMessageTextView(.Initialized, message: "Client Initialized")
        
        
        // Keep Screen On
        UIApplication.sharedApplication().idleTimerDisabled = true
        
        didBeaconSettingChanged()
  
    }
    
    func didTraceResultButtonTabbed(otification: NSNotification){
        performSegueWithIdentifier("ShowTraceResult", sender: self)
        
    }
    
    func didBeaconSettingChanged(){
        if mqttConnectionManager.settings != nil {
            if let beaconEnabled:Bool? = mqttConnectionManager.settings.beaconEnabled {
                if beaconEnabled == true {
                    initLocalBeacon()
                }
                else{
                    stopLocalBeacon()
                }
            }
        }
    }
    
    func didSettingsChanged(notification: NSNotification){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.clientIdLabel.text = self.mqttConnectionManager.settings.clientId
            self.didBeaconSettingChanged()
        })
    }
    
    func initLocalBeacon() {
        if localBeacon != nil {
            stopLocalBeacon()
        }
        
        let localBeaconUUID = mqttConnectionManager.settings.beaconUuid
        let localBeaconMajor: CLBeaconMajorValue = UInt16(mqttConnectionManager.settings.beaconMajor)!
        let localBeaconMinor: CLBeaconMinorValue = UInt16(mqttConnectionManager.settings.beaconMinor)!
        
       
        if let uuid = NSUUID(UUIDString: localBeaconUUID) {
            localBeacon = CLBeaconRegion(proximityUUID: uuid, major: localBeaconMajor, minor: localBeaconMinor, identifier: "Your private identifer here")
            
            beaconPeripheralData = localBeacon.peripheralDataWithMeasuredPower(-200)
            peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        }
        
    }

    func stopLocalBeacon() {
        
        if localBeacon != nil {
            peripheralManager.stopAdvertising()
            peripheralManager = nil
            beaconPeripheralData = nil
            localBeacon = nil
        }
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if peripheral.state == .PoweredOn {
            peripheralManager.startAdvertising(beaconPeripheralData as! [String: AnyObject]!)
        } else if peripheral.state == .PoweredOff {
            peripheralManager.stopAdvertising()
        }
    }
    
    func didConnectionStatusChanged(notification: NSNotification) {
        var isConnected = true
        if let connections = notification.userInfo?[connectionManagerUserInfoConnectionsKey] as? [Connection] {
            for connection in connections {
                if !connection.isConnected {
                    isConnected = false
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if(isConnected){
                self.statusImage.image = UIImage(named: "Connected")
            }
            else{
                self.statusImage.image = UIImage(named: "Disconnected")
            }
        })
    }
    
    func didEnterDefectStation(stationName: String, pvi: String, vin: String, status: String, traceResults: NSDictionary){
        
        //let popViewController : PopUpViewControllerSwift = PopUpViewControllerSwift(nibName: "PopUpViewController", bundle: nil)
        

        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.popViewController.title = "Defect Station"
            self.popViewController.showInView(self.view, withStationName:stationName, withPvi:pvi, withVin:vin, withShipToOk: status, withTraceResults: traceResults, animated: true)
        })
    }

    
    func didReceivedMessage(notification: NSNotification) {
        if let jsonResult = notification.userInfo?[connectionManagerUserInfoMessageJsonKey] as? NSDictionary {
            updateFields(jsonResult)
        }
    }

    
    func updateFields(jsonResult: NSDictionary){
        
        if let command: String = jsonResult["command"] as? String {
            
        
           if command == "new-defect-station-entered" || command == "new-inspector-entered" {
                if let stationInfo: NSDictionary = (jsonResult["stationInfo"] as? NSDictionary)!{
                    
                    let stationName = stationInfo["stationName"] as? String
                    let pvi = stationInfo["pvi"] as? String
                    let vin = stationInfo["vin"] as? String
                    
           
                    let traceResults: NSDictionary? = jsonResult["traceResults"] as? NSDictionary
                    let status = (traceResults!["status"] as? String)!
                    
                    
                
                    
                    myTraceResults = TraceResult.traceResultWithJSON(traceResults!)

                
                    if stationName != nil && pvi != nil {
                        didEnterDefectStation(stationName!, pvi: pvi!, vin: vin!, status: status, traceResults: traceResults!)
                    }
                    
                }
            
            
            }
            
            
            else if command == "new-station-entered"{
                
                if let stationInfo: NSDictionary = jsonResult["stationInfo"] as? NSDictionary {
                    
                    if let stationName: String = stationInfo["stationName"] as? String {
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            self.stationNameLabel.text = stationName
                            
                        })
                    }
                    
                    if let pvi: String = stationInfo["pvi"] as? String {
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            self.pviTextField.text = pvi
                            
                        })
                    }
                    
                    if let vin: String = stationInfo["vin"] as? String {
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            self.vinTextField.text = vin
                            
                        })
                    }
                    
                    
                    if let expectedBroadcastCode: String = stationInfo["expectedBroadcastcode"] as? String {
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            self.expectedBcTextField.text = expectedBroadcastCode
                            
                        })
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.traceDataTextField.text = ""
                        self.barcodeScanTextView.text = ""
                        
                    })
                    

                    self.updateStatusMessageTextView(.Processing, message: "New Station Entered!!!")
                    
                }
                
                
            }
            
            else if command == "trace-data-entered" {
                
                if let barcodeData: String = jsonResult["barcodeData"] as? String {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.barcodeScanTextView.text = barcodeData
                        
                    })
                    
                    self.updateStatusMessageTextView(.Processing, message: "Barcode Data Entered!!!")
                    
                }
                
            }
            
            else if command == "error" {
                
                if let errorMessage: String = jsonResult["errorDescription"] as? String {
                    
                    self.updateStatusMessageTextView(.Error, message: errorMessage)
                }
                
            }
            
            else if command == "tracecomplete" {
                
                if let traceData: String = jsonResult["traceData"] as? String {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.traceDataTextField.text = traceData
                        
                    })
                    self.updateStatusMessageTextView(.Complete, message: "Trace Validation OK!!!!!")
                    
                }
            }
            
        }
        
        
    }
    
    func updateStatusMessageTextView(statusType: StatusType, message: String){
    
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            if(statusType == .Error){
                self.statusMessageTextView.backgroundColor = UIColor.redColor()
                self.playSound("BeepScanBad")
                
            }
            if(statusType == .Alert){
                self.statusMessageTextView.backgroundColor = UIColor.yellowColor()
                self.playSound("BeepScanBad")
            }
            if(statusType == .Normal){
                self.statusMessageTextView.backgroundColor = UIColor.blueColor()
                self.playSound("BeepScanGood")
            }
            if(statusType == .Processing){
                self.statusMessageTextView.backgroundColor = UIColor.greenColor()
                self.playSound("BeepScanGood")
            }
            if(statusType == .Initialized){
                self.statusMessageTextView.backgroundColor = UIColor.greenColor()
                self.playSound("BeepScanGood")
            }
            if(statusType == .Complete){
                self.statusMessageTextView.backgroundColor = UIColor.blueColor()
                self.playSound("BeepScanGood")
            }
            self.statusMessageTextView.text = message

            
        })

        
    }
    
    func playSound(soundName: String)
    {

        // Load "mysoundname.wav"
        if let soundURL = NSBundle.mainBundle().URLForResource(soundName, withExtension: "wav") {
            var mySound: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(soundURL, &mySound)
            // Play
            AudioServicesPlaySystemSound(mySound);
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        }
        
    }
    
    @IBAction func scanPressed(sender: UITapGestureRecognizer) {
        scanPressed()
    }
    
    
    func scanPressed() {
        // Add Custom UI and Code to BarcodeScannerDemo class if you want
        let barcodeScanner = BarcodeScanner()
        // Set some properties available to customize
        barcodeScanner.shouldAskForPermissions = true
        barcodeScanner.shouldShowBarcodeRegion = true
        barcodeScanner.highlightColor = .greenColor()
        barcodeScanner.shouldPauseAfterScannedItem = true
        
        self.navigationController?.pushViewController(barcodeScanner, animated: true)
    }

    func textFieldDidEndEditing(textField: UITextField) {
        if textField == barcodeScanTextView {
            let barcodeScannedValue = barcodeScanTextView.text
            
            NSNotificationCenter.defaultCenter().postNotificationName(mainViewControllerDidPublishRequestedNotification, object: self, userInfo: [mainViewControllerBarcodeDataKey: barcodeScannedValue!])
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
    
        textField.resignFirstResponder()
        return true
        
    }
 
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowConnectionTableViewController" {
            
            let navController = segue.destinationViewController as! UINavigationController
            let connectionTableViewController = navController.topViewController as! ConnectionTableViewController
            connectionTableViewController.connections = mqttConnectionManager.connections
        }
        
        if segue.identifier == "ShowSettingsViewController" {
            
            let navController = segue.destinationViewController as! UINavigationController
            let settingsViewController = navController.topViewController as! SettingsViewController
            settingsViewController.settings = mqttConnectionManager.settings
        }
        
        if segue.identifier == "ShowTraceResult" {
            
            let navController = segue.destinationViewController as! UINavigationController
            let traceResultViewController = navController.topViewController as! TraceResultTableViewController
            traceResultViewController.traceResults = myTraceResults!
        }
    }
    
    @IBAction func unwindToSettings(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? SettingsViewController, settings = sourceViewController.settings {
            
            mqttConnectionManager.settings = settings
            NSNotificationCenter.defaultCenter().postNotificationName(settingsViewControllerDidSettingChangedNotification, object: self, userInfo: nil)
            
            saveSettings(settings)
        }
    }
    
  
   
    
    func barcodeScannerScannedValue(barcodeScannedValue : String?){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.barcodeScanTextView.text = barcodeScannedValue
            
            NSNotificationCenter.defaultCenter().postNotificationName(mainViewControllerDidPublishRequestedNotification, object: self, userInfo: [mainViewControllerBarcodeDataKey: barcodeScannedValue!])
        })
    }

    

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func navigationControllerSupportedInterfaceOrientations(navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    // MARK: NSCoding
    func saveSettings(settings: Settings){
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(settings, toFile:Settings.ArchiveURL.path!)
        
        if !isSuccessfulSave {
            print("Failed to save settings...")
        }
    }


}
