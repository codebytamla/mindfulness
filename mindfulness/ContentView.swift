//
//  ContentView.swift
//  mindfulness
//
//  Created by leo on 31/8/2568 BE.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var sessions: [MeditationSession]
    @Query private var userProfiles: [UserProfile]
    
    @State private var showingMeditationFlow = false
    @State private var currentStep: MeditationFlowStep = .emotion
    @State private var selectedEmotion: EmotionCategory?
    @State private var emotionIntensity: Int = 5
    @State private var selectedSituation: SituationCategory?
    @State private var situationDescription: String?
    @State private var selectedDuration: Int = 10
    
    private var userProfile: UserProfile {
        if let profile = userProfiles.first {
            return profile
        } else {
            let newProfile = UserProfile()
            modelContext.insert(newProfile)
            return newProfile
        }
    }
    
    private var recentSessions: [MeditationSession] {
        sessions.sorted(by: { $0.timestamp > $1.timestamp }).prefix(5).map { $0 }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 10) {
                        Text("Mindfulness")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("AI-powered guided meditation")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Quick start section
                    VStack(spacing: 15) {
                        Button(action: {
                            showingMeditationFlow = true
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Start New Meditation")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Text("Personalized guidance based on how you feel")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "brain.head.profile")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                            }
                            .padding(20)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal)
                    
                    // Stats section
                    if !sessions.isEmpty {
                        VStack(spacing: 15) {
                            HStack {
                                Text("Your Progress")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            HStack(spacing: 15) {
                                StatCard(
                                    title: "Total Sessions",
                                    value: "\(sessions.count)",
                                    icon: "checkmark.circle.fill",
                                    color: .green
                                )
                                
                                StatCard(
                                    title: "Total Minutes",
                                    value: "\(sessions.reduce(0) { $0 + $1.duration })",
                                    icon: "clock.fill",
                                    color: .blue
                                )
                                
                                StatCard(
                                    title: "Streak",
                                    value: "\(calculateStreak()) days",
                                    icon: "flame.fill",
                                    color: .orange
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Recent sessions
                    if !recentSessions.isEmpty {
                        VStack(spacing: 15) {
                            HStack {
                                Text("Recent Sessions")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            LazyVStack(spacing: 10) {
                                ForEach(recentSessions, id: \.id) { session in
                                    SessionCard(session: session)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 50)
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showingMeditationFlow) {
                MeditationFlowView { session in
                    modelContext.insert(session)
                    updateUserProfile(with: session)
                    showingMeditationFlow = false
                }
            }
        }
    }
    
    private func calculateStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        let sessionDates = Set(sessions.map { calendar.startOfDay(for: $0.timestamp) })
        
        while sessionDates.contains(currentDate) || (streak == 0 && sessionDates.contains(calendar.date(byAdding: .day, value: -1, to: currentDate)!)) {
            if sessionDates.contains(currentDate) {
                streak += 1
            } else if streak == 0 {
                // Check yesterday for current streak
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
                if sessionDates.contains(currentDate) {
                    streak += 1
                } else {
                    break
                }
            } else {
                break
            }
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        return streak
    }
    
    private func updateUserProfile(with session: MeditationSession) {
        userProfile.totalSessions += 1
        userProfile.totalMinutes += session.duration
        userProfile.lastMeditationDate = session.timestamp
        
        // Update preferred durations and favorite types based on ratings
        if let rating = session.rating, rating >= 4 {
            if !userProfile.preferredDurations.contains(session.duration) {
                userProfile.preferredDurations.append(session.duration)
            }
            if !userProfile.favoriteTypes.contains(session.meditationType) {
                userProfile.favoriteTypes.append(session.meditationType)
            }
        }
        
        userProfile.meditationStreak = calculateStreak()
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

struct SessionCard: View {
    let session: MeditationSession
    
    private var emotionColor: Color {
        switch session.emotion.valence {
        case .pleasant:
            return session.emotion.arousal == .high ? .green : .mint
        case .unpleasant:
            return session.emotion.arousal == .high ? .red : .indigo
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Circle()
                        .fill(emotionColor)
                        .frame(width: 8, height: 8)
                    
                    Text(session.emotion.rawValue.capitalized)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if let postMood = session.postMeditationMood, postMood != session.emotion {
                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(postMood.rawValue.capitalized)
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                Text("\(session.meditationType.rawValue.replacingOccurrences(of: "_", with: " ").capitalized) • \(session.duration) min")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(session.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let rating = session.rating {
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(star <= rating ? .yellow : .gray)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

enum MeditationFlowStep {
    case emotion, situation, duration, session, completion
}

struct MeditationFlowView: View {
    let onComplete: (MeditationSession) -> Void
    
    @State private var currentStep: MeditationFlowStep = .emotion
    @State private var selectedEmotion: EmotionCategory?
    @State private var emotionIntensity: Int = 5
    @State private var selectedSituation: SituationCategory?
    @State private var situationDescription: String?
    @State private var selectedDuration: Int = 10
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Group {
            switch currentStep {
            case .emotion:
                EmotionSelectionView { emotion, intensity in
                    selectedEmotion = emotion
                    emotionIntensity = intensity
                    currentStep = .situation
                }
            case .situation:
                SituationInputView(
                    selectedEmotion: selectedEmotion!,
                    emotionIntensity: emotionIntensity
                ) { situation, description in
                    selectedSituation = situation
                    situationDescription = description
                    currentStep = .duration
                }
            case .duration:
                DurationSelectionView(
                    selectedEmotion: selectedEmotion!,
                    emotionIntensity: emotionIntensity,
                    selectedSituation: selectedSituation,
                    situationDescription: situationDescription
                ) { duration in
                    selectedDuration = duration
                    currentStep = .session
                }
            case .session:
                MeditationSessionView(
                    emotion: selectedEmotion!,
                    emotionIntensity: emotionIntensity,
                    situation: selectedSituation,
                    situationDescription: situationDescription,
                    duration: selectedDuration
                ) { session in
                    onComplete(session)
                    dismiss()
                }
            case .completion:
                EmptyView() // Handled by MeditationSessionView
            }
        }
        .onAppear {
            currentStep = .emotion
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: MeditationSession.self, inMemory: true)
}
