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
    let id: UUID
    var name: String
    var birthDate: String
    var passDate: String
    var birthdayReminders: Bool
    var memorialReminders: Bool
    
    // Include id in CodingKeys to persist it properly
    enum CodingKeys: String, CodingKey {
        case id, name, birthDate, passDate, birthdayReminders, memorialReminders
    }
    
    // Provide initializer that creates new UUID for new loved ones
    init(id: UUID = UUID(), name: String, birthDate: String, passDate: String, birthdayReminders: Bool, memorialReminders: Bool) {
        self.id = id
        self.name = name
        self.birthDate = birthDate
        self.passDate = passDate
        self.birthdayReminders = birthdayReminders
        self.memorialReminders = memorialReminders
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
            // Initialize with empty array - users start fresh
            lovedOnes = []
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
        return lovedOnes.map { ($0.name, $0.name) }
    }
    
    var lovedOnesNames: [String] {
        return lovedOnes.map { $0.name }
    }
    
    // Helper to get birth date for a loved one
    func getBirthDate(for name: String) -> String? {
        getLovedOne(byName: name)?.birthDate
    }
    
    // Helper to get pass date for a loved one
    func getPassDate(for name: String) -> String? {
        getLovedOne(byName: name)?.passDate
    }
    
    // MARK: - Reset Functionality
    func resetToDefaults() {
        lovedOnes = []
        saveLovedOnes()
    }
    
    func clearAll() {
        lovedOnes = []
        saveLovedOnes()
    }
}