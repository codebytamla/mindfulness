//
//  SituationInputView.swift
//  mindfulness
//
//  Created by leo on 31/8/2568 BE.
//

import SwiftUI

struct SituationInputView: View {
    let selectedEmotion: EmotionCategory
    let emotionIntensity: Int
    
    @State private var selectedSituation: SituationCategory?
    @State private var customDescription = ""
    @State private var showingCustomInput = false
    
    let onSelectionComplete: (SituationCategory?, String?) -> Void
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.green.opacity(0.1),
                        Color.blue.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        VStack(spacing: 10) {
                            Text("What's happening?")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("This helps us find the perfect meditation for your situation")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 20)
                        
                        // Current emotion summary
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                            Text("Feeling \(selectedEmotion.rawValue) (\(emotionIntensity)/10)")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.medium)
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                        
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(SituationCategory.allCases, id: \.self) { situation in
                                SituationCard(
                                    situation: situation,
                                    isSelected: selectedSituation == situation
                                ) {
                                    withAnimation(.spring()) {
                                        selectedSituation = situation
                                        if situation == .other {
                                            showingCustomInput = true
                                        } else {
                                            showingCustomInput = false
                                            customDescription = ""
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        if showingCustomInput {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Tell us more (optional)")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                TextField("What's on your mind?", text: $customDescription, axis: .vertical)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .lineLimit(3...6)
                            }
                            .padding()
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            .padding(.horizontal)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                        
                        VStack(spacing: 15) {
                            Button(action: {
                                let description = showingCustomInput && !customDescription.isEmpty ? customDescription : nil
                                onSelectionComplete(selectedSituation, description)
                            }) {
                                HStack {
                                    Image(systemName: "arrow.right.circle.fill")
                                    Text(selectedSituation == nil ? "Skip & Continue" : "Continue")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedSituation == nil ? Color.gray : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            
                            if selectedSituation == nil {
                                Text("It's okay to skip this step")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct SituationCard: View {
    let situation: SituationCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    private var cardColor: Color {
        switch situation {
        case .work: return .blue
        case .relationships: return .pink
        case .health: return .green
        case .financial: return .orange
        case .grief: return .purple
        case .dailyStress: return .red
        case .sleep: return .indigo
        case .other: return .gray
        }
    }
    
    private var displayName: String {
        switch situation {
        case .work: return "Work"
        case .relationships: return "Relationships"
        case .health: return "Health"
        case .financial: return "Financial"
        case .grief: return "Loss & Grief"
        case .dailyStress: return "Daily Stress"
        case .sleep: return "Sleep"
        case .other: return "Something Else"
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(cardColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: situation.icon)
                        .font(.title3)
                        .foregroundColor(cardColor)
                }
                
                Text(displayName)
                    .font(.system(.callout, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? cardColor : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SituationInputView(
        selectedEmotion: .anxious,
        emotionIntensity: 7
    ) { situation, description in
        print("Selected situation: \(situation?.rawValue ?? "none"), description: \(description ?? "none")")
    }
}