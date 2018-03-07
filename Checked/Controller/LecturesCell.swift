//
//  LecturesCell.swift
//  Checked
//
//  Created by Çağlar Uslu on 7.03.2018.
//  Copyright © 2018 Çağlar Uslu. All rights reserved.
//

import UIKit
import Firebase

class LecturesCell: UITableViewCell {

    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var identifier: UILabel!
    @IBOutlet weak var buttonHolder: UIButton!
    @IBOutlet weak var participateButton: UIButton!
    
    var lecture = Lectures()
    
    
    @IBAction func participatePressed(_ sender: Any) {
        
        if let fullName = UserDefaults.standard.string(forKey: "fullName"){
            
            
            Database.database().reference().child("participation").child(lecture.key!).child(lecture.current_hour!).updateChildValues([fullName: 1], withCompletionBlock: { (error, ref) in
                if error == nil{
                    self.buttonHolder.isHidden = true
                    self.participateButton.isHidden = true
                    self.descriptionLabel.isHidden = false
                    
                }
            })
            
        }
        
        
    }
    
}
