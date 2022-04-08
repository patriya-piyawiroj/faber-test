// Copyright © 2020 faber. All rights reserved.

import Foundation

final class TasteSwipeCardView: UIView {
    private struct Constants {
        static let cornerRadius: CGFloat = 10
    }

    struct ViewModel {
        let url: URL?
        let dishName: String
        let restaurantName: String
        let dishPrice: Double?
    }

    private let imageView: TasteSwipeCardImageView
    private let footerView: TasteSwipeFooterView

    // MARK: - Initializer

    init(viewModel: ViewModel) {
        imageView = TasteSwipeCardImageView(viewModel: TasteSwipeCardImageView.ViewModel(url: viewModel.url))
        footerView = TasteSwipeFooterView(viewModel: TasteSwipeFooterView.ViewModel(dishName: viewModel.dishName,
                                                                                    restaurantName: viewModel.restaurantName,
                                                                                    dishPrice: viewModel.dishPrice))

        super.init(frame: .zero)

        addSubview(imageView)
        addSubview(footerView)

        clipsToBounds = true
        layer.cornerRadius = Constants.cornerRadius
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()


        footerView.sizeToFit()
        footerView.frame = CGRect(x: 0,
                                  y: frame.maxY - footerView.frame.height,
                                  width: frame.width,
                                  height: footerView.frame.height)
        imageView.frame = CGRect(x: frame.minX,
                                 y: frame.minY,
                                 width: frame.width,
                                 height: frame.height - footerView.frame.height)
    }
}
