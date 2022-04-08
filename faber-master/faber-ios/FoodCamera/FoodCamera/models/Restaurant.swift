//
//  Restaurant.swift
//  FoodCamera
//
//  Created by Faber Labs on 3/29/20.
//  Copyright © 2020 Yinghui Linda He. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Restaurant: Hashable, Codable, Identifiable {
    public let id = UUID()
    let name: String
    let icon: String
    let cover: String
    let userRating: Int
    let cuisineType: String
    let menu: Array<MenuItem>
    
    init?(json: JSON) {
        guard let name = json["entity_name"].string else { return nil }
        self.name = name
        self.icon = json["profile"]["display_icon"].stringValue
        self.cover = json["profile"]["cover_photo"].stringValue
        self.userRating = json["avg_rating"].numberValue.intValue
        self.cuisineType = json["cuisine_type"][0].stringValue
        self.menu = json["menu_items"].arrayValue.compactMap { return MenuItem(json:$0) }
    }

}
