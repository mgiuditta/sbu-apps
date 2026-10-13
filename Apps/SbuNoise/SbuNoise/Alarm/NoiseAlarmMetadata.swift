import AlarmKit
import Foundation

/// Which alarm of Sbu Noise a system alarm backs up.
@available(iOS 26, *)
nonisolated struct NoiseAlarmMetadata: AlarmMetadata {
    let alarmID: UUID
}
