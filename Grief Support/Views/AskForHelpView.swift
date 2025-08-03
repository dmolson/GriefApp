//
//  AskForHelpView.swift
//  Grief Support
//
//  Created by Danielle Olson on 8/1/25.
//

import SwiftUI

struct AskForHelpView: View {
    @State private var showingShareSheet = false
    @State private var selectedMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Ideas for Asking for Help
                    SectionHeaderView(title: "Ideas for Asking for Help")
                    
                    // Practical Support
                    CardView {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Practical Support")
                                .font(.appHeadline)
                            
                            HelpSuggestionView(text: "Help with grocery shopping or meal preparation")
                            HelpSuggestionView(text: "Assistance with household tasks or childcare")
                            HelpSuggestionView(text: "Transportation to appointments or support groups")
                            HelpSuggestionView(text: "Help organizing memorial services or legal matters")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Emotional Support
                    CardView {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Emotional Support")
                                .font(.appHeadline)
                            
                            HelpSuggestionView(text: "Someone to listen without judgment")
                            HelpSuggestionView(text: "Companionship during difficult moments")
                            HelpSuggestionView(text: "Help processing difficult emotions")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Message Templates
                    SectionHeaderView(title: "Message Templates")
                    
                    CardView {
                        VStack(spacing: 12) {
                            MessageTemplateView(
                                title: "Asking for Company",
                                preview: "I'm having a really difficult day and could use some company. Would you be able to come over or talk on the phone?",
                                action: { sendMessage($0) }
                            )
                            
                            MessageTemplateView(
                                title: "Practical Help",
                                preview: "I'm struggling with daily tasks right now. Could you help me with groceries or a meal this week?",
                                action: { sendMessage($0) }
                            )
                            
                            MessageTemplateView(
                                title: "Just Listening",
                                preview: "I need someone to talk to about what I'm going through. Are you free to listen for a bit?",
                                action: { sendMessage($0) }
                            )
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
                .padding(.top, 144) // Account for header height
            }
            .background(Color(UIColor.systemBackground))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [selectedMessage])
        }
    }
    
    private func sendMessage(_ message: String) {
        selectedMessage = message
        showingShareSheet = true
    }
}

struct HelpSuggestionView: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(ThemeColors.adaptivePrimary.opacity(0.2))
                .frame(width: 6, height: 6)
                .offset(y: 6)
            
            Text(text)
                .font(.appBodySmall)
                .foregroundColor(.secondary)
        }
        .padding(.leading, 8)
    }
}

struct MessageTemplateView: View {
    let title: String
    let preview: String
    let action: (String) -> Void
    
    var body: some View {
        Button(action: { action(preview) }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title)
                        .font(.appHeadline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.forward.app")
                        .font(.system(size: 16))
                        .foregroundColor(ThemeColors.adaptivePrimary)
                }
                
                Text(preview)
                    .font(.appBodySmall)
                    .italic()
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        // Configure for iPad compatibility
        if let popover = controller.popoverPresentationController {
            popover.sourceView = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?.windows
                .first { $0.isKeyWindow }
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    AskForHelpView()
}