//
//  ParticipateLessonVC.swift
//  Checked
//
//  Created by Çağlar Uslu on 6.03.2018.
//  Copyright © 2018 Çağlar Uslu. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseDatabase

class ParticipateLessonVC: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    var userFullName = ""
    var textField: UITextField?
    
    var lectures = [UInt16: Lectures]()
    var currentLectures = [UInt16: Lectures]()
    var currentLectureUUIDs = [UInt16]()
    
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }

    
    
    override func viewDidAppear(_ animated: Bool) {
        if let fullName = UserDefaults.standard.string(forKey: "fullName"){
            userFullName = fullName
        }else{
            let alert = UIAlertController(title: "İsim Soyisim", message: "Dikkat! Doğruladıktan sonra adını değiştiremezsin!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addTextField(configurationHandler: textField)
            
            alert.addAction(UIAlertAction(title: "İptal", style: UIAlertActionStyle.default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
                self.dismiss(animated: true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Doğrula", style: UIAlertActionStyle.default, handler: { (action) in
                
                let nameTextField = alert.textFields![0]
                if nameTextField.text != nil{
                    if nameTextField.text! != "" && nameTextField.text! != " "{
                        UserDefaults.standard.set(nameTextField.text!, forKey: "fullName")
                        UserDefaults.standard.synchronize()
                    }else{
                        self.present(alert, animated: true, completion: nil)
                    }
                }else{
                    self.present(alert, animated: true, completion: nil)
                }
            }))
            
            self.present(alert, animated: true, completion: nil)
            
            
        }

    }
    

    func textField(textField: UITextField!){
        self.textField = textField
        self.textField?.placeholder = "İsim Soyisim"
    }
    
    func rangeBeacons(uuid: String, major: CLBeaconMajorValue, minor: CLBeaconMinorValue, identifier: String){
        guard let beaconUUID = UUID(uuidString: uuid) else {print("UUID hatalı"); return}
        let region = CLBeaconRegion(proximityUUID: beaconUUID, major: major, minor: minor, identifier: identifier)
        
        locationManager.startRangingBeacons(in: region)
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            fetchLectures()
        }
    }
    
    
    func fetchLectures(){
        Database.database().reference().child("lectures").observe(.childAdded) { (snapshot) in
            if let dictionary = snapshot.value as? Dictionary<String, AnyObject>{
                let minorVal = dictionary["minor"] as? CLBeaconMinorValue
                let majorVal = dictionary["major"] as? CLBeaconMajorValue
                let uuidVal = dictionary["uuid"] as? String
                let identifierVal = dictionary["identifier"] as? String
                
                let lecture = Lectures()
                
                if let current_hour = dictionary["current_hour"] as? String{
                    lecture.current_hour = current_hour
                }
                
                
                lecture.minor = minorVal!
                lecture.major = majorVal!
                lecture.uuid = uuidVal!
                lecture.identifier = identifierVal!
                lecture.key = snapshot.key
                
                self.lectures[majorVal!] = lecture
                
                self.rangeBeacons(uuid: uuidVal!, major: majorVal!, minor: minorVal!, identifier: identifierVal!)
                
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        for beacon in beacons{
            
            let major = beacon.major.uint16Value
            
            let uuid = beacon.proximityUUID.uuidString
            
            if beacon.proximity != .unknown{
                
                if !currentLectureUUIDs.contains(major){
                    
                    currentLectures[major] = lectures[major]!
                    currentLectureUUIDs.append(major)
                    
                }
                
            }else{
                if currentLectureUUIDs.contains(major){
                    
                    if let currentLecIndex = currentLectureUUIDs.index(of: major) {
                        currentLectureUUIDs.remove(at: currentLecIndex)
                    }
                    
                    currentLectures.removeValue(forKey: major)
                    
                }
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Array(currentLectures.values).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "lecturesCell", for: indexPath) as? LecturesCell{
            let values = Array(currentLectures.values)
            let lecture = values[indexPath.row]
            
            cell.identifier.text = lecture.identifier!
            cell.lecture = lecture
            
            return cell
            
        }else{
            return UITableViewCell()
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    

    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    

}






