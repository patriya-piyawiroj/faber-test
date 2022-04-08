// Copyright © 2020 faber. All rights reserved.

import Foundation

protocol CameraOverlayDelegate: AnyObject {
    func overlayViewDidTapClose(_ overlayView: CameraOverlayView)
    func overlayViewDidTapSwitch(_ overlayView: CameraOverlayView)
    func overlayViewDidScale(to scale: CGFloat)
    func overlayViewDidTapCapture(_ overlayView: CameraOverlayView)
}

class CameraOverlayView: UIView {
    private struct Constants {
        static let closeButtonSize = CGSize(width: 32, height: 32)
        static let closeButtonPadding: CGFloat = 12

        static let switchCameraButtonSize = CGSize(width: 44, height: 44)
        static let rotationDuration: TimeInterval = 0.5

        static let captureButtonSize = CGSize(width: 80, height: 80)
        static let captureButtonPadding: CGFloat = 40

        static let inferenceStackViewBottomSpacing: CGFloat = 120
    }

    let switchCameraButton = FaberButton(style: .switch)
    private let closeButton = FaberButton(style: .close)
    private let captureButton = CameraCaptureButton()
    private let inferenceStackView = CameraInferenceStackView()
    weak var delegate: CameraOverlayDelegate?

    // MARK: - Lifecycle

    init() {
        super.init(frame: .zero)
        backgroundColor = .clear

        closeButton.frame.size = Constants.closeButtonSize
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        addSubview(closeButton)

        switchCameraButton.frame.size = Constants.switchCameraButtonSize
        switchCameraButton.addTarget(self, action: #selector(didTapSwitch), for: .touchUpInside)
        addSubview(switchCameraButton)

        captureButton.frame.size = Constants.captureButtonSize
        captureButton.addTarget(self, action: #selector(didTapCapture), for: .touchUpInside)
        addSubview(captureButton)

        addSubview(inferenceStackView)

        setupDoubleTapRecognizer()
        setupPinchGestureRecognizer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    func update(with inferences: [Inference]) {
        inferenceStackView.update(with: inferences)
        setNeedsLayout()
    }

    // MARK: - Private

    private func setupDoubleTapRecognizer() {
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapRecognizer.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapRecognizer)
    }

    private func setupPinchGestureRecognizer() {
        let pinchTapRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        addGestureRecognizer(pinchTapRecognizer)
    }

    @objc
    private func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
        let scale = recognizer.scale
        delegate?.overlayViewDidScale(to: scale)

        // Need to reset the scale.
        recognizer.scale = 1.0
    }

    @objc
    private func handleDoubleTap() {
        switchCamera()
    }

    private func switchCamera() {
        delegate?.overlayViewDidTapSwitch(self)
        UIView.animate(withDuration: Constants.rotationDuration,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
                        self.switchCameraButton.transform = CGAffineTransform(rotationAngle: .pi)
        },
                       completion: { _ in
                        self.switchCameraButton.transform = CGAffineTransform.identity
        })
    }

    // MARK: - Button Taps

    @objc
    private func didTapClose() {
        delegate?.overlayViewDidTapClose(self)
    }

    @objc
    private func didTapSwitch() {
        switchCamera()
    }

    @objc
    private func didTapCapture() {
        delegate?.overlayViewDidTapCapture(self)
    }

    // MARK: - Overrides

    override func layoutSubviews() {
        super.layoutSubviews()

        closeButton.center = CGPoint(
            x: Constants.closeButtonPadding + Constants.closeButtonSize.width / 2,
            y: Constants.closeButtonPadding + Constants.closeButtonSize.height / 2 + safeAreaInsets.top
        )

        captureButton.center = CGPoint(
            x: frame.maxX / 2,
            y: frame.maxY - Constants.captureButtonPadding - Constants.captureButtonSize.height / 2
        )

        switchCameraButton.center = CGPoint(
            x: (captureButton.frame.maxX + frame.maxX) / 2,
            y: captureButton.center.y
        )

        let size = inferenceStackView.sizeThatFits(frame.size)
        inferenceStackView.frame = CGRect(x: 0,
                                          y: frame.maxY - Constants.inferenceStackViewBottomSpacing - size.height,
                                          width: size.width,
                                          height: size.height)
    }
}
