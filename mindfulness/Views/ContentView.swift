//
//  ContentView.swift - Redesigned Meditation App Home
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
    @State private var selectedEmotion: EmotionCategory?
    @State private var hasAppeared = false
    @State private var currentTabIndex = 0
    
    private var userProfile: UserProfile {
        if let profile = userProfiles.first {
            return profile
        } else {
            let newProfile = UserProfile()
            modelContext.insert(newProfile)
            return newProfile
        }
    }
    
    private var timeBasedGreeting: (String, String) {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = "Friend" // Could be customizable
        
        if hour >= 5 && hour < 12 {
            return ("Good morning, \(name)", "sunrise.fill")
        } else if hour >= 12 && hour < 17 {
            return ("Good afternoon, \(name)", "sun.max.fill")
        } else {
            return ("Good evening, \(name)", "moon.stars.fill")
        }
    }
    
    var body: some View {
        ZStack {
            // Animated mesh background
            EmotionalMeshBackground(selectedEmotion: selectedEmotion)
            
            // Main content
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        // HERO SECTION (Top 40%)
                        VStack(spacing: 24) {
                            // Time-based greeting
                            HStack(spacing: 12) {
                                Image(systemName: timeBasedGreeting.1)
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Text(timeBasedGreeting.0)
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                            
                            // Emotional check-in
                            VStack(spacing: 16) {
                                Text("How are you feeling?")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                
                                EmotionChipScrollView(selectedEmotion: $selectedEmotion)
                            }
                            .padding(.horizontal, 24)
                        }
                        .frame(height: geometry.size.height * 0.4)
                        
                        // MAIN CTA (Floating card)
                        FloatingCTACard(selectedEmotion: selectedEmotion) {
                            showingMeditationFlow = true
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, -40) // Overlap with hero section
                        
                        // TODAY'S JOURNEY
                        TodaysJourneyCard(sessions: sessions, selectedEmotion: selectedEmotion)
                            .padding(.horizontal, 24)
                            .padding(.top, 32)
                        
                        // BOTTOM SECTION (TabView)
                        TabView(selection: $currentTabIndex) {
                            JourneyEntriesPage(sessions: sessions, selectedEmotion: selectedEmotion)
                                .tag(0)
                            
                            DiscoverPage(selectedEmotion: selectedEmotion)
                                .tag(1)
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(height: 400)
                        .padding(.top, 24)
                        
                        Spacer(minLength: 120) // Space for floating buttons
                    }
                }
                .scrollIndicators(.hidden)
                .refreshable {
                    // Breathing animation on pull to refresh
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                }
            }
            
            // Floating action buttons (no tab bar)
            FloatingActionButtons(
                onProfileTap: {
                    showingSettings = true
                },
                onLibraryTap: {
                    showingSessionHistory = true
                },
                onInsightsTap: {
                    // Show insights/analytics
                    print("Insights tapped")
                }
            )
            
            // Page indicator for TabView
            VStack {
                Spacer()
                
                HStack(spacing: 8) {
                    ForEach(0..<2, id: \.self) { index in
                        Circle()
                            .fill(currentTabIndex == index ? .white : .white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentTabIndex == index ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentTabIndex)
                    }
                }
                .padding(.bottom, 140)
            }
        }
        .navigationBarHidden(true)
        .scaleEffect(hasAppeared ? 1.0 : 0.95)
        .opacity(hasAppeared ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8).delay(0.1)) {
                hasAppeared = true
            }
        }
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
    
    private func calculateStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        let sessionDates = Set(sessions.map { calendar.startOfDay(for: $0.timestamp) })
        
        while sessionDates.contains(currentDate) || (streak == 0 && sessionDates.contains(calendar.date(byAdding: .day, value: -1, to: currentDate)!)) {
            if sessionDates.contains(currentDate) {
                streak += 1
            } else if streak == 0 {
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
}






#Preview {
    ContentView()
        .modelContainer(for: MeditationSession.self, inMemory: true)
}
