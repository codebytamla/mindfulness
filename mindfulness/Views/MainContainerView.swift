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
    @State private var showErrorRecovery = false
    @State private var loadingTimeout = false
    
    var body: some View {
        Group {
            if authService.isLoading && !loadingTimeout {
                // Show loading while checking authentication state
                AuthenticationLoadingView()
                    .transition(.opacity.combined(with: .scale(scale: 0.95)).animation(.easeOut(duration: 0.4)))
                    .task {
                        print("🔄 MainContainerView: Starting loading timeout task")
                        // Set a loading timeout
                        try? await Task.sleep(nanoseconds: 15_000_000_000) // 15 seconds
                        print("⚠️ MainContainerView: Loading timeout reached - isLoading: \(authService.isLoading)")
                        if authService.isLoading {
                            print("🚨 MainContainerView: Setting timeout flags")
                            loadingTimeout = true
                            showErrorRecovery = true
                        }
                    }
            } else if showErrorRecovery {
                // Show error recovery options when stuck
                ErrorRecoveryView {
                    // Reset and try again
                    showErrorRecovery = false
                    loadingTimeout = false
                    hasSignedInWithApple = false
                    Task {
                        await authService.refreshSession()
                    }
                }
                .transition(.slide.combined(with: .opacity))
            } else if authService.isAuthenticated {
                // User is already authenticated (existing session)
                if !hasCompletedOnboarding {
                    OnboardingView {
                        await completeOnboarding()
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity).animation(.easeInOut(duration: 0.6)))
                    .onAppear {
                        print("✅ MainContainerView: User authenticated, showing onboarding")
                    }
                } else {
                    SimplifiedContentView()
                        .environmentObject(authService)
                        .onAppear {
                            print("✅ MainContainerView: User authenticated and onboarded, showing SimplifiedContentView")
                        }
                }
            } else if !hasSignedInWithApple {
                // No existing session and user hasn't signed in before
                AppleSignInView {
                    hasSignedInWithApple = true
                }
                .transition(.move(edge: .leading).combined(with: .opacity).animation(.easeInOut(duration: 0.5)))
            } else if isAuthenticating && !loadingTimeout {
                AuthenticationLoadingView()
                    .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                    .task {
                        // Set timeout for authentication
                        try? await Task.sleep(nanoseconds: 15_000_000_000) // 15 seconds
                        if isAuthenticating {
                            loadingTimeout = true
                            showErrorRecovery = true
                            isAuthenticating = false
                        }
                    }
            } else {
                // Fallback - offer to retry or sign in again
                ErrorRecoveryView {
                    // Reset and try Apple Sign In
                    showErrorRecovery = false
                    loadingTimeout = false
                    hasSignedInWithApple = false
                }
                .transition(.slide.combined(with: .opacity))
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
        loadingTimeout = false
        
        // Try to refresh session first
        await authService.refreshSession()
        
        // Wait a moment for auth service to check existing session
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
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