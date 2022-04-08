// Copyright © 2020 faber. All rights reserved.

import UIKit
import AVFoundation

protocol CameraPreCaptureDelegate: AnyObject {
    func preCaptureViewControllerDidCapture(_ preCaptureViewController: CameraViewController,
                                            pixelBuffer: CVPixelBuffer,
                                            inferences: [Inference])
    func preCaptureViewControllerDidDismiss(_ preCaptureViewController: CameraViewController)
}

class CameraViewController: UIViewController {
    fileprivate let delayBetweenInferences: Double = 1000
    fileprivate var lastInferenceTime: TimeInterval = Date.distantPast.timeIntervalSince1970 * 1000

    private let previewView: CameraPreviewView
    private let overlayView: CameraOverlayView
    fileprivate var cameraManager: CameraManager!
    private let tfHandler: CameraTFHandler
    weak var delegate: CameraPreCaptureDelegate?

    // MARK: - Initializer

    init() {
        previewView = CameraPreviewView()
        overlayView = CameraOverlayView()
        tfHandler = CameraTFHandler()

        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = UIColor.faberGray
        overlayView.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        cameraManager = CameraManager(previewView: previewView,
                                      cameraConfiguration: CameraManager.Configuration.defaultConfiguration())
        cameraManager.delegate = self

        overlayView.switchCameraButton.isHidden = !cameraManager.canToggleCamera

        view.addSubview(previewView)
        view.addSubview(overlayView)
    }

    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      cameraManager.checkCameraConfigurationAndStartSession()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cameraManager.stopSession()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewView.frame = view.bounds
        overlayView.frame = view.bounds
    }

    // MARK: - Private

    private func update(with inferences: [Inference]) {
        DispatchQueue.main.async {
            self.overlayView.update(with: inferences)
        }
    }
}

extension CameraViewController: CameraManagerDelegate {
    func cameraManagerDidReceiveError(_ error: CameraManager.CameraError) {
        switch error {
        case .invalidConfiguration:
            break
        case .permissionDenied:
            break
        case .runtimeError:
            break
        }
    }

    func cameraManagerDidReceiveSampleBuffer(_ cameraManager: CameraManager, sampleBuffer: CMSampleBuffer) {
        let pixelBuffer: CVPixelBuffer? = CMSampleBufferGetImageBuffer(sampleBuffer)
        let currentTime = Date().timeIntervalSince1970 * 1000

        guard let imagePixelBuffer = pixelBuffer else {
            return
        }

        guard (currentTime - lastInferenceTime) >= delayBetweenInferences else {
            // Don't run the model too often.
            return
        }

        lastInferenceTime = currentTime
        tfHandler.runModelOn(pixelBuffer: imagePixelBuffer) { [weak self] result in
            guard let inferences = result?.inferences else { return }
            self?.update(with: inferences)
        }
    }
}

extension CameraViewController: CameraOverlayDelegate {
    func overlayViewDidTapClose(_ overlayView: CameraOverlayView) {
        delegate?.preCaptureViewControllerDidDismiss(self)
    }

    func overlayViewDidTapSwitch(_ overlayView: CameraOverlayView) {
        cameraManager.toggleCameraOrientation()
    }

    func overlayViewDidScale(to scale: CGFloat) {
        cameraManager.zoom(by: scale)
    }

    func overlayViewDidTapCapture(_ overlayView: CameraOverlayView) {
        cameraManager.captureWithCompletion { [weak self] result in
            switch result {
            case .error(_):
                // TODO: Implement error states.
                break
            case .success(let pixelBuffer):
                self?.tfHandler.runModelOn(pixelBuffer: pixelBuffer) { modelResult in
                    if let strongSelf = self {
                        strongSelf.delegate?.preCaptureViewControllerDidCapture(strongSelf,
                                                                                pixelBuffer: pixelBuffer,
                                                                                inferences: modelResult?.inferences ?? [])
                    }
                }
                break
            }
        }
    }
}
