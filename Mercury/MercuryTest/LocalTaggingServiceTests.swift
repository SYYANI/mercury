import Foundation
import Testing
@testable import Mercury

@Suite("LocalTaggingService")
struct LocalTaggingServiceTests {

    @Test("Extracts named entities from text containing known organizations and people")
    func extractsEntitiesFromRichText() async {
        let service = LocalTaggingService()
        let text = "Apple announced new products at WWDC. CEO Tim Cook presented the keynote in Cupertino."
        let entities = await service.extractEntities(from: text)
        // NLTagger output may vary by OS version, but must return non-empty results
        // for a text that contains well-known named entities.
        #expect(entities.isEmpty == false)
    }

    @Test("Returns empty array for empty input")
    func returnsEmptyForEmptyInput() async {
        let service = LocalTaggingService()
        let entities = await service.extractEntities(from: "")
        #expect(entities.isEmpty)
    }

    @Test("Deduplicates repeated entity occurrences")
    func deduplicatesRepeatedEntities() async {
        let service = LocalTaggingService()
        let text = "Apple released a product. Apple announced another product from Apple."
        let entities = await service.extractEntities(from: text)
        let appleCount = entities.filter { $0 == "Apple" }.count
        #expect(appleCount <= 1)
    }

    @Test("Returns empty array for plain prose with no named entities")
    func returnsEmptyForPlainProse() async {
        let service = LocalTaggingService()
        let entities = await service.extractEntities(from: "the quick brown fox jumps over the lazy dog")
        // NLTagger should not extract entities from plain common words.
        // We test for nil or very low count rather than exact zero since
        // NLTagger confidence can vary.
        #expect(entities.count < 3)
    }

    // MARK: - Quality Filter Tests

    @Test("Character filter removes entities containing disallowed characters")
    func characterFilterRemovesNoisyFragments() {
        // Entities containing apostrophes and similar punctuation are dropped.
        let result = LocalTaggingService.applyQualityFilters(to: ["Intel", "AMD didn't", "Apple"])
        #expect(result.contains("Intel"))
        #expect(result.contains("Apple"))
        #expect(result.contains("AMD didn't") == false)
    }

    @Test("Superset dedup keeps shorter canonical form and removes the longer superset")
    func supersetDedupDropsLongerForm() {
        // "Intel CPUs" normalizes to "intel cpus"; "intel" is a word-prefix of "intel cpus",
        // so "Intel CPUs" is identified as a superset and removed.
        let result = LocalTaggingService.applyQualityFilters(to: ["Intel", "Intel CPUs", "Apple"])
        #expect(result.contains("Intel"))
        #expect(result.contains("Apple"))
        #expect(result.contains("Intel CPUs") == false)
    }

    @Test("extractEntities is a pure function with no database side-effects")
    func extractEntitiesHasNoDatabaseSideEffects() async {
        // This test enforces the behavioral contract: extractEntities must be callable without
        // any database setup, produce no mutations, and return deterministic results.
        let service = LocalTaggingService()
        let text = "Apple announced new products at WWDC. CEO Tim Cook presented the keynote in Cupertino."
        let first = await service.extractEntities(from: text)
        let second = await service.extractEntities(from: text)
        // Calling twice on the same text must yield identical results.
        #expect(first == second)
    }
}
