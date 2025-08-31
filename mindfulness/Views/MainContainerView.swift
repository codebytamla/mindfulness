//
//  MainContainerView.swift
//  mindfulness
//
//  Created by leo on 31/8/2568 BE.
//

import SwiftUI

struct MainContainerView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: hasCompletedOnboarding)
    }
}

#Preview {
    MainContainerView()
        .modelContainer(for: MeditationSession.self, inMemory: true)
}