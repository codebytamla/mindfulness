//
//  MeditationAI.swift
//  mindfulness
//
//  Created by leo on 31/8/2568 BE.
//

import Foundation

class MeditationAI: ObservableObject {
    @Published var isGenerating = false
    @Published var generatedScript = ""
    @Published var recommendedType: MeditationType = .mindfulness
    
    func generateMeditationScript(
        emotion: EmotionCategory,
        intensity: Int,
        duration: Int,
        situation: SituationCategory? = nil,
        situationDescription: String? = nil
    ) async -> (script: String, type: MeditationType) {
        
        await MainActor.run {
            isGenerating = true
        }
        
        // Simulate AI processing time
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let meditationType = determineMeditationType(emotion: emotion, intensity: intensity, situation: situation)
        let script = createScript(
            type: meditationType,
            emotion: emotion,
            intensity: intensity,
            duration: duration,
            situation: situation,
            situationDescription: situationDescription
        )
        
        await MainActor.run {
            self.generatedScript = script
            self.recommendedType = meditationType
            self.isGenerating = false
        }
        
        return (script: script, type: meditationType)
    }
    
    private func determineMeditationType(
        emotion: EmotionCategory,
        intensity: Int,
        situation: SituationCategory?
    ) -> MeditationType {
        
        // Apply Polyvagal Theory and Cognitive Appraisal Theory
        switch emotion {
        case .anxious, .overwhelmed:
            return intensity > 7 ? .breathwork : .bodyScan
        case .angry, .frustrated:
            return .breathwork // Cooling breath work
        case .sad:
            return intensity > 6 ? .selfCompassion : .lovingKindness
        case .tired:
            return situation == .sleep ? .sleepStory : .guidedImagery
        case .excited:
            return .mindfulness // Help ground excessive energy
        case .content:
            return .mindfulness
        }
    }
    
    private func createScript(
        type: MeditationType,
        emotion: EmotionCategory,
        intensity: Int,
        duration: Int,
        situation: SituationCategory?,
        situationDescription: String?
    ) -> String {
        
        let introduction = createIntroduction(emotion: emotion, situation: situation)
        let coreContent = createCoreContent(type: type, duration: duration, emotion: emotion, intensity: intensity)
        let conclusion = createConclusion(emotion: emotion)
        
        return """
        \(introduction)
        
        \(coreContent)
        
        \(conclusion)
        """
    }
    
    private func createIntroduction(emotion: EmotionCategory, situation: SituationCategory?) -> String {
        let emotionAcknowledgment = switch emotion {
        case .anxious:
            "I understand you're feeling anxious right now. This is a completely natural response, and you're taking a wonderful step by choosing to meditate."
        case .sad:
            "I recognize that you're experiencing sadness. It's okay to feel this way, and it's beautiful that you're creating space for yourself right now."
        case .angry:
            "I hear that you're feeling angry. Anger is a valid emotion, and we're going to work together to find some peace within this feeling."
        case .overwhelmed:
            "I see that you're feeling overwhelmed. Let's take this one breath at a time and create some space in your mind and body."
        case .excited:
            "I notice your excitement! Let's channel this wonderful energy in a mindful way."
        case .content:
            "I'm glad you're feeling content. Let's deepen this sense of peace and well-being."
        case .tired:
            "I understand you're feeling tired. Let's create a gentle space for rest and restoration."
        case .frustrated:
            "I hear your frustration. Let's work together to transform this energy into something more peaceful."
        }
        
        let situationContext = if let situation = situation {
            switch situation {
            case .work:
                " Work challenges are common, and it's wise to take this moment for yourself."
            case .relationships:
                " Relationship dynamics can be complex, and you deserve this time to center yourself."
            case .health:
                " Health concerns can be worrying, and finding inner calm can be especially healing right now."
            case .financial:
                " Financial stress affects many of us, and you're choosing a powerful way to find balance."
            case .grief:
                " Grief is one of life's most challenging experiences, and meditation can offer gentle support."
            case .dailyStress:
                " Daily stress is so common in our busy world, and you're making a wise choice to pause."
            case .sleep:
                " Sleep challenges can be frustrating, and this meditation will help prepare your mind and body for rest."
            case .other:
                " Whatever you're experiencing, this meditation will provide support and peace."
            }
        } else {
            ""
        }
        
        return """
        Welcome to this meditation. Find a comfortable position, either sitting or lying down. 
        
        \(emotionAcknowledgment)\(situationContext)
        
        Begin by gently closing your eyes, or softening your gaze downward. Take a moment to arrive here, fully present in this space you've created for yourself.
        """
    }
    
