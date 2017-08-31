//
//  SettingsViewController.swift
//  PuckStation
//
//  Created by 문득룡 on 6/13/16.
//  Copyright © 2016 문득룡. All rights reserved.
//

import UIKit


class SettingsViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    // MARK: Properties
    
    @IBOutlet weak var clientIdTextField: UITextField!
    @IBOutlet weak var subscribeTopicTextField: UITextField!
    @IBOutlet weak var publishTopicTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    @IBOutlet weak var beaconEnabledSwitch: UISwitch!
    
    @IBOutlet weak var beaconUuidTextField: UITextField!
    
    @IBOutlet weak var beaconMajorTextField: UITextField!
    
    @IBOutlet weak var beaconMinorTextField: UITextField!
    var settings : Settings?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        clientIdTextField.delegate = self
        subscribeTopicTextField.delegate = self
        publishTopicTextField.delegate = self
        
        if let settings = settings {
            clientIdTextField.text = settings.clientId
            subscribeTopicTextField.text = settings.subscribeTopic
            publishTopicTextField.text = settings.publishTopic
            beaconUuidTextField.text = settings.beaconUuid
            beaconEnabledSwitch.on = settings.beaconEnabled
            beaconMinorTextField.text = settings.beaconMinor
            beaconMajorTextField.text = settings.beaconMajor
        }
   
        
        checkValidation()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidation()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        saveButton.enabled = false
    }
    
    
    func checkValidation() {
        let clientId = clientIdTextField.text ?? ""
        let subscribeTopic = subscribeTopicTextField.text ?? ""
        let publishTopic = publishTopicTextField.text ?? ""
  

        
        saveButton.enabled = !clientId.isEmpty && !subscribeTopic.isEmpty && !publishTopic.isEmpty
    }
    
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            let cliendId = clientIdTextField.text ?? ""
            let subscribeTopic = subscribeTopicTextField.text ?? ""
            let publicTopic = publishTopicTextField.text ?? ""
            let beaconEnabled = beaconEnabledSwitch.on
            let beaconUuid = beaconUuidTextField.text ?? ""
            let beaconMajor = beaconMajorTextField.text ?? ""
            let beaconMinor = beaconMinorTextField.text ?? ""
            
            settings = Settings(clientId: cliendId, subscribeTopic: subscribeTopic, publishTopic: publicTopic, beaconEnabled: beaconEnabled, beaconUuid: beaconUuid, beaconMajor: beaconMajor, beaconMinor: beaconMinor)
            
        }
    }
    
    @IBAction func beaconEnableChanged(sender: UISwitch) {
        let beaconUuid = beaconUuidTextField.text ?? ""
        let beaconMajor = beaconMajorTextField.text ?? ""
        let beaconMinor = beaconMinorTextField.text ?? ""
        
        if(beaconUuid.isEmpty || beaconMajor.isEmpty || beaconMinor.isEmpty){
            sender.setOn(false, animated: false)
        }else{
        
            let uuid = NSUUID(UUIDString: beaconUuid)
            
            if uuid == nil {
                sender.setOn(false, animated: false)
            }
        
        }
        
        
    }
    @IBAction func generateButtonTouched(sender: UIButton) {
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let uuid = NSUUID()
            self.beaconUuidTextField.text = uuid.UUIDString
        })
    }
    
    // MARK: actions
    @IBAction func cancel(sender: UIBarButtonItem) {
        
        let currentIndex = navigationController?.viewControllers.indexOf(self)
        
        if currentIndex > 0 {
            navigationController!.popToViewController((navigationController?.viewControllers[currentIndex! - 1])!, animated: true)
        }
        else{
            dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
}