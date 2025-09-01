import SwiftUI

struct FloatingCTACard: View {
    let selectedEmotion: EmotionCategory?
    let onStartMeditation: () -> Void
    
    @State private var selectedDuration = 5
    @State private var isPlaying = false
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var isPressed = false
    
    private let durations = [3, 5, 10, 15]
    
    private var sessionTitle: String {
        guard let emotion = selectedEmotion else {
            return "Start 5-min session"
        }
        
        switch emotion {
        case .excited: return "Channel excitement"
        case .content: return "Deepen contentment"
        case .anxious: return "Ease anxiety"
        case .overwhelmed: return "Find clarity"
        case .angry: return "Release anger"
        case .frustrated: return "Transform frustration"
        case .tired: return "Restore energy"
        case .sad: return "Honor sadness"
        }
    }
    
    private var emotionColor: Color {
        guard let emotion = selectedEmotion else {
            return Color(hex: "007AFF")
        }
        
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
        VStack(spacing: 24) {
            // Main CTA Button
            ZStack {
                // Rotating gradient border
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [emotionColor, emotionColor.opacity(0.3), emotionColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 130, height: 130)
                    .rotationEffect(.degrees(rotationAngle))
                    .animation(.linear(duration: 4).repeatForever(autoreverses: false), value: rotationAngle)
                
                // Pulsing glow
                Circle()
                    .fill(emotionColor.opacity(0.2))
                    .frame(width: 140, height: 140)
                    .scaleEffect(pulseScale)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: pulseScale)
                
                // Main button
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isPlaying.toggle()
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        onStartMeditation()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 120, height: 120)
                        
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [emotionColor.opacity(0.8), emotionColor.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: isPlaying ? "pause.fill" : "waveform")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(.white)
                            .scaleEffect(isPressed ? 0.9 : 1.0)
                            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isPressed)
                    }
                }
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isPressed)
                .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                        isPressed = pressing
                    }
                }, perform: {})
            }
            
            // Session title
            VStack(spacing: 8) {
                Text(sessionTitle)
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("\(selectedDuration) minutes of guided meditation")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            // Duration picker
            HStack(spacing: 0) {
                ForEach(durations, id: \.self) { duration in
                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        selectedDuration = duration
                    }) {
                        Text("\(duration) min")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(selectedDuration == duration ? .black : .white.opacity(0.7))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(selectedDuration == duration ? .white : Color.clear)
                            )
                    }
                }
            }
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            )
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(
                            LinearGradient(
                                colors: [emotionColor.opacity(0.1), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: emotionColor.opacity(0.3), radius: 20, x: 0, y: 10)
        .onAppear {
            rotationAngle = 360
            pulseScale = 1.1
        }
        .animation(.easeInOut(duration: 0.8), value: selectedEmotion)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        FloatingCTACard(selectedEmotion: .excited) {
            print("Start meditation")
        }
        .padding()
    }
}