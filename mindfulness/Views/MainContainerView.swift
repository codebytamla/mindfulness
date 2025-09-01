//
//  MainContainerView.swift
//  mindfulness
//
//  Created by leo on 31/8/2568 BE.
//

import SwiftUI

struct MainContainerView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasSignedInWithApple") private var hasSignedInWithApple = false
    @StateObject private var authService = AuthenticationService.shared
    @State private var isAuthenticating = false
    
    var body: some View {
        Group {
            if !hasSignedInWithApple {
                AppleSignInView {
                    hasSignedInWithApple = true
                }
            } else if !hasCompletedOnboarding {
                OnboardingView {
                    await completeOnboarding()
                }
            } else if authService.isAuthenticated {
                ContentView()
                    .environmentObject(authService)
            } else if isAuthenticating {
                AuthenticationLoadingView()
            } else {
                // Fallback - should retry authentication
                ContentView()
                    .environmentObject(authService)
                    .task {
                        await retryAuthentication()
                    }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: hasSignedInWithApple)
        .animation(.easeInOut(duration: 0.5), value: hasCompletedOnboarding)
        .animation(.easeInOut(duration: 0.3), value: authService.isAuthenticated)
    }
    
    @MainActor
    private func completeOnboarding() async {
        hasCompletedOnboarding = true
    }
    
    @MainActor
    private func retryAuthentication() async {
        // Check for existing session - Apple Sign In should be persistent
        if authService.currentUser == nil {
            // If no user, redirect back to Apple Sign In
            hasSignedInWithApple = false
        }
        isAuthenticating = false
    }
}

#Preview {
    MainContainerView()
        .modelContainer(for: MeditationSession.self, inMemory: true)
}