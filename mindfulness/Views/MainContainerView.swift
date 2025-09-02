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
            if authService.isLoading {
                // Show loading while checking authentication state
                AuthenticationLoadingView()
                    .transition(.opacity.combined(with: .scale(scale: 0.95)).animation(.easeOut(duration: 0.4)))
            } else if authService.isAuthenticated {
                // User is already authenticated (existing session)
                if !hasCompletedOnboarding {
                    OnboardingView {
                        await completeOnboarding()
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity).animation(.easeInOut(duration: 0.6)))
                } else {
                    ContentView()
                        .environmentObject(authService)
                        .transition(.move(edge: .bottom).combined(with: .opacity).animation(.spring(response: 0.8, dampingFraction: 0.8)))
                }
            } else if !hasSignedInWithApple {
                // No existing session and user hasn't signed in before
                AppleSignInView {
                    hasSignedInWithApple = true
                }
                .transition(.move(edge: .leading).combined(with: .opacity).animation(.easeInOut(duration: 0.5)))
            } else if isAuthenticating {
                AuthenticationLoadingView()
                    .transition(.opacity.animation(.easeInOut(duration: 0.3)))
            } else {
                // Fallback - should retry authentication
                AuthenticationLoadingView()
                    .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                    .task {
                        await retryAuthentication()
                    }
            }
        }
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