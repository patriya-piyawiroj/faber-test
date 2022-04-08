//
//  UpdateUserLocationService.swift
//  FoodCamera
//
//  Created by Faber Labs on 5/11/20.
//  Copyright © 2020 Yinghui Linda He. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

// A service that updates the user's location in database
class UpdateUserLocationService {
    
    func updateUserLocation(userID: String, latitude: String, longitude: String) {
        let parameters: [String : Double] = [
            "latitude" : Double(latitude)!,
            "longitude" : Double(longitude)!
        ];
        
        AF.request(String(format: "https://us-central1-faberlabs-29ab0.cloudfunctions.net/user/%@/location", userID),
                   method: .put,
                   parameters: parameters,
                   encoding: JSONEncoding.default)
        .responseJSON { response in }

    }
}
