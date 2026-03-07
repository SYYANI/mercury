import SwiftUI

struct TagRenameSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.localizationBundle) private var bundle

    let title: String
    let initialName: String
    let onCommit: (String) -> Void

    @State private var text: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)

            TextField(String(localized: "Tag name", bundle: bundle), text: $text)
                .textFieldStyle(.roundedBorder)
                .frame(minWidth: 260)
                .onSubmit { commit() }

            HStack {
                Spacer()
                Button(String(localized: "Cancel", bundle: bundle), role: .cancel) {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Button(String(localized: "Rename", bundle: bundle)) {
                    commit()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(20)
        .onAppear { text = initialName }
    }

    private func commit() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            dismiss()
            return
        }
        onCommit(trimmed)
        dismiss()
    }
}
