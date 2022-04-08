// Copyright © 2020 faber. All rights reserved.

import CoreGraphics

extension CGSize {
    /// Returns the width to height aspect ratio.
    public var aspectRatio: CGFloat? {
        if height == 0.0 {
            return nil
        }
        
        return width / height
    }
}

extension CGRect {
    public var center: CGPoint {
        return CGPoint(x: avg(minX, maxX),
                       y: avg(minY, maxY))
    }
}

public func avg(_ lhs: CGFloat,
                _ rhs: CGFloat) -> CGFloat {
    return (lhs + rhs) / 2.0
}
