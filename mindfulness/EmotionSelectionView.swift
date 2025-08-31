//
//  EmotionSelectionView.swift
//  mindfulness
//
//  Created by leo on 31/8/2568 BE.
//

import SwiftUI

struct EmotionSelectionView: View {
    @State private var selectedEmotion: EmotionCategory?
    @State private var emotionIntensity: Double = 5
    @State private var showingNextStep = false
    
    let onSelectionComplete: (EmotionCategory, Int) -> Void
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                    VStack(spacing: 30) {
                        VStack(spacing: 10) {
                            Text("How are you feeling?")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Take a moment to recognize your current emotional state")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 20)
                        
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(EmotionCategory.allCases, id: \.self) { emotion in
                                EmotionCard(
                                    emotion: emotion,
                                    isSelected: selectedEmotion == emotion
                                ) {
                                    withAnimation(.spring()) {
                                        selectedEmotion = emotion
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        if selectedEmotion != nil {
                            VStack(spacing: 15) {
                                Text("How intense is this feeling?")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                HStack {
                                    Text("Mild")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Slider(value: $emotionIntensity, in: 1...10, step: 1)
                                        .accentColor(.blue)
                                    
                                    Text("Intense")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text("\(Int(emotionIntensity))/10")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            .padding(.horizontal)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                        
                        if selectedEmotion != nil {
                            Button(action: {
                                guard let emotion = selectedEmotion else { return }
                                onSelectionComplete(emotion, Int(emotionIntensity))
                            }) {
                                HStack {
                                    Image(systemName: "arrow.right.circle.fill")
                                    Text("Continue")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                }
            }
    }
}

struct EmotionCard: View {
    let emotion: EmotionCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    private var emotionColor: Color {
        switch emotion.valence {
        case .pleasant:
            return emotion.arousal == .high ? .green : .mint
        case .unpleasant:
            return emotion.arousal == .high ? .red : .indigo
        }
    }
    
    private var emotionIcon: String {
        switch emotion {
        case .anxious: return "heart.circle.fill"
        case .sad: return "cloud.fill"
        case .angry: return "flame.fill"
        case .overwhelmed: return "tornado"
        case .excited: return "star.fill"
        case .content: return "leaf.fill"
        case .tired: return "powersleep"
        case .frustrated: return "exclamationmark.triangle.fill"
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(emotionColor.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: emotionIcon)
                        .font(.title2)
                        .foregroundColor(emotionColor)
                }
                
                Text(emotion.rawValue.capitalized)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? emotionColor : Color.clear, lineWidth: 3)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    EmotionSelectionView { emotion, intensity in
        print("Selected: \(emotion.rawValue) with intensity \(intensity)")
    }
}