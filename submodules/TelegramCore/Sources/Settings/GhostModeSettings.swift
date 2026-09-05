import Foundation
import SwiftSignalKit

public struct GhostModeSettings: Codable, Equatable {
    public var hideOnlineStatus: Bool
    public var hideInputActivities: Bool
    public var hideReadReceipts: Bool

    public init(hideOnlineStatus: Bool, hideInputActivities: Bool, hideReadReceipts: Bool) {
        self.hideOnlineStatus = hideOnlineStatus
        self.hideInputActivities = hideInputActivities
        self.hideReadReceipts = hideReadReceipts
    }

    public static let defaultSettings = GhostModeSettings(
        hideOnlineStatus: false,
        hideInputActivities: false,
        hideReadReceipts: false
    )
}

public final class GhostModeSettingsStore {
    public static let shared = GhostModeSettingsStore()

    private static let defaultsKey = "org.telegram.ghostModeSettings"
    private let value: Atomic<GhostModeSettings>
    private let promise: ValuePromise<GhostModeSettings>

    private init() {
        let settings: GhostModeSettings
        if let data = UserDefaults.standard.data(forKey: GhostModeSettingsStore.defaultsKey), let decoded = try? JSONDecoder().decode(GhostModeSettings.self, from: data) {
            settings = decoded
        } else {
            settings = .defaultSettings
        }
        self.value = Atomic(value: settings)
        self.promise = ValuePromise(settings, ignoreRepeated: true)
    }

    public var settings: Signal<GhostModeSettings, NoError> {
        return self.promise.get()
    }

    public var current: GhostModeSettings {
        return self.value.with { $0 }
    }

    public func update(_ f: (GhostModeSettings) -> GhostModeSettings) {
        let updated = self.value.modify(f)
        if let data = try? JSONEncoder().encode(updated) {
            UserDefaults.standard.set(data, forKey: GhostModeSettingsStore.defaultsKey)
        }
        self.promise.set(updated)
    }
}