    private func createCoreContent(
        type: MeditationType,
        duration: Int,
        emotion: EmotionCategory,
        intensity: Int
    ) -> String {
        
        switch type {
        case .breathwork:
            return createBreathworkContent(duration: duration, emotion: emotion, intensity: intensity)
        case .bodyScan:
            return createBodyScanContent(duration: duration)
        case .lovingKindness:
            return createLovingKindnessContent(duration: duration)
        case .mindfulness:
            return createMindfulnessContent(duration: duration)
        case .sleepStory:
            return createSleepStoryContent(duration: duration)
        case .progressiveMuscleRelaxation:
            return createProgressiveMuscleRelaxationContent(duration: duration)
        case .guidedImagery:
            return createGuidedImageryContent(duration: duration)
        case .selfCompassion:
            return createSelfCompassionContent(duration: duration, emotion: emotion)
        }
    }
    
    private func createBreathworkContent(duration: Int, emotion: EmotionCategory, intensity: Int) -> String {
        let breathingTechnique = if emotion.arousal == .high && intensity > 6 {
            // 4-7-8 breathing for high arousal negative emotions
            """
            We'll use a calming 4-7-8 breathing technique. Inhale through your nose for 4 counts, hold for 7, and exhale through your mouth for 8 counts.
            
            Let's begin: Inhale... 2... 3... 4... Hold... 2... 3... 4... 5... 6... 7... 
            Exhale slowly through your mouth... 2... 3... 4... 5... 6... 7... 8...
            
            Beautiful. Continue this rhythm at your own pace. With each exhale, feel tension leaving your body.
            """
        } else {
            // Simple box breathing for gentler approach
            """
            We'll practice box breathing - equal counts for inhaling, holding, exhaling, and holding.
            
            Inhale for 4... 2... 3... 4... 
            Hold for 4... 2... 3... 4...
            Exhale for 4... 2... 3... 4...
            Hold for 4... 2... 3... 4...
            
            Continue this gentle rhythm, allowing each breath to bring you deeper into calm.
            """
        }
        
        let extendedContent = if duration > 10 {
            """
            
            Now, as you continue breathing, imagine each inhale bringing in peace and calm. Each exhale releases any tension, worry, or stress you've been carrying.
            
            Notice how your body begins to feel with each mindful breath. Your shoulders might soften, your jaw might unclench, your entire being settling into this moment of peace.
            
            If your mind wanders, that's perfectly natural. Simply return your attention to your breath, this anchor that's always available to you.
            """
        } else {
            ""
        }
        
        return breathingTechnique + extendedContent
    }
    
    private func createBodyScanContent(duration: Int) -> String {
        let basic = """
        Let's begin a gentle body scan. Start by bringing your attention to the top of your head. Notice any sensations there - perhaps warmth, tingling, or simply awareness.
        
        Slowly move your attention down to your forehead, around your eyes, your cheeks, and jaw. Don't try to change anything, just observe with kindness.
        
        Notice your neck and shoulders. These areas often hold tension. Breathe into them, allowing them to soften with each exhale.
        
        Move down to your arms, your chest, feeling your heart beating steadily. Your ribcage expanding and contracting with each breath.
        """
        
        let extended = if duration > 10 {
            """
            
            Continue down to your stomach area, your lower back. Notice how your body feels against whatever surface is supporting you.
            
            Bring attention to your hips, your thighs, your knees. Each part of your body deserving of this gentle attention and care.
            
            Notice your calves, your ankles, and finally your feet. Feel how they're grounded, connected to the earth beneath you.
            
            Now take a moment to feel your body as a whole - one complete, integrated system, worthy of your love and attention.
            """
        } else {
            ""
        }
        
        return basic + extended
    }
    
