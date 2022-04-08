// Copyright © 2020 faber. All rights reserved.

import Foundation
import AVFoundation

struct CameraCaptureError: Error { }

/// Manages a camera feed with callbacks for frame updates and capture API's.
final class CameraManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    enum CameraError {
        case invalidConfiguration
        case permissionDenied
        case runtimeError
    }

    struct Configuration {
        let sessionPreset: AVCaptureSession.Preset
        let videoGravity: AVLayerVideoGravity

        static func defaultConfiguration() -> Configuration {
            return Configuration(sessionPreset: .high,
                                 videoGravity: .resizeAspectFill)
        }
    }

    typealias CaptureCompletion = (CompletionResult<CVPixelBuffer>) -> Void
    private enum CaptureStatus {
        case idle
        case capturing(_ completion: CaptureCompletion)
    }

    private enum CameraConfiguration {
        case success
        case failed
        case permissionDenied
    }

    private enum CameraFacing {
        case uninitialized
        case front
        case back
    }

    var delegate: CameraManagerDelegate?
    var canToggleCamera: Bool {
        return frontCameraInput != nil
            && backCameraInput != nil
    }

    private let previewView: CameraPreviewView
    private let session: AVCaptureSession = AVCaptureSession()
    private let cameraSessionQueue = DispatchQueue(label: "cameraSessionQueue",
                                                   attributes: .concurrent)
    private let frontCameraInput: AVCaptureDeviceInput?
    private let backCameraInput: AVCaptureDeviceInput?

    private lazy var videoDataOutput: AVCaptureVideoDataOutput = {
        let output = AVCaptureVideoDataOutput()
        let sampleBufferQueue = DispatchQueue(label: "sampleBufferQueue")
        output.setSampleBufferDelegate(self, queue: sampleBufferQueue)
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [ String(kCVPixelBufferPixelFormatTypeKey) : kCMPixelFormat_32BGRA]

        return output
    }()
    private var isSessionRunning = false
    private var captureStatus = CaptureStatus.idle
    private var cameraConfiguration: CameraConfiguration = .failed
    private var lastPreviewFrame: CVPixelBuffer?
    private var cameraFacing = CameraFacing.uninitialized

    // MARK: - Initializer

    init(previewView: CameraPreviewView,
         cameraConfiguration: Configuration = Configuration.defaultConfiguration()) {
        self.previewView = previewView

        if let front = AVCaptureDevice.default(.builtInWideAngleCamera,
                                               for: .video,
                                               position: .front) {
            frontCameraInput = CameraManager.videoDeviceInputForCameraDevice(front)
        } else {
            frontCameraInput = nil
        }

        if let back = AVCaptureDevice.default(.builtInWideAngleCamera,
                                              for: .video,
                                              position: .back) {
            backCameraInput = CameraManager.videoDeviceInputForCameraDevice(back)
        } else {
            backCameraInput = nil
        }


        super.init()

        // Camera session setup.
        session.sessionPreset = cameraConfiguration.sessionPreset
        self.previewView.previewLayer.videoGravity = cameraConfiguration.videoGravity
        self.previewView.session = session

        self.attemptToConfigureSession()
    }

    // MARK: - Public API's

    func captureWithCompletion(_ completion: @escaping CaptureCompletion) {
        if let pixelBuffer = lastPreviewFrame {
            completion(.success(pixelBuffer))
        } else {
            // Wait for the next one.
            captureStatus = .capturing(completion)
        }
    }

    func zoom(by scale: CGFloat) {
        guard let input = (cameraFacing == .back
            ? backCameraInput
            : frontCameraInput)
            else {
                return
        }

        let maximum = input.device.activeFormat.videoMaxZoomFactor
        let newZoomScale = input.device.videoZoomFactor * scale
        let zoomScale = CGFloat.maximum(CGFloat.minimum(newZoomScale, maximum), 1)
        cameraSessionQueue.async {
            try? input.device.lockForConfiguration()
            input.device.videoZoomFactor = zoomScale
            input.device.unlockForConfiguration()
        }
    }

    func toggleCameraOrientation() {
        guard
            let front = frontCameraInput,
            let back = backCameraInput
            else {
                return
        }

        // Reset zoom scale.
        cameraSessionQueue.async {
            try? front.device.lockForConfiguration()
            front.device.videoZoomFactor = 1
            front.device.unlockForConfiguration()

            try? back.device.lockForConfiguration()
            back.device.videoZoomFactor = 1
            back.device.unlockForConfiguration()
        }


        switch cameraFacing {
        case .uninitialized,
             .front:
            cameraFacing = .back
            cameraSessionQueue.async {
                self.session.beginConfiguration()
                self.removeVideoDeviceInput(front)
                self.addVideoDeviceInput(back)
                self.session.commitConfiguration()
            }
            return
        case .back:
            cameraFacing = .front
            cameraSessionQueue.async {
                self.session.beginConfiguration()
                self.removeVideoDeviceInput(back)
                self.addVideoDeviceInput(front)
                self.session.commitConfiguration()
            }
            return
        }
    }

    // MARK: - Private

    private static func videoDeviceInputForCameraDevice(_ device: AVCaptureDevice) -> AVCaptureDeviceInput? {
        return try? AVCaptureDeviceInput(device: device)
    }

    // MARK: - Session Start and End methods

    func checkCameraConfigurationAndStartSession() {
        cameraSessionQueue.async {
            switch self.cameraConfiguration {
            case .success:
                self.addObservers()
                self.startSession()
            case .failed:
                DispatchQueue.main.async {
                    self.delegate?.cameraManagerDidReceiveError(.invalidConfiguration)
                }
            case .permissionDenied:
                DispatchQueue.main.async {
                    self.delegate?.cameraManagerDidReceiveError(.permissionDenied)
                }
            }
        }
    }

    func stopSession() {
        self.removeObservers()
        cameraSessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
            }
        }
    }

    func resumeInterruptedSession(withCompletion completion: @escaping (Bool) -> ()) {
        cameraSessionQueue.async {
            self.startSession()

            DispatchQueue.main.async {
                completion(self.isSessionRunning)
            }
        }
    }

    private func startSession() {
        self.session.startRunning()
        self.isSessionRunning = self.session.isRunning
    }

    // MARK: - Session Configuration Methods.

    private func attemptToConfigureSession() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.cameraConfiguration = .success
        case .notDetermined:
            self.cameraSessionQueue.suspend()
            self.requestCameraAccess(completion: { (granted) in
                self.cameraSessionQueue.resume()
            })
        case .denied:
            self.cameraConfiguration = .permissionDenied
        default:
            break
        }

        cameraSessionQueue.async {
            self.configureSession()
        }
    }

    private func requestCameraAccess(completion: @escaping (Bool) -> ()) {
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            if !granted {
                self.cameraConfiguration = .permissionDenied
            }
            else {
                self.cameraConfiguration = .success
            }
            completion(granted)
        }
    }


    private func configureSession() {
        guard cameraConfiguration == .success else { return }

        session.beginConfiguration()

        defer {
            self.session.commitConfiguration()
        }

        // Default to back camera. If not available, go to front.
        guard let input = backCameraInput ?? frontCameraInput else {
            self.cameraConfiguration = .failed
            return
        }

        // Tries to add an AVCaptureVideoDataOutput.
        guard addVideoDataOutput() else {
            self.cameraConfiguration = .failed
            return
        }

        addVideoDeviceInput(input)
        cameraFacing = .back


        self.cameraConfiguration = .success
    }

    private func addVideoDeviceInput(_ videoDeviceInput: AVCaptureDeviceInput) {
        guard session.canAddInput(videoDeviceInput) else { return }
        session.addInput(videoDeviceInput)
        configureConnection()
    }

    private func removeVideoDeviceInput(_ videoDeviceInput: AVCaptureDeviceInput) {
        session.removeInput(videoDeviceInput)
    }

    private func addVideoDataOutput() -> Bool {
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            videoDataOutput.connection(with: .video)?.videoOrientation = .portrait
            configureConnection()
            return true
        }

        return false
    }

    private func configureConnection() {
        videoDataOutput.connection(with: .video)?.videoOrientation = .portrait
        videoDataOutput.connection(with: .video)?.isVideoMirrored = cameraFacing == .front
    }

    // MARK: - Notification Observer Handling

    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(CameraManager.sessionRuntimeErrorOccured(notification:)), name: NSNotification.Name.AVCaptureSessionRuntimeError, object: session)
    }

    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVCaptureSessionRuntimeError, object: session)
    }

    // MARK: - Notification Observers

    @objc
    func sessionRuntimeErrorOccured(notification: Notification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else {
            return
        }

        if error.code == .mediaServicesWereReset {
            cameraSessionQueue.async {
                if self.isSessionRunning {
                    self.startSession()
                } else {
                    DispatchQueue.main.async {
                        self.delegate?.cameraManagerDidReceiveError(.runtimeError)
                    }
                }
            }
        } else {
            delegate?.cameraManagerDidReceiveError(.runtimeError)
        }
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            lastPreviewFrame = pixelBuffer

            switch captureStatus {
            case .idle:
                break
            case .capturing(let completion):
                completion(.success(pixelBuffer))
            }
        }

        delegate?.cameraManagerDidReceiveSampleBuffer(self,
                                                      sampleBuffer: sampleBuffer)
    }
}
