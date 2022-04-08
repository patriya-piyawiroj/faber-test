// Copyright © 2020 faber. All rights reserved.

import Foundation

final class CameraTFHandler {
    typealias RunCompletion = ((Result?) -> Void)
    var result: Result?
    private lazy var modelDataHandler: ModelDataHandler? = {
        let handler = ModelDataHandler(modelFileInfo: MobileNet.modelInfo,
                                       labelsFileInfo: MobileNet.labelsInfo,
                                       resultCount: 5)
        return handler
    }()
    private let modelQueue = DispatchQueue(label: "io.faberlabs.Faber.tfModelQueue")

    func runModelOn(pixelBuffer: CVPixelBuffer,
                    completion: @escaping RunCompletion) {
        modelQueue.async { [weak self] in
            let model = self?.modelDataHandler?.runModel(onFrame: pixelBuffer)
            completion(model)
        }
    }
}
