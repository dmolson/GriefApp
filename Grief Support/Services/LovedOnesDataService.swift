//
//  LovedOnesDataService.swift
//  Grief Support
//
//  Created by Danielle Olson on 8/3/25.
//

import Foundation
import Combine

// MARK: - LovedOne Data Model
struct LovedOne: Identifiable, Codable {
    let id = UUID()
    var name: String
    var birthDate: String
    var passDate: String
    var birthdayReminders: Bool
    var memorialReminders: Bool
    
    // For Codable conformance, we need to handle the UUID
    enum CodingKeys: String, CodingKey {
        case name, birthDate, passDate, birthdayReminders, memorialReminders
    }
}

// MARK: - Loved Ones Data Service
class LovedOnesDataService: ObservableObject {
    @Published var lovedOnes: [LovedOne] = []
    
    private let userDefaults = UserDefaults.standard
    private let lovedOnesKey = "savedLovedOnes"
    
    static let shared = LovedOnesDataService()
    
    private init() {
        loadLovedOnes()
    }
    
    // MARK: - Data Persistence
    func loadLovedOnes() {
        if let data = userDefaults.data(forKey: lovedOnesKey),
           let decoded = try? JSONDecoder().decode([LovedOne].self, from: data) {
            lovedOnes = decoded
        } else {
            // Initialize with default data if no saved data exists
            lovedOnes = [
                LovedOne(name: "Matthew", birthDate: "March 15, 1985", passDate: "August 12, 2024", birthdayReminders: true, memorialReminders: true)
            ]
            saveLovedOnes()
        }
    }
    
    func saveLovedOnes() {
        if let encoded = try? JSONEncoder().encode(lovedOnes) {
            userDefaults.set(encoded, forKey: lovedOnesKey)
        }
    }
    
    // MARK: - CRUD Operations
    func addLovedOne(_ lovedOne: LovedOne) {
        lovedOnes.append(lovedOne)
        saveLovedOnes()
    }
    
    func updateLovedOne(_ updatedLovedOne: LovedOne) {
        if let index = lovedOnes.firstIndex(where: { $0.id == updatedLovedOne.id }) {
            lovedOnes[index] = updatedLovedOne
            saveLovedOnes()
        }
    }
    
    func deleteLovedOne(_ lovedOne: LovedOne) {
        lovedOnes.removeAll { $0.id == lovedOne.id }
        saveLovedOnes()
    }
    
    func deleteLovedOne(withId id: UUID) {
        lovedOnes.removeAll { $0.id == id }
        saveLovedOnes()
    }
    
    // MARK: - Utility Methods
    func getLovedOne(byId id: UUID) -> LovedOne? {
        return lovedOnes.first { $0.id == id }
    }
    
    func getLovedOne(byName name: String) -> LovedOne? {
        return lovedOnes.first { $0.name.lowercased() == name.lowercased() }
    }
    
    // MARK: - Conversion for RitualsView Compatibility
    var lovedOnesForRituals: [(String, String)] {
        return lovedOnes.map { ($0.name, $0.name.lowercased()) }
    }
    
    var lovedOnesNames: [String] {
        return lovedOnes.map { $0.name }
    }
    
    // MARK: - Reset Functionality
    func resetToDefaults() {
        lovedOnes = [
            LovedOne(name: "Matthew", birthDate: "March 15, 1985", passDate: "August 12, 2024", birthdayReminders: true, memorialReminders: true)
        ]
        saveLovedOnes()
    }
    
    func clearAll() {
        lovedOnes = []
        saveLovedOnes()
    }
}