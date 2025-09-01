import SwiftUI

struct EmotionalMeshBackground: View {
    @State private var animateGradient = false
    let selectedEmotion: EmotionCategory?
    
    private var emotionColors: [Color] {
        guard let emotion = selectedEmotion else {
            return defaultColors
        }
        
        switch emotion {
        case .excited: return [Color(hex: "FFD700"), Color(hex: "FFA500"), Color(hex: "FF6B35")]
        case .content: return [Color(hex: "87CEEB"), Color(hex: "98FB98"), Color(hex: "E0FFFF")]
        case .anxious: return [Color(hex: "9370DB"), Color(hex: "8A2BE2"), Color(hex: "7B68EE")]
        case .overwhelmed: return [Color(hex: "FF4500"), Color(hex: "FF6347"), Color(hex: "FFB347")]
        case .angry: return [Color(hex: "8B0000"), Color(hex: "DC143C"), Color(hex: "FF0000")]
        case .frustrated: return [Color(hex: "FF69B4"), Color(hex: "FF1493"), Color(hex: "DC143C")]
        case .tired: return [Color(hex: "2F4F4F"), Color(hex: "556B2F"), Color(hex: "8B4513")]
        case .sad: return [Color(hex: "191970"), Color(hex: "483D8B"), Color(hex: "6A5ACD")]
        }
    }
    
    private var defaultColors: [Color] {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 6 && hour < 12 {
            // Morning: Warm energizing
            return [Color(hex: "FF9500"), Color(hex: "FF6B35"), Color(hex: "F7931E")]
        } else if hour >= 12 && hour < 18 {
            // Afternoon: Bright and clear
            return [Color(hex: "007AFF"), Color(hex: "5AC8FA"), Color(hex: "00C7BE")]
        } else {
            // Evening/Night: Cool and calming
            return [Color(hex: "5E2CA5"), Color(hex: "A550DF"), Color(hex: "BF5AF2")]
        }
    }
    
    var body: some View {
        ZStack {
            // Base dark gradient
            LinearGradient(
                colors: [Color.black, Color(hex: "1C1C1E")],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Animated gradient overlay (fallback for MeshGradient)
            RadialGradient(
                colors: [
                    emotionColors[0].opacity(0.3),
                    emotionColors[1].opacity(0.2),
                    emotionColors[2].opacity(0.1),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 50,
                endRadius: 400
            )
            .scaleEffect(animateGradient ? 1.1 : 1.0)
            .rotationEffect(.degrees(animateGradient ? 5 : -5))
            .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animateGradient)
            
            // Additional gradient layers for depth
            RadialGradient(
                colors: [
                    Color.clear,
                    emotionColors[1].opacity(0.2),
                    emotionColors[2].opacity(0.3)
                ],
                center: .bottomTrailing,
                startRadius: 50,
                endRadius: 350
            )
            .scaleEffect(animateGradient ? 0.9 : 1.1)
            .rotationEffect(.degrees(animateGradient ? -3 : 3))
            .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animateGradient)
            
            // Subtle particle effect
            ForEach(0..<12, id: \.self) { index in
                Circle()
                    .fill(emotionColors[index % emotionColors.count].opacity(0.1))
                    .frame(width: CGFloat.random(in: 2...6))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height * 0.4)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 3...6))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.2),
                        value: animateGradient
                    )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            animateGradient = true
        }
        .animation(.easeInOut(duration: 1.5), value: selectedEmotion)
    }
}

#Preview {
    EmotionalMeshBackground(selectedEmotion: .excited)
}