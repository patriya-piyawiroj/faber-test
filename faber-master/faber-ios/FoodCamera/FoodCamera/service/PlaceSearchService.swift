//
//  PlaceSearchService.swift
//  FoodCamera
//
//  Created by Faber Labs on 5/11/20.
//  Copyright © 2020 Yinghui Linda He. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class PlaceSearchService {
    @Published var locationByUser = [String : String]()
    
    func searchPlace(placeToSearch: String, completion: @escaping ([String : String])->()) {
        let apiKey = "AIzaSyBM6g4_VGwhxHADkzGvMpU1DJnaLwocTIo"
        
        // for some reason, passing the parameters using a dict as the parameters argument results in validation failure
        AF.request(String(format: "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=%@&inputtype=textquery&fields=geometry&key=%@", placeToSearch.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!, apiKey),
                   method: .get,
                   encoding: JSONEncoding.default)
        .responseJSON { response in
            guard let responseValue = response.value else { return }
            let json = JSON(responseValue)
            let location = json["candidates"][0]["geometry"]["location"]
            self.locationByUser = [
                "lat" : location["lat"].stringValue,
                "lng" : location["lng"].stringValue
            ]
            completion(self.locationByUser)
        }

    }
}
