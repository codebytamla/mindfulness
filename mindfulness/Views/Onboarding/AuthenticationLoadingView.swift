//
//  AuthenticationLoadingView.swift
//  mindfulness
//
//  Created by leo on 31/8/2568 BE.
//

import SwiftUI

struct AuthenticationLoadingView: View {
    @Environment(\.theme) var theme
    @State private var isAnimating = false
    @State private var currentTip = 0
    
    private let tips = [
        "Setting up your personalized meditation experience...",
        "Connecting to secure servers...",
        "Preparing your mindfulness journey...",
        "Almost ready to begin..."
    ]
    
    var body: some View {
        ZStack {
            // Theme-based background
            LinearGradient(
                gradient: Gradient(colors: [
                    theme.bgGradientStart,
                    theme.bgGradientEnd
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Animated logo/icon
                ZStack {
                    Circle()
                        .stroke(theme.textSecondary.opacity(0.3), lineWidth: 2)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(theme.primary, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: isAnimating)
                    
                    Image(systemName: "drop.fill")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(theme.textPrimary)
                }
                
                VStack(spacing: 12) {
                    Text("Setting up your account...")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.textPrimary)
                    
                    Text(tips[currentTip])
                        .font(.subheadline)
                        .foregroundColor(theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .animation(.easeInOut(duration: 0.5), value: currentTip)
                }
                
                // Animated dots
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(theme.accent.opacity(0.8))
                            .frame(width: 8, height: 8)
                            .scaleEffect(isAnimating ? 1.0 : 0.3)
                            .animation(
                                .easeInOut(duration: 0.8)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                                value: isAnimating
                            )
                    }
                }
            }
        }
        .onAppear {
            isAnimating = true
            startTipRotation()
        }
    }
    
    private func startTipRotation() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentTip = (currentTip + 1) % tips.count
            }
        }
    }
}

#Preview {
    AuthenticationLoadingView()
}