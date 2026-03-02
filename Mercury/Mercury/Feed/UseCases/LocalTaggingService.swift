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
    /// Returns deduplicated entity strings in order of appearance.
    /// Returns an empty array when no entities are found or the input is empty.
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

        return results
    }
}
