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
import CoreBluetooth
import MessageUI

class TeacherPanel: UIViewController, UITableViewDelegate, UITableViewDataSource, CBPeripheralManagerDelegate, CBCentralManagerDelegate, MFMailComposeViewControllerDelegate {

    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!
    
    var manager:CBCentralManager!
    
    var fromPaused = false
    
    static let teacherPanelSingleton = TeacherPanel()
    
    @IBOutlet weak var tableView: UITableView!
    
    var textField: UITextField?
    
    var lectures = [Lectures]()
    var participants = [String]()
    
    var cellLecture = Lectures()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        fetchLessons()
        
        manager = CBCentralManager()
        manager.delegate = self
    }
    
    
    // Delegate method
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        let alert = UIAlertController(title: "Bluetooth", message: "Yoklamanızın sadece sınıf içinde geçerli olması için aktive edin", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        if central.state == .poweredOn {
            
            alert.dismiss(animated: true, completion: nil)
        }
        
        else if central.state == .poweredOff{
            
            present(alert, animated: true, completion: nil)
            
        }
    }
    
    func initLocalBeacon(lecture: Lectures) {
        if localBeacon != nil {
            stopLocalBeacon()
        }
        
        let localBeaconUUID = lecture.uuid!
        let localBeaconMajor: CLBeaconMajorValue = lecture.major!
        let localBeaconMinor: CLBeaconMinorValue = lecture.minor!
        
        let uuid = UUID(uuidString: localBeaconUUID)!
        localBeacon = CLBeaconRegion(proximityUUID: uuid, major: localBeaconMajor, minor: localBeaconMinor, identifier: lecture.identifier!)
        
        beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    func stopLocalBeacon() {
        peripheralManager.stopAdvertising()
        peripheralManager = nil
        beaconPeripheralData = nil
        localBeacon = nil
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            peripheralManager.startAdvertising(beaconPeripheralData as! [String: AnyObject]!)
        } else if peripheral.state == .poweredOff {
            peripheralManager.stopAdvertising()
        }
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lectures.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "panelCell", for: indexPath) as? PanelCell{
            
            let lecture = lectures[indexPath.row]
            cell.lecture = lecture
            cell.identifier.text = lecture.identifier!
            cell.startBtn.addTarget(self, action: #selector(startPressed), for: .touchUpInside)
            cell.stopBtn.addTarget(self, action: #selector(stopPressed), for: .touchUpInside)
            cell.pauseBtn.addTarget(self, action: #selector(pausePressed), for: .touchUpInside)
            
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    
    
    
    
    ///////////////////////////
    
    
    
    
    @objc func startPressed(){
        
        initLocalBeacon(lecture: cellLecture)
        
        if !fromPaused{
            let ref = Database.database().reference().child("participation").child(cellLecture.key!).childByAutoId()
            Database.database().reference().child("lectures").child(self.cellLecture.key!).updateChildValues(["current_hour": ref.key])
            
            cellLecture.current_hour = ref.key
            
            ref.updateChildValues(["participants": [" ": 1], "time": ServerValue.timestamp()])
        }
        
        
    }
    
    
    @objc func stopPressed(){
        
        fromPaused = false
        stopLocalBeacon()
        
        Database.database().reference().child("lectures").child(self.cellLecture.key!).child("current_hour").removeValue()
        
        stopPressed2(lecture: cellLecture)
        
    }
    
    
    @objc func pausePressed(){
        
        fromPaused = true
        
        stopLocalBeacon()
        
    }
    
    
    
    ///////////////////////////
    
    
    
    
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    func fetchLessons(){
        
        Database.database().reference().child("teachers").child((Auth.auth().currentUser?.uid)!).child("lectures").observe(.childAdded) { (snapshot) in
            
            let lecture = Lectures()
            
            lecture.key = snapshot.key
            
            Database.database().reference().child("lectures").child(snapshot.key).observeSingleEvent(of: .value, with: { (snapshot) in
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
    

    
    func stopPressed2(lecture: Lectures){
        
        Database.database().reference().child("participation").child(lecture.key!).child(lecture.current_hour!).child("participants").observeSingleEvent(of: .value) { (snapshot) in
            let count = snapshot.childrenCount
            Database.database().reference().child("participation").child(lecture.key!).child(lecture.current_hour!).child("participants").observe(.childAdded) { (snapshot) in
                self.participants.append(snapshot.key)
                if self.participants.count == count{
                    
                    Database.database().reference().child("participation").child(lecture.key!).child(lecture.current_hour!).observeSingleEvent(of: .value) { (snapshot) in
                        if let dic = snapshot.value as? Dictionary<String, AnyObject>{
                            let time = dic["time"] as? Double
                            let stringTime = self.setDate(time: time!)
                            let participants = self.participantsMailFormat()
                            self.sendEmail(to: (Auth.auth().currentUser?.email!)!, subject: "YOKLAMA: \(lecture.identifier!) - \(stringTime)", body: participants)
                        }
                    }
                    
                    
                }
            }
        }
    }
    
    func participantsMailFormat() -> String{
        var participantsFormat = ""
        for participant in participants{
            participantsFormat += participant + "\n"
        }
        return participantsFormat
    }
    
    func setDate(time: Double) -> String {
        let unixDate = time
        let date = Date(timeIntervalSince1970: unixDate / 1000)
        let stringDate = "\(date)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        let date2 = dateFormatter.date(from: stringDate)!
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = dateFormatter.string(from:date2)
        return dateString
    }
    
    func sendEmail(to: String, subject: String, body: String){
        let mailComposeViewController = configureMailController(to: to, subject: subject, body: body)
        if MFMailComposeViewController.canSendMail(){
            present(mailComposeViewController, animated: true, completion: nil)
        }else{
            showMailError()
        }
    }
    
    func configureMailController(to: String, subject: String, body: String) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.setToRecipients([to])
        composer.setSubject(subject)
        composer.setMessageBody(body, isHTML: false)
        
        return composer
    }
    
    func showMailError(){
        let alert = UIAlertController(title: "Hata", message: "Email gönderilemedi", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

}



















