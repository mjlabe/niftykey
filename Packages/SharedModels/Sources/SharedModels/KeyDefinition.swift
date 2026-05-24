import Foundation

public struct KeyDefinition: Identifiable, Hashable, Sendable {
    public let id: String
    public let primary: String
    public let secondary: String?
    public let widthWeight: CGFloat
    public let type: KeyType

    public init(
        id: String,
        primary: String,
        secondary: String? = nil,
        widthWeight: CGFloat = 1.0,
        type: KeyType = .character
    ) {
        self.id = id
        self.primary = primary
        self.secondary = secondary
        self.widthWeight = widthWeight
        self.type = type
    }

    public var isModifier: Bool {
        switch type {
        case .shift, .backspace, .space, .returnKey, .numeric, .symbols, .emoji, .globe:
            return true
        default:
            return false
        }
    }
}
