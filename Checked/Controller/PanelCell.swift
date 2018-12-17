//
//  PanelCell.swift
//  Checked
//
//  Created by Çağlar Uslu on 7.03.2018.
//  Copyright © 2018 Çağlar Uslu. All rights reserved.
//

import UIKit
import Firebase

class PanelCell: UITableViewCell {

    
    @IBOutlet weak var identifier: UILabel!
    
    var lecture = Lectures()
    
    
    

    @IBOutlet weak var pauseBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var startBtn: UIButton!
    
    @IBOutlet weak var stopStackView: UIStackView!
    @IBOutlet weak var startStackView: UIStackView!
    @IBOutlet weak var pauseStackView: UIStackView!
    
    @IBAction func stopPressed(_ sender: Any) {
        stopStackView.isHidden = true
        pauseStackView.isHidden = true
        startStackView.isHidden = false
        
    }
    
    
    
    @IBAction func startPressed(_ sender: Any) {
        stopStackView.isHidden = false
        pauseStackView.isHidden = false
        startStackView.isHidden = true
        
    }
    
    @IBAction func pausePressed(_ sender: Any) {
        stopStackView.isHidden = false
        pauseStackView.isHidden = true
        startStackView.isHidden = false
        
    }
    
    
    
    
}








