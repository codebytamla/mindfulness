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
    @State private var showingSettings = false
    @State private var showingSessionHistory = false
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
        sessions.sorted(by: { $0.timestamp > $1.timestamp }).prefix(3).map { $0 }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header with settings button
                    HStack {
               
                        Spacer()
                        
                        Button(action: {
                            showingSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                                .frame(width: 44, height: 44)
                                .background(Color(UIColor.systemGray6))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Enhanced CTA section
                    VStack(spacing: 15) {
                        PremiumCTAButton(action: {
                            showingMeditationFlow = true
                        })
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
                    
                    // Recent sessions card
                    if !recentSessions.isEmpty {
                        VStack(spacing: 0) {
                            // Card header
                            HStack {
                                Text("Recent Sessions")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Button(action: {
                                    showingSessionHistory = true
                                }) {
                                    HStack(spacing: 4) {
                                        Text("See All")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 12)
                            
                            // Sessions list
                            LazyVStack(spacing: 8) {
                                ForEach(recentSessions, id: \.id) { session in
                                    SessionCard(session: session)
                                        .padding(.horizontal, 16)
                                }
                            }
                            .padding(.bottom, 16)
                        }
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(16)
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
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingSessionHistory) {
                SessionHistoryView()
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
    
    private var relativeTimeText: String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(session.timestamp) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Today at \(formatter.string(from: session.timestamp))"
        } else if calendar.isDateInYesterday(session.timestamp) {
            return "Yesterday"
        } else {
            let daysDifference = calendar.dateComponents([.day], from: session.timestamp, to: now).day ?? 0
            if daysDifference < 7 {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE" // Day of week
                return formatter.string(from: session.timestamp)
            } else {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                return formatter.string(from: session.timestamp)
            }
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
                
                Text(relativeTimeText)
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
        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 0.5)
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
        NavigationView {
            Group {
                switch currentStep {
                case .emotion:
                    EmotionSelectionView { emotion, intensity in
                        selectedEmotion = emotion
                        emotionIntensity = intensity
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .situation
                        }
                    }
                    .navigationBarItems(
                        leading: Button("Cancel") {
                            dismiss()
                        },
                        trailing: ProgressIndicator(currentStep: 1, totalSteps: 3)
                    )
                case .situation:
                    SituationInputView(
                        selectedEmotion: selectedEmotion!,
                        emotionIntensity: emotionIntensity
                    ) { situation, description in
                        selectedSituation = situation
                        situationDescription = description
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .duration
                        }
                    }
                    .navigationBarItems(
                        leading: Button("Back") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStep = .emotion
                            }
                        },
                        trailing: ProgressIndicator(currentStep: 2, totalSteps: 3)
                    )
                case .duration:
                    DurationSelectionView(
                        selectedEmotion: selectedEmotion!,
                        emotionIntensity: emotionIntensity,
                        selectedSituation: selectedSituation,
                        situationDescription: situationDescription
                    ) { duration in
                        selectedDuration = duration
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .session
                        }
                    }
                    .navigationBarItems(
                        leading: Button("Back") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStep = .situation
                            }
                        },
                        trailing: ProgressIndicator(currentStep: 3, totalSteps: 3)
                    )
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
            .navigationBarHidden(currentStep == .session) // Hide nav bar during meditation
        }
        .onAppear {
            currentStep = .emotion
        }
    }
}

struct ProgressIndicator: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
            
            Text("\(currentStep)/\(totalSteps)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct PremiumCTAButton: View {
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Spacer()
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                        
                        Text("Start New Meditation")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                    }
                    
//                    Text("AI-powered guidance tailored to your emotions")
//                        .font(.subheadline)
//                        .fontWeight(.medium)
//                        .foregroundColor(.white.opacity(0.35))
//                        .lineLimit(2)
                }
                
                Spacer()
                
                ZStack {
//                    Circle()
//                        .fill(.white.opacity(0.15))
//                        .frame(width: 56, height: 56)
                    
                    
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(
                ZStack {
                    // Base gradient
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.0, green: 0.4, blue: 1.0),     // Deeper blue
                            Color(red: 0.3, green: 0.0, blue: 0.8),     // Rich purple  
                            Color(red: 0.6, green: 0.0, blue: 0.6)      // Magenta accent
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Overlay shimmer effect
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            .white.opacity(0.1),
                            .clear
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .cornerRadius(20)
            .shadow(
                color: Color.blue.opacity(0.3),
                radius: isPressed ? 4 : 12,
                x: 0,
                y: isPressed ? 2 : 8
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

#Preview {
    ContentView()
        .modelContainer(for: MeditationSession.self, inMemory: true)
}
