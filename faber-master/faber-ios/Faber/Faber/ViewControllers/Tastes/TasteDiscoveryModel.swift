// Copyright © 2020 faber. All rights reserved.

import Foundation
import SwiftyJSON

struct TasteDiscoveryModel {
    let id: String
    let price: Double?
    let businessName: String
    let dishName: String?
    let imageURLs: [String]

    init?(json: JSON) {
        guard
            let id = json["dish_id"].string,
            let businessName = json["business_name"].string,
            let imageURLArray = json["photos"].array
            else {
                return nil
        }

        let imageURLs = imageURLArray.compactMap { return $0.string }
        guard imageURLs.count > 0 else { return nil }

        // HACK: This is jsut a placeholder until we can actually get proper
        // data coming in from the backend without missing fields.
        let price = json["price"].double
        let dishName = json["dish_name"].string

        self.id = id
        self.price = price
        self.businessName = businessName
        self.dishName = dishName
        self.imageURLs = imageURLs
    }
}
