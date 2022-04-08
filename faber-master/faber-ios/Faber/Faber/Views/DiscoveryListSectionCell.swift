// Copyright © 2020 faber. All rights reserved.

import UIKit

class DiscoveryListSectionCell: UICollectionViewCell {
    private struct Constants {
        static let cornerRadius: CGFloat = 15
        static let verticalPadding: CGFloat = 10
        static let horizontalPadding: CGFloat = 10
    }
    var place: DiscoveryRecommendationModel.Place? {
        didSet {
            guard
                let place = place,
                place != oldValue
            else {
                return
            }
            nameLabel.text = place.name
            imageView.sd_setImage(with: URL(string: place.previewImageURL))
            ratingImageView.image = UIImage(named: starImageName(forRating: place.rating))
            setNeedsLayout()
        }
    }

    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let ratingImageView = UIImageView()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.layer.cornerRadius = Constants.cornerRadius
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)

        nameLabel.textColor = UIColor.faberLightText
        addSubview(nameLabel)

        ratingImageView.backgroundColor = UIColor.faberGray.colorLightened(amount: 0.3)?.withAlphaComponent(0.8)
        ratingImageView.contentMode = .center
        imageView.addSubview(ratingImageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let height = frame.height
        let labelHeight = height / 4
        nameLabel.frame = CGRect(x: Constants.horizontalPadding,
                                 y: 0,
                                 width: frame.width - 2 * Constants.horizontalPadding,
                                 height: labelHeight)
        let imageDimension = height - labelHeight - Constants.verticalPadding
        imageView.frame = CGRect(x: Constants.horizontalPadding,
                                 y: nameLabel.frame.maxY,
                                 width: imageDimension,
                                 height: imageDimension)

        let ratingHeight = imageDimension * 0.25
        ratingImageView.frame = CGRect(x: 0,
                                       y: imageDimension - ratingHeight,
                                       width: imageDimension,
                                       height: ratingHeight)
    }

    // MARK: - Private

    private func starImageName(forRating rating: Float) -> String {
        if rating <= 1.0 { return "yelp_stars_0_0" }
        else if rating <= 1.0 { return "yelp_stars_1_0" }
        else if rating <= 1.5 { return "yelp_stars_1_5" }
        else if rating <= 2.0 { return "yelp_stars_2_0" }
        else if rating <= 2.5 { return "yelp_stars_2_5" }
        else if rating <= 3.0 { return "yelp_stars_3_0" }
        else if rating <= 3.5 { return "yelp_stars_3_5" }
        else if rating <= 4.0 { return "yelp_stars_4_0" }
        else if rating <= 4.5 { return "yelp_stars_4_5" }
        else { return "yelp_stars_5_0" }
    }
}
