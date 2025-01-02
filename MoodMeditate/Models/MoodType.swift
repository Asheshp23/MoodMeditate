//
//  MoodType.swift
//  MoodMeditate
//
//  Created by Ashesh Patel on 2024-12-18.
//
import Foundation

// Mood Enum representing different emotional states
enum MoodType: String, CaseIterable, Identifiable {
  case calm = "Calm"
  case anxious = "Anxious"
  case energetic = "Energetic"
  case stressed = "Stressed"
  case sad = "Sad"
  
  var id: String { self.rawValue }
  
  // Tailwind Color Mapping
  var color: TailwindColor {
    switch self {
    case .calm: return .emerald
    case .anxious: return .red
    case .energetic: return .blue
    case .stressed: return .orange
    case .sad: return .indigo
    }
  }
}

// Meditation Script Model
struct MeditationScript: Identifiable {
  let id: UUID
  let mood: MoodType
  let duration: Int // in minutes
  let script: String
  let audioFile: String
}

// Mood Tracking Model
struct MoodEntry: Identifiable {
  let id: UUID
  let mood: MoodType
  let timestamp: Date
  let intensity: Double // 0-10 scale
}