    private func createLovingKindnessContent(duration: Int) -> String {
        """
        Let's cultivate loving-kindness, starting with yourself. Place your hand on your heart if that feels comfortable.
        
        Repeat these phrases silently or aloud:
        "May I be happy. May I be healthy. May I be safe. May I be at ease."
        
        Feel the intention behind these words, sending genuine care to yourself.
        
        Now think of someone you love - a family member, friend, or pet. Extend these same wishes to them:
        "May you be happy. May you be healthy. May you be safe. May you be at ease."
        
        Now think of someone neutral - perhaps a cashier you saw today, or a neighbor. Send them the same loving wishes:
        "May you be happy. May you be healthy. May you be safe. May you be at ease."
        
        If you're ready, think of someone you find challenging. This is advanced practice, so be gentle with yourself:
        "May you be happy. May you be healthy. May you be safe. May you be at ease."
        
        Finally, extend these wishes to all beings everywhere:
        "May all beings be happy. May all beings be healthy. May all beings be safe. May all beings be at ease."
        
        Rest in this sense of universal love and connection.
        """
    }
    
    private func createMindfulnessContent(duration: Int) -> String {
        """
        Let's practice simple mindfulness - just being present with what is.
        
        Begin by noticing your breath, not changing it, just observing its natural rhythm.
        
        Now expand your awareness to sounds around you. Perhaps you hear traffic, birds, the hum of electronics, or silence itself. Just listen without judgment.
        
        Notice any sensations in your body - the feeling of your clothes, the temperature of the air, any physical sensations that arise.
        
        Observe your thoughts as they come and go, like clouds passing across the sky of your mind. You don't need to follow them or push them away, just notice them with gentle curiosity.
        
        If you find yourself getting caught up in thinking, simply return to your breath as an anchor to the present moment.
        
        This is mindfulness - this simple awareness of what's happening right now, without needing it to be different.
        """
    }
    
    private func createSleepStoryContent(duration: Int) -> String {
        """
        Let's prepare your mind and body for restful sleep with a gentle journey.
        
        Imagine yourself in a peaceful meadow at twilight. The air is warm and gentle, with a soft breeze that carries the sweet scent of wildflowers.
        
        You're lying on a soft blanket, looking up at the sky as day slowly transitions to night. The first stars are just beginning to appear, twinkling like diamonds against the deepening blue.
        
        Feel the earth supporting you completely. Every muscle in your body can relax and let go. Your breathing naturally slows and deepens.
        
        As the sky grows darker, more stars appear. Each one seems to pulse gently with a calming light. You feel perfectly safe and at peace in this beautiful place.
        
        The sounds of the day fade away, replaced by the gentle rustling of leaves and perhaps the distant call of a night bird. These sounds are soothing, helping you drift deeper into relaxation.
        
        Allow yourself to sink deeper into this peaceful state, knowing that your body knows exactly how to rest and restore itself as you sleep.
        """
    }
    
    private func createProgressiveMuscleRelaxationContent(duration: Int) -> String {
        """
        We'll systematically tense and release different muscle groups to help you achieve deep relaxation.
        
        Start by making fists with both hands. Squeeze them tight... tighter... feel the tension... and release. Notice the contrast between tension and relaxation.
        
        Now tense your arms by bringing your fists up toward your shoulders. Hold the tension... and release. Feel your arms drop heavy and relaxed.
        
        Scrunch up your face muscles - squeeze your eyes shut, wrinkle your forehead, clench your jaw... hold it... and release. Feel your face muscles soften completely.
        
        Hunch your shoulders up toward your ears... hold the tension... and let them drop. Feel them settling into relaxation.
        
        Arch your back slightly, feeling tension in your back muscles... and release, allowing your back to settle.
        
        Tense your stomach muscles, pulling them in tight... and release, allowing your belly to be soft and relaxed.
        
        Press your legs together and point your toes... feel the tension throughout your legs... and release. Let your legs fall apart naturally, completely relaxed.
        
        Notice how relaxed your entire body feels now, heavy and at peace.
        """
    }
    
