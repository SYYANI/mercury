//
//  LocalTaggingService.swift
//  Mercury
//

import Foundation
import NaturalLanguage

/// A local NLP service that extracts named entities (organizations, people, places)
/// from text using macOS `NLTagger`. Results are used as provisional `nlp`-sourced tags.
actor LocalTaggingService {
    private static let relevantTypes: Set<NLTag> = [.organizationName, .personalName, .placeName]
    private static let taggerOptions: NLTagger.Options = [.omitWhitespace, .omitPunctuation, .joinNames]

    /// Extracts named entities from the given text.
    ///
    /// Returns deduplicated, quality-filtered entity strings in order of appearance.
    /// Returns an empty array when no entities are found or the input is empty.
    ///
    /// Quality filters applied (in order after extraction):
    /// 1. Character filter: entities containing characters other than letters, digits, spaces,
    ///    or hyphens are dropped (catches noisy fragments like "AMD didn't").
    /// 2. Length filter: entities with more than 4 words or more than 25 characters are dropped.
    /// 3. Superset dedup: when entity A's normalizedName is a word-prefix of entity B's
    ///    normalizedName, B is dropped and A is kept (handles "Intel" vs "Intel CPUs").
    ///
    /// This method has no side-effects; it does not write to any database or persistent store.
    func extractEntities(from text: String) -> [String] {
        guard text.isEmpty == false else { return [] }

        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text

        var seen = Set<String>()
        var results: [String] = []

        tagger.enumerateTags(
            in: text.startIndex..<text.endIndex,
            unit: .word,
            scheme: .nameType,
            options: Self.taggerOptions
        ) { tag, tokenRange in
            guard let tag, Self.relevantTypes.contains(tag) else { return true }
            let entity = String(text[tokenRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            guard entity.isEmpty == false, seen.contains(entity) == false else { return true }
            seen.insert(entity)
            results.append(entity)
            return true
        }

        return Self.applyQualityFilters(to: results)
    }

    // MARK: - Quality Filters

    private static let allowedEntityCharacters: CharacterSet = {
        CharacterSet.letters
            .union(.decimalDigits)
            .union(CharacterSet(charactersIn: " -"))
    }()

    /// Applies post-extraction quality filters and returns the cleaned entity list.
    nonisolated static func applyQualityFilters(to entities: [String]) -> [String] {
        // Pass 1: character filter and length filter.
        let filtered = entities.filter { entity in
            // Character filter: allow only letters, digits, spaces, hyphens.
            guard entity.unicodeScalars.allSatisfy({ allowedEntityCharacters.contains($0) }) else {
                return false
            }
            // Length filter: reject entities longer than 4 words or 25 characters.
            let words = entity.components(separatedBy: .whitespaces).filter { $0.isEmpty == false }
            guard words.count <= 4, entity.count <= 25 else { return false }
            return true
        }

        // Pass 2: superset dedup — if entity A's normalizedName is a word-prefix of entity B's
        // normalizedName, B is a superset of A and is removed.
        let normedForms = filtered.map { TagNormalization.normalize($0) }
        let supersetsToRemove: Set<Int> = Set(
            filtered.indices.filter { i in
                let iNorm = normedForms[i]
                return filtered.indices.contains { j in
                    guard j != i else { return false }
                    let jNorm = normedForms[j]
                    // j's normalized form is a strict word-prefix of i → i is a superset.
                    return iNorm.hasPrefix(jNorm + " ")
                }
            }
        )

        return filtered
            .enumerated()
            .filter { supersetsToRemove.contains($0.offset) == false }
            .map { $0.element }
    }
}
