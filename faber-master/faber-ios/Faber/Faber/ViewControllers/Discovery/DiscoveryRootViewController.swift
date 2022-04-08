// Copyright © 2020 faber. All rights reserved.

import MapKit
import UIKit

class DiscoveryRootViewController: UIViewController, CLLocationManagerDelegate, DiscoveryDataProviderDelegate  {
    private struct Constants {
        struct Hack {
            // HACK: Debug location data for now.
            static let debugCoordinates = CLLocationCoordinate2DMake(47.620843, -122.349088)
            static let debugRegionMeters = 1000.0
        }
        static let minimumDrawerSpacing: CGFloat = 180
        static let buttonSize = CGSize(width: 200, height: 45)
    }

    typealias Dependencies = FirestoreDependency & FirebaseAuthDependency

    let mapView = MKMapView()
    private var dataProvider: DiscoveryDataProvider
    private let recommendationsViewController: DiscoveryListViewController
    private let drawerViewController: DrawerViewController
    private lazy var searchButton: FaberButton = {
        let button = FaberButton(style: .default(themeColor: UIColor.faberLightGreen.withAlphaComponent(0.8)))
        button.roundedCorners = true
        button.frame = CGRect(origin: .zero, size: Constants.buttonSize)
        button.setTitle("Search Here", for: .normal)
        button.addTarget(self,
                         action: #selector(performSearch),
                         for: .touchUpInside)
        return button
    }()

    init(dependencies: DiscoveryRootViewController.Dependencies) {
        self.dataProvider = YelpDiscoveryDataProvider()
        recommendationsViewController = DiscoveryListViewController()
        drawerViewController = DrawerViewController(childViewController: recommendationsViewController)
        drawerViewController.drawerMinimumTopSpacing = Constants.minimumDrawerSpacing
        super.init(nibName: nil, bundle: nil)

        self.dataProvider.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.addSubview(searchButton)

        // Map setup
        view.addSubview(mapView)
        let coordinateRegion = MKCoordinateRegion(center: Constants.Hack.debugCoordinates,
                                                  latitudinalMeters: Constants.Hack.debugRegionMeters,
                                                  longitudinalMeters: Constants.Hack.debugRegionMeters)
        mapView.setRegion(coordinateRegion, animated: false)
    }

    // MARK: - DiscoveryDataProviderDelegate

    func discoveryDataProviderDidUpdateRecommendations(_ discoveryDataProvider: DiscoveryDataProvider) {
        recommendationsViewController.discoveryDataProviderDidUpdateRecommendations(discoveryDataProvider)
        recommendationsViewController.setLoading(false)
        drawerViewController.updateDrawerPosition(to: .collapsed)
        drawerViewController.enableDragging = true
    }

    // MARK: - Private

    @objc
    private func performSearch() {
        if drawerViewController.parent == nil {
            drawerViewController.present(on: self)
        }

        let coordinate = mapView.region.center
        recommendationsViewController.setLoading(true)
        drawerViewController.updateDrawerPosition(to: .collapsed)
        drawerViewController.enableDragging = false
        dataProvider.loadDataFor(latitude: coordinate.latitude,
                                 longitude: coordinate.longitude,
                                 radius: mapView.currentRadius)
    }
    
    // MARK: - Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        mapView.frame = view.bounds
        searchButton.center = CGPoint(x: mapView.bounds.center.x,
                                      y: view.safeAreaInsets.top + 20)
    }
}

private extension MKMapView {
    var topCenterCoordinate: CLLocationCoordinate2D {
        return self.convert(CGPoint(x: frame.size.width / 2.0, y: 0),
                            toCoordinateFrom: self)
    }

    var currentRadius: Double {
        let centerLocation = CLLocation(latitude: centerCoordinate.latitude,
                                        longitude: centerCoordinate.longitude)
        let topCenterLocation = CLLocation(latitude: topCenterCoordinate.latitude,
                                           longitude: topCenterCoordinate.longitude)
        return centerLocation.distance(from: topCenterLocation)
    }
}
