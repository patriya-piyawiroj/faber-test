//
//  GetUserLocationService.swift
//  FoodCamera
//
//  Created by Faber Labs on 5/14/20.
//  Copyright © 2020 Yinghui Linda He. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class GetUserLocationService {
    @Published var restaurantsByTypes = [String: [Restaurant]]()
    
    func getUserLocation(userID: String) {
        // Get user location
        AF.request(
            String(format: "https://us-central1-faberlabs-29ab0.cloudfunctions.net/user/%@", userID),
                   method: .get)
            .responseJSON { response in
                guard let responseValue = response.value else { return }
                let json = JSON(responseValue)
                let locationDict = json["location"].dictionaryValue
                let userLatitude = (locationDict["_latitude"]?.rawValue as? Double) ?? 34.0221506;
                let userLongitude = (locationDict["_longitude"]?.rawValue as? Double) ?? -118.2875205;
                
                
                
        }
    }
}
