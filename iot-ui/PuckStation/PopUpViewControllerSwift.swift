//
//  PopUpViewControllerSwift.swift
//  NMPopUpView
//
//  Created by Nikos Maounis on 13/9/14.
//  Copyright (c) 2014 Nikos Maounis. All rights reserved.
//

import UIKit
import QuartzCore



@objc public class PopUpViewControllerSwift : UIViewController {
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var shipToOkTextField: UITextField!
  
    
    @IBOutlet weak var pviTextField: UITextField!
    @IBOutlet weak var vinTextField: UITextField!
   

    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        self.popUpView.layer.cornerRadius = 5
        self.popUpView.layer.shadowOpacity = 0.8
        self.popUpView.layer.shadowOffset = CGSizeMake(0.0, 0.0)
        

    }
    
    public func showInView(aView: UIView!, withStationName stationName: String!, withPvi pvi : String!, withVin vin : String!, withShipToOk shipToOk: String!,withTraceResults traceResults: NSDictionary!, animated: Bool)
    {
        aView.addSubview(self.view)

        self.view.center = CGPointMake(CGRectGetMidX(aView.bounds),
                                            CGRectGetMidY(aView.bounds));
        
   
        stationNameLabel.text = stationName
        pviTextField.text = pvi
        vinTextField.text = vin
        shipToOkTextField.text = shipToOk
   

        
        if shipToOk == "OK" {
    
            stationNameLabel.backgroundColor = UIColor.init(red: 0.01, green: 0.25, blue: 0.87, alpha: 1.0)
            popUpView!.backgroundColor = UIColor.init(red: 0.00, green: 0.74, blue: 1.0, alpha: 1.0)
        }
        else{

            stationNameLabel.backgroundColor = UIColor.init(red: 0.65, green: 0.11, blue: 0.00, alpha: 1.0)
            popUpView.backgroundColor = UIColor.redColor()
        }
       
        
        if animated
        {
            self.showAnimate()
        }
        
    }

    
    func showAnimate()
    {
        self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
        self.view.alpha = 0.0;
        UIView.animateWithDuration(0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animateWithDuration(0.25, animations: {
            self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
            self.view.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    self.view.removeFromSuperview()
                }
        });
    }
    
   
    @IBAction func didTraceResultTapped(sender: UIButton) {
        NSNotificationCenter.defaultCenter().postNotificationName(mainViewControllerDidTraceResultButtonTabbedNotification, object: self, userInfo: [:])
        
    }
    
    @IBAction public func closePopup(sender: AnyObject) {
        self.removeAnimate()
    }
}