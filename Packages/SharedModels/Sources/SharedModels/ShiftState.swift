import Foundation

public enum ShiftState: Hashable, Sendable {
    case lowercased
    case uppercased
    case capsLocked
    
    public var isUppercased: Bool {
        self != .lowercased
    }
}
