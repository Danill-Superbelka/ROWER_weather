import Foundation

// MARK: - Weather Endpoint

enum WeatherEndpoint: Endpoint {

    case forecast(lat: Double, lon: Double, days: Int)
    case search(query: String)

    private static let apiKey = "fa8b3df74d4042b9aa7135114252304"

    var baseURL: URL {
        URL(string: "https://api.weatherapi.com")!
    }

    var path: String {
        switch self {
        case .forecast: return "/v1/forecast.json"
        case .search: return "/v1/search.json"
        }
    }

    var method: HTTPMethod { .get }

    var queryItems: [URLQueryItem] {
        switch self {

        case .forecast(let lat, let lon, let days):
            return [
                .init(name: "key", value: Self.apiKey),
                .init(name: "q", value: "\(lat),\(lon)"),
                .init(name: "days", value: "\(days)")
            ]

        case .search(let query):
            return [
                .init(name: "key", value: Self.apiKey),
                .init(name: "q", value: query)
            ]
        }
    }
}

// MARK: - Weather Servicing

protocol WeatherServicing {
    func fetchForecast(lat: Double, lon: Double) async throws(NetworkError) -> ForecastResponse
    func searchCities(query: String) async throws(NetworkError) -> [CitySearchResult]
}

// MARK: - Weather Service

final class WeatherService: WeatherServicing {

    private let network: NetworkServicing

    init(network: NetworkServicing) {
        self.network = network
    }

    func fetchForecast(
        lat: Double,
        lon: Double
    ) async throws(NetworkError) -> ForecastResponse {

        try await network.request(
            WeatherEndpoint.forecast(lat: lat, lon: lon, days: 3),
            retries: 1
        )
    }

    func searchCities(
        query: String
    ) async throws(NetworkError) -> [CitySearchResult] {

        try await network.request(
            WeatherEndpoint.search(query: query),
            retries: 1
        )
    }
}
