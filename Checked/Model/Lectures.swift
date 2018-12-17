//
//  Lectures.swift
//  Checked
//
//  Created by Çağlar Uslu on 7.03.2018.
//  Copyright © 2018 Çağlar Uslu. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase
import FirebaseDatabase


class Lectures: NSObject{
    
    var uuid: String?
    var major: CLBeaconMajorValue?
    var minor: CLBeaconMinorValue?
    var identifier: String?
    var proximity: String?
    var key: String?
    var current_hour: String?
    
    
}
