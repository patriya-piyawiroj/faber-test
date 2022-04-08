// Copyright © 2020 faber. All rights reserved.

import Foundation

protocol CameraPostCaptureOverlayDelegate: AnyObject {
    func overlayViewDidTapBack(_ overlayView: CameraPostCaptureOverlayView)
    func overlayViewDidScale(to scale: CGFloat)
    func overlayViewDidPan(to point: CGPoint)
    func overlayViewDidRotate(_ rotation: CGFloat, isStart: Bool)
    func overlayViewDidTapNext(_ overlayView: CameraPostCaptureOverlayView)
}

class CameraPostCaptureOverlayView: UIView, UIGestureRecognizerDelegate {
    private struct Constants {
        static let inferenceStackViewBottomSpacing: CGFloat = 120

        static let backButtonSize = CGSize(width: 32, height: 32)
        static let backButtonPadding: CGFloat = 12
    }

    private let backButton = FaberButton(style: .back)
    private let inferenceStackView = CameraInferenceStackView()
    weak var delegate: CameraPostCaptureOverlayDelegate?

    // MARK: - Lifecycle

    init(inferences: [Inference]) {
        super.init(frame: .zero)
        backgroundColor = .clear

        backButton.frame.size = Constants.backButtonSize
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        addSubview(backButton)
        addSubview(inferenceStackView)
        inferenceStackView.update(with: inferences)

        // WIP: Add gesture recognizers if necessary.
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

    private func setupPinchGestureRecognizer() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self,
                                                              action: #selector(handlePinch(_:)))
        pinchGestureRecognizer.delegate = self
        addGestureRecognizer(pinchGestureRecognizer)
    }

    private func setupRotationGestureRecognizer() {
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self,
                                                                    action: #selector(handleRotation(_:)))
        rotationGestureRecognizer.delegate = self
        addGestureRecognizer(rotationGestureRecognizer)
    }

    private func setupPanGestureRecognizer() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                          action: #selector(handlePan(_:)))
        panGestureRecognizer.minimumNumberOfTouches = 2
        panGestureRecognizer.maximumNumberOfTouches = 2
        panGestureRecognizer.delegate = self
        addGestureRecognizer(panGestureRecognizer)
    }

    @objc
    private func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
        let scale = recognizer.scale
        delegate?.overlayViewDidScale(to: scale)

        // Need to reset the scale.
        recognizer.scale = 1.0
    }

    @objc
    private func handleRotation(_ recognizer: UIRotationGestureRecognizer) {
        delegate?.overlayViewDidRotate(recognizer.rotation,
                                       isStart: recognizer.state == .began)
    }

    @objc
    private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: self)
        delegate?.overlayViewDidPan(to: CGPoint(x: location.x - bounds.midX,
                                                y: location.y - bounds.midY))
    }

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // All gesture recognizers on this view should be able to work with each other.
        return true
    }

    // MARK: - Button Taps

    @objc
    private func didTapBack() {
        delegate?.overlayViewDidTapBack(self)
    }

    // MARK: - Overrides

    override func layoutSubviews() {
        super.layoutSubviews()

        backButton.center = CGPoint(
            x: Constants.backButtonPadding + Constants.backButtonSize.width / 2,
            y: Constants.backButtonPadding + Constants.backButtonSize.height / 2 + safeAreaInsets.top
        )

        let size = inferenceStackView.sizeThatFits(frame.size)
        inferenceStackView.frame = CGRect(x: 0,
                                          y: frame.maxY - Constants.inferenceStackViewBottomSpacing - size.height,
                                          width: size.width,
                                          height: size.height)
    }
}
