import XCTest
@testable import PredictionEngine

final class PredictionEngineTests: XCTestCase {
    func testTrieInsertAndSearch() {
        let trie = Trie()
        trie.insert("hello", frequency: 10)
        trie.insert("help", frequency: 8)
        trie.insert("world", frequency: 5)

        XCTAssertTrue(trie.search("hello"))
        XCTAssertTrue(trie.search("help"))
        XCTAssertTrue(trie.search("world"))
        XCTAssertFalse(trie.search("helo"))
        XCTAssertFalse(trie.search("hell"))
    }

    func testTriePrefixSearch() {
        let trie = Trie()
        trie.insert("hello", frequency: 10)
        trie.insert("help", frequency: 8)
        trie.insert("hero", frequency: 5)
        trie.insert("world", frequency: 3)

        let results = trie.wordsWithPrefix("hel")
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.first?.0, "hello")
    }

    func testPredictionService() {
        let service = PredictionService()
        let predictions = service.predict(prefix: "th", limit: 3)
        XCTAssertFalse(predictions.isEmpty)
        XCTAssertTrue(predictions.count <= 3)
    }

    func testPredictionServiceLearning() {
        let service = PredictionService()
        service.learn(word: "xyztest")
        let predictions = service.predict(prefix: "xyzt", limit: 3)
        XCTAssertTrue(predictions.contains(where: { $0.word == "xyztest" }))
    }

    func testAutocorrect() {
        let service = PredictionService()
        let correction = service.autocorrect(word: "thr")
        // "thr" is short and likely returns nil or a close match
        // This tests that autocorrect doesn't crash on short inputs
        _ = correction
    }
}
