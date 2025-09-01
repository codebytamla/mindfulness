import SwiftUI

struct EmotionChip: View {
    let emotion: EmotionCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    private var emotionEmoji: String {
        switch emotion {
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
    
    private var emotionLabel: String {
        switch emotion {
        case .excited: return "Excited"
        case .content: return "Content"
        case .anxious: return "Anxious"
        case .overwhelmed: return "Overwhelmed"
        case .angry: return "Angry"
        case .frustrated: return "Frustrated"
        case .tired: return "Tired"
        case .sad: return "Sad"
        }
    }
    
    private var chipColor: Color {
        switch emotion {
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
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            onTap()
        }) {
            HStack(spacing: 8) {
                Text(emotionEmoji)
                    .font(.title2)
                
                Text(emotionLabel)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(isSelected ? chipColor.opacity(0.3) : Color.white.opacity(0.1))
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                isSelected ? chipColor : Color.white.opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
            )
        }
        .scaleEffect(isSelected ? 1.05 : (isPressed ? 0.95 : 1.0))
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct EmotionChipScrollView: View {
    @Binding var selectedEmotion: EmotionCategory?
    
    private let emotions: [EmotionCategory] = [.excited, .content, .anxious, .overwhelmed, .angry, .frustrated, .tired, .sad]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(emotions, id: \.self) { emotion in
                    EmotionChip(
                        emotion: emotion,
                        isSelected: selectedEmotion == emotion
                    ) {
                        if selectedEmotion == emotion {
                            selectedEmotion = nil
                        } else {
                            selectedEmotion = emotion
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    @State var selectedEmotion: EmotionCategory? = .excited
    
    return ZStack {
        Color.black.ignoresSafeArea()
        EmotionChipScrollView(selectedEmotion: $selectedEmotion)
    }
}