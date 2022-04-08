// Copyright © 2020 faber. All rights reserved.

import Alamofire
import Foundation
import SwiftyJSON

final class TasteDiscoveryNetworkSource {
    func requestDishesWithin(radius: Int,
                             randomized: Bool = true,
                             completion: @escaping ([TasteDiscoveryModel]) -> Void) {
        let parameters = ["radius": radius]
        AF.request(NetworkConstants.baseURL + "random_dishes",
                   parameters: parameters)
            .responseJSON { response in
                switch response.result {
                case let .success(result):
                    let resultJSON = JSON(result)

                    let tmp = resultJSON
                        .arrayValue
                        .flatMap({ return $0["menu_items"].arrayValue })

                    let models = tmp
                        .compactMap({ return TasteDiscoveryModel(json: $0) })

                    completion(randomized
                        ? models.shuffled()
                        : models)

                    break
                case let .failure(error):
                    print(error)
                    break
                }
        }
    }

    /// Fire and forget way of reviewing the dish. Will not retry.
    func reviewDish(_ dish: TasteDiscoveryModel,
                    rightSwipe: Bool) {
        let parameters: [String: Any] = [
            "content": rightSwipe ? "dislike" : "like",
            "rating": rightSwipe ? 1 : 5,
            "dish_ref": dish.id,
        ]
        _ = AF.request(NetworkConstants.baseURL + "dish_reviews",
                   method: .post,
                   parameters: parameters)
    }
}
