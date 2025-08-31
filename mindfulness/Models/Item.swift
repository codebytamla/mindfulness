//
//  MeditationModels.swift
//  mindfulness
//
//  Created by leo on 31/8/2568 BE.
//

import Foundation
import SwiftData

// MARK: - Emotion Models (Circumplex Model of Affect)
enum EmotionValence: String, CaseIterable, Codable {
    case pleasant = "pleasant"
    case unpleasant = "unpleasant"
}

enum EmotionArousal: String, CaseIterable, Codable {
    case high = "high"
    case low = "low"
}

enum EmotionCategory: String, CaseIterable, Codable {
    case anxious = "anxious"
    case sad = "sad" 
    case angry = "angry"
    case overwhelmed = "overwhelmed"
    case excited = "excited"
    case content = "content"
    case tired = "tired"
    case frustrated = "frustrated"
    
    var valence: EmotionValence {
        switch self {
        case .content, .excited: return .pleasant
        case .anxious, .sad, .angry, .overwhelmed, .tired, .frustrated: return .unpleasant
        }
    }
    
    var arousal: EmotionArousal {
        switch self {
        case .anxious, .angry, .overwhelmed, .excited, .frustrated: return .high
        case .sad, .content, .tired: return .low
        }
    }
}

enum SituationCategory: String, CaseIterable, Codable {
    case work = "work"
    case relationships = "relationships"
    case health = "health"
    case financial = "financial"
    case grief = "grief"
    case dailyStress = "daily_stress"
    case sleep = "sleep"
    case other = "other"
    
    var icon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .relationships: return "heart.fill"
        case .health: return "cross.fill"
        case .financial: return "dollarsign.circle.fill"
        case .grief: return "cloud.rain.fill"
        case .dailyStress: return "exclamationmark.triangle.fill"
        case .sleep: return "moon.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

enum MeditationType: String, CaseIterable, Codable {
    case breathwork = "breathwork"
    case bodyScan = "body_scan"
    case lovingKindness = "loving_kindness"
    case mindfulness = "mindfulness"
    case sleepStory = "sleep_story"
    case progressiveMuscleRelaxation = "progressive_muscle_relaxation"
    case guidedImagery = "guided_imagery"
    case selfCompassion = "self_compassion"
}

// MARK: - Core Data Models
@Model
final class MeditationSession {
    var id: UUID
    var timestamp: Date
    var duration: Int // in minutes
    var actualDuration: Int? // actual time spent
    var emotion: EmotionCategory
    var emotionIntensity: Int // 1-10 scale
    var situation: SituationCategory?
    var situationDescription: String?
    var meditationType: MeditationType
    var aiGeneratedScript: String
    var isCompleted: Bool
    var rating: Int? // 1-5 stars
    var postMeditationMood: EmotionCategory?
    var notes: String?
    
    init(emotion: EmotionCategory, 
         emotionIntensity: Int,
         duration: Int,
         situation: SituationCategory? = nil,
         situationDescription: String? = nil,
         meditationType: MeditationType,
         aiGeneratedScript: String) {
        self.id = UUID()
        self.timestamp = Date()
        self.duration = duration
        self.emotion = emotion
        self.emotionIntensity = emotionIntensity
        self.situation = situation
        self.situationDescription = situationDescription
        self.meditationType = meditationType
        self.aiGeneratedScript = aiGeneratedScript
        self.isCompleted = false
    }
}

@Model
final class UserProfile {
    var id: UUID
    var createdAt: Date
    var preferredDurations: [Int] // preferred meditation lengths
    var favoriteTypes: [MeditationType]
    var meditationStreak: Int
    var lastMeditationDate: Date?
    var totalSessions: Int
    var totalMinutes: Int
    
    init() {
        self.id = UUID()
        self.createdAt = Date()
        self.preferredDurations = [5, 10]
        self.favoriteTypes = []
        self.meditationStreak = 0
        self.totalSessions = 0
        self.totalMinutes = 0
    }
}

@Model
final class MoodEntry {
    var id: UUID
    var timestamp: Date
    var emotion: EmotionCategory
    var intensity: Int
    var notes: String?
    
    init(emotion: EmotionCategory, intensity: Int, notes: String? = nil) {
        self.id = UUID()
        self.timestamp = Date()
        self.emotion = emotion
        self.intensity = intensity
        self.notes = notes
    }
}
