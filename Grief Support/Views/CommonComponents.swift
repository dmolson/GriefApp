//
//  CommonComponents.swift
//  Grief Support
//
//  Created by Danielle Olson on 8/1/25.
//

import SwiftUI

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
            .font(.system(size: 18, weight: .semibold))
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
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(hex: "555879"))
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
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "555879"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(hex: "555879"), lineWidth: 2)
                )
        }
    }
}

// MARK: - Toggle Switch
struct CustomToggle: View {
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle("", isOn: $isOn)
            .toggleStyle(SwitchToggleStyle(tint: Color(hex: "555879")))
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
}