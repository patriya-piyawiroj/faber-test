// Copyright © 2020 faber. All rights reserved.

import Foundation

final class CameraFlowManager: NSObject {
    enum State {
        case precapture
        case postcapture(pixelBuffer: CVPixelBuffer, inferences: [Inference])

        // TODO: Add metadata
        case upload
    }

    var viewController: UIViewController {
        return rootViewController
    }
    private let rootViewController = RootViewController()
    private let cameraViewController = CameraViewController()

    private var state: State = .precapture {
        didSet {
            // TODO: Guard against same state transitions.
            update()
        }
    }

    override init() {
        super.init()
        rootViewController.modalPresentationStyle = .fullScreen
        rootViewController.delegate = self
        cameraViewController.delegate = self
        update()
    }

    private func update() {
        DispatchQueue.main.async {
            switch self.state {
            case .precapture:
                self.rootViewController.set(childController: self.cameraViewController)
                break
            case .postcapture(let pixelBuffer, let inferences):
                let postCaptureViewController = CameraPostCaptureViewController(pixelBuffer: pixelBuffer,
                                                                                inferences: inferences)
                postCaptureViewController.delegate = self
                self.rootViewController.set(childController: postCaptureViewController)
                break
            case .upload:
                // WIP: Not implemented.
                break
            }
        }
    }
}

extension CameraFlowManager: RootViewControllerDelegate {
    func rootViewControllerViewWillAppear(_ rootViewController: RootViewController, animated: Bool) {
        // No-op.
    }

    func rootViewControllerViewDidAppear(_ rootViewController: RootViewController, animated: Bool) {
        // No-op.
    }

    func rootViewControllerViewWillDisappear(_ rootViewController: RootViewController, animated: Bool) {
        // No-op.
    }

    func rootViewControllerViewDidDisappear(_ rootViewController: RootViewController, animated: Bool) {
        state = .precapture
    }
}

extension CameraFlowManager: CameraPreCaptureDelegate {
    func preCaptureViewControllerDidCapture(_ preCaptureViewController: CameraViewController,
                                            pixelBuffer: CVPixelBuffer,
                                            inferences: [Inference]) {
        state = .postcapture(pixelBuffer: pixelBuffer,
                             inferences: inferences)
    }

    func preCaptureViewControllerDidDismiss(_ preCaptureViewController: CameraViewController) {
        state = .precapture
        rootViewController.dismiss(animated: true, completion: nil)
    }
}

extension CameraFlowManager: CameraPostCaptureDelegate {
    func postCaptureViewControllerDidDismiss(_ postCaptureViewController: CameraPostCaptureViewController) {
        state = .precapture
    }

    func postCaptureViewControllerDidFinish(_ postCaptureViewController: CameraPostCaptureViewController) {
        state = .upload
    }
}
