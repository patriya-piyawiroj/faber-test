// Copyright © 2020 faber. All rights reserved.

import Foundation

final class CameraInferenceStackView: UIView {
    private struct Constants {
        static let stackViewSpacing: CGFloat = 5
        static let verticalPadding: CGFloat = 10
        static let horizontalPadding: CGFloat = 10
        static let maximumStackViewElements = 5
    }

    private var labels: [CameraInferenceLabel]?

    // MARK: - Initializer

    init() {
        super.init(frame: .zero)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    func update(with inferences: [Inference]) {
        // Remove old labels.
        labels?.forEach { label in
            label.removeFromSuperview()
        }

        // Add new labels.
        let labels: [CameraInferenceLabel] = inferences.enumerated().compactMap { index, inference in
            guard index < Constants.maximumStackViewElements else { return nil }
            return CameraInferenceLabel(inferenceText: inference.label, index: index)
        }

        labels.forEach { label in
            addSubview(label)
        }
        self.labels = labels
        setNeedsLayout()
    }

    // MARK: - Layout

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let labels = labels else { return .zero }

        let sizeWithMargins = CGSize(width: size.width - 2 * Constants.horizontalPadding,
                                     height: size.height)
        var height: CGFloat = 0
        for (index, label) in labels.enumerated() {
            height += label.sizeThatFits(sizeWithMargins).height
            if index != 0 {
                height += Constants.stackViewSpacing
            }
        }
        height += 2 * Constants.verticalPadding
        return CGSize(width: size.width,
                      height: height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let labels = labels else { return }

        let width = frame.size.width - 2 * Constants.horizontalPadding

        var y = Constants.verticalPadding
        labels.forEach { label in
            let sizeWithMargins = CGSize(width: width,
                                         height: frame.size.height)
            let size = label.sizeThatFits(sizeWithMargins)
            label.frame = CGRect(x: Constants.horizontalPadding,
                                 y: y,
                                 width: size.width,
                                 height: size.height)

            y += size.height + Constants.stackViewSpacing
        }
    }
}
