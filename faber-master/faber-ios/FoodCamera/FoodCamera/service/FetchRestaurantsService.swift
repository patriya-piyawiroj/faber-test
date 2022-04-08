//
//  FetchRestaurants.swift
//  FoodCamera
//
//  Created by Faber Labs on 4/13/20.
//  Copyright © 2020 Yinghui Linda He. All rights reserved.
//

import Combine
import Alamofire
import SwiftyJSON

// A service that fetches restaurants near the user's location stored in database, and compile the data into a dict
class FetchRestaurantsService {
    // a dict of [cuisine types: restaurants under the cuisine type]
    @Published var restaurantsByTypes = [String: [Restaurant]]()
    @Published var isFetching = false
         
    // download data of restaurants near USC and update the dictionary of restaurants
    func fetchRecRestaurants(userID: String, latitude: String, longitude: String) {
        self.isFetching = true
        self.restaurantsByTypes = [String: [Restaurant]]()
        
        let parameters: [String : Any] = [
            "lat": latitude,
            "lng": longitude,
            "distThres" : 10000
        ];
                
        //Get nearby restaurants
        AF.request("https://us-central1-faberlabs-29ab0.cloudfunctions.net/search/business",
                   method: .get,
                   parameters: parameters)
                      .responseJSON { response in
                        guard let responseValue = response.value else { return }
                        let json = JSON(responseValue)
                        for restaurantJSON in json.arrayValue {
                            guard let restaurant = Restaurant(json: restaurantJSON) else { continue }
                            let cuisineType = restaurant.cuisineType == "" ? "Other" : restaurant.cuisineType
                            // check if the dict already contains this cuisine type
                            if(self.restaurantsByTypes[cuisineType] == nil) {
                                self.restaurantsByTypes[cuisineType] = [restaurant]
                            }
                            else {
                                self.restaurantsByTypes[cuisineType]!.append(restaurant)
                            }

                        }
                        self.isFetching = false
            };
            
        }
    
}
