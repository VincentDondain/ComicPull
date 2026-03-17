import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            WeeklyReleasesView()
                .tabItem {
                    Label("This Week", systemImage: "calendar")
                }

            CollectionView()
                .tabItem {
                    Label("Collection", systemImage: "books.vertical")
                }

            RecommendationsView()
                .tabItem {
                    Label("For You", systemImage: "sparkles")
                }

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
        }
    }
}

#Preview {
    ContentView()
}
