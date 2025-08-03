//
//  FontExtensions.swift
//  Grief Support
//
//  Created by Danielle Olson on 8/2/25.
//

import SwiftUI
import UIKit

// MARK: - Font Configuration
struct FontConfig {
    // Set USE_SATOSHI to false to quickly revert to system fonts
    static let USE_SATOSHI = false
}

extension Font {
    // MARK: - Chubbo Font (App Header)
    static func chubbo(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return Font.custom(chubboFontName(for: weight), size: size)
    }
    
    // MARK: - Melodrama Font (Headers) - Replacing unavailable Excon
    static func melodrama(size: CGFloat) -> Font {
        return Font.custom("Melodrama-Medium", size: size)
    }
    
    static func excon(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        // Excon fonts not available, using Melodrama as fallback
        return Font.custom(melodramaFontName(for: weight), size: size)
    }
    
    // MARK: - Satoshi Font (Body Text)
    static func satoshi(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        if FontConfig.USE_SATOSHI {
            return Font.custom(satoshiFontName(for: weight), size: size)
        } else {
            return Font.system(size: size, weight: weight)
        }
    }
    
    // MARK: - Semantic Font Styles
    
    // Headers using Excon
    static let largeTitle = Font.excon(size: 34, weight: .bold)
    static let title1 = Font.excon(size: 28, weight: .bold)
    static let title2 = Font.excon(size: 22, weight: .bold)
    static let title3 = Font.excon(size: 20, weight: .semibold)
    static let headline = Font.excon(size: 17, weight: .semibold)
    static let subheadline = Font.excon(size: 15, weight: .medium)
    
    // Body text using Satoshi
    static let body = Font.satoshi(size: 17, weight: .regular)
    static let callout = Font.satoshi(size: 16, weight: .regular)
    static let footnote = Font.satoshi(size: 13, weight: .regular)
    static let caption1 = Font.satoshi(size: 12, weight: .regular)
    static let caption2 = Font.satoshi(size: 11, weight: .regular)
    
    // Custom app-specific styles
    static let appHeaderTitle = Font.custom("Chubbo-Light", size: 35) // Main "light after loss" header
    static let appTitle = Font.excon(size: 24, weight: .bold)
    static let tabTitle = Font.excon(size: 18, weight: .semibold)
    static let cardTitle = Font.excon(size: 16, weight: .semibold)
    static let supportiveText = Font.satoshi(size: 15, weight: .medium)
    static let quoteText = Font.satoshi(size: 15, weight: .medium)
    static let buttonText = Font.satoshi(size: 16, weight: .medium)
    
    // Easy to use app font aliases
    static let appBody = Font.satoshi(size: 16, weight: .regular)
    static let appBodySmall = Font.satoshi(size: 14, weight: .regular)
    static let appBodyLarge = Font.satoshi(size: 18, weight: .regular)
    static let appCaption = Font.satoshi(size: 12, weight: .regular)
    static let appHeadline = Font.satoshi(size: 18, weight: .medium)
    static let appLargeTitle = Font.satoshi(size: 24, weight: .bold)
    static let appSubheadline = Font.satoshi(size: 15, weight: .medium)
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

private func melodramaFontName(for weight: Font.Weight) -> String {
    switch weight {
    case .ultraLight:
        return "Melodrama-Light"
    case .thin:
        return "Melodrama-Light"
    case .light:
        return "Melodrama-Light"
    case .regular:
        return "Melodrama-Regular"
    case .medium:
        return "Melodrama-Medium"
    case .semibold:
        return "Melodrama-Semibold"
    case .bold:
        return "Melodrama-Bold"
    case .heavy:
        return "Melodrama-Bold"
    case .black:
        return "Melodrama-Bold"
    default:
        return "Melodrama-Medium"
    }
}

private func exconFontName(for weight: Font.Weight) -> String {
    // Excon fonts not available, using Melodrama as fallback
    return melodramaFontName(for: weight)
}

private func satoshiFontName(for weight: Font.Weight) -> String {
    switch weight {
    case .ultraLight:
        return "Satoshi-Light"
    case .thin:
        return "Satoshi-Light"
    case .light:
        return "Satoshi-Light"
    case .regular:
        return "Satoshi-Regular"
    case .medium:
        return "Satoshi-Medium"
    case .semibold:
        return "Satoshi-Bold"
    case .bold:
        return "Satoshi-Bold"
    case .heavy:
        return "Satoshi-Black"
    case .black:
        return "Satoshi-Black"
    default:
        return "Satoshi-Regular"
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