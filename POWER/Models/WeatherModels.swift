import Foundation

// MARK: - API Response

nonisolated struct ForecastResponse: Codable, Sendable {
    let location: Location
    let current: CurrentWeather
    let forecast: Forecast
}

struct Location: Codable, Sendable {
    let name: String
    let region: String
    let country: String
    let localtime: String
}

struct CurrentWeather: Codable, Sendable {
    let tempC: Double
    let condition: Condition
    let feelslikeC: Double
    let humidity: Int
    let windKph: Double

    enum CodingKeys: String, CodingKey {
        case tempC = "temp_c"
        case condition
        case feelslikeC = "feelslike_c"
        case humidity
        case windKph = "wind_kph"
    }
}

struct Condition: Codable, Sendable {
    let text: String
    let icon: String
    let code: Int
}

struct Forecast: Codable, Sendable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Codable, Sendable {
    let date: String
    let day: Day
    let hour: [HourWeather]
}

struct Day: Codable, Sendable {
    let maxtempC: Double
    let mintempC: Double
    let condition: Condition

    enum CodingKeys: String, CodingKey {
        case maxtempC = "maxtemp_c"
        case mintempC = "mintemp_c"
        case condition
    }
}

struct HourWeather: Codable, Sendable {
    let timeEpoch: Int
    let time: String
    let tempC: Double
    let condition: Condition

    enum CodingKeys: String, CodingKey {
        case timeEpoch = "time_epoch"
        case time
        case tempC = "temp_c"
        case condition
    }
}

// MARK: - City Search

nonisolated struct CitySearchResult: Codable, Sendable {
    let id: Int
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
}
