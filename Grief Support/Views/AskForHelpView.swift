//
//  AskForHelpView.swift
//  Grief Support
//
//  Created by Danielle Olson on 8/1/25.
//

import SwiftUI

struct AskForHelpView: View {
    @State private var showingShareSheet = false
    @State private var messageToShare = ""
    
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
                            
                            HelpSuggestionView(text: "Help with grocery shopping, meal preparation, or food delivery to your doorstep")
                            HelpSuggestionView(text: "Assistance with household tasks such as dog walking, dishes, laundry, or childcare")
                            HelpSuggestionView(text: "Transportation to appointments or support groups")
                            HelpSuggestionView(text: "Help organizing memorial services or legal matters")
                            HelpSuggestionView(text: "Assistance with or company during cleaning out your loved one's belongings")
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
                            HelpSuggestionView(text: "Someone who encourages you to share memories of your loved one")
                            HelpSuggestionView(text: "A friend who asks about your loved one and wants to hear their stories")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Message Templates
                    SectionHeaderView(title: "Message Templates")
                    
                    CardView {
                        VStack(spacing: 12) {
                            MessageTemplateView(
                                title: "Hard Grief Day",
                                preview: "I'm having a hard grief day. I just need someone to listen so I wanted to reach out.",
                                action: { sendMessage($0) }
                            )
                            
                            MessageTemplateView(
                                title: "Asking for Company",
                                preview: "I'm having a really difficult day and could use some company. Would you be able to come over or talk on the phone?",
                                action: { sendMessage($0) }
                            )
                            
                            MessageTemplateView(
                                title: "Just Listening",
                                preview: "I need someone to talk to about what I'm going through. Are you free to listen for a bit?",
                                action: { sendMessage($0) }
                            )
                            
                            MessageTemplateView(
                                title: "Practical Help",
                                preview: "I'm struggling with daily tasks right now. Could you help me with groceries or a meal this week?",
                                action: { sendMessage($0) }
                            )
                            
                            MessageTemplateView(
                                title: "Thank You for Understanding",
                                preview: "Thank you for your support. I've needed some space and time lately, and I really appreciate you understanding that I haven't felt like talking much.",
                                action: { sendMessage($0) }
                            )
                            
                            MessageTemplateView(
                                title: "Need a Distraction",
                                preview: "I need a distraction from my grief. Do you have any good movies, shows, or podcasts that you can recommend me?",
                                action: { sendMessage($0) }
                            )
                            
                            MessageTemplateView(
                                title: "Important Dates Reminder",
                                preview: "[Date] is my loved one's birthday/anniversary. I wanted to let you know in case you'd like to check in on me that day.",
                                action: { sendMessage($0) }
                            )
                            
                            MessageTemplateView(
                                title: "Share a Memory",
                                preview: "Would you be open to me telling you a story about my loved one? I'd love to share a memory with someone.",
                                action: { sendMessage($0) }
                            )
                            
                            MessageTemplateView(
                                title: "Connect with Another Griever",
                                preview: "I know you're also grieving. Would you be up to talk about our loved ones for a while? I think it might help us both.",
                                action: { sendMessage($0) }
                            )
                            
                            MessageTemplateView(
                                title: "Work - Bereavement Leave",
                                preview: "I wanted to let you know that my loved one has passed away and I need to take some time off of work to handle arrangements and grieve.",
                                action: { sendMessage($0) }
                            )
                            
                            MessageTemplateView(
                                title: "Requesting a Sick Day",
                                preview: "I need to request a sick day today to take care of my mental health as I'm struggling with my grief.",
                                action: { sendMessage($0) }
                            )
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
                .padding(.top, 144) // Account for header height
            }
            .background(ThemeColors.adaptiveSystemBackground)
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [messageToShare])
        }
    }
    
    private func sendMessage(_ message: String) {
        // Set the message first
        messageToShare = message
        
        // Use a minimal delay to ensure state propagation
        DispatchQueue.main.async {
            showingShareSheet = true
        }
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
            .background(ThemeColors.adaptiveSecondaryBackground)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        // Ensure we have valid string content
        let validItems = activityItems.compactMap { item -> String? in
            if let string = item as? String, 
               !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return string
            }
            return nil
        }
        
        // Use the valid items or provide a fallback
        let finalItems: [String] = validItems.isEmpty ? 
            ["I'm reaching out because I need some support right now."] : validItems
        
        let controller = UIActivityViewController(
            activityItems: finalItems,
            applicationActivities: nil
        )
        
        // Configure for iPad compatibility first
        if let popover = controller.popoverPresentationController {
            // Get the current window scene
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                popover.sourceView = window.rootViewController?.view
                popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    AskForHelpView()
}
