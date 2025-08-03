//
//  ResourcesView.swift
//  Grief Support
//
//  Created by Danielle Olson on 8/1/25.
//

import SwiftUI
import EventKit

struct ResourcesView: View {
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Emergency Banner
                    EmergencyBanner()
                    
                    // Grief Support
                    ResourceCategory(
                        title: "Grief Support",
                        resources: [
                            Resource(
                                icon: "person.2.fill",
                                title: "Grief Share Groups",
                                subtitle: "Find local support groups",
                                action: { 
                                    if let url = URL(string: "https://www.griefshare.org/findagroup") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            ),
                            Resource(
                                icon: "location.fill",
                                title: "Dougy Center Directory",
                                subtitle: "Grief support in your area",
                                action: { 
                                    if let url = URL(string: "https://www.dougy.org/program-finder?location=New%20York%2C%20NY") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            ),
                            Resource(
                                icon: "stethoscope",
                                title: "Therapist Directory",
                                subtitle: "Grief counseling specialists",
                                action: { 
                                    if let url = URL(string: "https://www.psychologytoday.com") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            )
                        ]
                    )
                    
                    // Addiction Resources
                    ResourceCategory(
                        title: "Addiction Resources",
                        resources: [
                            Resource(
                                icon: "heart.fill",
                                title: "Families Anonymous",
                                subtitle: "Support for families affected by addiction",
                                action: { 
                                    if let url = URL(string: "https://www.familiesanonymous.org") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            ),
                            Resource(
                                icon: "house.fill",
                                title: "Al-Anon",
                                subtitle: "Support for families and friends of alcoholics",
                                action: { 
                                    if let url = URL(string: "https://al-anon.org/al-anon-meetings/find-an-al-anon-meeting/") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            ),
                            Resource(
                                icon: "heart.circle.fill",
                                title: "Nar-Anon",
                                subtitle: "Support for families and friends affected by drug addiction",
                                action: { 
                                    if let url = URL(string: "https://www.nar-anon.org/find-a-meeting") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            )
                        ]
                    )
                    
                    // Awareness Events & Dates
                    SectionHeaderView(title: "Awareness Events & Dates")
                    
                    CardView {
                        VStack(spacing: 15) {
                            EventItem(
                                date: "August 31, 2025",
                                title: "International Overdose Awareness Day",
                                description: "A day to remember those who have died from overdose and acknowledge the grief felt by families and friends."
                            )
                            
                            EventItem(
                                date: "October 6-12, 2025",
                                title: "National Mental Health Awareness Week",
                                description: "Events focusing on mental health support and addiction awareness."
                            )
                            
                            EventItem(
                                date: "November 20, 2025",
                                title: "National Survivors of Suicide Loss Day",
                                description: "Support and healing for those who have lost someone to suicide."
                            )
                        }
                    }
                    
                    PrimaryButton(title: "Add Events to Calendar") {
                        addEventsToCalendar()
                    }
                    
                    SecondaryButton(title: "Find Local Events") {
                        // Open Eventbrite to search for grief support events
                        if let url = URL(string: "https://www.eventbrite.com/d/online/grief-support/") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                .padding()
                .padding(.top, 144) // Account for header height
            }
            .background(Color(UIColor.systemBackground))
            .navigationBarHidden(true)
        }
        .alert("Calendar Events", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func addEventsToCalendar() {
        let eventStore = EKEventStore()
        
        eventStore.requestFullAccessToEvents { granted, error in
            DispatchQueue.main.async {
                if granted {
                    createAwarenessEvents(eventStore: eventStore)
                } else {
                    alertMessage = "Calendar access denied. Please enable calendar access in Settings to add awareness events."
                    showingAlert = true
                }
            }
        }
    }
    
    private func createAwarenessEvents(eventStore: EKEventStore) {
        let events = [
            (
                title: "International Overdose Awareness Day",
                date: DateComponents(year: 2025, month: 8, day: 31),
                description: "A day to remember those who have died from overdose and acknowledge the grief felt by families and friends."
            ),
            (
                title: "National Mental Health Awareness Week",
                date: DateComponents(year: 2025, month: 10, day: 6),
                description: "Events focusing on mental health support and addiction awareness. (Runs through October 12)"
            ),
            (
                title: "National Survivors of Suicide Loss Day",
                date: DateComponents(year: 2025, month: 11, day: 20),
                description: "Support and healing for those who have lost someone to suicide."
            )
        ]
        
        var addedCount = 0
        var errorCount = 0
        
        for eventInfo in events {
            let event = EKEvent(eventStore: eventStore)
            event.title = eventInfo.title
            event.notes = eventInfo.description
            event.calendar = eventStore.defaultCalendarForNewEvents
            
            // Set as all-day event
            if let startDate = Calendar.current.date(from: eventInfo.date) {
                event.startDate = startDate
                event.endDate = startDate
                event.isAllDay = true
                
                // Add reminder 1 week before
                let alarm = EKAlarm(relativeOffset: -7 * 24 * 60 * 60) // 1 week in seconds
                event.addAlarm(alarm)
                
                do {
                    try eventStore.save(event, span: .thisEvent)
                    addedCount += 1
                } catch {
                    errorCount += 1
                }
            } else {
                errorCount += 1
            }
        }
        
        if addedCount > 0 {
            alertMessage = "Successfully added \(addedCount) awareness event(s) to your calendar with 1-week reminders."
        } else {
            alertMessage = "Failed to add events to calendar. Please try again."
        }
        showingAlert = true
    }
}

struct EmergencyBanner: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 18))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("You don't have to face this alone. If you're having thoughts of suicide or are in crisis, help is available right now.")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Call 988 for immediate support - trained counselors are available 24/7.")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                
                Text("If you're in immediate physical danger, call 911.")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.red)
        .cornerRadius(8)
    }
}

struct ResourceCategory: View {
    let title: String
    let resources: [Resource]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            SectionHeaderView(title: title)
            
            CardView {
                VStack(spacing: 8) {
                    ForEach(resources) { resource in
                        ResourceLink(resource: resource)
                    }
                }
            }
        }
    }
}

struct Resource: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
}

struct ResourceLink: View {
    let resource: Resource
    
    var body: some View {
        Button(action: resource.action) {
            HStack(spacing: 12) {
                Image(systemName: resource.icon)
                    .font(.system(size: 20))
                    .foregroundColor(ThemeColors.adaptivePrimaryText)
                    .frame(width: 40, height: 40)
                    .background(ThemeColors.adaptivePrimaryBackground)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(resource.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(resource.subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EventItem: View {
    let date: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Rectangle()
                .fill(ThemeColors.adaptivePrimary)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(date)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ThemeColors.adaptivePrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.leading, 15)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ResourcesView()
}
