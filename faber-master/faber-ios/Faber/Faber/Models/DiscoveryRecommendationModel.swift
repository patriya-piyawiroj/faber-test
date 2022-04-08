// Copyright © 2020 faber. All rights reserved.

import Foundation
import SwiftyJSON

struct DiscoveryRecommendationModel {
    struct Place {
        struct Status {
            let new: Bool
            let recommended: Bool

            // HACK: Fake data
            static func random() -> Status {
                return Status(new: Bool.random(), recommended: Bool.random())
            }
        }
        let name: String
        let previewImageURL: String
        let rating: Float
        let status: Status

        init?(json: JSON) {
            guard let name = json["entity_name"].string else { return nil }
            self.name = name
            self.previewImageURL = json["preview_image_url"].stringValue
            self.rating = json["avg_rating"].numberValue.floatValue
            // HACK: Fake data
            self.status = Status.random()
        }
    }
    let places: [Place]
    let percentage: Float

    init?(json: JSON) {
        guard let placesJSON = json["places"].array else {
            return nil
        }

        self.places = placesJSON.compactMap { return Place(json: $0) }
        // HACK: Fake data
        self.percentage = Float.random(in: 50..<99)/100
    }

    // MARK: - Computed Properties

    var contextString: String {
        let newCount = places.filter { place in
            return place.status.new
        }.count
        let recommendedCount = places.filter { place in
            return place.status.recommended
        }.count

        var context = String(format: "%d places", places.count)

        if (newCount > 0) {
            context += String(format: ", %d new", newCount)
        }

        if (recommendedCount > 0) {
            context += String(format: ", %d recommended", recommendedCount)
        }

        return context
    }
}

// MARK: - Equatable extensions

extension DiscoveryRecommendationModel: Equatable {
    static func == (lhs: DiscoveryRecommendationModel,
                    rhs: DiscoveryRecommendationModel) -> Bool {
        return lhs.places.elementsEqual(rhs.places)
            && lhs.percentage == rhs.percentage
    }
}

extension DiscoveryRecommendationModel.Place: Equatable {
    static func == (lhs: DiscoveryRecommendationModel.Place,
                    rhs: DiscoveryRecommendationModel.Place) -> Bool {
        return lhs.name == rhs.name
            && lhs.previewImageURL == rhs.previewImageURL
            && lhs.rating == rhs.rating
            && lhs.status == rhs.status
    }
}

extension DiscoveryRecommendationModel.Place.Status: Equatable {
    static func == (lhs: DiscoveryRecommendationModel.Place.Status,
                    rhs: DiscoveryRecommendationModel.Place.Status) -> Bool {
        return lhs.new == rhs.new
            && lhs.recommended == rhs.recommended
    }
}
