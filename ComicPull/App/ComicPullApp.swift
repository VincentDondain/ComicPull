import SwiftUI
import SwiftData

@main
struct ComicPullApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Comic.self,
            Series.self,
            Creator.self,
            UserReview.self
        ])
    }
}
