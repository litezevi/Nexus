//
//  NexusApp.swift
//  NexusApp
//

import SwiftUI

@main
struct NexusApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

// MARK: - Unified Color System

extension Color {
    init?(hex: String) {
        let hexSanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&int) else {
            return nil
        }
        
        let red, green, blue: Double
        switch hexSanitized.count {
        case 6: // RGB (RRGGBB)
            red = Double((int >> 16) & 0xFF) / 255.0
            green = Double((int >> 8) & 0xFF) / 255.0
            blue = Double(int & 0xFF) / 255.0
        default:
            return nil
        }
        
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1.0)
    }
    
    // Статические цвета (определены только один раз)
    static let darkGray = Color(hex: "#1C1C1E") ?? Color.black
    static let lightGray = Color(hex: "#E5E5E5") ?? Color.white
    static let mediumGray = Color(hex: "#2C2C2E") ?? Color.gray
}

extension UIColor {
    convenience init?(hex: String) {
        let hexSanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&int) else {
            return nil
        }
        
        let red, green, blue: CGFloat
        switch hexSanitized.count {
        case 6: // RGB (RRGGBB)
            red = CGFloat((int >> 16) & 0xFF) / 255.0
            green = CGFloat((int >> 8) & 0xFF) / 255.0
            blue = CGFloat(int & 0xFF) / 255.0
        default:
            return nil
        }
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    // Статические цвета (определены только один раз)
    static let darkGray = UIColor(hex: "#1C1C1E") ?? UIColor.black
    static let lightGray = UIColor(hex: "#E5E5E5") ?? UIColor.white
    static let mediumGray = UIColor(hex: "#2C2C2E") ?? UIColor.gray
}
