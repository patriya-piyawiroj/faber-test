// Copyright © 2020 faber. All rights reserved.

import Foundation
import SwiftyJSON

class MockDiscoveryDataProvider: DiscoveryDataProvider {
    weak var delegate: DiscoveryDataProviderDelegate?

    var discoveryRecommendations: DiscoveryRecommendationModel? {
        didSet {
            delegate?.discoveryDataProviderDidUpdateRecommendations(self)
        }
    }

    func loadDataFor(latitude: Double,
                     longitude: Double,
                     radius: Double) {
        let places: [[String: Any]] = placeStrings.map { name, url in
            return [
                "entity_name": name,
                "preview_image_url": url,
                "avg_rating": Float.random(in: 0..<5)
            ]
        }
        let recommendations = [
            "places": places
        ]
        let discoveryRecommendations = DiscoveryRecommendationModel(json: JSON(recommendations))
        let delay = TimeInterval.random(in: 5..<50) / 10
        dispatch_after(delay) {
            self.discoveryRecommendations = discoveryRecommendations
        }
    }
}


private let placeStrings: [(String, String)] = [
    ("Master Chef",
     "https://images.unsplash.com/photo-1474859569645-e0def92b02bc?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=300&q=80"),
    ("Faber Dining",
     "https://images.unsplash.com/photo-1467727673784-39c8ccb7e5fb?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=300&q=80"),
    ("Hot Wingz",
     "https://images.unsplash.com/photo-1479648490851-ba0a18de1bc8?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=300&q=80"),
    ("Pizzaz",
     "https://images.unsplash.com/photo-1471440671318-55bdbb772f93?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=300&q=80"),
    ("I Scream 4 Ice Cream",
     "https://images.unsplash.com/photo-1480321182142-e77f14b9aa64?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=300&q=80"),
    ("Juice Cleanse",
     "https://images.unsplash.com/photo-1498183598268-bc8dbd3ef884?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=300&q=80"),
    ("Jason's Bistro",
     "https://www.faberlabs.io/static/media/team-jason-300x300.a5d70767.jpg"),
    ("Vincent's Korean Fusion",
     "https://www.faberlabs.io/static/media/team-anonymous-300x300.a54a3e69.jpg"),
]
