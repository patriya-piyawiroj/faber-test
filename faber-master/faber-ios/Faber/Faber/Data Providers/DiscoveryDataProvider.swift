// Copyright © 2020 faber. All rights reserved.

import Foundation

protocol DiscoveryDataProviderDelegate: AnyObject {
    func discoveryDataProviderDidUpdateRecommendations(_ discoveryDataProvider: DiscoveryDataProvider)
}

protocol DiscoveryDataProvider {
    var discoveryRecommendations: DiscoveryRecommendationModel? { get }
    var delegate: DiscoveryDataProviderDelegate? { get set }

    func loadDataFor(latitude: Double,
                     longitude: Double,
                     radius: Double)
}
