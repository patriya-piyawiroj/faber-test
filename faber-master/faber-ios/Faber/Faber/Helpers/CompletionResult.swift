// Copyright © 2020 faber. All rights reserved.

import Foundation

enum CompletionResult<T> {
    case success(_ result: T)
    case error(_ error: Error)
}
