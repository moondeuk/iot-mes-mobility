//
//  TraceResultTableViewCell.swift
//  PuckStation
//
//  Created by 문득룡 on 6/19/16.
//  Copyright © 2016 문득룡. All rights reserved.
//

import UIKit

class TraceResultTableViewCell: UITableViewCell {

    @IBOutlet weak var partImage: UIImageView!
    
    @IBOutlet weak var traceIdTextField: UITextField!
    
    @IBOutlet weak var partNameTextField: UITextField!
    
    @IBOutlet weak var scanTimeTextField: UITextField!
    
    
    @IBOutlet weak var resultTextField: UITextField!
    
    @IBOutlet weak var traceDataTextField: UITextField!
    
    @IBOutlet weak var defectDescriptionTextView: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
