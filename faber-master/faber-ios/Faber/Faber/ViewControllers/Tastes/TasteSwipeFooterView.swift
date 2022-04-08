// Copyright © 2020 faber. All rights reserved.

import Foundation

final class TasteSwipeFooterView: UIView {
    struct ViewModel {
        let dishName: String
        let restaurantName: String
        let dishPrice: Double?
    }

    private struct Constants {
        static let interitemSpacing: CGFloat = 4
        static let verticalSpacing: CGFloat = 10
        static let horizontalSpacing: CGFloat = 10
    }

    private let dishNameLabel: UILabel
    private let restaurantLabel: UILabel
    private let priceLabel: UILabel?

    private let viewModel: ViewModel

    // MARK: Initializer

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        dishNameLabel = TasteSwipeFooterView.createDishNameLabel(viewModel.dishName)
        restaurantLabel = TasteSwipeFooterView.createRestaurantLabel(viewModel.restaurantName)
        if let price = viewModel.dishPrice {
            priceLabel = TasteSwipeFooterView.createPriceLabel(price)
        } else {
            priceLabel = nil
        }

        super.init(frame: .zero)

        backgroundColor = UIColor(rgbHexString: "F5F6FA")
        addSubview(dishNameLabel)
        addSubview(restaurantLabel)

        if let priceLabel = priceLabel {
            addSubview(priceLabel)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        dishNameLabel.sizeToFit()
        dishNameLabel.frame = CGRect(x: Constants.horizontalSpacing,
                                     y: Constants.verticalSpacing,
                                     width: frame.width - 2 * Constants.horizontalSpacing,
                                     height: dishNameLabel.frame.height)

        var maxY = dishNameLabel.frame.maxY

        if let priceLabel = priceLabel {
            priceLabel.sizeToFit()
            priceLabel.frame = CGRect(x: Constants.horizontalSpacing,
                                      y: maxY + Constants.interitemSpacing,
                                      width: frame.width - 2 * Constants.horizontalSpacing,
                                      height: priceLabel.frame.height)

            maxY = priceLabel.frame.maxY
        }

        restaurantLabel.sizeToFit()
        restaurantLabel.frame = CGRect(x: Constants.horizontalSpacing,
                                  y: maxY + Constants.interitemSpacing,
                                  width: frame.width - 2 * Constants.horizontalSpacing,
                                  height: restaurantLabel.frame.height)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let height = (2 * Constants.verticalSpacing
            + dishNameLabel.sizeThatFits(size).height
            + restaurantLabel.sizeThatFits(size).height
            + Constants.interitemSpacing)

        if let priceLabel = priceLabel {
            let adjustedHeight = (height
                + priceLabel.sizeThatFits(size).height
                + Constants.interitemSpacing)

            return CGSize(width: size.width,
                          height: adjustedHeight)
        } else {
            return CGSize(width: size.width,
                          height: height)
        }
    }

    // MARK: - Private

    private static func createDishNameLabel(_ name: String) -> UILabel {
        let label = UILabel()
        label.text = name
        label.textColor = UIColor.faberGray
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return label
    }

    private static func createRestaurantLabel(_ restaurant: String) -> UILabel {
        let label = UILabel()
        label.text = restaurant
        label.textColor = UIColor.faberGray
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        return label
    }

    private static func createPriceLabel(_ price: Double) -> UILabel {
        let label = UILabel()
        label.text = String(format: "$%.2f", price)
        label.textColor = UIColor.faberGray
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        return label
    }
}
