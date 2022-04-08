// Copyright © 2020 faber. All rights reserved.

import Foundation

protocol CameraPostCaptureDelegate: AnyObject {
    func postCaptureViewControllerDidDismiss(_ postCaptureViewController: CameraPostCaptureViewController)
    func postCaptureViewControllerDidFinish(_ postCaptureViewController: CameraPostCaptureViewController)
}

final class CameraPostCaptureViewController: UIViewController, CameraPostCaptureOverlayDelegate {
    weak var delegate: CameraPostCaptureDelegate?

    private let imageView = UIImageView()
    private let overlayView: CameraPostCaptureOverlayView

    private let pixelBuffer: CVPixelBuffer

    // MARK: Initializer

    init(pixelBuffer: CVPixelBuffer,
         inferences: [Inference]) {
        self.pixelBuffer = pixelBuffer
        self.overlayView = CameraPostCaptureOverlayView(inferences: inferences)
        super.init(nibName: nil, bundle: nil)

        overlayView.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.faberGray

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let image = UIImage(ciImage: ciImage)
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        
        // ImageView needs to be added first, on the bottom.
        view.addSubview(imageView)
        view.addSubview(overlayView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        overlayView.frame = view.bounds
        imageView.bounds = view.bounds
        imageView.center = view.center
    }

    // MARK: - CameraPostCaptureOverlayDelegate

    private var imageScale: CGFloat = 1 {
        didSet {
            guard imageScale != oldValue else { return }
            updateTransform()
        }
    }

    private var imageRotation: CGFloat = 0 {
        didSet {
            guard imageRotation != oldValue else { return }
            updateTransform()
        }
    }

    private var imageTranslation: (tx: CGFloat, ty: CGFloat) = (0, 0) {
        didSet {
            guard
                imageTranslation.tx != oldValue.tx
                    || imageTranslation.ty != oldValue.ty
                else {
                    return
            }
            updateTransform()
        }
    }

    private func updateTransform() {
        imageView.transform = CGAffineTransform.identity
            .scaledBy(x: imageScale,
                      y: imageScale)
            .rotated(by: imageRotation)
            .translatedBy(x: imageTranslation.tx,
                          y: imageTranslation.ty)
    }

    private var transform: CGAffineTransform = .identity {
        didSet {
            guard transform != oldValue else { return }
            imageView.transform = transform
        }
    }

    func overlayViewDidTapBack(_ overlayView: CameraPostCaptureOverlayView) {
        delegate?.postCaptureViewControllerDidDismiss(self)
    }

    private var lastRotation: CGFloat = 0
    func overlayViewDidRotate(_ rotation: CGFloat,
                              isStart: Bool) {
        if isStart {
            lastRotation = rotation
        } else {
            lastRotation = rotation - lastRotation
            imageRotation = lastRotation
        }
    }

    func overlayViewDidPan(to point: CGPoint) {
        imageTranslation = (point.x, point.y)
    }

    func overlayViewDidScale(to scale: CGFloat) {
        imageScale = CGFloat.maximum(imageScale * scale, 0.5)
    }

    func overlayViewDidTapNext(_ overlayView: CameraPostCaptureOverlayView) {

    }
}
