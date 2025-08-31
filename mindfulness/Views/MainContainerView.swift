//
//  MainContainerView.swift
//  mindfulness
//
//  Created by leo on 31/8/2568 BE.
//

import SwiftUI

struct MainContainerView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var authService = AuthenticationService.shared
    @State private var isAuthenticating = false
    
    var body: some View {
        Group {
            if !hasCompletedOnboarding {
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
        .animation(.easeInOut(duration: 0.5), value: hasCompletedOnboarding)
        .animation(.easeInOut(duration: 0.3), value: authService.isAuthenticated)
    }
    
    @MainActor
    private func completeOnboarding() async {
        hasCompletedOnboarding = true
        isAuthenticating = true
        
        let result = await authService.signInAnonymously()
        
        switch result {
        case .success(let user):
            print("✅ Anonymous authentication successful for user: \(user.id)")
        case .failure(let error):
            print("❌ Anonymous authentication failed: \(error.localizedDescription)")
            // Continue anyway - user can still use the app offline
        }
        
        isAuthenticating = false
    }
    
    @MainActor
    private func retryAuthentication() async {
        isAuthenticating = true
        
        let result = await authService.signInAnonymously()
        
        switch result {
        case .success(let user):
            print("✅ Retry authentication successful for user: \(user.id)")
        case .failure(let error):
            print("❌ Retry authentication failed: \(error.localizedDescription)")
        }
        
        isAuthenticating = false
    }
}

#Preview {
    MainContainerView()
        .modelContainer(for: MeditationSession.self, inMemory: true)
}