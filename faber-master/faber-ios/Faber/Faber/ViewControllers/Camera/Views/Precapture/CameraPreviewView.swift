// Copyright © 2020 faber. All rights reserved.

import Foundation
import AVFoundation

/// Preview for camera stream.
class CameraPreviewView: UIView {
    var previewLayer: AVCaptureVideoPreviewLayer {
      guard let layer = layer as? AVCaptureVideoPreviewLayer else {
        fatalError("Layer expected is of type VideoPreviewLayer")
      }
      return layer
    }

    var session: AVCaptureSession? {
      get {
        return previewLayer.session
      }
      set {
        previewLayer.session = newValue
      }
    }

    override class var layerClass: AnyClass {
      return AVCaptureVideoPreviewLayer.self
    }
}
