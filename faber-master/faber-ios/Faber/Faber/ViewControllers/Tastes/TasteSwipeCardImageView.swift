// Copyright © 2020 faber. All rights reserved.

import Foundation

final class TasteSwipeCardImageView: UIView {
    struct ViewModel {
        let url: URL?
    }

    private let backgroundImageView = UIImageView()
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let imageView = UIImageView()

    // MARK: - Initializer

    init(viewModel: ViewModel) {
        super.init(frame: .zero)

        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.sd_setImage(with: viewModel.url)

        imageView.contentMode = .scaleAspectFit
        imageView.sd_setImage(with: viewModel.url)

        addSubview(backgroundImageView)
        addSubview(blurView)
        addSubview(imageView)

        clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundImageView.frame = frame
        blurView.frame = frame
        imageView.frame = frame
    }
}
