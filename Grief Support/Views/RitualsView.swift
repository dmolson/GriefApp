//
//  RitualsView.swift
//  Grief Support
//
//  Created by Danielle Olson on 8/1/25.
//

import SwiftUI
import PhotosUI
import UIKit

enum RitualType: String, CaseIterable {
    case connection = "Connection Ritual"
    case reflection = "Reflection Ritual"
    case birthday = "Birthday Ritual"
    case anniversary = "Anniversary Ritual"
    
    var icon: String {
        switch self {
        case .connection: return "sunrise.fill"
        case .reflection: return "moon.fill"
        case .birthday: return "birthday.cake.fill"
        case .anniversary: return "calendar.badge.plus"
        }
    }
}

struct RitualsView: View {
    var body: some View {
        Text("Rituals Working!")
    }
}

#Preview {
    RitualsView()
}