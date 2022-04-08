// Copyright © 2020 faber. All rights reserved.

import Foundation

final class CameraInferenceLabel: UILabel {
    private struct Constants {
        static let fontSize: CGFloat = 18
        static let textHorizontalInset: CGFloat = 10
        static let textVerticalInset: CGFloat = 5
        static let textColor = UIColor.faberLightText
    }
    private static let colors: [UIColor] = [
        UIColor.faberPink,
        UIColor.faberTan,
        UIColor.faberYellow,
        UIColor.faberTeal,
        UIColor.faberOrange,
    ]

    // MARK: - Initializer

    init(inferenceText: String,
         index: Int) {
        super.init(frame: .zero)
        text = inferenceText
        textColor = Constants.textColor
        font = UIFont.systemFont(ofSize: Constants.fontSize)
        layer.masksToBounds = true

        backgroundColor = CameraInferenceLabel.colors[index % CameraInferenceLabel.colors.count].withAlphaComponent(0.8)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(frame.width, frame.height) / 2
    }

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: Constants.textVerticalInset,
                                  left: Constants.textHorizontalInset,
                                  bottom: Constants.textVerticalInset,
                                  right: Constants.textHorizontalInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let insetSize = CGSize(width: size.width - 2 * Constants.textHorizontalInset,
                               height: size.height - 2 * Constants.textVerticalInset)
        let superSizeThatFits = super.sizeThatFits(insetSize)
        return CGSize(width: superSizeThatFits.width + 2 * Constants.textHorizontalInset,
                      height: superSizeThatFits.height + 2 * Constants.textVerticalInset)
    }
}
