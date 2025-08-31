//
//  mindfulnessApp.swift
//  mindfulness
//
//  Created by leo on 31/8/2568 BE.
//

import SwiftUI
import SwiftData

@main
struct mindfulnessApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MeditationSession.self,
            UserProfile.self,
            MoodEntry.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
