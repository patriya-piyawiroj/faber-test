// Copyright © 2020 faber. All rights reserved.

import UIKit

extension UIColor {
    enum ColorLuminance {
        case bright
        case dark
    }

    // MARK: - Hex

    convenience init?(rgbHexString: String) {
        let hexNSString = rgbHexString as NSString
        guard
            hexNSString.length == 6,
            let red = UIColor.scanHexComponent(from: hexNSString, in: NSRange(location: 0, length: 2)),
            let green = UIColor.scanHexComponent(from: hexNSString, in: NSRange(location: 2, length: 2)),
            let blue = UIColor.scanHexComponent(from: hexNSString, in: NSRange(location: 4, length: 2))
        else {
            return nil
        }

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }

    private static func scanHexComponent(from string: NSString, in range: NSRange) -> CGFloat? {
        let scanner = Scanner(string: string.substring(with: range))
        var value = UInt64(0)

        guard scanner.scanHexInt64(&value) else {
            return nil
        }

        return CGFloat(value) / 255.0
    }

    var rgbHexString: String {
        guard self != .white else {
            return "ffffff"
        }

        var red = CGFloat(0.0)
        var green = CGFloat(0.0)
        var blue = CGFloat(0.0)
        var alpha = CGFloat(0.0)

        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let redInt = Int(red * 255)
        let greenInt = Int(green * 255)
        let blueInt = Int(blue * 255)

        return String(format: "%02x%02x%02x", redInt, greenInt, blueInt)
    }

    // MARK: - Random Color

    static var random: UIColor {
        let red = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let green = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let blue = CGFloat(arc4random()) / CGFloat(UInt32.max)

        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }

    // MARK: Brightness

    func colorLuminance() -> ColorLuminance {
        var red = CGFloat(0)
        var green = CGFloat(0)
        var blue = CGFloat(0)
        var alpha = CGFloat(0)

        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) == true else {
            return .dark
        }

        // Relative luminance in colorimetric spaces - http://en.wikipedia.org/wiki/Luminance_(relative)
        red *= 0.2126
        green *= 0.7152
        blue *= 0.0722
        let luminance = red + green + blue

        return (luminance < 0.6) ? .dark : .bright
    }

    func colorLightened(amount: CGFloat) -> UIColor? {
        var red = CGFloat(0)
        var green = CGFloat(0)
        var blue = CGFloat(0)
        var alpha = CGFloat(0)

        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) == true else {
            return nil
        }

        red += (1.0 - red) * amount
        green += (1.0 - green) * amount
        blue += (1.0 - blue) * amount

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    func colorDarkened(amount: CGFloat) -> UIColor? {
        var red = CGFloat(0)
        var green = CGFloat(0)
        var blue = CGFloat(0)
        var alpha = CGFloat(0)

        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) == true else {
            return nil
        }

        red -= red * amount
        green -= green * amount
        blue -= blue * amount

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    func highlightColor(amount: CGFloat) -> UIColor? {
        if colorLuminance() == .bright {
            return colorDarkened(amount: amount)
        }
        else {
            return colorLightened(amount: amount)
        }
    }
}
