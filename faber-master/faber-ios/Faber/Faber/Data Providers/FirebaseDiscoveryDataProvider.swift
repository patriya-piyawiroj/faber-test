// Copyright © 2020 faber. All rights reserved.

import Foundation
import Firebase
import SwiftyJSON

class FirebaseDiscoveryDataProvider: DiscoveryDataProvider {
    typealias Dependencies = FirestoreDependency & FirebaseAuthDependency
    private let dependencies: Dependencies

    init(dependencies: FirebaseDiscoveryDataProvider.Dependencies) {
        self.dependencies = dependencies
    }

    weak var delegate: DiscoveryDataProviderDelegate?

    var discoveryRecommendations: DiscoveryRecommendationModel? {
        didSet {
            delegate?.discoveryDataProviderDidUpdateRecommendations(self)
        }
    }

    func loadDataFor(latitude: Double,
                     longitude: Double,
                     radius: Double) {
        // TODO: Implement latitude/longitude search
        dependencies
            .firestore
            .collection("businesses")
            .getDocuments { [weak self] (snapshot, err) in
                guard
                    err == nil,
                    let snapshot = snapshot
                else {
                    // Handle errors here.
                    return
                }

                let placesDictionary: [String: Any] = [
                    "places": snapshot.documents.compactMap { return $0.data() }
                ]
                self?.discoveryRecommendations = DiscoveryRecommendationModel(json: JSON(placesDictionary))
        }
    }
}
