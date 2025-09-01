import SwiftUI

enum MeditationFlowStep {
    case emotion, situation, duration, session, completion
}

struct MeditationFlowView: View {
    let onComplete: (MeditationSession) -> Void
    
    @State private var currentStep: MeditationFlowStep = .emotion
    @State private var selectedEmotion: EmotionCategory?
    @State private var emotionIntensity: Int = 5
    @State private var selectedSituation: SituationCategory?
    @State private var situationDescription: String?
    @State private var selectedDuration: Int = 10
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Group {
                switch currentStep {
                case .emotion:
                    EmotionSelectionView { emotion, intensity in
                        selectedEmotion = emotion
                        emotionIntensity = intensity
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .situation
                        }
                    }
                    .navigationBarItems(
                        leading: Button("Cancel") {
                            dismiss()
                        },
                        trailing: ProgressIndicator(currentStep: 1, totalSteps: 3)
                    )
                case .situation:
                    SituationInputView(
                        selectedEmotion: selectedEmotion!,
                        emotionIntensity: emotionIntensity
                    ) { situation, description in
                        selectedSituation = situation
                        situationDescription = description
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .duration
                        }
                    }
                    .navigationBarItems(
                        leading: Button("Back") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStep = .emotion
                            }
                        },
                        trailing: ProgressIndicator(currentStep: 2, totalSteps: 3)
                    )
                case .duration:
                    DurationSelectionView(
                        selectedEmotion: selectedEmotion!,
                        emotionIntensity: emotionIntensity,
                        selectedSituation: selectedSituation,
                        situationDescription: situationDescription
                    ) { duration in
                        selectedDuration = duration
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .session
                        }
                    }
                    .navigationBarItems(
                        leading: Button("Back") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStep = .situation
                            }
                        },
                        trailing: ProgressIndicator(currentStep: 3, totalSteps: 3)
                    )
                case .session:
                    MeditationSessionView(
                        emotion: selectedEmotion!,
                        emotionIntensity: emotionIntensity,
                        situation: selectedSituation,
                        situationDescription: situationDescription,
                        duration: selectedDuration
                    ) { session in
                        onComplete(session)
                        dismiss()
                    }
                case .completion:
                    EmptyView()
                }
            }
            .navigationBarHidden(currentStep == .session)
        }
        .onAppear {
            currentStep = .emotion
        }
    }
}

struct ProgressIndicator: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
            
            Text("\(currentStep)/\(totalSteps)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}