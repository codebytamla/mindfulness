//
//  OnboardingView.swift
//  mindfulness
//
//  Created by leo on 31/8/2568 BE.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    let onComplete: () -> Void
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "brain.head.profile",
            title: "AI-Powered Meditation",
            subtitle: "Personalized guidance that adapts to how you're feeling right now",
            description: "Our AI creates unique meditation sessions based on your emotions and life situations, making every practice perfectly tailored to you."
        ),
        OnboardingPage(
            icon: "heart.fill",
            title: "Science-Based Approach",
            subtitle: "Built on proven psychological frameworks",
            description: "We use the Circumplex Model of emotions and Cognitive Appraisal Theory to match you with the most effective meditation techniques."
        ),
        OnboardingPage(
            icon: "chart.line.uptrend.xyaxis",
            title: "Track Your Journey",
            subtitle: "See your progress and build lasting habits",
            description: "Monitor your meditation streaks, mood patterns, and personal growth as you develop a consistent mindfulness practice."
        )
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.1, blue: 0.2),
                    Color(red: 0.1, green: 0.05, blue: 0.3),
                    Color(red: 0.2, green: 0.1, blue: 0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        onComplete()
                    }
                    .foregroundColor(.white.opacity(0.7))
                    .font(.subheadline)
                    .fontWeight(.medium)
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
                
                Spacer()
                
                // Content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(maxHeight: 500)
                
                Spacer()
                
                // Page indicator and navigation
                VStack(spacing: 30) {
                    // Page dots
                    HStack(spacing: 12) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? .white : .white.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(index == currentPage ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.3), value: currentPage)
                        }
                    }
                    
                    // Navigation buttons
                    HStack(spacing: 16) {
                        if currentPage > 0 {
                            Button("Back") {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPage -= 1
                                }
                            }
                            .foregroundColor(.white.opacity(0.7))
                            .font(.subheadline)
                            .fontWeight(.medium)
                        }
                        
                        Spacer()
                        
                        Button(currentPage == pages.count - 1 ? "Get Started" : "Next") {
                            if currentPage == pages.count - 1 {
                                onComplete()
                            } else {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPage += 1
                                }
                            }
                        }
                        .foregroundColor(.white)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue,
                                    Color.purple
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 50)
            }
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 32) {
            // Icon
            ZStack {
                Circle()
                    .fill(.white.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: page.icon)
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(.white)
            }
            
            // Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, 32)
            }
        }
        .padding(.horizontal, 24)
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
}

#Preview {
    OnboardingView(onComplete: {})
}