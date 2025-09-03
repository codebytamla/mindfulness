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
            EmotionSelectionView { emotion, intensity in
                // Handle the emotion selection and continue the meditation flow
                showingMeditationFlow = false
                startMeditationFlow(emotion: emotion, intensity: intensity)
            }
        }
    }
    
    private func startMeditationFlow(emotion: EmotionCategory, intensity: Int) {
        // For now, just print the selection - this will be expanded later
        print("Starting meditation flow with emotion: \(emotion), intensity: \(intensity)")
        // TODO: Continue to SituationInputView and then DurationSelectionView
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
