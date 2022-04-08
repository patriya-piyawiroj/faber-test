// Copyright © 2020 faber. All rights reserved.

import Foundation
import AVFoundation

protocol CameraManagerDelegate {
    func cameraManagerDidReceiveError(_ error: CameraManager.CameraError)

    func cameraManagerDidReceiveSampleBuffer(_ cameraManager: CameraManager,
                                             sampleBuffer: CMSampleBuffer)
}
