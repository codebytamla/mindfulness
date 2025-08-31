//
//  MeditationCompletionView.swift
//  mindfulness
//
//  Created by leo on 31/8/2568 BE.
//

import SwiftUI

struct MeditationCompletionView: View {
    let emotion: EmotionCategory
    let duration: Int
    let meditationType: MeditationType
    
    @State private var rating: Int = 5
    @State private var postMeditationMood: EmotionCategory?
    @State private var notes = ""
    @State private var showingMoodSelection = false
    
    let onComplete: (Int?, EmotionCategory?, String?) -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Celebration header
                    VStack(spacing: 15) {
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.2))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.green)
                        }
                        
                        Text("Meditation Complete!")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("You've taken \(duration) minutes for your well-being")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Session summary
                    VStack(spacing: 15) {
                        HStack {
                            Label("Duration", systemImage: "clock")
                            Spacer()
                            Text("\(duration) minutes")
                                .fontWeight(.medium)
                        }
                        
                        Divider()
                        
                        HStack {
                            Label("Type", systemImage: "brain.head.profile")
                            Spacer()
                            Text(meditationType.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                                .fontWeight(.medium)
                        }
                        
                        Divider()
                        
                        HStack {
                            Label("Started feeling", systemImage: "heart")
                            Spacer()
                            Text(emotion.rawValue.capitalized)
                                .fontWeight(.medium)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Rating section
                    VStack(spacing: 15) {
                        Text("How was your meditation?")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 15) {
                            ForEach(1...5, id: \.self) { star in
                                Button(action: {
                                    rating = star
                                }) {
                                    Image(systemName: star <= rating ? "star.fill" : "star")
                                        .font(.title2)
                                        .foregroundColor(star <= rating ? .yellow : .gray)
                                }
                            }
                        }
                        
                        Text(getRatingDescription(rating))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                    .padding(.horizontal)
                    
                    // Mood check-in
                    VStack(spacing: 15) {
                        Text("How are you feeling now?")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Button(action: {
                            showingMoodSelection = true
                        }) {
                            HStack {
                                if let mood = postMeditationMood {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.red)
                                    Text("Feeling \(mood.rawValue.capitalized)")
                                        .fontWeight(.medium)
                                } else {
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(.blue)
                                    Text("Tap to check in with your mood")
                                        .foregroundColor(.blue)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if let beforeMood = postMeditationMood,
                           beforeMood != emotion {
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                    .foregroundColor(.green)
                                Text("Great! You shifted from \(emotion.rawValue) to \(beforeMood.rawValue)")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                    .padding(.horizontal)
                    
                    // Notes section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Any insights or reflections? (optional)")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        TextField("What did you notice during your meditation?", text: $notes, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                    .padding(.horizontal)
                    
                    // Complete button
                    Button(action: {
                        onComplete(rating, postMeditationMood, notes.isEmpty ? nil : notes)
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Complete Session")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 50)
                }
            }
            .navigationTitle("Session Complete")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingMoodSelection) {
            PostMeditationMoodView(selectedMood: $postMeditationMood)
        }
    }
    
    private func getRatingDescription(_ rating: Int) -> String {
        switch rating {
        case 1: return "Not helpful this time"
        case 2: return "Somewhat helpful"
        case 3: return "Moderately helpful"
        case 4: return "Very helpful"
        case 5: return "Extremely helpful"
        default: return ""
        }
    }
}

struct PostMeditationMoodView: View {
    @Binding var selectedMood: EmotionCategory?
    @Environment(\.dismiss) private var dismiss
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    VStack(spacing: 10) {
                        Text("How are you feeling now?")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Notice any shifts in your emotional state")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(EmotionCategory.allCases, id: \.self) { emotion in
                            PostMoodCard(
                                emotion: emotion,
                                isSelected: selectedMood == emotion
                            ) {
                                selectedMood = emotion
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    if selectedMood != nil {
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Confirm Mood")
                                .font(.headline)
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
            .navigationTitle("Current Mood")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Cancel") {
                    dismiss()
                }
            )
        }
    }
}

struct PostMoodCard: View {
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
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(emotionColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: emotionIcon)
                        .font(.title3)
                        .foregroundColor(emotionColor)
                }
                
                Text(emotion.rawValue.capitalized)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? emotionColor : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MeditationCompletionView(
        emotion: .anxious,
        duration: 10,
        meditationType: .breathwork
    ) { rating, mood, notes in
        print("Rating: \(rating ?? -1), Mood: \(mood?.rawValue ?? "none"), Notes: \(notes ?? "no notes")")
    }
}