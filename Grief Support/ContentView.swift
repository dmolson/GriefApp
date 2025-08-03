//
//  ContentView.swift
//  Grief Support
//
//  Created by Danielle Olson on 8/1/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showSettings = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("useSystemTheme") private var useSystemTheme = true
    
    var body: some View {
        TabView(selection: $selectedTab) {
            AskForHelpView()
                .tabItem {
                    Label("Ask for Help", systemImage: "hand.raised.fill")
                }
                .tag(0)
            
            RemindersView()
                .tabItem {
                    Label("Reminders", systemImage: "bell.fill")
                }
                .tag(1)
            
            RitualsView()
                .tabItem {
                    Label("Rituals", systemImage: "flame.fill")
                }
                .tag(2)
            
            ResourcesView()
                .tabItem {
                    Label("Resources", systemImage: "book.fill")
                }
                .tag(3)
        }
        .accentColor(ThemeColors.adaptiveAccent)
        .overlay(alignment: .top) {
            HeaderView(showSettings: $showSettings)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .preferredColorScheme(useSystemTheme ? nil : (isDarkMode ? .dark : .light))
        }
        .preferredColorScheme(useSystemTheme ? nil : (isDarkMode ? .dark : .light))
    }
}

struct HeaderView: View {
    @Binding var showSettings: Bool
    @State private var currentQuoteIndex = 0
    @State private var quoteOpacity = 1.0
    
    // Filter quotes to 3 lines maximum (approximately 60 characters per line)
    let quotes = [
        "Support through grief and remembrance",
        "You are not alone in your journey",
        "Healing happens one moment at a time",
        "Your feelings are valid and important",
        "Love lives on in memory and heart",
        "Take each day as it comes",
        "Your loved one's impact continues",
        // Skipping longer quotes to maintain consistent height
    ]
    
    let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("light after loss")
                        .font(.appHeaderTitle)
                        .foregroundColor(.white)
                    
                    Text(quotes[currentQuoteIndex])
                        .font(.quoteText)
                        .foregroundColor(.white.opacity(0.9))
                        .opacity(quoteOpacity)
                        .animation(.easeInOut(duration: 0.5), value: quoteOpacity)
                        .frame(height: 40, alignment: .top) // Fixed height for quote area
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Button(action: { showSettings = true }) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .padding(.top, 40) // Add extra padding from status bar
        }
        .background(Color(hex: "3F2E63")) // Make entire header background opaque
        .ignoresSafeArea(.all, edges: .top) // Extend to cover status bar area
        .onReceive(timer) { _ in
            withAnimation(.easeOut(duration: 0.25)) {
                quoteOpacity = 0.3
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                currentQuoteIndex = (currentQuoteIndex + 1) % quotes.count
                withAnimation(.easeIn(duration: 0.25)) {
                    quoteOpacity = 1.0
                }
            }
        }
        .onAppear {
            // Log skipped quotes for developer awareness
            let skippedQuotes = [
                "Grief is love with nowhere to go — Jamie Anderson",
                "Grief is the price we pay for love — Queen Elizabeth II", 
                "Grief changes shape, but it never ends — Keanu Reeves",
                "You don't move on from grief, you move forward with it — Nora McInerny",
                "Love is the bridge between you and everything — Rumi"
            ]
            for quote in skippedQuotes {
                print("⚠️ HeaderView: Skipped quote due to length: \(quote)")
            }
        }
    }
}

// Color extension for hex support
extension Color {
    init(hex: String) {
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
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
}
