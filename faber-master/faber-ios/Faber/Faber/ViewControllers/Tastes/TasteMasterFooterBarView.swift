// Copyright © 2020 faber. All rights reserved.

import Foundation

protocol TasteMasterFooterBarViewDelegate: AnyObject {
    func barViewDidSelectBack(_ barView: TasteMasterFooterBarView)
    func barViewDidSelectLike(_ barView: TasteMasterFooterBarView)
    func barViewDidSelectFavorite(_ barView: TasteMasterFooterBarView)
    func barViewDidSelectRefresh(_ barView: TasteMasterFooterBarView)
    func barViewDidSelectDislike(_ barView: TasteMasterFooterBarView)
}

final class TasteMasterFooterBarView: UIView {
    private struct Constants {
        static let largeSmallCircleRatio: CGFloat = 1.3
        static let horizontalSpacing: CGFloat = 20
        static let interitemSpacing: CGFloat = 10
        static let scaleFactor: CGFloat = 1.2
    }

    weak var delegate: TasteMasterFooterBarViewDelegate?

    // Order is back, dislike, refresh, like, favorite
    private let backButton: FaberButton
    private let dislikeButton: FaberButton
    private let refreshButton: FaberButton
    private let likeButton: FaberButton
    private let favoriteButton: FaberButton

    // MARK: - Initializer

    init() {
        backButton = FaberButton(style: .swipeBack)
        dislikeButton = FaberButton(style: .swipeDislike)
        refreshButton = FaberButton(style: .swipeRefresh)
        likeButton = FaberButton(style: .swipeLike)
        favoriteButton = FaberButton(style: .swipeFavorite)

        super.init(frame: .zero)

        backButton.addTarget(self,
                             action: #selector(didTapBack),
                             for: .touchUpInside)
        dislikeButton.addTarget(self,
                                action: #selector(didTapDislike),
                                for: .touchUpInside)
        refreshButton.addTarget(self,
                                action: #selector(didTapRefresh),
                                for: .touchUpInside)
        likeButton.addTarget(self,
                             action: #selector(didTapLike),
                             for: .touchUpInside)
        favoriteButton.addTarget(self,
                                 action: #selector(didTapFavorite),
                                 for: .touchUpInside)
        addSubview(backButton)
        addSubview(dislikeButton)
        addSubview(refreshButton)
        addSubview(likeButton)
        addSubview(favoriteButton)

        backButton.scaleFactor = Constants.scaleFactor
        dislikeButton.scaleFactor = Constants.scaleFactor
        refreshButton.scaleFactor = Constants.scaleFactor
        likeButton.scaleFactor = Constants.scaleFactor
        favoriteButton.scaleFactor = Constants.scaleFactor

        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        let horizontalSpace = (frame.width
            - 2 * Constants.horizontalSpacing
            - 4 * Constants.interitemSpacing)

        // There are 3 small buttons, 2 large buttons.
        let totalWeight = 2 * Constants.largeSmallCircleRatio + 3
        let smallCircleSize = horizontalSpace / totalWeight
        let largeCircleSize = smallCircleSize * Constants.largeSmallCircleRatio


        // Small button sizing.
        backButton.frame.size = CGSize(width: smallCircleSize,
                                       height: smallCircleSize)
        refreshButton.frame.size = CGSize(width: smallCircleSize,
                                          height: smallCircleSize)
        favoriteButton.frame.size = CGSize(width: smallCircleSize,
                                           height: smallCircleSize)

        // Large button sizing.
        dislikeButton.frame.size = CGSize(width: largeCircleSize,
                                          height: largeCircleSize)
        likeButton.frame.size = CGSize(width: largeCircleSize,
                                       height: largeCircleSize)

        // Start at the middle.
        refreshButton.center = bounds.center

        let spacing = (largeCircleSize + smallCircleSize) / 2 + Constants.interitemSpacing

        // Work our way left.
        dislikeButton.center = CGPoint(x: refreshButton.center.x - spacing,
                                       y: refreshButton.center.y)
        backButton.center = CGPoint(x: refreshButton.center.x - 2 * spacing,
                                    y: refreshButton.center.y)

        // Work our way right.
        likeButton.center = CGPoint(x: refreshButton.center.x + spacing,
                                    y: refreshButton.center.y)
        favoriteButton.center = CGPoint(x: refreshButton.center.x + 2 * spacing,
                                        y: refreshButton.center.y)
    }

    // MARK: - Button Actions

    @objc
    private func didTapBack() {
        delegate?.barViewDidSelectBack(self)
    }

    @objc
    private func didTapLike() {
        delegate?.barViewDidSelectLike(self)
    }

    @objc
    private func didTapFavorite() {
        delegate?.barViewDidSelectFavorite(self)
    }

    @objc
    private func didTapRefresh() {
        delegate?.barViewDidSelectRefresh(self)
    }

    @objc
    private func didTapDislike() {
        delegate?.barViewDidSelectDislike(self)
    }
}
