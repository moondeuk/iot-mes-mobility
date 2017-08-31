//
//  TraceResultTableViewController.swift
//  PuckStation
//
//  Created by 문득룡 on 6/19/16.
//  Copyright © 2016 문득룡. All rights reserved.
//

import UIKit

class TraceResultTableViewController: UITableViewController {

    var traceResults = [TraceResult]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source


    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: actions
    
    @IBAction func done(sender: UIBarButtonItem) {
        
        let currentIndex = navigationController?.viewControllers.indexOf(self)
        
        if currentIndex > 0 {
            navigationController!.popToViewController((navigationController?.viewControllers[currentIndex! - 1])!, animated: true)
        }
        else{
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return traceResults.count
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TraceResultTableViewCell", forIndexPath: indexPath) as! TraceResultTableViewCell
        
        let partName = self.traceResults[indexPath.row].partName
        let traceId = self.traceResults[indexPath.row].traceID
        let traceData = self.traceResults[indexPath.row].traceData
        let scanTime = self.traceResults[indexPath.row].scanTime
        let scanResult = self.traceResults[indexPath.row].scanResult
        let defectDescription = self.traceResults[indexPath.row].defectDescription
        
        var imageName: String?
        if partName == "Engine"{
            imageName = "engine"
        }
        else if partName == "Roof Rail Airbag LH"{
            imageName = "rrab"
        }
        else if partName == "Roof Rail Airbag RH"{
            imageName = "rrab"
        }
        else if partName == "Mission"{
            imageName = "transmission"
        }
        else if partName == "SDM"{
            imageName = "sdm"
        }
        else{
            imageName = "noimage"
        }
        
        



        cell.partImage.image = UIImage(named: imageName!)
        

        
        if scanResult == "OK" {
            cell.defectDescriptionTextView.backgroundColor = UIColor.init(red: 0.00, green: 0.74, blue: 1.0, alpha: 1.0)
        }
        else{

            cell.defectDescriptionTextView.backgroundColor = UIColor.redColor()
        }

        
      
        
        cell.partNameTextField.text = partName
      
        cell.traceIdTextField.text = traceId
        cell.traceDataTextField.text = traceData
        cell.scanTimeTextField.text = scanTime
        cell.resultTextField.text = scanResult
        cell.defectDescriptionTextView.text = defectDescription
        
     
        return cell
    }


}
