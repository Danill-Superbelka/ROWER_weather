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
    let windDir: String
    let pressureMb: Double
    let visKm: Double
    let uv: Double

    enum CodingKeys: String, CodingKey {
        case tempC = "temp_c"
        case condition
        case feelslikeC = "feelslike_c"
        case humidity
        case windKph = "wind_kph"
        case windDir = "wind_dir"
        case pressureMb = "pressure_mb"
        case visKm = "vis_km"
        case uv
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
    let astro: Astro
    let hour: [HourWeather]
}

struct Astro: Codable, Sendable {
    let sunrise: String
    let sunset: String
}

struct Day: Codable, Sendable {
    let maxtempC: Double
    let mintempC: Double
    let condition: Condition
    let avghumidity: Int
    let maxwindKph: Double
    let uv: Double
    let dailyChanceOfRain: Int

    enum CodingKeys: String, CodingKey {
        case maxtempC = "maxtemp_c"
        case mintempC = "mintemp_c"
        case condition
        case avghumidity
        case maxwindKph = "maxwind_kph"
        case uv
        case dailyChanceOfRain = "daily_chance_of_rain"
    }
}

struct HourWeather: Codable, Sendable {
    let timeEpoch: Int
    let time: String
    let tempC: Double
    let condition: Condition
    let humidity: Int
    let windKph: Double
    let chanceOfRain: Int
    let isDay: Int

    enum CodingKeys: String, CodingKey {
        case timeEpoch = "time_epoch"
        case time
        case tempC = "temp_c"
        case condition
        case humidity
        case windKph = "wind_kph"
        case chanceOfRain = "chance_of_rain"
        case isDay = "is_day"
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
