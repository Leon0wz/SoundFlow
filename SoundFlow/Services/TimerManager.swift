import Foundation

@Observable
@MainActor
final class TimerManager {
    var remainingSeconds: Int = 0
    var isActive = false

    private var timer: Foundation.Timer?

    func start(minutes: Int) {
        remainingSeconds = minutes * 60
        isActive = true
        timer = .scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isActive = false
        remainingSeconds = 0
    }

    private func tick() {
        guard remainingSeconds > 0 else {
            stop()
            return
        }
        remainingSeconds -= 1
    }
}
