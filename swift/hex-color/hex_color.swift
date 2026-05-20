#!/usr/bin/env swift

import Foundation

// MARK: - Color Representation

struct Color {
    let r: Double // 0...1
    let g: Double
    let b: Double
    let a: Double

    init(r: Double, g: Double, b: Double, a: Double = 1.0) {
        self.r = min(max(r, 0), 1)
        self.g = min(max(g, 0), 1)
        self.b = min(max(b, 0), 1)
        self.a = min(max(a, 0), 1)
    }

    // MARK: - Factory Methods

    static func hex(_ input: String) -> Color? {
        let cleaned = input.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        var r: UInt64 = 0, g: UInt64 = 0, b: UInt64 = 0, a: UInt64 = 255
        switch cleaned.count {
        case 6:
            guard Scanner(string: String(cleaned.prefix(2))).scanHexInt64(&r),
                  Scanner(string: String(cleaned.dropFirst(2).prefix(2))).scanHexInt64(&g),
                  Scanner(string: String(cleaned.dropFirst(4).prefix(2))).scanHexInt64(&b) else { return nil }
        case 8:
            guard Scanner(string: String(cleaned.prefix(2))).scanHexInt64(&r),
                  Scanner(string: String(cleaned.dropFirst(2).prefix(2))).scanHexInt64(&g),
                  Scanner(string: String(cleaned.dropFirst(4).prefix(2))).scanHexInt64(&b),
                  Scanner(string: String(cleaned.dropFirst(6).prefix(2))).scanHexInt64(&a) else { return nil }
        default:
            return nil
        }
        return Color(r: Double(r) / 255, g: Double(g) / 255, b: Double(b) / 255, a: Double(a) / 255)
    }

    static func rgb(_ r: Int, _ g: Int, _ b: Int, a: Int = 255) -> Color {
        Color(r: Double(r) / 255, g: Double(g) / 255, b: Double(b) / 255, a: Double(a) / 255)
    }

    // MARK: - Computed Properties

    var rgb255: (r: Int, g: Int, b: Int, a: Int) {
        (Int(round(r * 255)), Int(round(g * 255)), Int(round(b * 255)), Int(round(a * 255)))
    }

    var hex: String {
        let c = rgb255
        return a == 1.0
            ? String(format: "#%02X%02X%02X", c.r, c.g, c.b)
            : String(format: "#%02X%02X%02X%02X", c.r, c.g, c.b, c.a)
    }

    var hsl: (h: Double, s: Double, l: Double) {
        let maxC = max(r, g, b), minC = min(r, g, b)
        let l = (maxC + minC) / 2
        guard maxC != minC else { return (0, 0, l) }
        let d = maxC - minC
        let s = l > 0.5 ? d / (2 - maxC - minC) : d / (maxC + minC)
        var h: Double
        switch maxC {
        case r: h = ((g - b) / d) + (g < b ? 6 : 0)
        case g: h = ((b - r) / d) + 2
        default: h = ((r - g) / d) + 4
        }
        return (h * 60, s, l)
    }
}

// MARK: - Formatted Output

extension Color: CustomStringConvertible {
    var description: String {
        let c = rgb255
        let h = hsl
        let alpha = c.a < 255 ? ", \(c.a)" : ""
        return """
        HEX: \(hex)
        RGB: rgb(\(c.r), \(c.g), \(c.b)\(alpha))
        HSL: hsl(\(Int(round(h.h)))\u{00B0}, \(Int(round(h.s * 100)))%, \(Int(round(h.l * 100)))%)
        """
    }
}

// MARK: - CLI

func printUsage() {
    print("Usage: hex_color <hex|#RRGGBB[AA]> | <R G B [A]>")
    print("Examples:")
    print("  hex_color #FF6B35")
    print("  hex_color #FF6B3580")
    print("  hex_color 255 107 53")
    print("  hex_color 255 107 53 128")
}

guard CommandLine.arguments.count > 1 else { printUsage(); exit(0) }

let args = Array(CommandLine.arguments.dropFirst())
let color: Color?

let isHexInput = args[0].hasPrefix("#") || (args.count == 1 && Set(args[0].lowercased()).isSubset(of: Set("0123456789abcdef")))
if isHexInput {
    color = Color.hex(args[0])
} else {
    let nums = args.compactMap(Int.init)
    color = nums.count >= 3 ? Color.rgb(nums[0], nums[1], nums[2], a: nums.count > 3 ? nums[3] : 255) : nil
}

if let color {
    print(color)
} else {
    print("Error: Invalid color input."); printUsage(); exit(1)
}
