//
//  ConnectionInfoViewController.swift
//  PuckStation
//
//  Created by 문득룡 on 6/11/16.
//  Copyright © 2016 문득룡. All rights reserved.
//

import UIKit

let portDefault = 1883
let keepAliveDefault = 60

class ConnectionViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {

    // MARK: Properties
    
    @IBOutlet weak var connectionNameTextField: UITextField!
    @IBOutlet weak var hostNameTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var keepAliveTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!

    var connection: Connection?
    var connectionId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        connectionNameTextField.delegate = self
        hostNameTextField.delegate = self
        portTextField.delegate = self
        keepAliveTextField.delegate = self
        
        
        if let connection = connection {
            connectionId = connection.connectionId
            connectionNameTextField.text = connection.connectionName
            hostNameTextField.text = connection.hostName
            portTextField.text = String(connection.port)
            keepAliveTextField.text = String(connection.keepAlive)
        }
        else{
            portTextField.text = String(portDefault)
            keepAliveTextField.text = String(keepAliveDefault)
        }
        
        checkValidation()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    

    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField !== portTextField && textField !== keepAliveTextField {
            textField.resignFirstResponder()
            return true
        }
        else{
            return false
        }
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
       checkValidation()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        saveButton.enabled = false
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if(textField == portTextField || textField == keepAliveTextField){
            let aSet = NSCharacterSet(charactersInString:"0123456789").invertedSet
            let compSepByCharInSet = string.componentsSeparatedByCharactersInSet(aSet)
            let numberFiltered = compSepByCharInSet.joinWithSeparator("")
            return string == numberFiltered
        }
        
        return true
    }
    
    func checkValidation() {
        let connectionName = connectionNameTextField.text ?? ""
        let hostName = hostNameTextField.text ?? ""
        let port = portTextField.text ?? ""
        let keepAlive = keepAliveTextField.text ?? ""
        
        saveButton.enabled = !connectionName.isEmpty && !hostName.isEmpty && !port.isEmpty && !keepAlive.isEmpty
    }


    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            let connectionName = connectionNameTextField.text ?? ""
            let hostName = hostNameTextField.text ?? ""
            let port = portTextField.text ?? ""
            let keepAlive = keepAliveTextField.text ?? ""
            
            connection = Connection(connectionId: connectionId!, connectionName: connectionName, hostName: hostName, port: Int(port)!, keepAlive: Int(keepAlive)!)
            
        }
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
