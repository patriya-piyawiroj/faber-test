//
//  MenuItem.swift
//  FoodCamera
//
//  Created by Mac on 2020/4/11.
//  Copyright © 2020 Yinghui Linda He. All rights reserved.
//

import Foundation
import SwiftyJSON

// the model for an item (dish) in the menu of a restaurant
public struct MenuItem: Hashable, Codable, Identifiable {
    public var id = UUID()
    let name: String
    let photo: String
    let price: Double
    let description: String
    
    init?(json: JSON) {
        guard let name = json["name"].string else { return nil }
        self.name = name
        self.photo = json["photos"][0].stringValue
        self.price = json["price"].numberValue.doubleValue
        self.description = json["description"].stringValue
    }
    
    init?(name: String, photo: String, price: Double, description: String) {
        self.name = name
        self.photo = photo
        self.price = price
        self.description = description
    }
}
