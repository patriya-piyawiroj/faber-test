// Copyright © 2020 faber. All rights reserved.

import UIKit

final class CameraCaptureButton: UIButton {
    private struct Constants {
        static let color = UIColor.faberLightText
        static let outerLineWidth: CGFloat = 4
        static let clearWidth: CGFloat = 4
    }

    // MARK: - Override

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let color = isHighlighted
            ? Constants.color.withAlphaComponent(0.8)
            : Constants.color

        let outerPath = UIBezierPath(ovalIn: rect.insetBy(dx: Constants.outerLineWidth,
                                                          dy: Constants.outerLineWidth))
        color.setStroke()
        outerPath.lineWidth = Constants.outerLineWidth
        outerPath.stroke()

        let innerPath = UIBezierPath(ovalIn: rect.insetBy(dx: Constants.outerLineWidth + Constants.clearWidth,
                                                          dy: Constants.outerLineWidth + Constants.clearWidth))
        color.setFill()
        innerPath.fill()
    }

    override var isHighlighted: Bool {
        didSet {
            setNeedsDisplay()
        }
    }
}
