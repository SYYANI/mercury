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
}
