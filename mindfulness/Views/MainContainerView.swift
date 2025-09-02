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
            if authService.isAuthenticated {
                // User is already authenticated (existing session)
                if !hasCompletedOnboarding {
                    OnboardingView {
                        await completeOnboarding()
                    }
                } else {
                    ContentView()
                        .environmentObject(authService)
                }
            } else if !hasSignedInWithApple && !authService.isLoading {
                // No existing session and user hasn't signed in before
                AppleSignInView {
                    hasSignedInWithApple = true
                }
            } else if isAuthenticating || authService.isLoading {
                AuthenticationLoadingView()
            } else {
                // Fallback - should retry authentication
                AuthenticationLoadingView()
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
        isAuthenticating = true
        
        // Wait a moment for auth service to check existing session
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // If still no user after checking session, redirect to Apple Sign In
        if authService.currentUser == nil && !authService.isAuthenticated {
            print("🔄 No valid session found, redirecting to Apple Sign In")
            hasSignedInWithApple = false
        }
        
        isAuthenticating = false
    }
}

#Preview {
    MainContainerView()
        .modelContainer(for: MeditationSession.self, inMemory: true)
}