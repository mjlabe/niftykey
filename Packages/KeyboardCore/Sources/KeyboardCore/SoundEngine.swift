import AudioToolbox
import UIKit

public final class SoundEngine: @unchecked Sendable {
    public var isEnabled: Bool = false

    private let keyClickID: SystemSoundID = 1104
    private let deleteClickID: SystemSoundID = 1155
    private let modifierClickID: SystemSoundID = 1156

    public init() {}

    public func keyClick() {
        guard isEnabled else { return }
        AudioServicesPlaySystemSound(keyClickID)
    }

    public func deleteClick() {
        guard isEnabled else { return }
        AudioServicesPlaySystemSound(deleteClickID)
    }

    public func modifierClick() {
        guard isEnabled else { return }
        AudioServicesPlaySystemSound(modifierClickID)
    }
}
