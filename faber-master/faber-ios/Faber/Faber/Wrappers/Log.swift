// Copyright © 2020 faber. All rights reserved.

import Foundation

public func Log(_ format: String, _ args: CVarArg...) {
    let message = String(format: format, arguments:args)

    #if DEBUG
    print(message);
    #endif

    TFLogv(message, getVaList([]))
}
