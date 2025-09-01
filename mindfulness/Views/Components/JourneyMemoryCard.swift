import SwiftUI

struct JourneyMemoryCard: View {
    let session: MeditationSession
    
    @State private var isPressed = false
    
    private var emotionColor: Color {
        switch session.emotion {
        case .excited: return Color(hex: "FFD700")
        case .content: return Color(hex: "87CEEB")
        case .anxious: return Color(hex: "9370DB")
        case .overwhelmed: return Color(hex: "FF4500")
        case .angry: return Color(hex: "DC143C")
        case .frustrated: return Color(hex: "FF69B4")
        case .tired: return Color(hex: "2F4F4F")
        case .sad: return Color(hex: "191970")
        }
    }
    
    private var reflectionWord: String {
        // Convert rating to reflection word
        guard let rating = session.rating else {
            return "Mindful"
        }
        
        switch rating {
        case 5: return "Transcendent"
        case 4: return "Peaceful"
        case 3: return "Grounded"
        case 2: return "Present"
        default: return "Mindful"
        }
    }
    
    private var naturalTimeText: String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(session.timestamp) {
            let hour = calendar.component(.hour, from: session.timestamp)
            if hour >= 5 && hour < 12 {
                return "This morning"
            } else if hour >= 12 && hour < 17 {
                return "This afternoon"
            } else {
                return "This evening"
            }
        } else if calendar.isDateInYesterday(session.timestamp) {
            let hour = calendar.component(.hour, from: session.timestamp)
            if hour >= 5 && hour < 12 {
                return "Yesterday morning"
            } else if hour >= 12 && hour < 17 {
                return "Yesterday afternoon"
            } else {
                return "Yesterday evening"
            }
        } else {
            let daysDifference = calendar.dateComponents([.day], from: session.timestamp, to: now).day ?? 0
            if daysDifference < 7 {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE"
                let dayName = formatter.string(from: session.timestamp)
                let hour = calendar.component(.hour, from: session.timestamp)
                let timeOfDay = hour < 12 ? "morning" : (hour < 17 ? "afternoon" : "evening")
                return "\(dayName) \(timeOfDay)"
            } else {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                return formatter.string(from: session.timestamp)
            }
        }
    }
    
    private var meditationTypeDisplayName: String {
        session.meditationType.rawValue
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            // Could expand to show session details
        }) {
            HStack(spacing: 16) {
                // Emotion indicator circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [emotionColor.opacity(0.8), emotionColor.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(emotionEmoji)
                            .font(.title2)
                    )
                
                // Session details
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(reflectionWord)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        
                        // Duration badge
                        Text("\(session.duration)m")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(emotionColor.opacity(0.3))
                            )
                    }
                    
                    Text(meditationTypeDisplayName)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(naturalTimeText)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                // Mood improvement indicator
                if let postMood = session.postMeditationMood, postMood != session.emotion {
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.green)
                        
                        Text("Improved")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.green)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [emotionColor.opacity(0.1), Color.clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(emotionColor.opacity(0.2), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                isPressed = pressing
            }
        }, perform: {})
    }
    
    private var emotionEmoji: String {
        switch session.emotion {
        case .excited: return "🤩"
        case .content: return "😌"
        case .anxious: return "😰"
        case .overwhelmed: return "😵‍💫"
        case .angry: return "😤"
        case .frustrated: return "😣"
        case .tired: return "😴"
        case .sad: return "😢"
        }
    }
}

struct JourneyEntriesPage: View {
    let sessions: [MeditationSession]
    let selectedEmotion: EmotionCategory?
    
    private var recentSessions: [MeditationSession] {
        sessions.sorted(by: { $0.timestamp > $1.timestamp }).prefix(5).map { $0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Journey Entries")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            if recentSessions.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.white.opacity(0.3))
                    
                    VStack(spacing: 8) {
                        Text("Your journey begins with")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("a single breath")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Text("Start your first meditation to see your memories here")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(recentSessions, id: \.id) { session in
                        JourneyMemoryCard(session: session)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

struct DiscoverThemeCard: View {
    let title: String
    let description: String
    let color: Color
    let systemImage: String
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            onTap()
        }) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: systemImage)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(color)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Text(description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(20)
            .frame(height: 140)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [color.opacity(0.2), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct DiscoverPage: View {
    let selectedEmotion: EmotionCategory?
    
    private let themes = [
        ("Morning Rituals", "Start your day with intention and clarity", Color(hex: "FF9500"), "sunrise.fill"),
        ("Sleep Stories", "Gentle narratives to ease you into rest", Color(hex: "5E2CA5"), "moon.stars.fill"),
        ("Focus Flow", "Deep concentration for work and study", Color(hex: "007AFF"), "brain.head.profile"),
        ("Stress Relief", "Quick techniques for overwhelming moments", Color(hex: "DC143C"), "heart.fill"),
        ("Loving Kindness", "Cultivate compassion for self and others", Color(hex: "FF69B4"), "heart.text.square.fill"),
        ("Nature Sounds", "Connect with the healing power of nature", Color(hex: "87CEEB"), "leaf.fill")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Discover")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Curated meditations for every moment")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(Array(themes.enumerated()), id: \.offset) { index, theme in
                    DiscoverThemeCard(
                        title: theme.0,
                        description: theme.1,
                        color: theme.2,
                        systemImage: theme.3
                    ) {
                        // Handle theme selection
                        print("Selected theme: \(theme.0)")
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        JourneyEntriesPage(sessions: [], selectedEmotion: nil)
    }
}