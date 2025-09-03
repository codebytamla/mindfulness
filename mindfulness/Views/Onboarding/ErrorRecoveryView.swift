//
//  ErrorRecoveryView.swift
//  mindfulness
//
//  Created by Claude on 3/9/2025.
//

import SwiftUI

struct ErrorRecoveryView: View {
    @Environment(\.theme) var theme
    let onRetry: () -> Void
    
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
                Spacer()
                
                // Error icon
                ZStack {
                    Circle()
                        .fill(theme.glowColor)
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 40, weight: .light))
                        .foregroundColor(theme.textPrimary)
                }
                
                // Error message
                VStack(spacing: 16) {
                    Text("Connection Issue")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.textPrimary)
                    
                    Text("We're having trouble setting up your account. This can happen with slow network connections or server issues.")
                        .font(.body)
                        .foregroundColor(theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 16) {
                    // Retry button
                    Button(action: onRetry) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .font(.title3)
                            Text("Try Again")
                                .font(.headline)
                                .fontWeight(.semibold)
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
                    
                    // Continue offline button
                    Button(action: {
                        // This could trigger anonymous auth or offline mode
                        onRetry()
                    }) {
                        HStack {
                            Image(systemName: "person.fill.questionmark")
                                .font(.title3)
                            Text("Continue as Guest")
                                .font(.headline)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(theme.cardBackground)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(theme.primary.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
        }
    }
}

#Preview {
    ErrorRecoveryView {
        print("Retry tapped")
    }
    .environment(\.theme, WaterTheme.riverFlow.colors)
}