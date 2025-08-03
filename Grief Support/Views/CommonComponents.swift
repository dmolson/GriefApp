//
//  CommonComponents.swift
//  Grief Support
//
//  Created by Danielle Olson on 8/1/25.
//

import SwiftUI
import UIKit

// MARK: - Card View
struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Section Header
struct SectionHeaderView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.appHeadline)
            .foregroundColor(.primary)
    }
}

// MARK: - Primary Button
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.appHeadline)
                .foregroundColor(ThemeColors.adaptivePrimaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(ThemeColors.adaptivePrimaryBackground)
                .cornerRadius(8)
        }
    }
}

// MARK: - Secondary Button
struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.appHeadline)
                .foregroundColor(ThemeColors.adaptivePrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(ThemeColors.adaptivePrimary, lineWidth: 2)
                )
        }
    }
}

// MARK: - Toggle Switch
struct CustomToggle: View {
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle("", isOn: $isOn)
            .toggleStyle(SwitchToggleStyle(tint: ThemeColors.adaptiveAccent))
            .labelsHidden()
    }
}

// MARK: - Theme Colors
struct ThemeColors {
    static let primary = Color(hex: "555879")
    static let backgroundLight = Color(hex: "F4EFE8")
    static let backgroundCards = Color(hex: "F0EBE2")
    static let accent = Color(hex: "DED3C4")
    static let textPrimary = Color(hex: "333333")
    static let textSecondary = Color(hex: "6B6B6B")
    
    // Dark mode colors
    static let darkBackground = Color(hex: "2B3244")
    static let darkCards = Color(hex: "4A5068")
    static let darkBorders = Color(hex: "98A1BC")
    static let darkTextPrimary = Color(hex: "E8EBF0")
    static let darkTextSecondary = Color(hex: "B8C1D6")
    
    // Dynamic colors that adapt to light/dark mode
    static var adaptivePrimary: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor(hex: "555879")
        })
    }
    
    static var adaptivePrimaryBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor(hex: "555879")
        })
    }
    
    static var adaptivePrimaryText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "555879") : UIColor.white
        })
    }
    
    static var adaptiveAccent: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "A29ADB") : UIColor(hex: "3F2E63")
        })
    }
}


// MARK: - UIColor Extension
extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            alpha: Double(a) / 255
        )
    }
}