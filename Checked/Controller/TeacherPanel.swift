//
//  TeacherPanel.swift
//  Checked
//
//  Created by Çağlar Uslu on 7.03.2018.
//  Copyright © 2018 Çağlar Uslu. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class TeacherPanel: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    
    var textField: UITextField?
    
    var lectures = [Lectures]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        fetchLessons()
        
        
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lectures.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "panelCell", for: indexPath) as? PanelCell{
            
            let lecture = lectures[indexPath.row]
            cell.lecture = lecture
            cell.identifier.text = lecture.identifier!
            
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    func fetchLessons(){
        
        Database.database().reference().child("teachers").child((Auth.auth().currentUser?.uid)!).child("lectures").observe(.childAdded) { (snapshot) in
            
            let lecture = Lectures()
            
            lecture.key = snapshot.key
            
            Database.database().reference().child("lectures").child(snapshot.key).observe(.value, with: { (snapshot) in
                if let dic = snapshot.value as? Dictionary<String, AnyObject>{
                    let minorVal = dic["minor"] as? CLBeaconMinorValue
                    let majorVal = dic["major"] as? CLBeaconMajorValue
                    let uuidVal = dic["uuid"] as? String
                    let identifierVal = dic["identifier"] as? String
                    
                    lecture.minor = minorVal!
                    lecture.major = majorVal!
                    lecture.uuid = uuidVal!
                    lecture.identifier = identifierVal!
                    
                    self.lectures.append(lecture)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            })
        }
        
    }
    
    
    @IBAction func addLessonPressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "Ders Ekle", message: "Lütfen yoklama almak istediğin dersi ekle", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: textField)
        
        alert.addAction(UIAlertAction(title: "İptal", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Ekle", style: UIAlertActionStyle.default, handler: { (action) in
            
            let nameTextField = alert.textFields![0]
            if nameTextField.text != nil{
                if nameTextField.text! != "" && nameTextField.text! != " "{
                    
                    self.handleAddLesson(identifier: nameTextField.text!)
                    
                }else{
                    self.present(alert, animated: true, completion: nil)
                }
            }else{
                self.present(alert, animated: true, completion: nil)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    func textField(textField: UITextField!){
        self.textField = textField
        self.textField?.placeholder = "(örnek: ÜNİ101)"
    }
    
    func handleAddLesson(identifier: String){
        
        
        let ref = Database.database().reference().child("lectures")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.childrenCount
                
            let ref2 = ref.childByAutoId()
                
            ref2.observeSingleEvent(of: .value, with: { (snapshot) in
                
                let values = ["identifier": identifier, "minor": 1000, "major": UInt16(value + 1), "uuid": "B0702880-A295-A8AB-F734-031A98A512DE"] as [String : Any]

                Database.database().reference().child("teachers").child((Auth.auth().currentUser?.uid)!).child("lectures").updateChildValues([ref2.key: 1])
                
                Database.database().reference().updateChildValues(["biggest_major": UInt16(value + 1)])
                
                ref2.updateChildValues(values)
            })
            
            
            
            
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        
    }
    
    
    

}



















