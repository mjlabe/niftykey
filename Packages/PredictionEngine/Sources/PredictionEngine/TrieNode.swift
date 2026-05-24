import Foundation

final class TrieNode {
    var children: [Character: TrieNode] = [:]
    var isEndOfWord: Bool = false
    var frequency: Int = 0
    var word: String?
}

public final class Trie: @unchecked Sendable {
    private let root = TrieNode()
    private let lock = NSLock()

    public init() {}

    public func insert(_ word: String, frequency: Int = 1) {
        lock.lock()
        defer { lock.unlock() }

        var current = root
        for char in word.lowercased() {
            if current.children[char] == nil {
                current.children[char] = TrieNode()
            }
            current = current.children[char]!
        }
        current.isEndOfWord = true
        current.frequency += frequency
        current.word = word.lowercased()
    }

    public func search(_ word: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }

        var current = root
        for char in word.lowercased() {
            guard let next = current.children[char] else { return false }
            current = next
        }
        return current.isEndOfWord
    }

    public func wordsWithPrefix(_ prefix: String, limit: Int = 10) -> [(String, Int)] {
        lock.lock()
        defer { lock.unlock() }

        var current = root
        for char in prefix.lowercased() {
            guard let next = current.children[char] else { return [] }
            current = next
        }

        var results: [(String, Int)] = []
        collectWords(node: current, results: &results, limit: limit * 3)
        results.sort { $0.1 > $1.1 }
        return Array(results.prefix(limit))
    }

    private func collectWords(node: TrieNode, results: inout [(String, Int)], limit: Int) {
        if results.count >= limit { return }

        if node.isEndOfWord, let word = node.word {
            results.append((word, node.frequency))
        }

        for (_, child) in node.children {
            if results.count >= limit { break }
            collectWords(node: child, results: &results, limit: limit)
        }
    }

    public func updateFrequency(_ word: String, increment: Int = 1) {
        lock.lock()
        defer { lock.unlock() }

        var current = root
        for char in word.lowercased() {
            guard let next = current.children[char] else { return }
            current = next
        }
        if current.isEndOfWord {
            current.frequency += increment
        }
    }
}
