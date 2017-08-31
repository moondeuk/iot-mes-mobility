//
//  MqttListController.swift
//  PuckStation
//
//  Created by 문득룡 on 6/10/16.
//  Copyright © 2016 문득룡. All rights reserved.
//

import UIKit




class ConnectionTableViewController: UITableViewController{
    var connections = [Connection]()
    
    // MARK: Properties
    
    
    // MARK: Table view data source
    // Override to support editing the table view.
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return connections.count
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
        if editingStyle == .Delete {
            
            
            NSNotificationCenter.defaultCenter().postNotificationName(connectionTableViewControllerDidConnectionTableRemovedNotification, object: self, userInfo: [connectionManagerUserInfoConnectionKey: connections[indexPath.row]])
            
            
            connections.removeAtIndex(indexPath.row)
            
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! ConnectionTableViewCell
            cell.removeObservation()
            
            
            saveConnections()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ConnectionTableViewCell", forIndexPath: indexPath) as! ConnectionTableViewCell
        
        cell.connectionID = self.connections[indexPath.row].connectionId
        cell.isConnected = self.connections[indexPath.row].isConnected
        cell.serverNameLabel.text = self.connections[indexPath.row].connectionName
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigationItem.leftBarButtonItem = editButtonItem()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let connectionViewController = segue.destinationViewController as! ConnectionViewController
            
            if let selectedConnectionCell = sender as? ConnectionTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedConnectionCell)!
                let selectedConnection = connections[indexPath.row]
                connectionViewController.connection = selectedConnection
            }
        }
        else if segue.identifier == "AddItem" {
            
            print("Adding new connection.")
            let navController = segue.destinationViewController as! UINavigationController
            let connectionViewController = navController.topViewController as! ConnectionViewController
            connectionViewController.connectionId = getNewConnectionId()
        }
    }
    
    func getNewConnectionId() -> Int {
        
        var connectionId : Int = -1
        for connection in connections {
            if(connectionId < connection.connectionId){
                connectionId = connection.connectionId
            }
        }
        
        return connectionId + 1
    }
    
    @IBAction func back(sender: UIBarButtonItem) {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMode {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else{
            navigationController!.popViewControllerAnimated(true)
        }

    }
    
    @IBAction func unwindToConnectionList(sender: UIStoryboardSegue) {
        
        
        if let sourceViewController = sender.sourceViewController as? ConnectionViewController, connection = sourceViewController.connection {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow{
                connections[selectedIndexPath.row] = connection
                tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
            }
            else{
                let newIndexPath = NSIndexPath(forRow: connections.count, inSection: 0)
                
                connections.append(connection)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
                
            }
            
            
            NSNotificationCenter.defaultCenter().postNotificationName(connectionTableViewControllerDidConnectionTableChangedNotification, object: self, userInfo: [connectionManagerUserInfoConnectionKey: connection])
            
            saveConnections()
        }
    }
    
    // MARK: NSCoding
    func saveConnections(){
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(connections, toFile:Connection.ArchiveURL.path!)
        
        if !isSuccessfulSave {
            print("Failed to save connections...")
        }
    }
    
}
