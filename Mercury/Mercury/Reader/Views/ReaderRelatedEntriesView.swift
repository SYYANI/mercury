//
//  ReaderRelatedEntriesView.swift
//  Mercury
//

import SwiftUI

/// A horizontal strip of related entry cards.
/// Entries are ranked by shared-tag co-occurrence.
struct ReaderRelatedEntriesView: View {
    let entries: [EntryListItem]
    let onSelectEntry: (Int64) -> Void

    @Environment(\.localizationBundle) var bundle

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 10) {
                ForEach(entries) { item in
                    relatedEntryCard(item)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            .padding(.top, 4)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private func relatedEntryCard(_ item: EntryListItem) -> some View {
        Button {
            onSelectEntry(item.id)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title ?? String(localized: "(Untitled)", bundle: bundle))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 0)

                if let sourceTitle = item.feedSourceTitle {
                    Text(sourceTitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(10)
            .frame(width: 180, height: 80)
            .background(Color(nsColor: .textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
