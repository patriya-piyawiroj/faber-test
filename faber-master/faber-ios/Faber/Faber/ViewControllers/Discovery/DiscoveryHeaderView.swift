// Copyright © 2020 faber. All rights reserved.

import UIKit

class DiscoveryHeaderView: UICollectionReusableView {
    private struct Constants {
        static let defaultHeaderHeight: CGFloat = 100
    }

    private lazy var nearbyLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.faberLightText
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.text = NSLocalizedString("Nearby", comment: "Nearby label")
        return label
    }()
    private lazy var contextLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.faberLightText
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    private lazy var percentLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.faberLightText
        label.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private let imageCollectionView = ImageCollectionView()
    var data: DiscoveryRecommendationModel? {
        didSet {
            guard
                let data = data,
                data != oldValue
            else {
                return
            }
            let imageURLs: [URL] = data.places.compactMap { place in
                return URL(string: place.previewImageURL)
            }

            imageCollectionView.update(withImageURLs: Array(imageURLs.prefix(6)),
                                        imagesPerRow: 3,
                                        interImagePadding: 5)
            contextLabel.text = data.contextString
            percentLabel.text = String(format: "%.f%%", data.percentage * 100)
        }
    }

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(nearbyLabel)
        addSubview(contextLabel)
        addSubview(percentLabel)
        addSubview(imageCollectionView)
    }

    required init?(coder: NSCoder) {
        fatalError("Should not init with coder")
    }

    // MARK: - Sizing

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard data != nil else {
            return CGSize(width: size.width, height: Constants.defaultHeaderHeight)
        }
        let nearbyLabelHeight = nearbyLabel.sizeThatFits(size).height
        let contextLabelHeight = contextLabel.sizeThatFits(size).height
        let imageCollectionViewHeight = imageCollectionView.sizeThatFits(size).height
        let height = nearbyLabelHeight + contextLabelHeight + imageCollectionViewHeight + 40
        
        return CGSize(width: size.width,
                      height: height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        nearbyLabel.sizeToFit()
        nearbyLabel.frame.origin = CGPoint(x: 10, y: 10)
        
        contextLabel.sizeToFit()
        contextLabel.frame.origin = CGPoint(x: 10,
                                            y: nearbyLabel.frame.origin.y + nearbyLabel.frame.size.height + 5)
        
        percentLabel.frame = CGRect(x: frame.size.width * 0.6,
                                    y: 10,
                                    width: frame.size.width * 0.4 - 10,
                                    height: 40)
        
        let y = contextLabel.frame.origin.y + contextLabel.frame.size.height + 10
        imageCollectionView.frame = CGRect(x: 10,
                                           y: y,
                                           width: max(nearbyLabel.frame.width, contextLabel.frame.width),
                                           height: frame.size.height - y - 10)
    }
}
