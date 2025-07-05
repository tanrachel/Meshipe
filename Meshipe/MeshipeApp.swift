//
//  MeshipeApp.swift
//  Meshipe
//
//  Created by Rachel  Tan on 3/16/25.
//

import SwiftUI
import SwiftData

@main
struct MeshipeApp: App {
    let groqKey = ProcessInfo.processInfo.environment["groqkey"] ?? ""
    var body: some Scene {
        let mrgroq = GroqSession(api: groqKey)
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Recipe.self)
        .environment(mrgroq)
    }
}
