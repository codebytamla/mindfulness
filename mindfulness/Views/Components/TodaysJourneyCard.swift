import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let total: Double
    let color: Color
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 8)
                .frame(width: 120, height: 120)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: animatedProgress / total)
                .stroke(
                    LinearGradient(
                        colors: [color.opacity(0.8), color],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 1.5, dampingFraction: 0.8), value: animatedProgress)
            
            // Center content
            VStack(spacing: 4) {
                Text("\(Int(progress))")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("minutes")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .onAppear {
            withAnimation(.spring(response: 2.0, dampingFraction: 0.8).delay(0.5)) {
                animatedProgress = progress
            }
        }
    }
}

struct WeeklyPatternGraph: View {
    let weeklyData: [Double] // Last 7 days of meditation minutes
    let color: Color
    
    @State private var showBars = false
    
    private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]
    private let maxHeight: CGFloat = 60
    
    var body: some View {
        VStack(spacing: 16) {
            Text("This Week's Pattern")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(0..<7) { index in
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [color, color.opacity(0.6)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(
                                width: 24,
                                height: showBars ? CGFloat(weeklyData[index] / weeklyData.max()! * maxHeight) : 2
                            )
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(Double(index) * 0.1), value: showBars)
                        
                        Text(dayLabels[index])
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            
            Text("Building consistency, one breath at a time")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding()
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8).delay(0.3)) {
                showBars = true
            }
        }
    }
}

struct TodaysJourneyCard: View {
    let sessions: [MeditationSession]
    let selectedEmotion: EmotionCategory?
    
    @State private var showingWeeklyPattern = false
    @State private var dragOffset: CGSize = .zero
    
    private var todaysMinutes: Double {
        let today = Calendar.current.startOfDay(for: Date())
        return sessions
            .filter { Calendar.current.isDate($0.timestamp, inSameDayAs: today) }
            .reduce(0) { $0 + Double($1.duration) }
    }
    
    private var currentStreak: Int {
        calculateStreak()
    }
    
    private var weeklyData: [Double] {
        let calendar = Calendar.current
        let today = Date()
        var data: [Double] = []
        
        for i in (0..<7).reversed() {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let dayStart = calendar.startOfDay(for: date)
                let minutes = sessions
                    .filter { calendar.isDate($0.timestamp, inSameDayAs: dayStart) }
                    .reduce(0) { $0 + Double($1.duration) }
                data.append(max(minutes, 1)) // Ensure minimum height for visual
            } else {
                data.append(1)
            }
        }
        
        return data
    }
    
    private var emotionColor: Color {
        guard let emotion = selectedEmotion else {
            let hour = Calendar.current.component(.hour, from: Date())
            if hour >= 6 && hour < 12 {
                return Color(hex: "FF9500") // Morning orange
            } else if hour >= 12 && hour < 18 {
                return Color(hex: "007AFF") // Afternoon blue
            } else {
                return Color(hex: "5E2CA5") // Evening purple
            }
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
        ZStack {
            if showingWeeklyPattern {
                WeeklyPatternGraph(weeklyData: weeklyData, color: emotionColor)
            } else {
                mainJourneyView
            }
        }
        .frame(height: 200)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [emotionColor.opacity(0.15), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
        .scaleEffect(1 + dragOffset.width * 0.00005)
        .offset(x: dragOffset.width * 0.3)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        if abs(value.translation.width) > 100 {
                            showingWeeklyPattern.toggle()
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                        }
                        dragOffset = .zero
                    }
                }
        )
        .animation(.easeInOut(duration: 0.8), value: selectedEmotion)
    }
    
    private var mainJourneyView: some View {
        HStack(spacing: 32) {
            // Circular progress
            CircularProgressView(
                progress: todaysMinutes,
                total: 30, // Daily goal
                color: emotionColor
            )
            
            // Journey info
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Journey")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    if currentStreak > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                            
                            Text("\(currentStreak) day streak")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(.orange.opacity(0.2))
                        )
                    }
                }
                
                Text("You're building\nsomething beautiful")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.leading)
                
                // Swipe hint
                HStack(spacing: 4) {
                    Image(systemName: "arrow.left.and.right")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text("Swipe for weekly pattern")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            Spacer()
        }
        .padding(24)
    }
    
    private func calculateStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        let sessionDates = Set(sessions.map { calendar.startOfDay(for: $0.timestamp) })
        
        while sessionDates.contains(currentDate) || (streak == 0 && sessionDates.contains(calendar.date(byAdding: .day, value: -1, to: currentDate)!)) {
            if sessionDates.contains(currentDate) {
                streak += 1
            } else if streak == 0 {
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
                if sessionDates.contains(currentDate) {
                    streak += 1
                } else {
                    break
                }
            } else {
                break
            }
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        return streak
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        TodaysJourneyCard(sessions: [], selectedEmotion: .content)
            .padding()
    }
}