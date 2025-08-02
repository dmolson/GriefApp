//
//  AskForHelpView.swift
//  Grief Support
//
//  Created by Danielle Olson on 8/1/25.
//

import SwiftUI
import MessageUI

struct AskForHelpView: View {
    @State private var showingMessageCompose = false
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
                                .font(.system(size: 16, weight: .semibold))
                            
                            HelpSuggestionView(text: "Help with grocery shopping or meal preparation")
                            HelpSuggestionView(text: "Assistance with household tasks or childcare")
                            HelpSuggestionView(text: "Transportation to appointments or support groups")
                            HelpSuggestionView(text: "Help organizing memorial services or legal matters")
                        }
                    }
                    
                    // Emotional Support
                    CardView {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Emotional Support")
                                .font(.system(size: 16, weight: .semibold))
                            
                            HelpSuggestionView(text: "Someone to listen without judgment")
                            HelpSuggestionView(text: "Companionship during difficult moments")
                            HelpSuggestionView(text: "Help processing difficult emotions")
                        }
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
                    }
                }
                .padding()
                .padding(.top, 124) // Account for header height
            }
            .background(Color(UIColor.systemBackground))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingMessageCompose) {
            MessageComposeView(messageText: selectedMessage)
        }
    }
    
    private func sendMessage(_ message: String) {
        selectedMessage = message
        if MFMessageComposeViewController.canSendText() {
            showingMessageCompose = true
        } else {
            // Fallback: Copy to clipboard
            UIPasteboard.general.string = message
        }
    }
}

struct HelpSuggestionView: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Color(hex: "555879").opacity(0.2))
                .frame(width: 6, height: 6)
                .offset(y: 6)
            
            Text(text)
                .font(.system(size: 14))
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
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.forward.app")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "555879"))
                }
                
                Text(preview)
                    .font(.custom("CormorantGaramond-Regular", size: 15))
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

struct MessageComposeView: UIViewControllerRepresentable {
    let messageText: String
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let controller = MFMessageComposeViewController()
        controller.body = messageText
        controller.messageComposeDelegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        let parent: MessageComposeView
        
        init(_ parent: MessageComposeView) {
            self.parent = parent
        }
        
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    AskForHelpView()
}