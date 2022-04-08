// Copyright © 2020 faber. All rights reserved.

import UIKit

class FaberButton: UIButton {
    private struct Constants {
        static let backgroundAlpha: CGFloat = 0.6
        static let imageInsetPercentage: CGFloat = 0.25
    }

    enum Style {
        case `default`(themeColor: UIColor)
        case back
        case close
        case `switch`
        case swipeBack
        case swipeLike
        case swipeFavorite
        case swipeRefresh
        case swipeDislike

        var image: UIImage? {
            switch self {
            case .default:
                return nil
            case .back:
                // TODO: Attribution "back by Тимур Минвалеев from the Noun Project"
                return UIImage(named: "back")?.withRenderingMode(.alwaysTemplate)
            case .close:
                // TODO: Attribution "Close by AR Ehsan from the Noun Project"
                return UIImage(named: "close")?.withRenderingMode(.alwaysTemplate)
            case .switch:
                // TODO: Attribution "Rotate by Arafat Uddin from the Noun Project"
                return UIImage(named: "rotate")?.withRenderingMode(.alwaysTemplate)
            case .swipeBack:
                // TODO: Attribution "return by Adrien Coquet from the Noun Project"
                return UIImage(named: "swipe_back")?.withRenderingMode(.alwaysTemplate)
            case .swipeLike:
                // TODO: Attribution "Heart by i cons from the Noun Project"
                return UIImage(named: "swipe_like")?.withRenderingMode(.alwaysTemplate)
            case .swipeFavorite:
                // TODO: Attribution "Star by Yo! Baba from the Noun Project"
                return UIImage(named: "swipe_favorite")?.withRenderingMode(.alwaysTemplate)
            case .swipeRefresh:
                // TODO: Attribution "Refresh by Jardson Almeida from the Noun Project"
                return UIImage(named: "swipe_refresh")?.withRenderingMode(.alwaysTemplate)
            case .swipeDislike:
                // TODO: Attribution "Delete by Richard Kunák from the Noun Project"
                return UIImage(named: "swipe_dislike")?.withRenderingMode(.alwaysTemplate)
            }
        }

        var themeColor: UIColor {
            switch self {
            case .default(let color):
                return color
            case .back,
                 .close,
                 .switch,
                 .swipeBack,
                 .swipeLike,
                 .swipeFavorite,
                 .swipeRefresh,
                 .swipeDislike:
                return UIColor.darkText.withAlphaComponent(Constants.backgroundAlpha)
            }
        }

        var tintColor: UIColor? {
            switch self {
            case .default(_):
                return nil
            case .back,
                 .close,
                 .switch,
                 .swipeBack,
                 .swipeLike,
                 .swipeFavorite,
                 .swipeRefresh,
                 .swipeDislike:
                return UIColor.faberLightText
            }
        }

        var roundedCorners: Bool {
            switch self {
            case .default(_):
                return false
            case .back,
                 .close,
                 .switch,
                 .swipeBack,
                 .swipeLike,
                 .swipeFavorite,
                 .swipeRefresh,
                 .swipeDislike:
                return true
            }
        }
    }

    private let style: Style
    private let themeColor: UIColor

    var roundedCorners: Bool = false {
        didSet {
            guard roundedCorners != oldValue else { return }
            setNeedsLayout()
        }
    }

    var scaleFactor: CGFloat = 1.0 {
        didSet {
            guard scaleFactor != oldValue else { return }
            setNeedsLayout()
        }
    }

    // MARK: - Lifecycle

    required init(style: Style) {
        self.style = style
        themeColor = style.themeColor
        super.init(frame: .zero)
        backgroundColor = themeColor
        clipsToBounds = true
        tintColor = style.tintColor
        roundedCorners = style.roundedCorners
        setImage(style.image, for: .normal)
        imageView?.contentMode = .scaleAspectFit
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = roundedCorners ? frame.size.height / 2.0 : 0

        imageEdgeInsets = UIEdgeInsets(top: frame.height * Constants.imageInsetPercentage,
                                       left: frame.width * Constants.imageInsetPercentage,
                                       bottom: frame.height * Constants.imageInsetPercentage,
                                       right: frame.width * Constants.imageInsetPercentage)
    }

    // MARK: - Override

    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted
                ? 0.8
                : 1.0

            if scaleFactor != 1.0 {
                let scale = self.isHighlighted
                    ? 1.0 / scaleFactor
                    : 1.0
                UIView.animate(withDuration: 0.1) {
                    self.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
            }
        }
    }
}

