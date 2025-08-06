//
//  ContentView.swift
//  Grief Support
//
//  Created by Danielle Olson on 8/1/25.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showSettings = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("useSystemTheme") private var useSystemTheme = true
    @EnvironmentObject var notificationCoordinator: NotificationCoordinator
    
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
                .environmentObject(notificationCoordinator)
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
        .onReceive(notificationCoordinator.$selectedTab) { newTab in
            // Sync tab selection from notification coordinator
            selectedTab = newTab
        }
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
    
    @State private var timer: Timer.TimerPublisher = Timer.publish(every: AppConstants.UI.quoteRotationInterval, on: .main, in: .common)
    @State private var timerSubscription: AnyCancellable?
    
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
        .onAppear {
            // Start the timer when view appears
            timerSubscription = timer.autoconnect().sink { _ in
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
        }
        .onDisappear {
            // Cancel timer when view disappears to prevent memory leak
            timerSubscription?.cancel()
            timerSubscription = nil
        }
    }
}


#Preview {
    ContentView()
}
