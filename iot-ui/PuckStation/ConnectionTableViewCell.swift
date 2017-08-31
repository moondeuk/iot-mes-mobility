//
//  TableViewCell.swift
//  PuckStation
//
//  Created by 문득룡 on 6/10/16.
//  Copyright © 2016 문득룡. All rights reserved.
//

import UIKit

class ConnectionTableViewCell: UITableViewCell {

    
    @IBOutlet weak var connectionStatusLabel: UILabel!
    @IBOutlet weak var serverNameLabel: UILabel!
    
    var isConnected : Bool = false {
        didSet{
            if(isConnected){
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.connectionStatusLabel.text = "connected"
                    self.connectionStatusLabel.backgroundColor = UIColor.blueColor()
                    self.connectionStatusLabel.textColor = UIColor.whiteColor()
                })

               
            }
            else{
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.connectionStatusLabel.text = "disconnected"
                    self.connectionStatusLabel.backgroundColor = UIColor.redColor()
                    self.connectionStatusLabel.textColor = UIColor.whiteColor()
                })
            }
        }
    }
    
    var connectionID : Int = -1 {
        didSet {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.didConnectionStatusChanged(_:)), name: connectionManagerDidConnectionStatusChangedNotification, object: nil   )
        }
    }
    
    func didConnectionStatusChanged(notification: NSNotification) {
        if let connections = notification.userInfo?[connectionManagerUserInfoConnectionsKey] as? [Connection] {
            for connection in connections {
                if connection.connectionId == self.connectionID {
                    self.isConnected = connection.isConnected
                }
            }
        }
    }
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func removeObservation(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: connectionManagerDidConnectionStatusChangedNotification, object: nil)
    }

}
