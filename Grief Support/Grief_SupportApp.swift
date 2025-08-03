//
//  Grief_SupportApp.swift
//  Grief Support
//
//  Created by Danielle Olson on 8/1/25.
//

import SwiftUI
import CoreText

@main
struct Grief_SupportApp: App {
    @AppStorage("useSystemTheme") private var useSystemTheme = true
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    init() {
        // Load custom fonts
        loadCustomFonts()
    }
    
    private func loadCustomFonts() {
        let fontNames = [
            "Chubbo-Regular", "Chubbo-Bold", "Chubbo-Medium", "Chubbo-Light", 
            "Melodrama-Regular", "Melodrama-Light", "Melodrama-Medium", "Melodrama-Bold", "Melodrama-Semibold",
            "Satoshi-Regular", "Satoshi-Medium", "Satoshi-Bold", "Satoshi-Light", "Satoshi-Black",
            "Satoshi-Italic", "Satoshi-MediumItalic", "Satoshi-BoldItalic", "Satoshi-LightItalic", "Satoshi-BlackItalic"
        ]
        
        for fontName in fontNames {
            guard let fontURL = Bundle.main.url(forResource: fontName, withExtension: "otf") else {
                print("❌ Could not find font file: \(fontName).otf")
                continue
            }
            
            var error: Unmanaged<CFError>?
            let success = CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error)
            
            if success {
                print("✅ Successfully registered font: \(fontName)")
            } else {
                if let error = error?.takeRetainedValue() {
                    print("❌ Failed to register font \(fontName): \(error)")
                } else {
                    print("❌ Failed to register font: \(fontName)")
                }
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(useSystemTheme ? nil : (isDarkMode ? .dark : .light))
        }
    }
}
