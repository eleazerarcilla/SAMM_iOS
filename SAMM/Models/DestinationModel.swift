//
//  DestinationModel.swift
//  SAMM
//
//  Created by Eleazer Arcilla on 07/03/2018.
//  Copyright © 2018 Eleazer Arcilla. All rights reserved.
//

import UIKit

struct Destination: Decodable{
    var DestinationVars : [DestinationContents]
}
struct DestinationContents: Decodable {
    var ID: String
    var Value: String
    var Description: String
    var OrderOfArrival: String
    var Direction: String
    var Lat: String
    var Lng: String
    
    init(json: [String:Any]) {
        ID = json["ID"] as? String ?? "-1"
        Value = json["Value"] as? String ?? ""
        Description = json["Description"] as? String ?? ""
        OrderOfArrival = json["OrderOfArrival"] as? String ?? "-1"
        Direction = json["Direction"] as? String ?? "CC"
        Lat = json["Lat"] as? String ?? "0.0"
        Lng = json["Lng"] as? String ?? "0.0"
        
       
    }
    
}
