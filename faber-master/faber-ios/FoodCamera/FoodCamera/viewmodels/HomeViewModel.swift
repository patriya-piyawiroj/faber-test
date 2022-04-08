//
//  HomeViewModel.swift
//  FoodCamera
//
//  Created by Faber Labs on 4/13/20.
//  Copyright © 2020 Yinghui Linda He. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct HomeState {
    // a dict of [cuisine types: restaurants under the cuisine type]
    var restaurantsByTypes = [String: [Restaurant]]()
    var isFetching = true
    
    var locationByUser = [String : String]()
}

enum HomeInput {
    case search(String)  //TODO
}

class HomeViewModel: ViewModel {
    @Published private(set) var state = HomeState()
    
    private var disposables: Set<AnyCancellable> = []
    
    var restaurantsFetcher = FetchRestaurantsService()
    var userLocationUpdater = UpdateUserLocationService()
    var locationManager = LocationManager();
    var placeSearcher = PlaceSearchService();
    let userID: String = "5GqSKMHVOmAUsRoM9E8C";
    
    // FIXME: currently this doesn't seem to work when the app starts
    var userLatitude: String {
        return "\(locationManager.lastLocation?.coordinate.latitude ?? 34.0221506)";
    }
    var userLongitude: String {
        return "\(locationManager.lastLocation?.coordinate.longitude ?? -118.2875205)";
    }
    
    // checks whether the dict of restaurants is not set yet to display the loading status
    private var isFetchingPublisher: AnyPublisher<Bool, Never> {
        restaurantsFetcher.$isFetching
            .receive(on: RunLoop.main)
            .map { $0 }
            .eraseToAnyPublisher()
    }
    
    // receives the dict of restaurants
    private var restaurantsFetchedPublisher: AnyPublisher<[String: [Restaurant]], Never> {
        return restaurantsFetcher.$restaurantsByTypes
            .receive(on: RunLoop.main)
            .map { $0 }
            .eraseToAnyPublisher()
    }
    
    private var locationSetByUserPublisher: AnyPublisher<[String: String], Never> {
        return placeSearcher.$locationByUser
            .receive(on: RunLoop.main)
            .map { $0 }
            .eraseToAnyPublisher()
    }
    
    init() {
        isFetchingPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.state.isFetching, on: self)
            .store(in: &disposables)
        
        restaurantsFetchedPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.state.restaurantsByTypes, on: self)
            .store(in: &disposables)
        
        locationSetByUserPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.state.locationByUser, on: self)
            .store(in: &disposables)
        
        userLocationUpdater.updateUserLocation(userID: self.userID, latitude: self.userLatitude, longitude: self.userLongitude)
        restaurantsFetcher.fetchRecRestaurants(userID: self.userID, latitude: self.userLatitude, longitude: self.userLongitude)
    }

    func trigger(_ input: HomeInput) {
        switch input {
            // the user searches for a location
            case .search(let toSearch):
                // placeSearcher gets the coordinates of the location and gets recommended restaruants
                placeSearcher.searchPlace(placeToSearch: toSearch, completion: { location in
                    self.restaurantsFetcher.fetchRecRestaurants(userID: self.userID, latitude: location["lat"] ?? self.userLatitude, longitude: location["lng"] ?? self.userLongitude)
            })
        }
    }
}
