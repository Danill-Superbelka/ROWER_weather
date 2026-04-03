import CoreLocation
import OSLog

private let locationLog = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "POWER",
    category: "Location"
)

@MainActor
final class LocationService: NSObject, CLLocationManagerDelegate {

    private let manager = CLLocationManager()
    private let moscowCoordinate = CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173)

    private var continuations: [CheckedContinuation<CLLocationCoordinate2D, Never>] = []
    private var timeoutTask: Task<Void, Never>?

    private(set) var lastKnownCoordinate: CLLocationCoordinate2D?

    var cachedCoordinate: CLLocationCoordinate2D {
        manager.location?.coordinate ?? lastKnownCoordinate ?? moscowCoordinate
    }

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    // MARK: - Public API

    func requestLocation() async -> CLLocationCoordinate2D {
        let start = CFAbsoluteTimeGetCurrent()

        locationLog.debug("⏱ requestLocation() started, status=\(self.manager.authorizationStatus.rawValue)")

        let coordinate = await withCheckedContinuation { continuation in
            continuations.append(continuation)

            if let cached = manager.location,
               cached.timestamp.timeIntervalSinceNow > -300 {
                locationLog.debug("⚡ Using cached location (age: \(-cached.timestamp.timeIntervalSinceNow)s)")
                resolveAll(with: cached.coordinate)
                return
            }

            handleAuthorization(status: manager.authorizationStatus)
            startTimeoutIfNeeded()
        }

        let elapsed = CFAbsoluteTimeGetCurrent() - start

        locationLog.debug(
            "⏱ requestLocation() finished in \(elapsed, format: .fixed(precision: 3))s → (\(coordinate.latitude), \(coordinate.longitude))"
        )

        return coordinate
    }

    // MARK: - Authorization

    private func handleAuthorization(status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationLog.debug("📡 Requesting fresh location...")
            manager.requestLocation()

        case .notDetermined:
            locationLog.debug("❓ Requesting authorization...")
            manager.requestWhenInUseAuthorization()

        case .denied, .restricted:
            locationLog.debug("🚫 Location denied, using Moscow fallback")
            resolveAll(with: moscowCoordinate)

        @unknown default:
            resolveAll(with: moscowCoordinate)
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard !continuations.isEmpty else { return }

        locationLog.debug("🔄 Authorization changed: \(manager.authorizationStatus.rawValue)")

        handleAuthorization(status: manager.authorizationStatus)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            locationLog.debug("⚠️ Empty locations, fallback to Moscow")
            resolveAll(with: moscowCoordinate)
            return
        }

        locationLog.debug("📍 Got location: (\(location.coordinate.latitude), \(location.coordinate.longitude))")

        resolveAll(with: location.coordinate)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationLog.error("❌ Location error: \(error.localizedDescription)")

        resolveAll(with: moscowCoordinate)
    }

    // MARK: - Private

    private func resolveAll(with coordinate: CLLocationCoordinate2D) {
        lastKnownCoordinate = coordinate

        continuations.forEach { $0.resume(returning: coordinate) }
        continuations.removeAll()

        timeoutTask?.cancel()
        timeoutTask = nil
    }

    private func startTimeoutIfNeeded() {
        guard timeoutTask == nil else { return }

        timeoutTask = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)

            guard !continuations.isEmpty else { return }

            locationLog.debug("⏰ Timeout reached, using Moscow fallback")

            resolveAll(with: moscowCoordinate)
        }
    }
}
