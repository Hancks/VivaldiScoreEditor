import SwiftUI

@main
struct VivaldiScoreEditorApp: App {
    var body: some Scene {
        #if os(macOS)
        WindowGroup {
            ContentView()
                .frame(minWidth: 900, minHeight: 600)
        }
        .defaultSize(width: 1100, height: 700)
        #else
        WindowGroup {
            ContentView()
        }
        #endif
    }
}
