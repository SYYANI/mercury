//
//  AppModel+AgentAvailability.swift
//  Mercury
//

import Foundation
import GRDB

extension AppModel {
    // MARK: - Refresh

    /// Re-evaluates availability for all agent kinds and updates the
    /// @Published flags. Call after any settings mutation that may change
    /// whether an agent has a usable model+provider chain.
    func refreshAgentAvailability() async {
        let summary = await checkAgentAvailability(for: .summary)
        let translation = await checkAgentAvailability(for: .translation)
        let tagging = await checkAgentAvailability(for: .tagging)
        isSummaryAgentAvailable = summary
        isTranslationAgentAvailable = translation
        isTaggingAgentAvailable = tagging
    }

    // MARK: - Per-kind check

    /// An agent kind is available when its configured route (primaryModelId →
    /// fallbackModelId) has an explicitly selected primary model that resolves
    /// to an enabled model whose provider is also enabled. This mirrors the
    /// strict candidate-selection logic in `resolveAgentRouteCandidates` so
    /// the availability flag and the runtime always agree. Credential reads
    /// are skipped — reachability is validated at runtime via the failure/banner UX.
    private func checkAgentAvailability(for taskType: AgentTaskType) async -> Bool {
        // Load UserDefaults-configured settings — same source as resolveAgentRouteCandidates.
        let primaryModelId: Int64?
        let hasRequiredTaskSettings: Bool
        switch taskType {
        case .summary:
            let d = loadSummaryAgentDefaults()
            primaryModelId = d.primaryModelId
            hasRequiredTaskSettings = d.targetLanguage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        case .translation:
            let d = loadTranslationAgentDefaults()
            primaryModelId = d.primaryModelId
            hasRequiredTaskSettings = d.targetLanguage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
                && TranslationSettingsKey.concurrencyRange.contains(d.concurrencyDegree)
        case .tagging:
            let d = loadTaggingAgentDefaults()
            primaryModelId = d.primaryModelId
            hasRequiredTaskSettings = true
        }

        guard hasRequiredTaskSettings else { return false }
        guard let primaryModelId else { return false }

        do {
            return try await database.read { db in
                // Resolve the configured primary model strictly.
                let primaryModel: AgentModelProfile?
                switch taskType {
                case .summary:
                    primaryModel = try AgentModelProfile
                        .filter(Column("id") == primaryModelId)
                        .filter(Column("supportsSummary") == true)
                        .filter(Column("isEnabled") == true)
                        .filter(Column("isArchived") == false)
                        .fetchOne(db)
                case .translation:
                    primaryModel = try AgentModelProfile
                        .filter(Column("id") == primaryModelId)
                        .filter(Column("supportsTranslation") == true)
                        .filter(Column("isEnabled") == true)
                        .filter(Column("isArchived") == false)
                        .fetchOne(db)
                case .tagging:
                    primaryModel = try AgentModelProfile
                        .filter(Column("id") == primaryModelId)
                        .filter(Column("supportsTagging") == true)
                        .filter(Column("isEnabled") == true)
                        .filter(Column("isArchived") == false)
                        .fetchOne(db)
                }

                guard let primaryModel else { return false }

                // Primary model's provider must also be enabled.
                let primaryProvider = try AgentProviderProfile
                    .filter(Column("id") == primaryModel.providerProfileId)
                    .filter(Column("isEnabled") == true)
                    .filter(Column("isArchived") == false)
                    .fetchOne(db)

                return primaryProvider != nil
            }
        } catch {
            return false
        }
    }

    // MARK: - lastTestedAt persistence

    func persistAgentModelLastTestedAt(_ modelProfileId: Int64) async {
        do {
            try await database.write { db in
                guard var model = try AgentModelProfile
                    .filter(Column("id") == modelProfileId)
                    .fetchOne(db) else { return }
                model.lastTestedAt = Date()
                model.updatedAt = Date()
                try model.save(db)
            }
        } catch {
            // Non-critical; ignore silently.
        }
    }
}
