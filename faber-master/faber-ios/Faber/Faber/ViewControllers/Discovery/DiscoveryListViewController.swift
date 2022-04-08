// Copyright © 2020 faber. All rights reserved.

import UIKit

class DiscoveryListCollectionFlowLayout: UICollectionViewFlowLayout {

}

class DiscoveryListViewController: UIViewController,
    DiscoveryDataProviderDelegate,
    DrawerPresentable,
    UICollectionViewDelegateFlowLayout,
    UICollectionViewDataSource
{
    struct Constants {
        static let headerIdentifer = "discovery_header"
        static let cellIdentifier = "discovery_cell"
        static let headerReferenceSize = CGSize(width: 100, height: 100)
        static let cellSectionHeight: CGFloat = 200
    }
    private let sizingHeaderView = DiscoveryHeaderView(frame: .zero)
    private let collectionViewFlowLayout: DiscoveryListCollectionFlowLayout
    private let collectionView: UICollectionView
    private var recommendationModel: DiscoveryRecommendationModel? {
        didSet {
            if let recommendationModel = recommendationModel,
                recommendationModel != oldValue {
                sizingHeaderView.data = recommendationModel
                collectionView.reloadData()
            }
        }
    }
    private let loadingView = UIActivityIndicatorView(style: .large)

    // MARK: - Initializers

    init() {
        collectionViewFlowLayout = DiscoveryListCollectionFlowLayout()
        collectionViewFlowLayout.headerReferenceSize = Constants.headerReferenceSize
        collectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout: collectionViewFlowLayout)
        super.init(nibName: nil, bundle: nil)
        collectionView.register(DiscoveryHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: Constants.headerIdentifer)
        collectionView.register(DiscoveryListSectionCell.self,
                                forCellWithReuseIdentifier: Constants.cellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = UIColor.faberGray
        loadingView.backgroundColor = UIColor.faberGray
        view.addSubview(collectionView)
        view.addSubview(loadingView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        loadingView.frame = CGRect(x: 0,
                                   y: 0,
                                   width: view.bounds.width,
                                   height: collapsedHeight(for: view.frame.size))
    }

    // MARK: - Public

    func setLoading(_ loading: Bool) {
        loadingView.isHidden = !loading
        if loading {
            view.setNeedsLayout()
            loadingView.startAnimating()
            collectionView.contentOffset = .zero
        } else {
            loadingView.stopAnimating()
        }
    }

    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width,
                      height: Constants.cellSectionHeight)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return recommendationModel?.places.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier,
                                                      for: indexPath) as! DiscoveryListSectionCell
        if
            let recommendationModel = recommendationModel,
            recommendationModel.places.count > indexPath.row
        {
            cell.place = recommendationModel.places[indexPath.row]
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: Constants.headerIdentifer,
                for: indexPath)
            if
                let headerView = headerView as? DiscoveryHeaderView,
                let recommendationModel = recommendationModel
            {
                headerView.data = recommendationModel
            }
            return headerView
        }

        assertionFailure("Should have properly returned a header view!")
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        let height = sizingHeaderView.sizeThatFits(collectionView.frame.size).height
        return CGSize(width: collectionView.frame.width,
                      height: height)
    }

    // MARK: - DiscoveryDataProviderDelegate

    func discoveryDataProviderDidUpdateRecommendations(_ discoveryDataProvider: DiscoveryDataProvider) {
        recommendationModel = discoveryDataProvider.discoveryRecommendations
    }

    // MARK: - DrawerPresentable

    var drawerDragInteractiveHeight: CGFloat {
        guard let header = collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader).first else {
            return 0
        }

        // Look at scroll offset so that only dragging on the header will interact.
        return header.frame.height - collectionView.contentOffset.y
    }

    func collapsedHeight(for size: CGSize) -> CGFloat {
        return sizingHeaderView.sizeThatFits(size).height
    }
}
