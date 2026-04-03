import Foundation
import Combine
internal import _LocationEssentials

final class WeatherViewModel {

    // MARK: - Outputs

    @Published private(set) var state: WeatherViewState = .loading
    @Published private(set) var cityName: String = "—"
    @Published private(set) var forecast: ForecastResponse?

    // MARK: - Dependencies

    private let locationService = LocationService()
    private let weatherService = WeatherService(network: NetworkService.shared)

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
        do {
            let response = try await weatherService.fetchForecast(lat: lat, lon: lon)
            forecast = response
            cityName = response.location.name
            state = .loaded
        } catch {
            state = .error(NSLocalizedString("error.loadFailed", comment: ""))
        }
    }
}
