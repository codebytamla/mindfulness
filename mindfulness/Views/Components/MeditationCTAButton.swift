import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct MeditationCTAButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minHeight: 64)
            .background(
                ZStack {
                    // Material blur background
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial.opacity(0.1))
                    
                    // Main gradient background
                    LinearGradient(
                        colors: [Color(hex: "007AFF"), Color(hex: "AF52DE")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                }
            )
            .shadow(
                color: .black.opacity(0.3),
                radius: 20,
                x: 0,
                y: 10
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }
            }
    }
}

struct MeditationCTAButton: View {
    let action: () -> Void
    let longPressAction: (() -> Void)?
    
    @State private var isPulsing = false
    @State private var hasAppeared = false
    @Environment(\.colorScheme) private var colorScheme
    
    init(action: @escaping () -> Void, longPressAction: (() -> Void)? = nil) {
        self.action = action
        self.longPressAction = longPressAction
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Play button circle
                Circle()
                    .fill(.white)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "waveform")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "007AFF"))
                    )
                
                // Text content
                VStack(alignment: .leading, spacing: 2) {
                    Text("Start New Meditation")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Text("AI-powered guidance tailored to your emotions")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(MeditationCTAButtonStyle())
        .scaleEffect(isPulsing ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isPulsing)
        .scaleEffect(hasAppeared ? 1.0 : 0.9)
        .offset(y: hasAppeared ? 0 : 50)
        .opacity(hasAppeared ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                hasAppeared = true
            }
            
            // Start pulsing after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isPulsing = true
            }
        }
        .simultaneousGesture(
            longPressAction != nil ?
            LongPressGesture(minimumDuration: 0.8)
                .onEnded { _ in
                    let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                    impactFeedback.impactOccurred()
                    longPressAction?()
                } : nil
        )
        .accessibilityLabel("Start New Meditation")
        .accessibilityHint("Tap to begin a personalized meditation session based on your current emotions")
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    VStack(spacing: 40) {
        MeditationCTAButton(
            action: {
                print("Start meditation tapped")
            },
            longPressAction: {
                print("Long press detected")
            }
        )
        .padding()
        
        // Preview in different color schemes
        MeditationCTAButton(
            action: {
                print("Start meditation tapped")
            }
        )
        .padding()
        .preferredColorScheme(.dark)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemBackground))
}
