//
//  DurationSelectionView.swift
//  mindfulness
//
//  Created by leo on 31/8/2568 BE.
//

import SwiftUI

struct DurationSelectionView: View {
    let selectedEmotion: EmotionCategory
    let emotionIntensity: Int
    let selectedSituation: SituationCategory?
    let situationDescription: String?
    
    @State private var selectedDuration = 10
    @State private var showingCustomDuration = false
    @State private var customDuration = 15
    
    let onSelectionComplete: (Int) -> Void
    
    private let presetDurations = [3, 5, 10, 15, 20, 30]
    
    private var recommendedDuration: Int {
        switch selectedEmotion {
        case .anxious, .overwhelmed:
            return emotionIntensity > 7 ? 15 : 10
        case .angry, .frustrated:
            return 10
        case .sad, .tired:
            return emotionIntensity > 6 ? 20 : 15
        case .excited:
            return 5
        case .content:
            return 10
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.purple.opacity(0.1),
                    Color.pink.opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                    VStack(spacing: 30) {
                        VStack(spacing: 10) {
                            Text("How much time do you have?")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("We've prepared the perfect meditation length for you")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 20)
                        
                        // Current selections summary
                        VStack(spacing: 10) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                Text("\(selectedEmotion.rawValue.capitalized) (\(emotionIntensity)/10)")
                                
                                if let situation = selectedSituation {
                                    Divider()
                                        .frame(height: 20)
                                    Image(systemName: situation.icon)
                                        .foregroundColor(.blue)
                                    Text(situation.rawValue.capitalized)
                                }
                            }
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.medium)
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                        
                        // Recommended duration
                        VStack(spacing: 15) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text("Recommended for you")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            Button(action: {
                                selectedDuration = recommendedDuration
                                showingCustomDuration = false
                            }) {
                                VStack(spacing: 8) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.blue.opacity(0.2))
                                            .frame(width: 80, height: 80)
                                        
                                        VStack {
                                            Text("\(recommendedDuration)")
                                                .font(.title)
                                                .fontWeight(.bold)
                                            Text("min")
                                                .font(.caption)
                                        }
                                        .foregroundColor(.blue)
                                    }
                                    
                                    Text("Perfect for your current state")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedDuration == recommendedDuration ? Color.blue.opacity(0.1) : Color(UIColor.systemBackground))
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(selectedDuration == recommendedDuration ? Color.blue : Color.clear, lineWidth: 2)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal)
                        
                        // Preset durations
                        VStack(spacing: 15) {
                            Text("Or choose another duration")
                                .font(.headline)
                                .fontWeight(.medium)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                                ForEach(presetDurations.filter { $0 != recommendedDuration }, id: \.self) { duration in
                                    DurationCard(
                                        duration: duration,
                                        isSelected: selectedDuration == duration && !showingCustomDuration
                                    ) {
                                        selectedDuration = duration
                                        showingCustomDuration = false
                                    }
                                }
                                
                                // Custom duration option
                                Button(action: {
                                    showingCustomDuration = true
                                    selectedDuration = customDuration
                                }) {
                                    VStack(spacing: 8) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.gray.opacity(0.2))
                                                .frame(width: 60, height: 60)
                                            
                                            Image(systemName: "slider.horizontal.3")
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Text("Custom")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                    }
                                    .frame(height: 80)
                                    .frame(maxWidth: .infinity)
                                    .background(showingCustomDuration ? Color.gray.opacity(0.1) : Color(UIColor.systemBackground))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(showingCustomDuration ? Color.gray : Color.clear, lineWidth: 2)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        
                        if showingCustomDuration {
                            VStack(spacing: 15) {
                                Text("Custom Duration")
                                    .font(.headline)
                                
                                HStack {
                                    Text("3 min")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Slider(
                                        value: Binding(
                                            get: { Double(customDuration) },
                                            set: { 
                                                customDuration = Int($0)
                                                selectedDuration = customDuration
                                            }
                                        ),
                                        in: 3...60,
                                        step: 1
                                    )
                                    .accentColor(.purple)
                                    
                                    Text("60 min")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text("\(customDuration) minutes")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.purple)
                            }
                            .padding()
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            .padding(.horizontal)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                        
                        Button(action: {
                            onSelectionComplete(selectedDuration)
                        }) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                Text("Start \(selectedDuration)-Minute Meditation")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                }
            }
    }
}

struct DurationCard: View {
    let duration: Int
    let isSelected: Bool
    let onTap: () -> Void
    
    private var durationDescription: String {
        switch duration {
        case 3: return "Quick reset"
        case 5: return "Brief pause"
        case 10: return "Standard"
        case 15: return "Deep focus"
        case 20: return "Extended"
        case 30: return "Full session"
        default: return "Custom"
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.mint.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    VStack {
                        Text("\(duration)")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("min")
                            .font(.caption2)
                    }
                    .foregroundColor(.mint)
                }
                
                Text(durationDescription)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.mint.opacity(0.1) : Color(UIColor.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.mint : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    DurationSelectionView(
        selectedEmotion: .anxious,
        emotionIntensity: 7,
        selectedSituation: .work,
        situationDescription: nil
    ) { duration in
        print("Selected duration: \(duration) minutes")
    }
}