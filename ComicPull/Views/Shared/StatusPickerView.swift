import SwiftUI

struct StatusPickerView: View {
    @Binding var status: ReadingStatus?

    var body: some View {
        Menu {
            ForEach(ReadingStatus.allCases) { readingStatus in
                Button {
                    status = readingStatus
                } label: {
                    Label(readingStatus.rawValue, systemImage: readingStatus.systemImage)
                }
            }

            Divider()

            Button(role: .destructive) {
                status = nil
            } label: {
                Label("Remove from Collection", systemImage: "trash")
            }
        } label: {
            if let status {
                Label(status.rawValue, systemImage: status.systemImage)
                    .font(.subheadline)
            } else {
                Label("Add to Collection", systemImage: "plus.circle")
                    .font(.subheadline)
            }
        }
    }
}
