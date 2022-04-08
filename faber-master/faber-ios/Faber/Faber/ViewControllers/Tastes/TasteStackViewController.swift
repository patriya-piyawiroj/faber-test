// Copyright © 2020 faber. All rights reserved.

import Foundation
import Shuffle_iOS
import SDWebImage

final class TasteStackViewController: UIViewController {
    private struct Constants {
        static let verticalCardScale: CGFloat = 0.8
        static let horizontalCardScale: CGFloat = 0.9
        static let footerBarHeight: CGFloat = 80

        // TBD. Threshold needs to be tuned.
        static let prefetchThreshold = 3
    }

    private let footerBar = TasteMasterFooterBarView()
    private let networkSource = TasteDiscoveryNetworkSource()
    private let cardStackView = SwipeCardStack()
    private var fetching = false

    /// Alwasy call `updateModels`, do not update this directly.
    private var dishModels = [TasteDiscoveryModel]()

    // MARK: - Initializer

    init() {
        super.init(nibName: nil, bundle: nil)

        footerBar.delegate = self
        cardStackView.dataSource = self
        cardStackView.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func fetchData() {
        guard !fetching else { return }
        fetching = true
        networkSource.requestDishesWithin(radius: 10,
                                          randomized: true) { [weak self] models in
                                            self?.fetching = false
                                            self?.updateModels(models)
        }
    }

    // MARK: - Private

    /// Always call this, do not directly update the models.
    private func updateModels(_ models: [TasteDiscoveryModel]) {
        dishModels += models
        // This assumes that there are not duplicates shown.
        cardStackView.reloadData()
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.faberLightText
        view.addSubview(cardStackView)

        view.addSubview(footerBar)

        fetchData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = view.frame.width * Constants.horizontalCardScale
        footerBar.frame = CGRect(x: (view.frame.width - width) / 2,
                                 y: view.frame.maxY - Constants.footerBarHeight,
                                 width: width,
                                 height: Constants.footerBarHeight)

        let availableHeight = view.frame.height - Constants.footerBarHeight
        cardStackView.frame.size = CGSize(width: width,
                                          height: availableHeight * Constants.verticalCardScale)
        cardStackView.center.x = view.center.x
        cardStackView.frame.origin.y = (availableHeight - cardStackView.frame.height) * Constants.verticalCardScale
    }
}

extension TasteStackViewController: TasteMasterFooterBarViewDelegate {
    func barViewDidSelectBack(_ barView: TasteMasterFooterBarView) {
        // Work in progress.
    }

    func barViewDidSelectLike(_ barView: TasteMasterFooterBarView) {
        cardStackView.swipe(.right, animated: true)
    }

    func barViewDidSelectFavorite(_ barView: TasteMasterFooterBarView) {
        // Work in progress.
    }

    func barViewDidSelectRefresh(_ barView: TasteMasterFooterBarView) {
        // Work in progress.
    }

    func barViewDidSelectDislike(_ barView: TasteMasterFooterBarView) {
        cardStackView.swipe(.left, animated: true)
    }
}

extension TasteStackViewController: SwipeCardStackDelegate {

    // MARK: - SwipeCardStackDelegate

    func cardStack(_ cardStack: SwipeCardStack,
                   didSelectCardAt index: Int) {
        // No-op.
    }

    func cardStack(_ cardStack: SwipeCardStack,
                   didSwipeCardAt index: Int,
                   with direction: SwipeDirection) {
        if index >= dishModels.count - Constants.prefetchThreshold
            && !fetching {
            fetchData()
        }

        let dish = dishModels[index]
        networkSource.reviewDish(dish,
                                 rightSwipe: direction == .right)
    }

    func cardStack(_ cardStack: SwipeCardStack,
                   didUndoCardAt index: Int,
                   from direction: SwipeDirection) {
        // No-op.
    }

    func didSwipeAllCards(_ cardStack: SwipeCardStack) {
        if !fetching {
            fetchData()
        }
    }

    func shouldRecognizeHorizontalDrag(on cardStack: SwipeCardStack) -> Bool {
        return true
    }

    func shouldRecognizeVerticalDrag(on cardStack: SwipeCardStack) -> Bool {
        return false
    }
}

extension TasteStackViewController: SwipeCardStackDataSource {

    // MARK: - SwipeCardStackDataSource

    func cardStack(_ cardStack: SwipeCardStack,
                   cardForIndexAt index: Int) -> SwipeCard {
        let model = dishModels[index]

        let card = SwipeCard()
        card.swipeDirections = [.left, .right]

        let viewModel = TasteSwipeCardView.ViewModel(url: URL(string: model.imageURLs.first!),
                                                     dishName: model.dishName ?? "Unnamed Dish",
                                                     restaurantName: model.businessName,
                                                     dishPrice: model.price)
        card.content = TasteSwipeCardView(viewModel: viewModel)

        return card
    }

    func numberOfCards(in cardStack: SwipeCardStack) -> Int {
        return dishModels.count
    }
}
