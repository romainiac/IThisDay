//
//  ThisDayApp.swift
//  ThisDay
//
//  Created by Roman Yefimets on 3/26/24.
//

import SwiftUI
import SwiftData

@main
struct ThisDayApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Event.self,
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
            EventView()
        }
        .modelContainer(sharedModelContainer)
    }
}
