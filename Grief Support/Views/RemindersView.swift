//
//  RemindersView.swift
//  Grief Support
//
//  Created by Danielle Olson on 8/1/25.
//

import SwiftUI

struct RemindersView: View {
    @State private var reminders: [Reminder] = [
        Reminder(time: "8:00 AM", message: "Each day is a step forward in your healing journey.", isEnabled: true),
        Reminder(time: "12:00 PM", message: "Your loved one's memory lives on through your love.", isEnabled: true),
        Reminder(time: "6:00 PM", message: "It's okay to feel whatever you're feeling today.", isEnabled: true)
    ]
    @State private var showingAddReminder = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SectionHeaderView(title: "Daily Reminders")
                    
                    CardView {
                        VStack(spacing: 0) {
                            ForEach(reminders.indices, id: \.self) { index in
                                ReminderRow(reminder: $reminders[index])
                                
                                if index < reminders.count - 1 {
                                    Divider()
                                        .padding(.vertical, 8)
                                }
                            }
                        }
                    }
                    
                    PrimaryButton(title: "+ Add New Reminder") {
                        showingAddReminder = true
                    }
                    
                    SecondaryButton(title: "Customize Times") {
                        // TODO: Implement customize times
                    }
                }
                .padding()
                .padding(.top, 124) // Account for header height
            }
            .background(Color(UIColor.systemBackground))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddReminder) {
            AddReminderView(reminders: $reminders)
        }
    }
}

struct Reminder: Identifiable {
    let id = UUID()
    var time: String
    var message: String
    var isEnabled: Bool
}

struct ReminderRow: View {
    @Binding var reminder: Reminder
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(reminder.time)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "555879"))
                
                Text(reminder.message)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            CustomToggle(isOn: $reminder.isEnabled)
        }
        .padding(.vertical, 8)
    }
}

struct AddReminderView: View {
    @Binding var reminders: [Reminder]
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTime = Date()
    @State private var customMessage = ""
    
    let presetMessages = [
        "You are stronger than you know",
        "It's okay to take things one moment at a time",
        "Your feelings are valid",
        "Remember to be gentle with yourself",
        "You don't have to face this alone"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Time")) {
                    DatePicker("Reminder Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                }
                
                Section(header: Text("Message")) {
                    TextField("Custom message", text: $customMessage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section(header: Text("Or choose a preset message")) {
                    ForEach(presetMessages, id: \.self) { message in
                        Button(action: {
                            customMessage = message
                        }) {
                            Text(message)
                                .foregroundColor(.primary)
                                .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Add Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let formatter = DateFormatter()
                        formatter.timeStyle = .short
                        let timeString = formatter.string(from: selectedTime)
                        
                        let newReminder = Reminder(
                            time: timeString,
                            message: customMessage.isEmpty ? presetMessages[0] : customMessage,
                            isEnabled: true
                        )
                        reminders.append(newReminder)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    RemindersView()
}