    private func createGuidedImageryContent(duration: Int) -> String {
        """
        Let's take a journey to your personal place of peace and restoration.
        
        Imagine yourself walking along a path that leads to the most beautiful, peaceful place you can envision. This might be a beach, a forest, a garden, or any place where you feel completely at ease.
        
        As you walk, notice the details around you. What do you see? What colors, textures, and natural beauty surround you?
        
        What sounds do you hear in this peaceful place? Perhaps water flowing, birds singing, or a gentle breeze through leaves?
        
        Notice any scents in the air - perhaps ocean salt, pine trees, or flowers blooming.
        
        Find the perfect spot to rest in this beautiful place. Settle in comfortably, feeling completely safe and at peace.
        
        From this place of deep peace, you can handle anything that comes your way. This inner sanctuary is always available to you, whenever you need to return to calm and centeredness.
        
        Take a few more moments to soak in the peace of this place, knowing you can return here anytime through your meditation practice.
        """
    }
    
    private func createSelfCompassionContent(duration: Int, emotion: EmotionCategory) -> String {
        let emotionSpecificContent = switch emotion {
        case .sad:
            "Place your hand on your heart and feel its steady beating. Your heart has carried you through so much, and it continues to beat with love for you."
        case .angry, .frustrated:
            "It's okay to feel angry. This emotion shows that something matters to you. You can honor this feeling while also treating yourself with kindness."
        case .anxious, .overwhelmed:
            "Anxiety often comes from caring deeply. Your worried mind is trying to protect you. Can you offer it the same gentleness you'd give a friend?"
        default:
            "Whatever you're feeling right now is completely valid. You deserve the same kindness you would offer a dear friend."
        }
        
        return """
        Let's practice self-compassion - treating yourself with the same kindness you'd offer a good friend.
        
        \(emotionSpecificContent)
        
        Repeat these phrases to yourself, really meaning them:
        "This is a moment of difficulty."
        "Difficulty is part of life."
        "May I be kind to myself in this moment."
        
        Imagine wrapping yourself in a warm, comforting embrace. You are worthy of love and compassion, especially from yourself.
        
        Think about what you would say to a dear friend going through exactly what you're experiencing. Can you offer yourself those same words of understanding and care?
        
        Place both hands on your heart and breathe deeply. With each breath, send yourself love and acceptance. You are enough, just as you are.
        
        Remember that being imperfect, struggling, and feeling difficult emotions is part of the shared human experience. You are not alone in this.
        """
    }
    
    private func createConclusion(emotion: EmotionCategory) -> String {
        let emotionSpecificEncouragement = switch emotion {
        case .anxious:
            "Remember that you have tools to find calm whenever you need them. Your breath is always with you as an anchor to peace."
        case .sad:
            "Your feelings are valid, and you've shown great self-care by taking this time for meditation. Healing happens in its own time."
        case .angry:
            "You've transformed difficult energy into peaceful presence. This is a powerful skill you can use whenever you need it."
        case .overwhelmed:
            "You've created space in your mind and body. Remember that you can handle things one moment at a time."
        case .excited:
            "You've channeled your wonderful energy in a mindful way. This sense of grounded joy is available to you always."
        case .content:
            "You've deepened your natural sense of peace. This contentment is your true nature."
        case .tired:
            "You've given yourself the gift of rest and restoration. Your body and mind know how to heal themselves."
        case .frustrated:
            "You've transformed frustration into peaceful presence. This is true inner strength."
        }
        
        return """
        As we come to the end of this meditation, take a moment to appreciate yourself for taking this time for your well-being.
        
        \(emotionSpecificEncouragement)
        
        Begin to gently wiggle your fingers and toes, bringing movement back into your body. Take a deep breath in, and a long breath out.
        
        When you're ready, slowly open your eyes and return to your day, carrying this sense of peace with you.
        
        Remember that this calm, centered part of you is always available. You can return to it through your breath, through meditation, or simply by taking a mindful moment.
        
        Be gentle with yourself as you move forward. You've done beautiful work here today.
        """
    }
}