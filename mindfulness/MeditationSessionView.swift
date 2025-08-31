//
//  MeditationSessionView.swift
//  mindfulness
//
//  Created by leo on 31/8/2568 BE.
//

import SwiftUI

struct MeditationSessionView: View {
    let emotion: EmotionCategory
    let emotionIntensity: Int
    let situation: SituationCategory?
    let situationDescription: String?
    let duration: Int
    
    @StateObject private var meditationAI = MeditationAI()
    
    @State private var isGenerating = true
    @State private var meditationScript = ""
    @State private var meditationType: MeditationType = .mindfulness
    @State private var timeRemaining: Int = 0
    @State private var isActive = false
    @State private var showingCompletion = false
    @State private var timer: Timer?
    
    let onComplete: (MeditationSession) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                backgroundGradient
                    .ignoresSafeArea()
                
                if isGenerating {
                    generateMeditationView
                } else {
                    meditationPlayerView(geometry: geometry)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            timeRemaining = duration * 60 // Convert to seconds
            generateMeditation()
        }
        .onDisappear {
            timer?.invalidate()
            // TODO: Stop backend audio
        }
        .sheet(isPresented: $showingCompletion) {
            MeditationCompletionView(
                emotion: emotion,
                duration: duration,
                meditationType: meditationType
            ) { rating, postMood, notes in
                let session = MeditationSession(
                    emotion: emotion,
                    emotionIntensity: emotionIntensity,
                    duration: duration,
                    situation: situation,
                    situationDescription: situationDescription,
                    meditationType: meditationType,
                    aiGeneratedScript: meditationScript
                )
                session.isCompleted = true
                session.rating = rating
                session.postMeditationMood = postMood
                session.notes = notes
                session.actualDuration = duration - (timeRemaining / 60)
                
                onComplete(session)
            }
        }
    }
    
    private var backgroundGradient: some View {
        let gradientColors: [Color] = switch meditationType {
        case .breathwork: [.blue.opacity(0.3), .cyan.opacity(0.2)]
        case .bodyScan: [.green.opacity(0.3), .mint.opacity(0.2)]
        case .lovingKindness: [.pink.opacity(0.3), .red.opacity(0.2)]
        case .mindfulness: [.purple.opacity(0.3), .indigo.opacity(0.2)]
        case .sleepStory: [.indigo.opacity(0.4), .purple.opacity(0.3)]
        case .progressiveMuscleRelaxation: [.orange.opacity(0.3), .yellow.opacity(0.2)]
        case .guidedImagery: [.teal.opacity(0.3), .green.opacity(0.2)]
        case .selfCompassion: [.pink.opacity(0.3), .purple.opacity(0.2)]
        }
        
        return LinearGradient(
            gradient: Gradient(colors: gradientColors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var generateMeditationView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Animated meditation icon
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.white, lineWidth: 3)
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(isGenerating ? 360 : 0))
                    .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: isGenerating)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 15) {
                Text("Creating Your Meditation")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Our AI is crafting a personalized meditation based on how you're feeling right now")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
    
    private func meditationPlayerView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Timer circle
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 8)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: CGFloat(timeRemaining) / CGFloat(duration * 60))
                    .stroke(Color.white, lineWidth: 8)
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: timeRemaining)
                
                VStack {
                    Text(formatTime(timeRemaining))
                        .font(.system(size: 32, weight: .light, design: .monospaced))
                        .foregroundColor(.white)
                    
                    Text("remaining")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Meditation type and description
            VStack(spacing: 10) {
                Text(meditationType.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(getMeditationDescription())
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Audio controls
            HStack(spacing: 40) {
                Button(action: {
                    // TODO: Implement backend audio play/pause
                }) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
                
                Button(action: {
                    // TODO: Stop backend audio
                    timer?.invalidate()
                    showingCompletion = true
                }) {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Progress indicator
            VStack(spacing: 10) {
                Text("Guided by AI")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                // TODO: Add audio playing indicator for backend audio
            }
            
            Spacer()
        }
        .onAppear {
            startMeditation()
        }
    }
    
    private func generateMeditation() {
        Task {
            let result = await meditationAI.generateMeditationScript(
                emotion: emotion,
                intensity: emotionIntensity,
                duration: duration,
                situation: situation,
                situationDescription: situationDescription
            )
            
            await MainActor.run {
                meditationScript = result.script
                meditationType = result.type
                isGenerating = false
            }
        }
    }
    
    private func startMeditation() {
        guard !isGenerating else { return }
        
        // TODO: Start backend audio playback
        
        // Start timer
        isActive = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                // TODO: Stop backend audio
                showingCompletion = true
            }
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    private func getMeditationDescription() -> String {
        switch meditationType {
        case .breathwork:
            return "Focus on breathing patterns to calm your nervous system"
        case .bodyScan:
            return "Systematically relax each part of your body"
        case .lovingKindness:
            return "Cultivate compassion for yourself and others"
        case .mindfulness:
            return "Develop present moment awareness"
        case .sleepStory:
            return "A gentle story to prepare for restful sleep"
        case .progressiveMuscleRelaxation:
            return "Release physical tension through systematic relaxation"
        case .guidedImagery:
            return "Journey to a peaceful place in your mind"
        case .selfCompassion:
            return "Practice kindness and understanding toward yourself"
        }
    }
}

// TODO: Backend audio player will replace TTS functionality

#Preview {
    MeditationSessionView(
        emotion: .anxious,
        emotionIntensity: 7,
        situation: .work,
        situationDescription: nil,
        duration: 10
    ) { session in
        print("Session completed: \(session)")
    }
}