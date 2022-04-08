// Copyright © 2020 faber. All rights reserved.

import Foundation

func dispatch_after(_ delay: TimeInterval,
                    _ closure: @escaping () -> Void) {
    let time = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: time,
                                  execute: closure)
}
