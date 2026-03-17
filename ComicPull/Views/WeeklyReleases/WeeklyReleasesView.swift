import SwiftUI

struct WeeklyReleasesView: View {
    // TODO: Inject via environment or init
    // @State private var viewModel: WeeklyReleasesViewModel

    var body: some View {
        NavigationStack {
            Text("Weekly Releases")
                .font(.title)
                .foregroundStyle(.secondary)
                .navigationTitle("This Week")
        }
    }
}

#Preview {
    WeeklyReleasesView()
}
