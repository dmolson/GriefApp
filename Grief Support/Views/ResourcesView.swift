//
//  ResourcesView.swift
//  Grief Support
//
//  Created by Danielle Olson on 8/1/25.
//

import SwiftUI

struct ResourcesView: View {
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
                                action: { /* TODO: Open link */ }
                            ),
                            Resource(
                                icon: "phone.fill",
                                title: "24/7 Grief Helpline",
                                subtitle: "1-800-GRIEF-00",
                                action: { /* TODO: Call number */ }
                            ),
                            Resource(
                                icon: "stethoscope",
                                title: "Therapist Directory",
                                subtitle: "Grief counseling specialists",
                                action: { /* TODO: Open directory */ }
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
                                action: { /* TODO: Open link */ }
                            ),
                            Resource(
                                icon: "house.fill",
                                title: "Local Narcotics Anonymous",
                                subtitle: "Find meetings near you",
                                action: { /* TODO: Open map */ }
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
                        // TODO: Add to calendar
                    }
                    
                    SecondaryButton(title: "Find Local Events") {
                        // TODO: Open local events
                    }
                }
                .padding()
                .padding(.top, 124) // Account for header height
            }
            .background(Color(UIColor.systemBackground))
            .navigationBarHidden(true)
        }
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
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color(hex: "555879"))
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
            .background(Color(hex: "F0EBE2"))
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
                .fill(Color(hex: "555879"))
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(date)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "555879"))
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(.leading, 15)
        }
    }
}

#Preview {
    ResourcesView()
}