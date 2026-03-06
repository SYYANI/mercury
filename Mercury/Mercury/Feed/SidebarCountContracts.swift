//
//  SidebarCountContracts.swift
//  Mercury
//

import Foundation

// MARK: - Projection item types

struct SidebarTagItem: Identifiable, Sendable {
    var id: Int64 { tagId }
    var tagId: Int64
    var name: String
    var normalizedName: String
    var isProvisional: Bool
    /// Count of entries associated with this tag. Equivalent to `Tag.usageCount`.
    var usageCount: Int
    /// Count of unread entries associated with this tag.
    var unreadCount: Int
}

// MARK: - Projection root

/// A complete snapshot of all sidebar counter data, computed from the database by `SidebarCountStore`.
struct SidebarProjection: Sendable {
    /// Total number of unread entries across all feeds.
    var totalUnread: Int
    /// Total number of starred entries.
    var totalStarred: Int
    /// Number of starred entries that are also unread.
    var starredUnread: Int
    /// Per-feed unread counts keyed by feed ID. Feeds with zero unread entries are not present.
    var feedUnreadCounts: [Int64: Int]
    /// Visible tag rows for the sidebar. Ordered by `usageCount DESC, normalizedName ASC`.
    var tags: [SidebarTagItem]

    static let empty = SidebarProjection(
        totalUnread: 0,
        totalStarred: 0,
        starredUnread: 0,
        feedUnreadCounts: [:],
        tags: []
    )
}
