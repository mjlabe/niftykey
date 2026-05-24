import Foundation

public struct Prediction: Sendable, Equatable {
    public let word: String
    public let score: Double
    public let isAutocorrect: Bool

    public init(word: String, score: Double, isAutocorrect: Bool = false) {
        self.word = word
        self.score = score
        self.isAutocorrect = isAutocorrect
    }
}

public final class PredictionService: @unchecked Sendable {
    private let dictionary: Trie
    private let learnedWords: Trie
    private let lock = NSLock()

    public init() {
        self.dictionary = Trie()
        self.learnedWords = Trie()
        loadDefaultDictionary()
    }

    // MARK: - Predictions

    public func predict(prefix: String, context: String? = nil, limit: Int = 3) -> [Prediction] {
        guard !prefix.isEmpty else { return [] }

        let dictResults = dictionary.wordsWithPrefix(prefix, limit: limit * 2)
        let learnedResults = learnedWords.wordsWithPrefix(prefix, limit: limit)

        var combined: [Prediction] = []

        for (word, freq) in learnedResults {
            combined.append(Prediction(word: word, score: Double(freq) * 2.0))
        }

        for (word, freq) in dictResults {
            if !combined.contains(where: { $0.word == word }) {
                combined.append(Prediction(word: word, score: Double(freq)))
            }
        }

        combined.sort { $0.score > $1.score }
        return Array(combined.prefix(limit))
    }

    // MARK: - Autocorrect

    public func autocorrect(word: String) -> String? {
        guard word.count >= 3 else { return nil }

        if dictionary.search(word) { return nil }
        if learnedWords.search(word) { return nil }

        let candidates = dictionary.wordsWithPrefix(String(word.prefix(word.count - 1)), limit: 5)
        let close = candidates.filter { editDistance($0.0, word) <= 1 }
        return close.max(by: { $0.1 < $1.1 })?.0
    }

    // MARK: - Learning

    public func learn(word: String) {
        guard word.count >= 2 else { return }
        learnedWords.insert(word, frequency: 5)
    }

    public func reinforceWord(_ word: String) {
        learnedWords.updateFrequency(word, increment: 1)
        dictionary.updateFrequency(word, increment: 1)
    }

    public func resetLearnedWords() {
        // Reinitialize learned words trie
    }

    // MARK: - Edit Distance

    private func editDistance(_ a: String, _ b: String) -> Int {
        let aChars = Array(a)
        let bChars = Array(b)
        let m = aChars.count
        let n = bChars.count

        if m == 0 { return n }
        if n == 0 { return m }

        var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)

        for i in 0...m { dp[i][0] = i }
        for j in 0...n { dp[0][j] = j }

        for i in 1...m {
            for j in 1...n {
                if aChars[i - 1] == bChars[j - 1] {
                    dp[i][j] = dp[i - 1][j - 1]
                } else {
                    dp[i][j] = 1 + min(dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1])
                }
            }
        }
        return dp[m][n]
    }

    // MARK: - Dictionary Loading

    private func loadDefaultDictionary() {
        for entry in WordList.common {
            dictionary.insert(entry.word, frequency: entry.frequency)
        }
    }
}
