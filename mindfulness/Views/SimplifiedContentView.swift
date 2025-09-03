//
//  SimplifiedContentView.swift
//  mindfulness
//
//  Created by Claude on 3/9/2025.
//

import SwiftUI
import SwiftData

struct SimplifiedContentView: View {
    @Environment(\.theme) var theme
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var authService: AuthenticationService
    @Query private var sessions: [MeditationSession]
    @State private var showingSettings = false
    @State private var showingMeditationFlow = false
    @State private var selectedEmotion: EmotionCategory?
    @State private var emotionIntensity: Int = 5
    @State private var selectedSituation: SituationCategory?
    @State private var situationDescription: String?
    @State private var currentMeditationStep = 0 // 0: emotion, 1: situation, 2: duration
    
    var body: some View {
        NavigationView {
            ZStack {
                // Simple theme-based background
                LinearGradient(
                    gradient: Gradient(colors: [
                        theme.bgGradientStart,
                        theme.bgGradientEnd
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 16) {
                            HStack {
                                Spacer()
                                Button(action: {
                                    showingSettings = true
                                }) {
                                    Image(systemName: "line.3.horizontal.decrease")
                                        .font(.title2)
                                        .foregroundColor(theme.textSecondary)
                                        .frame(width: 44, height: 44)
                                }
                            }
                            
                            VStack(spacing: 12) {
                                Text("Find Your Peace")
                                    .font(.custom("Noteworthy-Bold", size: 34))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(theme.textPrimary)
                                
                                Text("Take a moment to center yourself with personalized meditation.")
                                    .font(.system(.callout, design: .rounded, weight: .medium))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(theme.textSecondary)
                                    .lineSpacing(2)
                                    .padding(.horizontal, 8)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Main CTA Button
                        VStack(spacing: 16) {
                            Button(action: {
                                showingMeditationFlow = true
                            }) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .font(.title2)
                                    Text("Start Meditation")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(theme.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [theme.buttonGradientStart, theme.buttonGradientEnd],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: theme.glowColor, radius: 8, x: 0, y: 4)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                        }
                        .padding(.horizontal, 20)
                        
                        // Progress section (below button)
                        if !sessions.isEmpty {
                            VStack(spacing: 16) {
                                HStack {
                                    Text("Your Progress")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(theme.textPrimary)
                                    Spacer()
                                }
                                
                                HStack(spacing: 16) {
                                    SimpleStatCard(
                                        title: "Sessions",
                                        value: "\(sessions.count)",
                                        theme: theme
                                    )
                                    
                                    SimpleStatCard(
                                        title: "Minutes",
                                        value: "\(sessions.reduce(0) { $0 + $1.duration })",
                                        theme: theme
                                    )
                                }
                                
                                // Session history button
                                Button("View Session History") {
                                    print("Session history tapped - need to implement")
                                }
                                .font(.subheadline)
                                .foregroundColor(theme.textSecondary)
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingMeditationFlow) {
            NavigationView {
                Group {
                    switch currentMeditationStep {
                    case 0:
                        EmotionSelectionView { emotion, intensity in
                            selectedEmotion = emotion
                            emotionIntensity = intensity
                            currentMeditationStep = 1
                        }
                    case 1:
                        if let emotion = selectedEmotion {
                            SituationInputView(
                                selectedEmotion: emotion,
                                emotionIntensity: emotionIntensity
                            ) { situation, description in
                                selectedSituation = situation
                                situationDescription = description
                                currentMeditationStep = 2
                            }
                        }
                    case 2:
                        if let emotion = selectedEmotion {
                            DurationSelectionView(
                                selectedEmotion: emotion,
                                emotionIntensity: emotionIntensity,
                                selectedSituation: selectedSituation,
                                situationDescription: situationDescription
                            ) { duration in
                                // Create and save the meditation session
                                createMeditationSession(
                                    emotion: emotion,
                                    intensity: emotionIntensity,
                                    situation: selectedSituation,
                                    description: situationDescription,
                                    duration: duration
                                )
                                resetMeditationFlow()
                            }
                        }
                    default:
                        Text("Invalid step")
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(false)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            resetMeditationFlow()
                        }
                    }
                }
            }
        }
    }
    
    private func createMeditationSession(
        emotion: EmotionCategory,
        intensity: Int,
        situation: SituationCategory?,
        description: String?,
        duration: Int
    ) {
        // For now, we'll choose a meditation type based on the emotion
        let meditationType = chooseMeditationType(for: emotion)
        
        // Generate a simple AI script placeholder
        let aiScript = generateSimpleScript(for: emotion, intensity: intensity, duration: duration)
        
        // Create the meditation session
        let session = MeditationSession(
            emotion: emotion,
            emotionIntensity: intensity,
            duration: duration,
            situation: situation,
            situationDescription: description,
            meditationType: meditationType,
            aiGeneratedScript: aiScript
        )
        
        // For demo purposes, we'll mark it as completed
        session.isCompleted = true
        session.actualDuration = duration
        
        // Save to SwiftData
        modelContext.insert(session)
        
        do {
            try modelContext.save()
            print("✅ Meditation session saved successfully!")
        } catch {
            print("❌ Failed to save meditation session: \(error)")
        }
    }
    
    private func chooseMeditationType(for emotion: EmotionCategory) -> MeditationType {
        switch emotion {
        case .anxious, .overwhelmed:
            return .breathwork
        case .sad, .tired:
            return .bodyScan
        case .angry, .frustrated:
            return .progressiveMuscleRelaxation
        case .excited:
            return .mindfulness
        case .content:
            return .lovingKindness
        }
    }
    
    private func generateSimpleScript(for emotion: EmotionCategory, intensity: Int, duration: Int) -> String {
        return "A personalized \(duration)-minute meditation for feeling \(emotion.rawValue) (intensity: \(intensity)/10). This would normally be generated by AI with a full meditation script."
    }
    
    private func resetMeditationFlow() {
        showingMeditationFlow = false
        currentMeditationStep = 0
        selectedEmotion = nil
        emotionIntensity = 5
        selectedSituation = nil
        situationDescription = nil
    }
}

struct SimpleStatCard: View {
    let title: String
    let value: String
    let theme: ThemeColors
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(theme.textPrimary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(theme.cardBackground)
        .cornerRadius(12)
    }
}

#Preview {
    SimplifiedContentView()
        .environment(\.theme, WaterTheme.riverFlow.colors)
        .modelContainer(for: MeditationSession.self, inMemory: true)
}
