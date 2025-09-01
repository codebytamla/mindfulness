import SwiftUI

struct FloatingActionButton: View {
    let systemImage: String
    let color: Color
    let position: FloatingButtonPosition
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var showRipple = false
    
    enum FloatingButtonPosition {
        case topRight
        case bottomLeft
        case bottomRight
    }
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                showRipple = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showRipple = false
            }
            
            action()
        }) {
            ZStack {
                // Ripple effect
                if showRipple {
                    Circle()
                        .fill(color.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .scaleEffect(showRipple ? 1.5 : 1.0)
                        .opacity(showRipple ? 0 : 1)
                        .animation(.easeOut(duration: 0.6), value: showRipple)
                }
                
                // Main button
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [color.opacity(0.8), color.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)
                    )
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: color.opacity(0.3), radius: 12, x: 0, y: 6)
                
                Image(systemName: systemImage)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white)
            }
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct FloatingActionButtons: View {
    let onProfileTap: () -> Void
    let onLibraryTap: () -> Void
    let onInsightsTap: () -> Void
    
    @State private var buttonsVisible = false
    
    var body: some View {
        ZStack {
            // Profile button - top right
            VStack {
                HStack {
                    Spacer()
                    
                    FloatingActionButton(
                        systemImage: "person.circle.fill",
                        color: Color(hex: "007AFF"),
                        position: .topRight,
                        action: onProfileTap
                    )
                    .offset(x: buttonsVisible ? 0 : 100, y: buttonsVisible ? 0 : -100)
                    .opacity(buttonsVisible ? 1 : 0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1), value: buttonsVisible)
                }
                .padding(.top, 60)
                .padding(.trailing, 20)
                
                Spacer()
            }
            
            // Bottom buttons
            VStack {
                Spacer()
                
                HStack {
                    // Insights button - bottom left
                    FloatingActionButton(
                        systemImage: "chart.xyaxis.line",
                        color: Color(hex: "FF9500"),
                        position: .bottomLeft,
                        action: onInsightsTap
                    )
                    .offset(x: buttonsVisible ? 0 : -100, y: buttonsVisible ? 0 : 100)
                    .opacity(buttonsVisible ? 1 : 0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2), value: buttonsVisible)
                    
                    Spacer()
                    
                    // Library button - bottom right
                    FloatingActionButton(
                        systemImage: "square.stack.fill",
                        color: Color(hex: "5E2CA5"),
                        position: .bottomRight,
                        action: onLibraryTap
                    )
                    .offset(x: buttonsVisible ? 0 : 100, y: buttonsVisible ? 0 : 100)
                    .opacity(buttonsVisible ? 1 : 0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: buttonsVisible)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100) // Above tab view area
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8).delay(0.5)) {
                buttonsVisible = true
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        FloatingActionButtons(
            onProfileTap: { print("Profile tapped") },
            onLibraryTap: { print("Library tapped") },
            onInsightsTap: { print("Insights tapped") }
        )
    }
}