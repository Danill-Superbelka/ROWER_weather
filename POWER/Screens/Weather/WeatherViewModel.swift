import Foundation
import Combine
import CoreLocation

final class WeatherViewModel {

    // MARK: - Outputs

    @Published private(set) var state: WeatherViewState = .loading
    @Published private(set) var cityName: String = "—"
    @Published private(set) var forecast: ForecastResponse?

    // MARK: - Dependencies

    private let locationService: LocationServicing
    private let weatherService: WeatherServicing

    // MARK: - Cache

    private var cachedForecast: ForecastResponse?
    private var cachedCoordinate: (lat: Double, lon: Double)?
    private var cacheTimestamp: Date?
    private let cacheLifetime: TimeInterval = 300

    // MARK: - Init

    init(
        locationService: LocationServicing,
        weatherService: WeatherServicing
    ) {
        self.locationService = locationService
        self.weatherService = weatherService
    }

    // MARK: - Public

    func loadByLocation() {
        Task { @MainActor in
            state = .loading
            let coordinate = await locationService.requestLocation()
            await fetchWeather(lat: coordinate.latitude, lon: coordinate.longitude)
        }
    }

    func loadByCity(_ city: CitySearchResult) {
        Task { @MainActor in
            state = .loading
            await fetchWeather(lat: city.lat, lon: city.lon)
        }
    }

    // MARK: - Private

    @MainActor
    private func fetchWeather(lat: Double, lon: Double) async {
        if let cached = cachedForecast,
           let timestamp = cacheTimestamp,
           let coord = cachedCoordinate,
           coordinatesMatch(coord, (lat, lon)) {

            // Fresh cache — use directly
            if Date().timeIntervalSince(timestamp) < cacheLifetime {
                forecast = cached
                cityName = cached.location.name
                state = .loaded
                return
            }

            // Stale cache — show it, then refresh silently
            forecast = cached
            cityName = cached.location.name
            state = .loaded
        }

        do {
            let response = try await weatherService.fetchForecast(lat: lat, lon: lon)
            cachedForecast = response
            cachedCoordinate = (lat, lon)
            cacheTimestamp = Date()
            forecast = response
            cityName = response.location.name
            state = .loaded
        } catch {
            if cachedForecast == nil {
                state = .error(NSLocalizedString("error.loadFailed", comment: ""))
            }
        }
    }

    private func coordinatesMatch(
        _ a: (lat: Double, lon: Double),
        _ b: (lat: Double, lon: Double)
    ) -> Bool {
        let precision = 100.0 // ~1 km
        return (a.lat * precision).rounded() == (b.lat * precision).rounded()
            && (a.lon * precision).rounded() == (b.lon * precision).rounded()
    }
}
