//
//  FontExtensions.swift
//  Grief Support
//
//  Created by Danielle Olson on 8/2/25.
//

import SwiftUI

extension Font {
    // MARK: - Chubbo Font (App Header)
    static func chubbo(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return Font.custom(chubboFontName(for: weight), size: size)
    }
    
    // MARK: - Excon Font (Headers)
    static func excon(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return Font.custom(exconFontName(for: weight), size: size)
    }
    
    // MARK: - Ranade Font (Body Text)
    static func ranade(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return Font.custom(ranadeFontName(for: weight), size: size)
    }
    
    // MARK: - Semantic Font Styles
    
    // Headers using Excon
    static let largeTitle = Font.excon(size: 34, weight: .bold)
    static let title1 = Font.excon(size: 28, weight: .bold)
    static let title2 = Font.excon(size: 22, weight: .bold)
    static let title3 = Font.excon(size: 20, weight: .semibold)
    static let headline = Font.excon(size: 17, weight: .semibold)
    static let subheadline = Font.excon(size: 15, weight: .medium)
    
    // Body text using Ranade
    static let body = Font.ranade(size: 17, weight: .regular)
    static let callout = Font.ranade(size: 16, weight: .regular)
    static let footnote = Font.ranade(size: 13, weight: .regular)
    static let caption1 = Font.ranade(size: 12, weight: .regular)
    static let caption2 = Font.ranade(size: 11, weight: .regular)
    
    // Custom app-specific styles
    static let appHeaderTitle = Font.chubbo(size: 28, weight: .bold) // Main "Light After Loss" header
    static let appTitle = Font.excon(size: 24, weight: .bold)
    static let tabTitle = Font.excon(size: 18, weight: .semibold)
    static let cardTitle = Font.excon(size: 16, weight: .semibold)
    static let supportiveText = Font.ranade(size: 15, weight: .medium)
    static let quoteText = Font.ranade(size: 15, weight: .medium)
    static let buttonText = Font.ranade(size: 16, weight: .medium)
}

// MARK: - Font Name Helpers
private func chubboFontName(for weight: Font.Weight) -> String {
    switch weight {
    case .ultraLight:
        return "Chubbo-Light"
    case .thin:
        return "Chubbo-Light"
    case .light:
        return "Chubbo-Light"
    case .regular:
        return "Chubbo-Regular"
    case .medium:
        return "Chubbo-Medium"
    case .semibold:
        return "Chubbo-Medium"  // Fallback to Medium since we don't have SemiBold
    case .bold:
        return "Chubbo-Bold"
    case .heavy:
        return "Chubbo-Bold"    // Fallback to Bold since we don't have ExtraBold
    case .black:
        return "Chubbo-Bold"    // Fallback to Bold since we don't have Black
    default:
        return "Chubbo-Regular"
    }
}

private func exconFontName(for weight: Font.Weight) -> String {
    switch weight {
    case .ultraLight:
        return "Excon-Thin"
    case .thin:
        return "Excon-Thin"
    case .light:
        return "Excon-Light"
    case .regular:
        return "Excon-Regular"
    case .medium:
        return "Excon-Medium"
    case .semibold:
        return "Excon-SemiBold"
    case .bold:
        return "Excon-Bold"
    case .heavy:
        return "Excon-ExtraBold"
    case .black:
        return "Excon-Black"
    default:
        return "Excon-Regular"
    }
}

private func ranadeFontName(for weight: Font.Weight) -> String {
    switch weight {
    case .ultraLight:
        return "Ranade-Thin"
    case .thin:
        return "Ranade-Thin"
    case .light:
        return "Ranade-Light"
    case .regular:
        return "Ranade-Regular"
    case .medium:
        return "Ranade-Medium"
    case .semibold:
        return "Ranade-SemiBold"
    case .bold:
        return "Ranade-Bold"
    case .heavy:
        return "Ranade-ExtraBold"
    case .black:
        return "Ranade-Black"
    default:
        return "Ranade-Regular"
    }
}

// MARK: - Font Loading Helper
struct FontLoader {
    static func loadFonts() {
        // This will help us debug font loading
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("Font Family: \(family)")
            for name in names {
                print("  Font Name: \(name)")
            }
        }
    }
}