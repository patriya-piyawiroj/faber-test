// Copyright © 2020 faber. All rights reserved.

import Foundation
import Alamofire
import SwiftyJSON

private struct Constants {
    // HACK: We really shouldn't be storing the API key here.
    static let apiKey = "uYAV4Jx3BMU3v_ns0an_8hLL3P4yROAeSP65ZpkD0Nj7eqrrz5mF2SpOAOgYzJXOgerMyDRMM6xGPMhdd2ahq6I4BJNMKSQsHQICoN-wX1woDwTR_9YdlPAO_rZAXnYx"
    static let clientID = "YLaa7tNeBV5YuyxJa59rNA"
    static let baseURLString = "https://api.yelp.com/v3/"
    static let businessSearchPath = "businesses/search"
}

final class YelpDiscoveryDataProvider: DiscoveryDataProvider {
    weak var delegate: DiscoveryDataProviderDelegate?
    var discoveryRecommendations: DiscoveryRecommendationModel? {
        didSet {
            delegate?.discoveryDataProviderDidUpdateRecommendations(self)
        }
    }

    private lazy var manager: Alamofire.Session = {
        let configuration = URLSessionConfiguration.af.default
        configuration.headers.add(name: "Authorization",
                                  value: "Bearer \(Constants.apiKey)")
        return Alamofire.Session(configuration: configuration)
    }()

    func loadDataFor(latitude: Double,
                     longitude: Double,
                     radius: Double) {
        let request = YelpRequest(latitude: latitude,
                                  longitude: longitude,
                                  radius:Int(radius))
        manager.request(request).response { [weak self] response in
            switch response.result {
            case .success:

                guard
                    let data = response.data,
                    let json = try? JSON(data: data)
                else {
                    // Error handling.
                    return
                }
                self?.handleResponse(json)
                break
            case .failure:
                // error handling
                break
            }
        }
    }

    private func handleResponse(_ json: JSON) {
        guard let recommendationModel = DiscoveryRecommendationModel(yelpJSON: json) else {
            return
        }

        discoveryRecommendations = recommendationModel
    }
}

private extension DiscoveryRecommendationModel {
    init?(yelpJSON: JSON) {
        guard let businesses = yelpJSON["businesses"].array else { return nil }

        // HACK: Remove this.
        self.percentage = Float.random(in: 50..<99)/100
        self.places = businesses.compactMap { return DiscoveryRecommendationModel.Place(yelpJSON: $0) }
    }
}

private extension DiscoveryRecommendationModel.Place {
    init?(yelpJSON: JSON) {
        guard
            let name = yelpJSON["name"].string,
            let rating = yelpJSON["rating"].float,
            let previewImageURL = yelpJSON["image_url"].string
        else {
            return nil
        }

        self.name = name
        self.previewImageURL = previewImageURL
        self.rating = rating
        self.status = Status.random()
    }
}

struct YelpRequest: URLConvertible {
    struct YelpRequestError: Error {
        let description: String
    }

    let latitude: Double
    let longitude: Double
    let radius: Int

    func asURL() throws -> URL {
        let base = try Constants.baseURLString.asURL()
        var urlRequest = URLRequest(url: base.appendingPathComponent(Constants.businessSearchPath))
        urlRequest.httpMethod = HTTPMethod.get.rawValue
        urlRequest = try URLEncoding.default.encode(urlRequest,
                                                    with: parameters)
        guard let url = urlRequest.url else {
            throw YelpRequestError(description: "Could not generate url!")
        }

        return url
    }

    private var parameters: [String: Any] {
        return [
            "term": "restaurant",
            "latitude": latitude,
            "longitude": longitude,
            "radius": radius
        ]
    }
}
